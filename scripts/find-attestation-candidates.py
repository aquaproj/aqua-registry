#!/usr/bin/env python3
"""Find github_release aqua packages missing github_artifact_attestations config.

A package is a candidate for adding `github_artifact_attestations` when ALL of
the following hold:

1. It is hosted on GitHub as a `github_release` package.
2. Its registry.yaml has NO `github_artifact_attestations` configuration.
   Additional signing types can be excluded via `--exclude-signed-by`, and
   individual packages can be suppressed via an `--exclude-file`.
3. Its latest GitHub release contains artifact attestations.

Unlike cosign / slsa_provenance / minisign (whose presence is visible from the
release asset *names*), Artifact Attestations are keyed by the SHA-256 digest
of each release asset and are not visible from the asset name. So the script:

  a. asks the GitHub Releases API for the latest release's assets (which now
     include a `digest` field of the form `sha256:...`), then
  b. asks the Repositories API `repos/{owner}/{repo}/attestations/{subject_digest}`
     for each asset digest, short-circuiting as soon as one is found.

The output is a list of space-separated lines, one per candidate package:

<pkgs registry.yaml path, relative to repo root> <attestations URL>

e.g.

pkgs/cli/cli/registry.yaml https://github.com/cli/cli/attestations?q=sort%3Acreated-asc

In `--dry-run` mode (or `--no-gh`) no GitHub API calls are made; candidate
packages (github_release packages lacking the config) are listed with `*` as the
type since attestation presence is not checked. This is handy for previewing
scope without rate limits.

Usage:
# find all github_release packages missing attestation config that DO have attestations
python3 scripts/find-attestation-candidates.py
# only a handful, for a smoke test
python3 scripts/find-attestation-candidates.py --limit 20
# preview scope without touching the API
python3 scripts/find-attestation-candidates.py --dry-run
# also skip packages already configured with cosign / slsa_provenance / minisign
python3 scripts/find-attestation-candidates.py --exclude-signed-by cosign
# skip packages listed in the exclusion file (per-package suppressions)
python3 scripts/find-attestation-candidates.py --exclude-file excludes.txt
# bound API cost by only checking up to N assets per release
python3 scripts/find-attestation-candidates.py --max-asset-checks 4
"""

from __future__ import annotations

import argparse
import json
import random
import subprocess
import sys
from concurrent.futures import ThreadPoolExecutor, as_completed
from pathlib import Path

import yaml

# The registry key that proves a package already has attestation config.
ATTESTATION_KEY = "github_artifact_attestations"
TARGET_TYPE = ATTESTATION_KEY

# Signing-related configuration keys. A package already configured with any of
# these is considered to have signing config.
SIGNING_KEYS = {
    "cosign",
    "slsa_provenance",
    "minisign",
    "github_artifact_attestations",
}

# Map a signing "type" (as used by --exclude-signed-by) to the registry key
# that proves it is already configured.
SIGNING_TYPE_TO_KEY = {
    "cosign": "cosign",
    "slsa_provenance": "slsa_provenance",
    "minisign": "minisign",
    "github_artifact_attestations": "github_artifact_attestations",
}

# We only care about GitHub release assets, since attestations are attached to
# release artifacts.
GITHUB_TYPES = {"github_release"}

# aqua's `releases/latest` endpoint already excludes drafts/prereleases.
RELEASE_API = "repos/{owner}/{name}/releases/latest"

REPO_ROOT = Path(__file__).resolve().parent.parent
DEFAULT_PKGS_DIR = REPO_ROOT / "pkgs"
DEFAULT_CACHE = REPO_ROOT / ".cache" / "attestation-candidates.json"
DEFAULT_ASSET_CACHE = REPO_ROOT / ".cache" / "release-assets.json"
DEFAULT_EXCLUDE_FILE = REPO_ROOT / ".cache" / "attestation-candidates-exclusions.txt"

