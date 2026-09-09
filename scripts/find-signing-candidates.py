#!/usr/bin/env python3
"""Find GitHub-hosted aqua packages that could gain supply-chain signing config.

For a chosen signature type, a package is a candidate when ALL of the
following hold:

1. It is hosted on GitHub as a `github_release` package.
2. Its registry.yaml has NO signing configuration for any of:
   - cosign
   - slsa_provenance
   - minisign
   - github_artifact_attestations
3. Its latest GitHub release contains an asset indicating that the tool's
   author already publishes signatures/provenance of that type:

      type            asset name matches
      --------------  ------------------
      cosign          *.sigstore.json, *.sigstore, *.bundle
      slsa_provenance *.intoto.jsonl
      minisign        *.minisig

The output is a list of space-separated lines, one per (package, signature
type) match:

<path to registry.yaml, relative to repo root> <type> <releases URL>

e.g.

pkgs/aquaproj/registry-tool/registry.yaml cosign https://github.com/aquaproj/registry-tool/releases

An exclusion file (--exclude-file) can suppress specific matches. Each line is
formatted as:

<pkgs registry.yaml path, relative to repo root> <signing type> [comments...]

The signing type is one of cosign/slsa_provenance/minisign, or "all" to exclude for every
type. Example:

pkgs/protocolbuffers/protobuf/protoc/registry.yaml slsa_provenance -- false positive/unsupported, provenance is for bazel.tar.gz

With no `--type`, all three types are searched and a package may appear once
per matching type. In `--dry-run` mode (or `--no-gh`) no GitHub API calls are
made; candidate packages are listed with `*` as the type since asset presence
is not checked, and only the local scan (type, signing-config presence) runs.
This is handy for previewing scope without rate limits.

Usage:
# all three types (union)
python3 scripts/find-signing-candidates.py
# only cosign candidates
python3 scripts/find-signing-candidates.py --type cosign
# cosign + minisign
python3 scripts/find-signing-candidates.py --type cosign --type minisign
# skip entries listed in an exclusion file
python3 scripts/find-signing-candidates.py --exclude-file excludes.txt
# smoke test
python3 scripts/find-signing-candidates.py --limit 20
"""

from __future__ import annotations

import argparse
import json
import subprocess
import sys
from concurrent.futures import ThreadPoolExecutor, as_completed
from pathlib import Path

import yaml

# Signature type -> release-asset name suffix(es) that prove the author
# already publishes that kind of signature/provenance. cosign publishes its
# bundle under a few extensions depending on the tool/format:
#   *.sigstore.json  (JSON bundle)
#   *.sigstore       (plain bundle)
#   *.bundle         (alternate/deprecated bundle extension)
SIGNATURE_TYPES = {
    "cosign": (".sigstore.json", ".sigstore", ".bundle"),
    "slsa_provenance": (".intoto.jsonl",),
    "minisign": (".minisig",),
}

# Signing-related configuration keys. If any of these appear anywhere in a
# package definition (base settings, version_overrides, nested checksum,
# overrides, etc.) the package is considered to already have signing config.
SIGNING_KEYS = {
    "cosign",
    "slsa_provenance",
    "minisign",
    "github_artifact_attestations",
}

# Map a signing "type" (as used by --type/--exclude-signed-by) to the registry
# key that proves it is already configured.
SIGNING_TYPE_TO_KEY = {
    "cosign": "cosign",
    "slsa_provenance": "slsa_provenance",
    "minisign": "minisign",
    "github_artifact_attestations": "github_artifact_attestations",
}

# We only care about GitHub release assets, since the signature/provenance
# files above are all release artifacts.
GITHUB_TYPES = {"github_release"}

# aqua's `releases/latest` endpoint already excludes drafts/prereleases.
RELEASE_API = "repos/{owner}/{name}/releases/latest"

REPO_ROOT = Path(__file__).resolve().parent.parent
DEFAULT_PKGS_DIR = REPO_ROOT / "pkgs"
DEFAULT_CACHE = REPO_ROOT / ".cache" / "signing-candidates.json"
DEFAULT_ASSET_CACHE = REPO_ROOT / ".cache" / "release-assets.json"
DEFAULT_EXCLUDE_FILE = REPO_ROOT / ".cache" / "signing-candidates-exclusions.txt"


def has_signing_config(node, keys: set[str] | None = None) -> bool:
    """Recursively check whether a parsed YAML node contains any signing key.

    If `keys` is None, all known signing keys are checked (exclude all).
    Otherwise only the supplied signing keys are checked.
    """
    if keys is None:
        keys = SIGNING_KEYS
    if isinstance(node, dict):
        for key, value in node.items():
            if isinstance(key, str) and key in keys:
                return True
            if has_signing_config(value, keys):
                return True
    elif isinstance(node, list):
        for item in node:
            if has_signing_config(item, keys):
                return True
    return False


