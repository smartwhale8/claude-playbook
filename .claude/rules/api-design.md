# API Design

Standards for building consistent, predictable, and well-documented APIs.

## REST Conventions

- Use nouns for resources, not verbs: `/users`, `/posts`, `/conversations` — not `/getUsers`, `/createPost`
- HTTP methods carry the verb: `GET` (read), `POST` (create), `PUT` (full replace), `PATCH` (partial update), `DELETE` (remove)
- Use plural nouns for collections: `/users`, `/posts` — not `/user`, `/post`
- Nest resources to express relationships: `/posts/{postId}/comments` — but limit nesting to 2 levels maximum
- Use query parameters for filtering, sorting, pagination: `/posts?status=published&sort=-created_at&limit=20`

## Response Format — Consistent Envelope

Choose one response envelope and use it for every endpoint. Example:

```json
{
  "success": true,
  "data": { ... },
  "meta": { "pagination": { "cursor": "...", "has_more": true } }
}
```

- `success`: boolean — always present
- `data`: the payload — type varies per endpoint
- `meta`: optional metadata (pagination, rate limits, request ID)
- Never return raw arrays or unwrapped objects at the top level
- Error responses follow the same structure: `{ "success": false, "error": { "code": "NOT_FOUND", "message": "..." } }`

## Pagination

Pick one primary pattern and apply it consistently:

- **Cursor-based** for feeds, timelines, real-time data (items ordered by time, infinite scroll)
- **Offset/limit** for bounded lists, search results, admin tables (items with stable ordering)

Every list endpoint must accept a `limit` parameter with a sensible default (e.g., 20) and enforced maximum (e.g., 100). Never return unbounded result sets.

## Request Validation

- Validate all input at the API boundary using schema validation (Pydantic, Zod, JSON Schema, etc.)
- Use field-level constraints: min/max length, value ranges, regex patterns, enum restrictions
- Return `400 Bad Request` with specific field-level errors — not generic "invalid input"
- Validate early, fail fast — don't partially process a request before discovering invalid data

## Versioning

- Version the API from day one: `/api/v1/...`
- When a breaking change is needed, create a new version — don't modify existing endpoints in ways that break existing clients
- Deprecation: mark old versions as deprecated in responses before removal

## Status Codes — Use Them Correctly

| Code | Meaning | When to use |
|------|---------|-------------|
| 200 | OK | Successful GET, PATCH, PUT |
| 201 | Created | Successful POST that creates a resource |
| 204 | No Content | Successful DELETE |
| 400 | Bad Request | Invalid input, validation failure |
| 401 | Unauthorized | Missing or invalid authentication |
| 403 | Forbidden | Authenticated but not authorized |
| 404 | Not Found | Resource doesn't exist |
| 409 | Conflict | Duplicate resource, state conflict |
| 422 | Unprocessable | Structurally valid but semantically wrong |
| 429 | Too Many Requests | Rate limited |
| 500 | Internal Error | Unhandled server error (should never be intentional) |

## Documentation

- Every endpoint should be self-documenting through typed schemas (auto-generated OpenAPI/Swagger)
- Include descriptions on schemas, parameters, and response models — not just type information
- Document expected error codes and their meanings for each endpoint
