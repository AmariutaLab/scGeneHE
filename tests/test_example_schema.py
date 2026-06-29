import csv
import unittest
from pathlib import Path


REPO_ROOT = Path(__file__).resolve().parents[1]
EXAMPLE_DIR = REPO_ROOT / "example"
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


def read_csv_rows(path):
    with path.open(newline="") as handle:
        return list(csv.DictReader(handle))


class ExampleSchemaTest(unittest.TestCase):
    def test_gene_list_matches_example_gene(self):
        genes = [
            line.strip()
            for line in (EXAMPLE_DIR / "gene_list.txt").read_text().splitlines()
            if line.strip()
        ]
        self.assertEqual(genes, [GENE])

    def test_point_phenotype_schema_and_ids(self):
        pheno_path = EXAMPLE_DIR / GENE / f"{GENE}_sample_expression.txt"
        rows = read_csv_rows(pheno_path)
        self.assertEqual(list(rows[0].keys()), EXPECTED_COLUMNS)
        self.assertEqual(len(rows), 5000)
        self.assertEqual(len({row["iid"] for row in rows}), 100)
        self.assertTrue(all(row["fid"] == row["iid"] for row in rows))
        self.assertTrue(all(int(float(row[GENE])) >= 0 for row in rows))

    def test_bootstrap_fixture_schema_and_ids(self):
        boot_path = EXAMPLE_DIR / GENE / "boot0" / "1.0_sample_boot_0.txt"
        id_path = EXAMPLE_DIR / GENE / "boot0" / "1.0_sample_boot_id.txt"
        rows = read_csv_rows(boot_path)
        self.assertEqual(list(rows[0].keys()), EXPECTED_COLUMNS)
        self.assertEqual(len(rows), 5000)
        self.assertEqual(len({row["iid"] for row in rows}), 100)

        id_rows = [line.split("\t") for line in id_path.read_text().splitlines() if line]
        self.assertEqual(len(id_rows), 100)
        self.assertTrue(all(len(row) == 2 for row in id_rows))

    def test_phenotype_samples_are_in_fam(self):
        fam_path = EXAMPLE_DIR / "HM_chr1_1MB_100_indiv.fam"
        fam_iids = {
            line.split()[1]
            for line in fam_path.read_text().splitlines()
            if line.strip()
        }
        rows = read_csv_rows(EXAMPLE_DIR / GENE / f"{GENE}_sample_expression.txt")
        self.assertEqual({row["iid"] for row in rows}, fam_iids)


if __name__ == "__main__":
    unittest.main()