def get_owner_repo(pkg: dict, source: Path):
    """Return (owner, name) for a package, deriving from `name` if needed."""
    owner = pkg.get("repo_owner")
    name = pkg.get("repo_name")
    if not owner or not name:
        # Fall back to the package name, e.g. "owner/repo" or "owner/repo/tool".
        full = str(pkg.get("name", ""))
        parts = [p for p in full.split("/") if p]
        if len(parts) >= 2:
            owner, name = parts[0], parts[1]
    if not owner or not name:
        print(
            f"skip (no owner/name): {source}: {pkg.get('name', '<unknown>')}",
            file=sys.stderr,
        )
        return None, None
    return owner, name


def find_candidates(pkgs_dir: Path, exclude_keys: set[str] | None = None):
    """Yield (owner, name, source_path) for github_release packages lacking signing config.

    `exclude_keys` limits which signing types cause a package to be skipped.
    None means "exclude packages having any signing type configured" (default).
    """
    seen = set()
    for registry in sorted(pkgs_dir.rglob("registry.yaml")):
        try:
            data = yaml.safe_load(registry.read_text(encoding="utf-8"))
        except Exception as exc:  # noqa: BLE001 - never abort the whole run
            print(f"warn: failed to parse {registry}: {exc}", file=sys.stderr)
            continue
        if not isinstance(data, dict):
            continue
        packages = data.get("packages") or []
        for pkg in packages:
            if not isinstance(pkg, dict):
                continue
            if pkg.get("type") not in GITHUB_TYPES:
                continue
            owner, name = get_owner_repo(pkg, registry)
            if not owner or not name:
                continue
            key = f"{owner}/{name}"
            if key in seen:
                continue
            if has_signing_config(pkg, exclude_keys):
                continue
            seen.add(key)
            yield owner, name, registry


class RateLimitError(Exception):
    """Raised when `gh` hits a GitHub API rate limit; fetching is aborted."""


def gh_release_assets(owner: str, name: str, asset_cache: dict) -> list[str] | None:
    """Return asset names of the latest release, or None if there is no release.

    The raw asset list is cached in `asset_cache` keyed by `owner/name` so the
    release assets are not re-fetched on every run. A rate-limit (HTTP 403)
    error aborts fetching entirely (raises RateLimitError) instead of retrying
    with backoff. Other errors (auth, network, not found) cause a return of
    None for this repo.
    """
    repo = f"{owner}/{name}"
    if repo in asset_cache:
        raw = asset_cache[repo]
    else:
        cmd = [
            "gh",
            "api",
            RELEASE_API.format(owner=owner, name=name),
            "--jq",
            ".assets",
        ]
        try:
            proc = subprocess.run(cmd, capture_output=True, text=True, timeout=60)
        except subprocess.TimeoutExpired:
            # Timeout is per-repo; give up on this repo only, do not abort others.
            return None
        if proc.returncode != 0:
            last_err = proc.stderr.strip()
            if "Not Found" in last_err or "404" in last_err:
                # No release / repo moved / not found -> treat as "no assets".
                return None
            if "rate limit" in last_err.lower() or "Retry-After" in proc.stderr:
                # Rate limited: abort all fetching rather than retrying.
                raise RateLimitError(f"{owner}/{name}: {last_err}")
            # Other gh errors (auth, network) -> give up on this repo.
            return None
        try:
            raw = json.loads(proc.stdout)
        except Exception:  # noqa: BLE001
            return None
        if not isinstance(raw, list):
            return None
        asset_cache[repo] = raw
    if not isinstance(raw, list):
        return None
    return [a.get("name") for a in raw if isinstance(a, dict) and a.get("name")]


def compute_types(assets: list[str] | None) -> dict[str, bool]:
    """Map each signature type to whether a matching asset is present."""
    return {
        t: any(a.endswith(suffix) for suffix in suffixes for a in (assets or []))
        for t, suffixes in SIGNATURE_TYPES.items()
    }


def load_cache(path: Path) -> dict:
    if not path.exists():
        return {"results": {}}
    try:
        data = json.loads(path.read_text(encoding="utf-8"))
    except Exception:  # noqa: BLE001
        return {"results": {}}
    if not isinstance(data, dict):
        return {"results": {}}
    return data


def load_asset_cache(path: Path) -> dict:
    """Load the latest-release asset cache: a dict of `owner/name` -> asset list."""
    if not path.exists():
        return {}
    try:
        data = json.loads(path.read_text(encoding="utf-8"))
    except Exception:  # noqa: BLE001
        return {}
    if not isinstance(data, dict):
        return {}
    return data


