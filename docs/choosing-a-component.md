# Choosing a component

Claude Code gives you seven places to put a behaviour. Picking the wrong one
means your guardrail either never fires or fires constantly and costs you
context. This page is the decision.

## The seven

| Component | Where it lives | When it acts | Costs context |
|---|---|---|---|
| **CLAUDE.md** | `.claude/CLAUDE.md` | Read at the start of every session | Always |
| **Rules** | `.claude/rules/*.md` | Every session, or only when Claude opens a matching file | Always, or only when matched |
| **Skills** | `.claude/skills/<name>/SKILL.md` | When you invoke them, or when Claude judges them relevant | Description always, body only when invoked |
| **Subagents** | `.claude/agents/<name>.md` | When delegated to, in their own context window | Almost nothing in your context |
| **Hooks** | `.claude/settings.json` | On an event, deterministically | Nothing, unless they return context |
| **Workflows** | `.claude/workflows/<name>.js` | When you run them | Nothing; results stay in script variables |
| **MCP servers** | `.mcp.json` | When Claude calls one of their tools | Tool names always, schemas on demand |

## The decision

Start here and take the first answer that fits.

**Must this hold every single time, with no judgement?**
Use a **hook**. CLAUDE.md is context that Claude weighs against everything else
in the window. A `PreToolUse` hook is a gate. "Never force push" in prose is a
request; `guard-destructive.sh` is enforcement. This distinction is the single
most useful thing in the playbook.

**Does it only matter for certain files?**
Use a **path-scoped rule**. Frontmatter with `paths:` loads the rule when Claude
reads a matching file and never otherwise. A React convention should not be in
context while Claude edits a Terraform module.

**Is it a procedure with steps, run on request?**
Use a **skill**. The body loads only when the skill runs, so a 200-line workflow
costs nothing in the sessions that do not use it. Add
`disable-model-invocation: true` when it has side effects you want to trigger
yourself.

**Does it need to read a lot to answer a little?**
Use a **subagent**. It explores in its own context window and returns a summary.
The forty files it read never touch your conversation. This is the main defence
against context exhaustion.

**Is it the same step across dozens of items?**
Use a **workflow**. A script holds the loop and the intermediate results, so a
500-file migration does not have to fit in one context window.

**Does it apply to every session regardless of file or task?**
Only now use **CLAUDE.md**, and only if Claude could not work it out by reading
the code.

## The mistake everyone makes

Putting everything in CLAUDE.md, or in unconditional rules.

Anthropic's guidance is a 200-line ceiling on CLAUDE.md, because longer files
get ignored: the rule you care about gets lost among forty you do not. A study
from ETH Zurich (arXiv 2602.11988) measured more than a 20% increase in
inference cost from always-on context files, with no improvement in task
success.

This playbook shipped that mistake until September 2026. Fourteen rule files
loaded in every session, roughly 9,400 tokens, including Alembic migration
guidance in projects with no Python and no database. Scoping them to paths cut
the always-loaded set to about 1,700 tokens without removing a single rule.

Run `/context` to see what your setup actually costs. Run `/doctor` and Claude
proposes cuts. Run `/skill-doctor` to find skills that have never fired.

## Worked examples

| You want | Use | Why |
|---|---|---|
| Lint every edited file | Hook (`PostToolUse`) | Deterministic, no judgement, must not be skipped |
| Block writes to `.env` | Permission deny rule, plus a hook | A rule Claude cannot reason its way around |
| Never commit to `main` | Hook (`PreToolUse`) | Prose here is advisory; a hook is not |
| React components match the design system | Path-scoped rule on `**/*.tsx` | Needs judgement, only applies to UI files |
| Review before committing | Skill (`/review`) | A procedure, run deliberately, expensive to run always |
| Audit a change for vulnerabilities | Subagent | Reads widely, and a fresh context reviews better |
| Understand how auth works | Subagent (`explorer`) | Reads many files, returns three paragraphs |
| Migrate 400 files | Workflow | More items than one context window holds |
| The build command | CLAUDE.md | Claude cannot guess it, and every session needs it |
| "Write clean code" | Nothing | Claude already does this. The line only dilutes the rest. |
