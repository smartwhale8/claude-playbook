# Performance

Guidelines for building performant applications without premature optimization.

## Optimize Where It Matters

- Profile before optimizing — don't guess where the bottleneck is
- Optimize the critical path: page load, core user interactions, data-heavy operations
- Premature optimization is waste — write correct, clean code first, then optimize measured bottlenecks
- The biggest gains usually come from algorithmic improvements and reducing I/O, not micro-optimizations

## Database Performance

- **No N+1 queries**: The #1 backend performance killer. Never query inside a loop — batch-fetch with `WHERE IN` or use eager loading
- **Index strategically**: Index columns in WHERE clauses, JOIN conditions, and ORDER BY — especially foreign keys and timestamps
- **Paginate everything**: No unbounded queries. Every list endpoint has a LIMIT with a sensible default and enforced maximum
- **Select what you need**: Don't fetch entire rows when you need 2 columns. Don't eager-load relationships you won't use
- **Use EXPLAIN**: When a query is slow, analyze its execution plan before adding indexes or rewriting

## API Performance

- Minimize round trips: return related data together rather than requiring multiple sequential requests
- Use pagination for large datasets — never dump entire tables through an API
- Compress responses (gzip/brotli) for large payloads
- Set appropriate cache headers for data that doesn't change frequently
- Consider response size: don't return 50 fields when the client needs 5

## Frontend Performance

- **Lazy load routes and heavy components**: Don't load the entire app upfront — split by route
- **Debounce expensive operations**: Search inputs, resize handlers, scroll listeners — 200-300ms delay
- **Virtualize long lists**: Don't render 1000 DOM elements — use virtual scrolling for lists over ~100 items
- **Optimize images**: Use appropriate formats (WebP), sizes, and lazy loading for below-the-fold images
- **Minimize re-renders**: Memoize expensive computations, avoid creating new objects/arrays in render paths
- **Bundle size**: Audit regularly. Tree-shake unused imports. Avoid importing entire libraries for one function

## Caching

- Cache at the right layer: HTTP cache headers, in-memory cache, CDN, database query cache
- Cache invalidation is hard — use time-based expiry (TTL) as the default strategy
- Cache reads that are frequent and expensive; don't cache cheap operations or rarely-accessed data
- Document what's cached and how it's invalidated — stale data is a feature, not a bug, when it's intentional

## Async & Concurrency

- Use async I/O for operations that wait on external resources (database, APIs, file system)
- Run independent I/O operations concurrently, not sequentially — if you need data from 3 services, fetch all 3 in parallel
- Use background jobs for operations that don't need to complete before responding (email, analytics, cleanup)
- Set timeouts on all external calls — don't let a slow third-party service hang your entire request
