#!/usr/bin/env bash
#
# SessionStart hook: put the facts Claude would otherwise spend three tool calls
# discovering into the session at startup.
#
# Contract (https://code.claude.com/docs/en/hooks):
#   - `additionalContext` on a SessionStart hook is added to Claude's context.
#   - Keep the output small. Everything printed here costs tokens in every
#     session, which is the same budget CLAUDE.md draws on.
#
# Registered in .claude/settings.json under SessionStart, matcher "startup|resume".

set -uo pipefail

if ! command -v jq >/dev/null 2>&1 || ! command -v git >/dev/null 2>&1; then
  exit 0
fi

if ! git rev-parse --is-inside-work-tree >/dev/null 2>&1; then
  exit 0
fi

BRANCH=$(git rev-parse --abbrev-ref HEAD 2>/dev/null)
CHANGED=$(git status --porcelain 2>/dev/null | wc -l | tr -d ' ')
RECENT=$(git log --oneline -5 2>/dev/null)

CONTEXT="Current branch: ${BRANCH}
Uncommitted files: ${CHANGED}
Recent commits:
${RECENT}"

jq -n --arg ctx "$CONTEXT" '{
  hookSpecificOutput: {
    hookEventName: "SessionStart",
    additionalContext: $ctx
  }
}'
