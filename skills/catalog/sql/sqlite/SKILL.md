---
name: sqlite
description: Use when working with SQLite databases — schema design, migrations, query tuning, WAL/locking, pragma configuration, and file-based deployment.
---

# SQLite

## 1. Schema Design

Prefer 3NF unless denormalization is justified. Enforce integrity via constraints, not application logic.

```sql
CREATE TABLE users (
  id      INTEGER PRIMARY KEY,
  email   TEXT    NOT NULL UNIQUE,
  active  INTEGER NOT NULL DEFAULT 1 CHECK (active IN (0, 1)),
  created TEXT    NOT NULL DEFAULT (datetime('now'))
);

CREATE TABLE posts (
  id      INTEGER PRIMARY KEY,
  user_id INTEGER NOT NULL REFERENCES users(id) ON DELETE CASCADE,
  title   TEXT    NOT NULL,
  body    TEXT
);
```

Key rules:
- Use `INTEGER PRIMARY KEY` for rowid alias (fast, no extra index)
- `TEXT` for strings, `INTEGER` for booleans/enums (SQLite has no bool type)
- Add `CHECK` constraints for bounded values
- Declare `REFERENCES` — but **enable enforcement** (see Pitfalls)

**Safe migration pattern — add a NOT NULL column to a populated table:**

```sql
-- Step 1: Add nullable (instant, no table rewrite)
ALTER TABLE users ADD COLUMN email_verified INTEGER;

-- Step 2: Backfill (run in batches if table is large)
UPDATE users SET email_verified = 0 WHERE email_verified IS NULL;

-- Step 3: Enforce NOT NULL + default (SQLite requires recreate-table for this)
-- Option A: recreate table (offline migration)
CREATE TABLE users_new AS SELECT * FROM users;
-- ... alter DDL, copy data, rename
-- Option B: accept NOT NULL via CHECK instead
ALTER TABLE users ADD CONSTRAINT chk_ev CHECK (email_verified IS NOT NULL);
-- (SQLite 3.37+: use STRICT tables for stronger typing)
```

> ⚠️ SQLite doesn't support `ALTER COLUMN`. Changing a column type or adding NOT NULL to an existing column requires a table rebuild: `CREATE TABLE new → INSERT SELECT → DROP old → ALTER RENAME`.

---

## 2. Performance — EXPLAIN QUERY PLAN + Indexes

**Workflow:**

1. Run `EXPLAIN QUERY PLAN` on the slow query
2. Look for `SCAN` (full table scan) vs `SEARCH … USING INDEX`
3. Add a covering index for the hot path
4. Re-run to confirm index is used

```sql
-- Diagnose
EXPLAIN QUERY PLAN
  SELECT id, status FROM orders WHERE customer_id = 42 ORDER BY created_at DESC;
-- Bad output: SCAN orders  ← full scan
-- Good output: SEARCH orders USING INDEX idx_orders_cust (customer_id=?)

-- Fix: covering index (includes all columns needed by the query)
CREATE INDEX idx_orders_cust_created ON orders (customer_id, created_at DESC);
-- Now the query can be satisfied entirely from the index — no table lookup
```

**Sargable predicates** — keep indexed columns free of functions:

```sql
-- ❌ Not sargable — index on created_at won't be used
WHERE strftime('%Y', created_at) = '2024'

-- ✓ Sargable
WHERE created_at >= '2024-01-01' AND created_at < '2025-01-01'
```

Other index rules:
- Composite index `(a, b)` covers `WHERE a = ? AND b = ?` and `WHERE a = ?` but **not** `WHERE b = ?` alone
- `ORDER BY` can use an index only if sort direction matches index definition
- Avoid `SELECT *` on hot paths — list only needed columns

**Pagination:** Large `OFFSET` scans from row 0 every time. Use keyset pagination:

```sql
-- ❌ Slow at high offsets
SELECT * FROM posts ORDER BY id LIMIT 20 OFFSET 10000;

-- ✓ Fast keyset
SELECT * FROM posts WHERE id > :last_seen_id ORDER BY id LIMIT 20;
```

---

## 3. SQLite-Specific Configuration

Apply these pragmas at connection open time — they're connection-scoped (except `journal_mode` which persists to the file):

```sql
PRAGMA journal_mode  = WAL;       -- enables concurrent readers + 1 writer
PRAGMA synchronous   = NORMAL;    -- safe with WAL; FULL is slower, OFF is risky
PRAGMA busy_timeout  = 5000;      -- wait up to 5s before SQLITE_BUSY error
PRAGMA cache_size    = -20000;    -- 20MB page cache (negative = KB)
PRAGMA foreign_keys  = ON;        -- MUST set per-connection; off by default
PRAGMA temp_store    = MEMORY;    -- temp tables in RAM
```

**WAL mode behavior:**
- Multiple readers can run concurrently with one writer
- WAL file (`db.sqlite-wal`) accumulates until checkpointed (auto at 1000 pages)
- Do **not** delete `-wal` or `-shm` files while the database is open
- Checkpoint manually if WAL grows large: `PRAGMA wal_checkpoint(TRUNCATE);`

**Concurrency limits:**
- SQLite supports one writer at a time (database-level write lock)
- High write contention → use `busy_timeout` + retry, or serialize writes via a queue
- For heavy concurrent writes, consider Postgres instead

**Backup:** Copy the file only when no writes are in progress, or use the online backup API:

```sql
VACUUM INTO 'backup.sqlite';  -- atomic snapshot, works with WAL
```

---

## 4. Common Pitfalls

| Pitfall | Fix |
|---|---|
| `foreign_keys` is OFF by default | Set `PRAGMA foreign_keys = ON` on every connection |
| Write lock contention → `SQLITE_BUSY` | Set `busy_timeout`, keep transactions short |
| `VACUUM` locks the entire database | Run during maintenance windows; use `VACUUM INTO` for online copy |
| Large `OFFSET` pagination is slow | Switch to keyset pagination (`WHERE id > ?`) |
| Changing column type/nullability | Requires full table rebuild; plan carefully |
| Forgetting to re-run pragmas | Pragmas are connection-scoped — set in connection init code |
| WAL file grows unbounded | Trigger `PRAGMA wal_checkpoint(TRUNCATE)` periodically or on idle |
