"""DB-free unit tests for the consolidated_db -> local sync (change detection + helpers).

The dedup guarantee is REPLACE-on-PK / TRUNCATE-on-full-copy; these tests pin the bits that decide
WHICH rows are considered changed — the part that, if wrong, freezes a table (the
national_fingerprint_mapping bug: created_at/updated_at not recognised) or misses reference edits.
"""
import pathlib
import sys

sys.path.insert(0, str(pathlib.Path(__file__).resolve().parents[1]))
import sync_source as S  # noqa: E402


# ----- version comparators -------------------------------------------------
def test_newer_timestamp_comparator():
    assert S._newer(2, 1)                 # source newer -> changed
    assert not S._newer(1, 2)             # source older -> unchanged
    assert not S._newer(1, 1)             # equal -> unchanged
    assert S._newer(5, None)              # local has no value yet -> changed
    assert not S._newer(None, 5)          # source null timestamp -> not a spurious change


def test_differs_hash_comparator():
    assert S._differs("a", "b")
    assert not S._differs("a", "a")
    assert S._differs("x", None)


# ----- change-column detection (the freeze bug) ----------------------------
class FakeCol:
    """Cursor that answers has_column() from a set of (table, column) the source 'has'."""
    def __init__(self, present):
        self.present = set(present)
        self._r = None
    def execute(self, sql, params=None):
        # has_column(cur, db, table, col) -> SELECT 1 ... column_name=%s
        _db, table, col = params
        self._r = (1,) if (table, col) in self.present else None
    def fetchone(self): return self._r


def test_change_expr_recognises_created_updated_at():
    # national_fingerprint_mapping only has created_at/updated_at (NOT date_*). Must NOT be static.
    cur = FakeCol({("national_fingerprint_mapping", "created_at"),
                   ("national_fingerprint_mapping", "updated_at")})
    expr = S.change_expr(cur, "national_fingerprint_mapping")
    assert expr is not None and "GREATEST" in expr
    assert "`updated_at`" in expr and "`created_at`" in expr


def test_change_expr_openmrs_date_columns():
    cur = FakeCol({("person_openmrs", "date_created"),
                   ("person_openmrs", "date_changed"),
                   ("person_openmrs", "date_updated")})
    expr = S.change_expr(cur, "person_openmrs")
    assert expr.startswith("GREATEST(") and "`date_updated`" in expr


def test_change_expr_single_column_no_greatest():
    cur = FakeCol({("concept_name", "date_created")})
    expr = S.change_expr(cur, "concept_name")
    assert "GREATEST" not in expr and "`date_created`" in expr


def test_change_expr_none_when_no_timestamp():
    # locations/site have no change timestamp -> None -> sync falls back to content-hash diff
    cur = FakeCol(set())
    assert S.change_expr(cur, "locations") is None


# ----- content-hash expression --------------------------------------------
class FakeCols:
    def __init__(self, cols): self.cols = cols
    def execute(self, sql, params=None): pass
    def fetchall(self): return [(c,) for c in self.cols]


def test_row_hash_expr_covers_all_columns_null_safe():
    expr = S.row_hash_expr(FakeCols(["value_reference", "name", "active"]), "consolidated_db", "locations")
    assert expr.startswith("MD5(CONCAT_WS(CHAR(31),")
    for c in ("value_reference", "name", "active"):
        assert f"`{c}`" in expr
    assert "COALESCE(CAST(" in expr and "CHAR(0)" in expr   # NULL-safe per column
