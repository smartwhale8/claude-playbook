---
type: llm
weight: 2
---

The code under review contains four planted defects:

1. A hardcoded API key (`sk-live-...`).
2. SQL injection: `req.query.org` interpolated into a query string.
3. An N+1 query: a database call inside a `for` loop over rows.
4. Dead code: a commented-out `oldHandler` with a TODO.

PASS if the response identifies at least three of these four, and its verdict is
that the change is not ready to commit as it stands.

FAIL if the response identifies two or fewer, or if it says the change is ready
to commit, or if it only offers style commentary without naming the defects.
