import subprocess
import sys
import tempfile
import unittest
from pathlib import Path


SCRIPT = Path(__file__).with_name("fix_pkg_yaml.py")


class FixPkgYAMLTest(unittest.TestCase):
    def assert_fixed(self, source, expected, filename="pkg.yaml"):
        with tempfile.TemporaryDirectory() as temp_dir:
            path = Path(temp_dir) / filename
            path.write_text(source, encoding="utf-8")
            subprocess.run([sys.executable, SCRIPT, path], check=True)
            self.assertEqual(path.read_text(encoding="utf-8"), expected)

    def test_fixes_old_short_syntax_without_rewriting_the_entry(self):
        source = """\
packages:
  - name: owner/repo@v2.0.0
  # Keep this explanation.
  - name: owner/repo@v1.0.0 # Keep this inline comment.
    vars:
      go_version: 1.24.0
  - name: owner/repo
    version: v0.9.0
"""
        expected = """\
packages:
  - name: owner/repo@v2.0.0
  # Keep this explanation.
  - name: owner/repo # Keep this inline comment.
    version: v1.0.0
    vars:
      go_version: 1.24.0
  - name: owner/repo
    version: v0.9.0
"""

        self.assert_fixed(source, expected)

    def test_quotes_versions_that_yaml_would_parse_as_another_type(self):
        source = """\
packages:
  - name: owner/repo@v2.0.0
  - name: owner/repo@2026-08-27
  - name: owner/repo@true
  - name: owner/repo@null
  - name: owner/repo@1.0
  - name: owner/repo@01
  - name: owner/repo@.5
"""
        expected = """\
packages:
  - name: owner/repo@v2.0.0
  - name: owner/repo
    version: "2026-08-27"
  - name: owner/repo
    version: "true"
  - name: owner/repo
    version: "null"
  - name: owner/repo
    version: "1.0"
  - name: owner/repo
    version: "01"
  - name: owner/repo
    version: ".5"
"""

        self.assert_fixed(source, expected)

    def test_fixes_quoted_short_syntax(self):
        source = """\
packages:
  - name: owner/repo@v2.0.0
  - name: "owner/repo@v1.0.0"
  - name: 'owner/repo@v0.9.0'
"""
        expected = """\
packages:
  - name: owner/repo@v2.0.0
  - name: owner/repo
    version: v1.0.0
  - name: owner/repo
    version: v0.9.0
"""

        self.assert_fixed(source, expected)

    def test_is_idempotent(self):
        source = """\
packages:
  - name: owner/repo@v2.0.0
  - name: owner/repo@v1.0.0
"""

        with tempfile.TemporaryDirectory() as temp_dir:
            path = Path(temp_dir) / "pkg.yaml"
            path.write_text(source, encoding="utf-8")

            subprocess.run([sys.executable, SCRIPT, path], check=True)
            first_result = path.read_text(encoding="utf-8")
            subprocess.run([sys.executable, SCRIPT, path], check=True)

            self.assertEqual(path.read_text(encoding="utf-8"), first_result)

    def test_ignores_non_pkg_yaml_files(self):
        source = """\
packages:
  - name: owner/repo@v2.0.0
  - name: owner/repo@v1.0.0
"""

        self.assert_fixed(source, source, filename="registry.yaml")

    def test_does_not_add_a_duplicate_version_field(self):
        source = """\
packages:
  - name: owner/repo@v2.0.0
  - name: owner/repo@v1.0.0
    version: v0.9.0
"""

        self.assert_fixed(source, source)

    def test_leaves_incomplete_short_syntax_for_lint(self):
        source = """\
packages:
  - name: owner/repo@v2.0.0
  - name: owner/repo@
"""

        self.assert_fixed(source, source)


if __name__ == "__main__":
    unittest.main()
