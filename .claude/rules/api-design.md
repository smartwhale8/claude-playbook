---
paths:
  - "**/api/**/*.{ts,js,py,go,rb,java,kt}"
  - "**/routes/**/*.{ts,js,py,go,rb,java,kt}"
  - "**/controllers/**/*.{ts,js,py,go,rb,java,kt}"
  - "**/handlers/**/*.{ts,js,py,go,rb,java,kt}"
  - "**/*{Controller,Router,Handler}.{ts,js,py,go,rb,java,kt}"
---

# API Design

<!-- Path-scoped. Loads only when Claude opens an API or route file. -->
<!-- Added 2026-02-15, scoped and trimmed 2026-09-20. -->
<!-- Edit the paths above to match where your endpoints live. -->

## Resource naming

- Plural nouns for collections, HTTP methods for the verb: `GET /users`, `POST /posts`. Never `/getUsers`.
- Nest at most two levels: `/posts/{postId}/comments`.
- Filtering, sorting, and pagination go in query parameters.

## One response envelope

Pick one shape and use it on every endpoint, success and failure alike.

```json
{ "success": true, "data": {}, "meta": { "pagination": { "cursor": "...", "has_more": true } } }
```

```json
{ "success": false, "error": { "code": "NOT_FOUND", "message": "..." } }
```

Never return a bare array or an unwrapped object at the top level.

## Pagination is mandatory

- Every list endpoint takes `limit`, with a default and an enforced maximum.
- Cursor pagination for feeds and timelines. Offset pagination for stable, bounded lists.
- No endpoint returns an unbounded result set.

## Validation and status codes

- Validate at the boundary with a schema, and return field-level errors, not "invalid input".
- `201` for a created resource, `204` for a delete, `400` for invalid input, `401` unauthenticated, `403` unauthorized, `404` missing, `409` conflict, `422` semantically wrong, `429` rate limited.
- A `500` is always a bug, never a designed response.

## Versioning

Version from the first endpoint: `/api/v1/`. Breaking changes create a new version rather than altering the old one.
