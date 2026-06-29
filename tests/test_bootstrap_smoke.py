import csv
import subprocess
import sys
import tempfile
import unittest
from pathlib import Path


REPO_ROOT = Path(__file__).resolve().parents[1]
GENE = "CDC37"
EXPECTED_COLUMNS = [
    "fid",
    "iid",
    "cid",
    "PC1",
    "PC2",
    "PC3",
    "PC4",
    "PC5",
    "PC6",
    "percent.mt",
    GENE,
]


class BootstrapSmokeTest(unittest.TestCase):
    def test_bootstrap_real_generates_expected_files(self):
        with tempfile.TemporaryDirectory(prefix="scgenehe_bootstrap_") as temp_dir:
            out_dir = Path(temp_dir) / "bootstrap"
            command = [
                sys.executable,
                str(REPO_ROOT / "scGeneHE" / "bootstrap_real.py"),
                "--boot_rate=0.02",
                "--n_boot=1",
                f"--gene={GENE}",
                f"--pheno_path={REPO_ROOT / 'example' / GENE / f'{GENE}_sample_expression.txt'}",
                f"--fam_path={REPO_ROOT / 'example' / 'HM_chr1_1MB_100_indiv.fam'}",
                "--covar=PC1,PC2,PC3,PC4,PC5,PC6,percent.mt",
                f"--bootstrap_path={out_dir}",
                "--out_str=smoke",
                f"--pheno_col={GENE}",
                "--sample_id_col=iid",
                "--seed=1",
            ]
            subprocess.run(command, check=True, cwd=REPO_ROOT)

            pheno_path = out_dir / "boot0" / "smoke_0.txt"
            id_path = out_dir / "boot0" / "smoke_id.txt"
            self.assertTrue(pheno_path.exists())
            self.assertTrue(id_path.exists())

            with pheno_path.open(newline="") as handle:
                rows = list(csv.DictReader(handle))
            self.assertEqual(list(rows[0].keys()), EXPECTED_COLUMNS)
            self.assertEqual(len(rows), 100)
            self.assertTrue(all(row["fid"] == row["iid"] for row in rows))

            id_rows = [line.split("\t") for line in id_path.read_text().splitlines() if line]
            self.assertGreater(len(id_rows), 0)
            self.assertTrue(all(len(row) == 2 for row in id_rows))


if __name__ == "__main__":
    unittest.main()
