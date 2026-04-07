---
name: postgres
description: Use when working with PostgreSQL — schema design, indexing, query optimization (EXPLAIN/ANALYZE), connection pooling, VACUUM/autovacuum, migrations, and performance troubleshooting.
---

# PostgreSQL

## 1. Schema Design

Prefer 3NF. Use appropriate types — wrong types cause silent correctness bugs and prevent index use.

```sql
CREATE TABLE users (
  id         bigserial    PRIMARY KEY,
  email      text         NOT NULL UNIQUE,
  created_at timestamptz  NOT NULL DEFAULT now(),
  active     boolean      NOT NULL DEFAULT true
);

CREATE TABLE orders (
  id          bigserial   PRIMARY KEY,
  customer_id bigint      NOT NULL REFERENCES users(id),
  status      text        NOT NULL CHECK (status IN ('pending','paid','cancelled')),
  created_at  timestamptz NOT NULL DEFAULT now(),
  total_cents integer     NOT NULL CHECK (total_cents >= 0)
);

CREATE INDEX idx_orders_customer ON orders (customer_id);  -- index every FK
```

Type rules:
- `timestamptz` not `timestamp` — stores UTC, displays in session timezone
- `text` not `varchar(n)` unless you need the length constraint (no perf difference)
- `bigserial` / `bigint` for IDs (int overflows at ~2B rows)
- Money as `integer` (cents) or `numeric`, never `float`
- Always index foreign key columns — Postgres does **not** do this automatically

**Partitioning:** Consider when table exceeds ~100M rows or has time-series data with range-based access and pruning needs. Use `PARTITION BY RANGE (created_at)` with monthly/yearly partitions. Adds complexity — don't use prematurely.

---

## 2. Performance — EXPLAIN (ANALYZE, BUFFERS)

**Workflow:**

1. Run `EXPLAIN (ANALYZE, BUFFERS)` — never just `EXPLAIN` for real diagnosis
2. Find the most expensive node (highest `actual time` or rows estimate mismatch)
3. Look for: Seq Scan on large tables, Sort without index, Nested Loop on unindexed joins
4. Add index, re-run, confirm plan change

```sql
-- Full diagnosis
EXPLAIN (ANALYZE, BUFFERS, FORMAT TEXT)
  SELECT id, status FROM orders WHERE customer_id = 42 ORDER BY created_at DESC;

-- If you see: Seq Scan on orders (cost=...) or Sort
-- Fix: covering index — satisfies filter + sort + returns status without heap lookup
CREATE INDEX idx_orders_cust_created ON orders (customer_id, created_at DESC) INCLUDE (status);

-- After: you should see Index Only Scan using idx_orders_cust_created
```

**Partial indexes** — index a subset of rows when most queries filter on a common condition:

```sql
-- Only index active orders (avoids indexing cancelled/archived rows)
CREATE INDEX idx_orders_pending ON orders (customer_id, created_at DESC)
  WHERE status = 'pending';
```

**Sargable predicates:**

```sql
-- ❌ Function on indexed column — index not used
WHERE date_trunc('day', created_at) = '2024-01-15'

-- ✓ Range scan — index used
WHERE created_at >= '2024-01-15' AND created_at < '2024-01-16'
```

**Identify slow queries with pg_stat_statements:**

```sql
SELECT query, calls, mean_exec_time, total_exec_time
FROM pg_stat_statements
ORDER BY total_exec_time DESC
LIMIT 20;
```

**Keyset pagination** instead of large OFFSET:

```sql
-- ❌ Scans from row 0
SELECT * FROM orders ORDER BY id LIMIT 20 OFFSET 50000;

-- ✓ Uses index
SELECT * FROM orders WHERE id > :last_id ORDER BY id LIMIT 20;
```

---

## 3. Operations

