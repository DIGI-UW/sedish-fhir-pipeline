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


# ----- schema-drift handling (#1 alert + B drop/recreate the ONE table) ----
class DriftConn:
    def commit(self): pass


class DriftCursor:
    """Answers ensure_table's queries: table-exists, column list, SHOW CREATE; records executed SQL."""
    def __init__(self, cols, table_exists=True):
        self.cols, self.table_exists = cols, table_exists
        self.executed, self._r = [], None
        self.connection = DriftConn()
    def execute(self, sql, params=None):
        self.executed.append(sql)
        s = sql.lower()
        if "information_schema.tables" in s:
            self._r = [(1,)] if self.table_exists else []
        elif "information_schema.columns" in s:
            self._r = [(c,) for c in self.cols]
        elif "show create table" in s:
            self._r = [("t", "CREATE TABLE `t` (...)")]
        else:
            self._r = []
    def fetchone(self): return self._r[0] if self._r else None
    def fetchall(self): return list(self._r)


def test_ensure_table_drops_and_recreates_on_column_drift():
    src = DriftCursor(cols=["id", "mspp_code", "new_col"])          # source gained a column
    loc = DriftCursor(cols=["id", "mspp_code"], table_exists=True)  # local is behind
    S.ensure_table(src, loc, "national_fingerprint_mapping")
    assert any("drop table" in s.lower() for s in loc.executed)     # only this table dropped
    assert any("show create table" in s.lower() for s in src.executed)  # then recreated from source


def test_ensure_table_no_drop_when_column_set_matches():
    # same columns, different ORDER -> not drift (REPLACE maps by name); must NOT drop
    src = DriftCursor(cols=["id", "mspp_code"])
    loc = DriftCursor(cols=["mspp_code", "id"], table_exists=True)
    S.ensure_table(src, loc, "t")
    assert not any("drop table" in s.lower() for s in loc.executed)


def test_ensure_table_creates_when_missing():
    src = DriftCursor(cols=["id"])
    loc = DriftCursor(cols=[], table_exists=False)
    S.ensure_table(src, loc, "t")
    assert not any("drop table" in s.lower() for s in loc.executed)  # nothing to drop
    assert any("show create table" in s.lower() for s in src.executed)
