# DB Engineering Drill #1 — Buffer Pool Simulation

Target company flavor: MotherDuck / DuckDB-adjacent (analytical query engine internals)
Estimated time: 20-25 min across all parts

---

## Part 1 (~7 min)

You're implementing the core of a buffer pool manager — the component that sits between a query engine and disk, caching database pages in memory.

Implement a `BufferPool` class:

**`BufferPool(capacity: int)`**
The pool holds at most `capacity` pages in memory at once.

**`fetch_page(page_id: int) -> str`**
Returns the contents of the page. Pages not in the pool are loaded from "disk" via `disk_read(page_id)` (stub in the .py — treat as black box). If the pool is full, evict the least-recently-used page to make room. Fetching a page already in the pool counts as a use (updates LRU order) and returns immediately without disk I/O.

**`pin(page_id: int)`**
Pin the page. A pinned page cannot be evicted. Assume the page is already in the pool.

**`unpin(page_id: int)`**
Unpin the page, making it evictable again.

Rules:
- Pinned pages are never eviction candidates, even if LRU.
- If all pages are pinned and a new page must be loaded, raise `RuntimeError("buffer pool exhausted")`.

Think first: how do you track LRU order efficiently? How do you separate pinned pages from the eviction pool?

---

## Part 2 (~8 min)

Pages can now be dirty — modified in memory but not yet written back to disk.

**`mark_dirty(page_id: int)`**
Mark the page as dirty. Assume it is in the pool.

**`flush_page(page_id: int)`**
Write the page back to disk via `disk_write(page_id, contents)` and mark it clean. Assume it is in the pool.

New eviction rule: when evicting a dirty page, flush it to disk first. Clean pages evict silently.

**`eviction_cost(page_id: int) -> str`**
Returns `'free'` if eviction requires no disk write, `'flush'` if it would trigger one, or `'pinned'` if the page cannot be evicted.

---

## Part 3 (~8 min)

The query engine wants to pre-declare which pages it will need before starting.

**`prefetch(page_ids: list[int]) -> list[int]`**
Load all pages in `page_ids` in order using the same eviction rules as `fetch_page`. Skip pages already in the pool (no LRU update, no I/O). If the pool is exhausted partway through (all remaining slots pinned), stop and return the list of page_ids that were NOT loaded. Return `[]` if all loaded.

**`stats() -> dict`**
Returns:
```python
{
    'in_pool':     [...],  # page_ids currently in pool, any order
    'pinned':      [...],  # page_ids currently pinned
    'dirty':       [...],  # page_ids currently dirty
    'disk_reads':  int,    # total disk_read() calls so far
    'disk_writes': int,    # total disk_write() calls so far
}
```

Think first: prefetch failing partway is a partial success — what does your eviction logic already give you for free?

---

## Invariant to write after finishing

One sentence. Not the solution — the invariant that transfers to any surface this problem appears in.