**Connection pooling (PgBouncer):**
- Postgres forks a process per connection — direct connections are expensive
- PgBouncer transaction mode: connections returned to pool after each transaction
- Typical sizing: `max_client_conn = 200`, `default_pool_size = 10–25` per application user
- Pitfall: `SET`, `PREPARE`, advisory locks, `LISTEN/NOTIFY` don't survive transaction-mode pooling — use session mode for those

**VACUUM / autovacuum:**
- Postgres MVCC keeps dead tuples until VACUUM removes them
- Autovacuum runs automatically but can lag under heavy write load
- Monitor bloat:

```sql
SELECT schemaname, tablename,
       n_dead_tup, n_live_tup,
       round(n_dead_tup::numeric / nullif(n_live_tup + n_dead_tup, 0) * 100, 1) AS dead_pct,
       last_autovacuum
FROM pg_stat_user_tables
ORDER BY n_dead_tup DESC;
```

- Tune per-table if autovacuum is too slow: `ALTER TABLE orders SET (autovacuum_vacuum_scale_factor = 0.01);`
- Never `VACUUM FULL` on a live production table — it takes an exclusive lock and rewrites the entire table

**WAL basics:**
- `wal_level = replica` for streaming replication (default in most managed services)
- `synchronous_commit = off` improves write throughput at the cost of up to ~1 WAL buffer of data on crash (not corruption — just last few ms of commits)
- `checkpoint_completion_target = 0.9` reduces I/O spikes

---

## 4. Migrations

**Safe pattern for adding a NOT NULL column to a large table:**

```sql
-- Step 1: Add nullable — instant, no table rewrite
ALTER TABLE orders ADD COLUMN notes text;

-- Step 2: Backfill in batches (don't UPDATE all rows in one transaction)
UPDATE orders SET notes = '' WHERE id BETWEEN 1 AND 100000 AND notes IS NULL;
-- repeat for next batch...

-- Step 3: Set default + NOT NULL constraint
-- In Postgres 11+, ADD COLUMN with a constant default is instant (stored in catalog)
ALTER TABLE orders ALTER COLUMN notes SET DEFAULT '';
ALTER TABLE orders ALTER COLUMN notes SET NOT NULL;
-- Postgres will validate existing rows — if backfill is complete this is fast
```

**Non-blocking index creation:**

```sql
-- ❌ Blocks writes for the duration
CREATE INDEX idx_orders_status ON orders (status);

-- ✓ Runs concurrently, doesn't block writes (takes longer)
CREATE INDEX CONCURRENTLY idx_orders_status ON orders (status);
-- Note: if it fails, a INVALID index remains — drop it and retry
```

**Dangerous migration patterns to avoid:**
- `ALTER TABLE ... ALTER COLUMN type` on a large table → rewrites entire table with lock. Instead: add new column, backfill, swap, drop old.
- Adding a NOT NULL constraint without a default on a populated table → full table scan with lock
- Renaming columns/tables used by active code without a deploy window

---

## 5. Common Pitfalls

| Pitfall | Consequence | Fix |
|---|---|---|
| Long-running transactions | Blocks autovacuum; holds row locks; XID consumed | Set `statement_timeout`, `idle_in_transaction_session_timeout` |
| XID wraparound | Database forced into read-only mode to prevent data loss | Monitor `age(datfrozenxid)` in `pg_database`; let autovacuum run |
| Missing indexes on FK columns | Slow deletes/updates on parent table (cascade scans child) | `CREATE INDEX` on every FK column |
| `idle in transaction` connections | Holds locks, prevents VACUUM | Set `idle_in_transaction_session_timeout = '30s'` |
| N+1 queries | 100 rows → 101 queries | Use JOINs or `WHERE id = ANY(:ids)` bulk fetch |
| `VACUUM FULL` in production | Exclusive lock rewrites entire table | Use regular `VACUUM`; schedule `VACUUM FULL` only in maintenance window |
| Sequences near int max | Inserts fail with overflow error | Use `bigserial`; monitor with `SELECT last_value FROM seq_name` |
