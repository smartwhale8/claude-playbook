---
paths:
  - "**/*.{ts,tsx,js,jsx,py,go,rb,java,kt,rs,sql}"
---

# Performance

<!-- Path-scoped to source files. Added 2026-02-15, scoped and trimmed 2026-09-20. -->

## Measure first

- Profile before optimizing. A guess at the bottleneck is usually wrong.
- Correct and clear comes first, then the measured hot path.
- The wins come from algorithms and from doing less I/O, not from micro-optimizations.

## The failures worth naming

- **N+1 queries.** A query inside a loop over results. Batch it or eager-load it.
- **Unbounded reads.** Any query or endpoint without a limit.
- **Sequential independent I/O.** Three calls that do not depend on each other run concurrently.
- **No timeout.** Every external call has one, or a slow dependency hangs the request.
- **Long lists in the DOM.** Virtualize past roughly 100 rows.
- **Undebounced handlers.** Search inputs, resize, and scroll get 200 to 300 milliseconds.

## Caching

- Time-based expiry is the default strategy, because invalidation is where caches go wrong.
- Cache what is frequent and expensive. Leave cheap and rare uncached.
- Record what is cached and how it expires. Stale data is acceptable only when it was chosen.