def parse_exclusions(path: Path) -> set[tuple[str, str]]:
    """Parse an exclusion file of `pkgs_path type [comments...]` lines.

    Blank lines and lines starting with `#` are ignored. Each remaining line is
    split on whitespace; the first token is the registry.yaml path (relative to
    the repo root) and the second is a signing type (one of cosign/slsa_provenance/minisign
    or "all"). Returns a set of (pkgs_path, signing_type) tuples.
    """
    if not path.exists():
        return set()
    valid = set(SIGNATURE_TYPES) | {"all"}
    excl: set[tuple[str, str]] = set()
    for ln, raw in enumerate(path.read_text(encoding="utf-8").splitlines(), 1):
        line = raw.strip()
        if not line or line.startswith("#"):
            continue
        parts = line.split()
        if len(parts) < 2:
            print(
                f"warn: bad exclusion line {ln} in {path.name}: {line!r}",
                file=sys.stderr,
            )
            continue
        pkg_path, stype = parts[0], parts[1]
        if stype not in valid:
            print(
                f"warn: unknown signing type {stype!r} in {path.name}:{ln}",
                file=sys.stderr,
            )
            continue
        excl.add((pkg_path, stype))
    return excl


def main() -> int:
    parser = argparse.ArgumentParser(
        description=__doc__,
        formatter_class=argparse.RawDescriptionHelpFormatter,
    )
    parser.add_argument(
        "--pkgs-dir",
        type=Path,
        default=DEFAULT_PKGS_DIR,
        help="Path to the pkgs directory.",
    )
    parser.add_argument(
        "--cache",
        type=Path,
        default=DEFAULT_CACHE,
        help="Cache file for gh results.",
    )
    parser.add_argument(
        "--asset-cache",
        type=Path,
        default=DEFAULT_ASSET_CACHE,
        help="Cache file for latest-release asset lists (avoids re-fetching release assets).",
    )
    parser.add_argument(
        "--no-cache",
        action="store_true",
        help="Ignore and do not write the cache.",
    )
    parser.add_argument(
        "--workers",
        type=int,
        default=8,
        help="Number of concurrent gh queries.",
    )
    parser.add_argument(
        "--limit",
        type=int,
        default=0,
        help="Limit the number of gh queries (0 = unlimited).",
    )
    parser.add_argument(
        "--format",
        choices=["lines", "json"],
        default="lines",
        help="Output format.",
    )
    parser.add_argument(
        "--check-only",
        action="store_true",
        help="Only print a summary, no candidate list.",
    )
    parser.add_argument(
        "--type",
        action="append",
        choices=[*SIGNATURE_TYPES, "all"],
        default=None,
        help="Signature type to look for (repeatable). Default: all three (union).",
    )
    parser.add_argument(
        "--dry-run",
        "--no-gh",
        action="store_true",
        help="Skip gh queries; list candidate packages with type '*' (assets not checked).",
    )
    parser.add_argument(
        "--exclude-signed-by",
        action="append",
        choices=list(SIGNING_TYPE_TO_KEY.keys()),
        default=None,
        help="Only exclude packages already signed with one of these types (repeatable). "
        "Default: the types being generated (--type); with --type all, also github_artifact_attestations.",
    )
    parser.add_argument(
        "--exclude-file",
        type=Path,
        default=DEFAULT_EXCLUDE_FILE,
        help="File of `pkgs/<path>/registry.yaml <type> [comments]` lines to exclude from output. "
        "Defaults to .cache/signing-exclusions.txt; a missing file is not an error.",
    )
    args = parser.parse_args()

    if args.type is None or "all" in args.type:
        selected = set(SIGNATURE_TYPES)
    else:
        selected = set(args.type)

    # Packages to skip based on already-configured signing types. We always
    # exclude the types being generated (so a package that already has e.g.
    # slsa_provenance configured is still a candidate when generating cosign),
    # and `--exclude-signed-by` adds further types on top. When generating all
    # types, also exclude github_artifact_attestations.
    exclude_keys = {SIGNING_TYPE_TO_KEY[t] for t in selected}
    if args.type is None or "all" in args.type:
        exclude_keys.add(SIGNING_TYPE_TO_KEY["github_artifact_attestations"])
    if args.exclude_signed_by:
        exclude_keys |= {SIGNING_TYPE_TO_KEY[t] for t in args.exclude_signed_by}

    cache = load_cache(args.cache) if not args.no_cache else {"results": {}}
    cache_results = cache.setdefault("results", {})
    asset_cache = load_asset_cache(args.asset_cache) if not args.no_cache else {}

    exclusions = parse_exclusions(args.exclude_file) if args.exclude_file else set()
    if exclusions:
        print(
            f"loaded {len(exclusions)} exclusion entries from {args.exclude_file.name}",
            file=sys.stderr,
        )
    # Whole-repo paths excluded for any type (used in dry-run where the
    # specific type is unknown).
    excluded_paths = {p for p, _ in exclusions}

    candidates = list(find_candidates(args.pkgs_dir, exclude_keys))
    print(
        f"scanned {len(candidates)} github_release packages without signing config",
        file=sys.stderr,
    )

    # De-duplicate repos (multiple tools may share a repo) and split into
    # cached vs. to-be-queried. A cached value must be a dict of per-type
    # booleans; anything else (stale cache, missing) is re-queried.
    repos = sorted({f"{o}/{n}" for o, n, _ in candidates})
    # Map each repo to its registry.yaml path (relative to repo root), using
    # the first package that produced it.
    repo_paths: dict[str, str] = {}
    for o, n, source in candidates:
        key = f"{o}/{n}"
        if key not in repo_paths:
            repo_paths[key] = str(source.relative_to(REPO_ROOT))
    to_query = [r for r in repos if not isinstance(cache_results.get(r), dict)]
    if args.limit:
        to_query = to_query[: args.limit]

    print(
        f"repos to query via gh: {len(to_query)} (cached: {len(repos) - len(to_query)})",
        file=sys.stderr,
    )

    def query(repo: str):
        owner, _, name = repo.partition("/")
        assets = gh_release_assets(owner, name, asset_cache)
        return repo, compute_types(assets)

    if to_query and not args.dry_run:
        with ThreadPoolExecutor(max_workers=args.workers) as pool:
            futures = {pool.submit(query, r): r for r in to_query}
            rate_limited = False
            done = 0
            for fut in as_completed(futures):
                if rate_limited:
                    # Abort: cancel any not-yet-started queries; in-flight ones
                    # are left to finish but their results are ignored.
                    for f in futures:
                        f.cancel()
                    break
                try:
                    repo, result = fut.result()
                except RateLimitError as exc:
                    rate_limited = True
                    print(
                        f"rate limit hit ({exc}); aborting remaining gh queries",
                        file=sys.stderr,
                    )
                    for f in futures:
                        f.cancel()
                    break
                cache_results[repo] = result
                done += 1
                if done % 50 == 0:
                    print(f"queried {done}/{len(to_query)}", file=sys.stderr)

    # Persist cache.
    if not args.no_cache and not args.dry_run:
        args.cache.parent.mkdir(parents=True, exist_ok=True)
        args.cache.write_text(
            json.dumps(cache, indent=2, sort_keys=True),
            encoding="utf-8",
        )
        args.asset_cache.parent.mkdir(parents=True, exist_ok=True)
        args.asset_cache.write_text(
            json.dumps(asset_cache, indent=2, sort_keys=True),
            encoding="utf-8",
        )

    # Build (type, repo, path, url) matches.
    matches: list[tuple[str, str, str, str]] = []
    if args.dry_run:
        # No GitHub API calls: we know the candidate repos but not which
        # asset types exist, so the type is reported as "*".
        print("dry-run: skipping gh queries", file=sys.stderr)
        for repo in repos:
            owner, _, name = repo.partition("/")
            path = repo_paths.get(repo, f"pkgs/{owner}/{name}/registry.yaml")
            if path in excluded_paths:
                continue
            url = f"https://github.com/{owner}/{name}/releases"
            matches.append(("*", repo, path, url))
    else:
        for repo in repos:
            booleans = cache_results.get(repo)
            if not isinstance(booleans, dict):
                continue
            owner, _, name = repo.partition("/")
            path = repo_paths.get(repo, f"pkgs/{owner}/{name}/registry.yaml")
            url = f"https://github.com/{owner}/{name}/releases"
            for t in sorted(selected):
                if (path, t) in exclusions or (path, "all") in exclusions:
                    continue
                if booleans.get(t):
                    matches.append((t, repo, path, url))

    matched_repos = sorted({r for _, r, *_ in matches})
    if args.dry_run:
        print(
            f"found {len(matched_repos)} candidate repos (dry-run, types not checked)",
            file=sys.stderr,
        )
    else:
        counts = {t: sum(1 for tt, *_ in matches if tt == t) for t in sorted(selected)}
        count_str = ", ".join(f"{t}: {counts[t]}" for t in sorted(selected))
        print(
            f"found {len(matched_repos)} candidate repos ({count_str})",
            file=sys.stderr,
        )

    if args.check_only:
        return 0

    if args.format == "json":
        print(
            json.dumps(
                [{"path": p, "type": t, "url": u, "repo": r} for t, r, p, u in matches],
                indent=2,
                sort_keys=True,
            ),
        )
    else:
        for t, r, p, u in matches:
            print(f"{p} {t} {u}")
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
