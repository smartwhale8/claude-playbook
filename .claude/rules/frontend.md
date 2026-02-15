# Frontend

Standards for building maintainable, performant frontend applications.

## Component Architecture

- Components do one thing — if a component handles data fetching, business logic, and rendering, split it
- Prefer composition over prop drilling: break large components into smaller ones that compose together
- Container components handle data/state; presentational components handle rendering — keep these concerns separate
- Components should be reusable by default: accept props for customization, don't hardcode values that could vary
- Keep component files under ~200 lines — if larger, extract sub-components or hooks

## State Management

- **Local state** (`useState` / reactive refs): UI-only state — modals, form inputs, loading flags, toggle states
- **Shared state** (store/context): State needed by multiple components or persisted across navigation — user session, feed data, preferences
- Never duplicate state — if data exists in a store, components read from the store, not from their own copy
- Loading, error, and success states must be explicit in the store — not implicit or derived from `null` checks
- For optimistic updates: apply the change immediately, attempt the API call, rollback on failure

## API Client

- All API calls go through a single, shared HTTP client instance — never create one-off axios/fetch calls in components
- The client handles: auth token injection, base URL, content-type headers, error response interception
- Feature-specific API functions live in dedicated modules (e.g., `api/users.ts`, `api/posts.ts`) that import the shared client
- Components call these typed API functions — never construct URLs or request configs directly

## TypeScript

- All API response data must have explicit TypeScript interfaces — define them alongside the API functions
- Never use `any` — use `unknown` and narrow with type guards when the type is truly dynamic
- Props interfaces are required for all components that accept props
- Prefer type inference where possible — don't annotate what TypeScript already knows

## Error Handling

- Wrap all async API calls in `try/catch` in event handlers and effects
- Display errors to the user: error text, toasts, banners — never swallow errors silently
- `console.error` is for development debugging, not a substitute for user-facing error handling
- Maintain usable UI state after errors — don't leave blank screens or broken forms

## Forms

- Use controlled components with validation before submission
- Disable submit buttons during async operations to prevent double-submission
- Show field-level validation errors inline, not just a generic "form invalid" message
- Reset form state appropriately: clear on successful submit, preserve on error for retry

## Routing

- Route definitions should be centralized in one file/config — not scattered across components
- Use route parameters for resource IDs: `/users/:userId`, not query strings
- Protect authenticated routes with guards/middleware — don't rely on UI hiding alone
- Handle 404/not-found routes with a fallback page
