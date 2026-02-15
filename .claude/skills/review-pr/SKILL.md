---
name: review-pr
description: Review a pull request for quality, security, and correctness
disable-model-invocation: true
---

Review pull request: $ARGUMENTS

Follow this checklist:

1. **Read the PR**: Run `gh pr view $ARGUMENTS` and `gh pr diff $ARGUMENTS`
2. **Understand scope**: What is this PR trying to accomplish?
3. **Review for correctness**:
   - Does the code do what it claims?
   - Are there edge cases not handled?
   - Are there off-by-one errors, null pointer risks, or race conditions?
4. **Review for architecture**:
   - Does this follow existing patterns in the codebase?
   - Is there code duplication that should be extracted?
   - Are new dependencies justified?
5. **Review for security**:
   - Input validation on external data?
   - SQL injection, XSS, or other OWASP risks?
   - Secrets or credentials exposed?
6. **Review for testing**:
   - Are new behaviors covered by tests?
   - Are edge cases tested?
7. **Summarize**: Provide a clear summary with specific, actionable feedback