# Auxiliary / metadata files that are extremely unlikely to be the artifact
# aqua actually installs. We check these last so that, when a per-repo asset
# check cap is in effect, we spend our budget on the real binaries first.
AUXILIARY_SUFFIXES = (
    ".apk",
    ".appimage",
    ".asc",
    ".bundle",
    ".cert",
    ".crt",
    ".deb",
    ".gem",
    ".html",
    ".json",
    ".jsonl",
    ".md",
    ".md5",
    ".minisig",
    ".msi",
    ".msixbundle",
    ".pem",
    ".rpm",
    ".sbom",
    ".sha1",
    ".sha256",
    ".sha256sum",
    ".sha512",
    ".sha512sum",
    ".sig",
    ".sigstore",
    ".so",
    ".txt",
    ".vsix",
    ".wasm",
    ".whl",
    ".xml",
    ".yaml",
    ".yml",
)


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
    """Yield (owner, name, source_path) for github_release packages lacking attestation config.

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


def _gh_run(args: list[str]) -> tuple[str, str]:
    """Run a `gh` command.

    Returns a tuple of (status, payload) where status is one of:
      "ok"         - command succeeded; payload is stdout
      "not_found"  - resource does not exist (HTTP 404)
      "error"      - any other failure; payload is the last error message
    A rate-limit (HTTP 403) error aborts fetching entirely (raises
    RateLimitError) instead of retrying with backoff.
    """
    try:
        proc = subprocess.run(args, capture_output=True, text=True, timeout=60)
    except subprocess.TimeoutExpired:
        # Timeout is per-command; report as a generic error.
        return "error", "timeout"
    if proc.returncode == 0:
        return "ok", proc.stdout
    last_err = proc.stderr.strip()
    if "Not Found" in last_err or "404" in last_err:
        return "not_found", ""
    if "rate limit" in last_err.lower() or "Retry-After" in proc.stderr:
        # Rate limited: abort all fetching rather than retrying.
        raise RateLimitError(last_err)
    return "error", last_err


def gh_release_assets(owner: str, name: str, asset_cache: dict) -> list[dict] | None:
    """Return the latest release's asset metadata, or None if there is no release.

    Each entry is a dict with at least `name`, `digest`, and `size`. Results are
    cached in `asset_cache` keyed by `owner/name` to avoid re-fetching the
    release assets on every run.
    """
    repo = f"{owner}/{name}"
    if repo in asset_cache:
        cached = asset_cache[repo]
        return cached if isinstance(cached, list) else None
    status, payload = _gh_run(
        [
            "gh",
            "api",
            RELEASE_API.format(owner=owner, name=name),
            "--jq",
            ".assets",
        ],
    )
    if status != "ok":
        # not_found -> no release / repo moved; error -> skip this repo.
        return None
    try:
        assets = json.loads(payload)
    except Exception:  # noqa: BLE001
        return None
    if not isinstance(assets, list):
        return None
    asset_cache[repo] = assets
    return assets


def gh_attestation_exists(owner: str, name: str, digest_hash: str) -> bool | None:
    """Return whether an attestation exists for a given asset digest.

    Returns:
      True  - at least one attestation is present
      False - definitively no attestation for this digest (HTTP 404)
      None  - could not determine (API error / rate-limit exhaustion)

    """
    status, payload = _gh_run(
        [
            "gh",
            "api",
            f"repos/{owner}/{name}/attestations/sha256:{digest_hash}?predicate_type=provenance",
        ],
    )
    if status == "not_found":
        return False
    if status != "ok":
        return None
    try:
        data = json.loads(payload)
    except Exception:  # noqa: BLE001
        return None
    attestations = data.get("attestations") if isinstance(data, dict) else None
    return bool(attestations)


def gh_has_attestations(
    owner: str,
    name: str,
    max_asset_checks: int,
    asset_cache: dict,
) -> bool | None:
    """Return whether the latest release has any artifact attestations.

    Returns True/False (definitive) or None when it could not be determined.
    A None result is never cached by the caller.

    Assets are checked with real (non-auxiliary) files first, since those are
    the artifacts aqua actually installs and is most likely to have
    attestations; auxiliary/metadata files (see AUXILIARY_SUFFIXES) are checked
    only after the real ones. Within each group, larger assets are checked
    first. `max_asset_checks` bounds the number of attestation lookups per
    release (0 = unlimited). When the cap truncates the scan and nothing was
    found, None is returned so the result is not cached as a false negative.
    """
    assets = gh_release_assets(owner, name, asset_cache)
    if assets is None:
        return None
    entries: list[tuple[bool, int, str]] = []
    for asset in assets:
        digest = asset.get("digest") or ""
        if not digest.startswith("sha256:"):
            continue
        asset_name = (asset.get("name") or "").lower()
        is_aux = asset_name.endswith(AUXILIARY_SUFFIXES)
        entries.append((is_aux, asset.get("size") or 0, digest.partition(":")[2]))
    if not entries:
        return False
    # Real (non-auxiliary) assets first, then by descending size within each
    # group so the largest binaries are checked before small metadata files.
    entries.sort(key=lambda e: (e[0], -e[1]))
    # Randomize within each group so that, across runs, a different subset of
    # assets is checked first. Combined with the per-release check cap, this
    # spreads coverage over time and improves the cache-hit rate (a repo
    # returning False under the cap only means "none of the assets we happened
    # to check had attestations", so varying the sample avoids repeatedly
    # missing the one attested asset).
    real = [e for e in entries if not e[0]]
    aux = [e for e in entries if e[0]]
    random.shuffle(real)
    random.shuffle(aux)
    digest_hashes = [e[2] for e in real + aux]
    if max_asset_checks and max_asset_checks > 0:
        digest_hashes = digest_hashes[:max_asset_checks]
        scanned_all = len(digest_hashes) == len(entries)
    else:
        scanned_all = True
    for digest_hash in digest_hashes:
        res = gh_attestation_exists(owner, name, digest_hash)
        if res is True:
            return True
        if res is None:
            return None
        # res is False -> try the next asset.
    # Nothing found. Only cache a definitive False if we actually scanned every
    # digestible asset (i.e. the cap did not truncate the scan).
    return False if scanned_all else None


def parse_exclusions(path: Path) -> set[str]:
    """Parse an exclusion file of `pkgs_path [comments...]` lines.

    This script only deals with `github_artifact_attestations`, so an entry
    here suppresses the attestation lookup for that package regardless of any
    signing-type filtering. Blank lines and lines starting with `#` are
    ignored; the first whitespace-delimited token is the registry.yaml path
    (relative to the repo root) and the remainder, if present, is a free-form
    comment. Returns a set of registry.yaml paths.
    """
    if not path.exists():
        return set()
    excl: set[str] = set()
    for raw in path.read_text(encoding="utf-8").splitlines():
        line = raw.strip()
        if not line or line.startswith("#"):
            continue
        excl.add(line.split()[0])
    return excl


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
        "--max-asset-checks",
        type=int,
        default=1,
        help="Max attestation lookups per release (0 = check all asset digests). "
        "Checking is short-circuited on the first hit. Default: 1.",
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
        "--exclude-signed-by",
        action="append",
        choices=[*SIGNING_TYPE_TO_KEY.keys(), "all"],
        default=None,
        help="Only exclude packages already signed with one of these types "
        "(repeatable). Use 'all' to also exclude packages already configured with any "
        "signing type. Default: the target type github_artifact_attestations.",
    )
    parser.add_argument(
        "--dry-run",
        "--no-gh",
        action="store_true",
        help="Skip gh queries; list candidate packages with type '*' "
        "(attestations not checked).",
    )
    parser.add_argument(
        "--exclude-file",
        type=Path,
        default=DEFAULT_EXCLUDE_FILE,
        help="File of `pkgs/<path>/registry.yaml [comments]` lines to exclude from output. "
        "Any listed package has its attestation lookup suppressed. "
        "Defaults to .cache/attestation-candidates-exclusions.txt; "
        "a missing file is not an error.",
    )
    args = parser.parse_args()

    # Exclusion file: explicit per-package suppressions. This script only
    # concerns github_artifact_attestations, so any listed package has its
    # attestation lookup suppressed regardless of signing-type filtering.
    excluded_paths = parse_exclusions(args.exclude_file) if args.exclude_file else set()
    if excluded_paths:
        print(
            f"loaded {len(excluded_paths)} exclusion entries from {args.exclude_file.name}",
            file=sys.stderr,
        )

    # Packages to skip based on already-configured signing types. We always
    # exclude the target type (so a package that already has attestation config
    # is not "missing" it), and `--exclude-signed-by` adds further types.
    exclude_keys = {SIGNING_TYPE_TO_KEY[TARGET_TYPE]}
    if args.exclude_signed_by:
        if "all" in args.exclude_signed_by:
            exclude_keys = set(SIGNING_KEYS)
        else:
            exclude_keys |= {SIGNING_TYPE_TO_KEY[t] for t in args.exclude_signed_by}

    cache = load_cache(args.cache) if not args.no_cache else {"results": {}}
    cache_results = cache.setdefault("results", {})
    asset_cache = load_asset_cache(args.asset_cache) if not args.no_cache else {}

    candidates = list(find_candidates(args.pkgs_dir, exclude_keys))
    print(
        f"scanned {len(candidates)} github_release packages excluding "
        f"signing config for: {', '.join(sorted(exclude_keys))}",
        file=sys.stderr,
    )

    # De-duplicate repos (multiple tools may share a repo) and split into
    # cached vs. to-be-queried. A cached value must be a bool; anything else
    # (stale cache, missing) is re-queried.
    repos = sorted({f"{o}/{n}" for o, n, _ in candidates})
    repo_paths: dict[str, str] = {}
    for o, n, source in candidates:
        key = f"{o}/{n}"
        if key not in repo_paths:
            repo_paths[key] = str(source.relative_to(REPO_ROOT))
    to_query = [r for r in repos if not isinstance(cache_results.get(r), bool)]
    if args.limit:
        to_query = to_query[: args.limit]

    print(
        "repos to query via gh: "
        f"{len(to_query)} (cached: {len(repos) - len(to_query)})",
        file=sys.stderr,
    )

    def query(repo: str):
        owner, _, name = repo.partition("/")
        return repo, gh_has_attestations(
            owner,
            name,
            args.max_asset_checks,
            asset_cache,
        )

    if to_query and not args.dry_run:
        with ThreadPoolExecutor(max_workers=args.workers) as pool:
            futures = {pool.submit(query, r): r for r in to_query}
            rate_limited = False
            done = 0
            for fut in as_completed(futures):
                if rate_limited:
                    # Abort: cancel any not-yet-started queries; in-flight ones
                    # are left to finish but their results are ignored.
                    fut.cancel()
                    break
                try:
                    repo, result = fut.result()
                except RateLimitError:
                    rate_limited = True
                    print(
                        "rate limit hit; aborting remaining gh queries",
                        file=sys.stderr,
                    )
                    for f in futures:
                        f.cancel()
                    break
                # Only cache definitive results (True/False); None means
                # "could not determine" and must be re-queried later.
                if result is not None:
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

    # Build (repo, path, url) matches, honoring the exclusion file. The same
    # cache lookup applies in dry-run (which merely reuses cached results
    # instead of making new GitHub API calls).
    matches: list[tuple[str, str, str]] = []
    for repo in repos:
        if cache_results.get(repo) is not True:
            continue
        owner, _, name = repo.partition("/")
        path = repo_paths.get(repo, f"pkgs/{owner}/{name}/registry.yaml")
        if path in excluded_paths:
            continue
        url = f"https://github.com/{owner}/{name}/attestations?q=sort%3Acreated-asc"
        matches.append((repo, path, url))

    matched_repos = sorted({r for r, *_ in matches})
    print(
        f"found {len(matched_repos)} candidate repos with attestations",
        file=sys.stderr,
    )

    if args.check_only:
        return 0

    if args.format == "json":
        print(
            json.dumps(
                [{"path": p, "url": u, "repo": r} for r, p, u in matches],
                indent=2,
                sort_keys=True,
            ),
        )
    else:
        for _r, p, u in matches:
            print(f"{p} {u}")
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
