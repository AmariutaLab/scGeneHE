import unittest
from pathlib import Path


REPO_ROOT = Path(__file__).resolve().parents[1]
FORBIDDEN_PATTERNS = (
    "/" + "expanse",
    "/" + "scratch",
    "/" + "home/" + "zxu" + "6",
    "ddp" + "412",
    "zix" + "016",
    "zxu" + "6",
)
SKIP_DIRS = {".git", "__pycache__"}
TEXT_SUFFIXES = {
    ".R",
    ".csv",
    ".md",
    ".py",
    ".sh",
    ".txt",
    ".yaml",
    ".yml",
}


class LocalPathTest(unittest.TestCase):
    def test_no_local_absolute_paths_in_text_files(self):
        violations = []
        for path in REPO_ROOT.rglob("*"):
            if any(part in SKIP_DIRS for part in path.parts):
                continue
            if not path.is_file() or path.suffix not in TEXT_SUFFIXES:
                continue
            text = path.read_text(errors="ignore")
            for pattern in FORBIDDEN_PATTERNS:
                if pattern in text:
                    violations.append(f"{path.relative_to(REPO_ROOT)} contains {pattern}")

        self.assertEqual(violations, [])


if __name__ == "__main__":
    unittest.main()
