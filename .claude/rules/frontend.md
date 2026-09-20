---
paths:
  - "**/*.{tsx,jsx,vue,svelte}"
  - "**/components/**/*"
  - "**/pages/**/*"
  - "**/app/**/*.{ts,tsx,js,jsx}"
---

# Frontend

<!-- Path-scoped. Loads only when Claude opens a component or page file. -->
<!-- Added 2026-02-15, scoped and trimmed 2026-09-20. -->

## Components

- One responsibility each. A component that fetches, decides, and renders is three components.
- Container components hold data and state. Presentational components render props.
- Over roughly 200 lines, extract a sub-component or a hook.

## State

- Local state for UI concerns: open or closed, the current input value, a loading flag.
- Shared state for anything two components need or that survives navigation.
- Never keep a second copy of data that already lives in the store.
- Loading, error, and success are explicit states, not inferred from a `null` check.

## The API client

- One shared HTTP client instance handles the base URL, the auth token, the headers, and error interception.
- Typed functions per feature (`api/users.ts`) wrap that client. Components call those functions.
- A raw `fetch` or `axios` call inside a component bypasses all of it.

## TypeScript

- Every API response has an explicit interface, declared next to the function that returns it.
- No `any`. Use `unknown` and narrow it.
- Do not annotate what inference already knows.

## Forms and errors

- Controlled inputs, validated before submit, with the submit button disabled while the request is in flight.
- Validation errors appear next to the field.
- Every async call in a handler or effect is wrapped, and the failure is shown to the user. `console.error` is not error handling.
