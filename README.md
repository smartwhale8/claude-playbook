# Claude Playbook

A production-ready `.claude/` directory template that enforces professional software engineering standards in any project using [Claude Code](https://code.claude.com).

Drop it into a new repo and start building with guardrails from day one.

> If you find this useful, a star helps others discover it too.

> **Disclaimer:** This is an independent community project. "Claude" and "Claude Code" are products of [Anthropic](https://www.anthropic.com). This repository is not affiliated with, endorsed by, or sponsored by Anthropic.

---

## Why This Exists

Claude Code is powerful, but without guardrails it will:
- Introduce bandaid fixes instead of addressing root causes
- Build components in isolation that drift from the rest of the system
- Leave dead code, duplicate models, and inconsistent patterns behind
- Produce N+1 queries, silent error swallowing, and hardcoded secrets

This template prevents that. It provides **rules** (loaded every session), **skills** (reusable workflows), **agents** (specialized reviewers), and **hooks** (automated checks) — all configured and ready to use.

---

## What's Included

```
.claude/
├── CLAUDE.md                          # Project instructions template
├── .gitignore                         # Keeps personal settings out of git
│
├── rules/                             # Loaded automatically every session
│   ├── code-quality.md                # No dead code, no bandaids, root-cause fixes
│   ├── engineering-principles.md      # DRY, YAGNI, KISS, SRP, code smells, naming
│   ├── architecture.md                # Separation of concerns, dependency direction
│   ├── api-design.md                  # REST conventions, response format, pagination
│   ├── error-handling.md              # Structured errors, custom exceptions, fail fast
│   ├── security.md                    # OWASP, secrets, auth, input validation
│   ├── database.md                    # Schema design, constraints, query patterns
│   ├── alembic.md                     # Migration best practices (Python/SQLAlchemy)
│   ├── frontend.md                    # Components, state management, TypeScript
│   ├── frontend-consistency.md        # Reuse before create, no visual drift
│   ├── testing.md                     # Test types, structure, reliability
│   ├── performance.md                 # Query optimization, caching, async patterns
│   ├── git-workflow.md                # Commits, branches, PR standards
│   └── llm-prompts.md                # Jinja2 templates for prompt management
│
├── skills/                            # On-demand workflows (invoked with /skill-name)
│   ├── review/SKILL.md              # /review — pre-commit code review against rules
│   ├── fix-issue/SKILL.md            # /fix-issue 123 — end-to-end issue resolution
│   └── review-pr/SKILL.md            # /review-pr 456 — structured PR review
│
├── agents/                            # Specialized subagents (run in isolated context)
│   └── security-reviewer.md          # Delegated security audit
│
└── hooks/                             # Automated scripts on Claude events
    └── lint-on-edit.sh               # Auto-lint after every file edit
```

### Understanding the Components

Claude Code has four distinct extension mechanisms. Each serves a different purpose and fires at a different time. Choosing the wrong one means your guardrail either doesn't fire when needed or fires too aggressively.

#### Rules — "Always think this way"

Rules are loaded into Claude's context at the start of **every session**. They shape how Claude reasons about your code — what patterns to follow, what to avoid, what standards to enforce. Rules are **advisory**: Claude reads them and applies them during code generation, but nothing mechanically prevents a violation.

**Use rules for**: engineering principles, coding standards, architectural patterns, naming conventions — anything that requires Claude's judgment to apply.

**Examples**: "No N+1 queries", "Use custom exceptions not bare HTTPException", "Reuse existing components before creating new ones"

#### Skills — "Do this workflow when I ask"

Skills are multi-step workflows invoked **on demand** with `/skill-name`. They use Claude's full AI reasoning — reading files, analyzing code, making decisions. Skills only run when you explicitly invoke them.

**Use skills for**: code review, issue fixing, PR review, migrations, refactoring — complex workflows that are too expensive to run automatically but valuable when invoked deliberately.

**Examples**: `/review` before committing, `/fix-issue 123` to resolve a GitHub issue end-to-end

#### Agents — "Delegate this to a specialist"

Agents run in their own **isolated context window**. When Claude delegates to an agent, the agent's file reads and analysis don't pollute your main conversation. The agent reports back a summary.

**Use agents for**: tasks that require reading many files (security audits, codebase analysis) where you don't want the exploration consuming your main context.

**Examples**: "Use the security-reviewer agent to audit these changes"

#### Hooks — "Run this script automatically, every time"

Hooks are **shell scripts** that fire automatically on specific Claude events. They are **deterministic** — they execute every time, no exceptions, no AI judgment involved. Hooks cannot use Claude's reasoning; they run bash commands.

**Use hooks for**: linting, formatting, type-checking, running tests — fast, deterministic checks that don't need AI reasoning.

**Hook trigger events**:

| Event | When it fires | Use case |
|-------|--------------|----------|
| `PreToolUse` | Before Claude runs a tool | Block writes to protected files/directories |
| `PostToolUse` | After Claude runs a tool | Lint/format the file Claude just edited |
| `UserPromptSubmit` | When you send a message | Inject context or validate prompts |
| `Stop` | When Claude finishes responding | Run tests after Claude is done |

**Important**: Hooks only fire on **Claude's actions** (tool invocations), not on your manual edits in the IDE. Each hook fires once per tool call — if Claude edits 3 files, the post-edit hook fires 3 times, not once per line.

#### Choosing the Right One

```
Need AI reasoning?
├── Yes
│   ├── Should it run every session? → Rule
│   ├── Should it run on demand?     → Skill
│   └── Should it run in isolation?  → Agent
└── No (deterministic script)        → Hook
```

| Scenario | Right choice | Why |
|----------|-------------|-----|
| "Always use ApiResponse wrapper" | **Rule** | Needs AI judgment to apply during code generation |
| "Review my changes before I commit" | **Skill** (`/review`) | Expensive AI analysis, run deliberately |
| "Audit this code for security issues" | **Agent** | Reads many files, shouldn't clutter main context |
| "Lint every file after edit" | **Hook** | Fast shell script, must happen every time, no AI needed |
| "Block commits to production branch" | **Hook** | Deterministic check, no AI reasoning required |
| "Check if a similar component exists before creating" | **Rule** | Needs AI judgment while generating code |

---

## Getting Started

### Starting a new project (recommended)

The easiest way to use this scaffolding is as a **GitHub template repository**. This gives you a "Use this template" button on GitHub that copies everything into a new repo in one click.

**From the GitHub UI:**

1. Click the green **"Use this template"** button at the top of this repo
2. Choose **"Create a new repository"**
3. Name your repo, set visibility, and click **"Create"**
4. Clone your new repo — it already has the full `.claude/` scaffolding

**From the command line:**

```bash
# Create a new repo from this template
gh repo create my-new-project --template YOUR_USERNAME/claude-playbook --public --clone
cd my-new-project
```

**After creating your repo:**

1. Edit `.claude/CLAUDE.md` — replace the template commands with your actual build/test/lint commands
2. Remove rules that don't apply (no database? delete `database.md` and `alembic.md`)
3. Add project-specific details to the rules you keep
4. Start building — Claude Code picks up the rules automatically

### Adding to an existing project

#### Option 1: Copy the entire `.claude/` directory

```bash
# From your project root
cp -r /path/to/claude-playbook/.claude/ .claude/
```

Then customize `CLAUDE.md` with your project's commands, style, and architecture.

#### Option 2: Cherry-pick what you need

```bash
# Just the rules
mkdir -p .claude/rules
cp /path/to/claude-playbook/.claude/rules/code-quality.md .claude/rules/
cp /path/to/claude-playbook/.claude/rules/security.md .claude/rules/

# Just the skills
cp -r /path/to/claude-playbook/.claude/skills/ .claude/skills/
```

#### Option 3: Symlink for shared updates

```bash
# Rules stay in sync across all your projects
mkdir -p .claude
ln -s /path/to/claude-playbook/.claude/rules .claude/rules
```

---

## Customizing for Your Project

### Step 1: Edit `CLAUDE.md`

Replace the template commands with your actual build, test, and lint commands. Keep it under 80 lines — only include what Claude can't figure out by reading your code.

### Step 2: Make rules project-specific

The rules are intentionally generic. After copying, add your project's real file paths, class names, and patterns:

**Generic (template):**
> Use custom exception classes instead of framework-default exceptions

**Project-specific (customized):**
> Use `NotFoundError`, `BadRequestError`, `ForbiddenError` from `app/core/exceptions.py`. Handlers registered in `main.py:72-125` return `{"success": false, "error": {"code": "...", "message": "..."}}`

### Step 3: Remove what doesn't apply

- No database? Delete `database.md` and `alembic.md`
- No frontend? Delete `frontend.md` and `frontend-consistency.md`
- No LLM features? Delete `llm-prompts.md`

### Step 4: Add domain-specific rules

Create new files for your domain:

```bash
.claude/rules/
├── payments.md        # PCI compliance, transaction handling
├── ml-pipeline.md     # Model versioning, data validation
└── infrastructure.md  # Terraform conventions, deployment rules
```

### Step 5: Scope rules to specific paths (optional)

Rules can target specific file types using YAML frontmatter:

```markdown
---
paths:
  - "src/api/**/*.ts"
  - "src/services/**/*.ts"
---

# Backend API Rules
These rules only apply when Claude works with backend files.
```

---

## Rules Reference

### Core Principles
| File | What it enforces |
|------|-----------------|
| `code-quality.md` | No dead code, no bandaid fixes, root-cause solutions only, no over-engineering |
| `engineering-principles.md` | DRY, YAGNI, KISS, Single Responsibility, code smell recognition, naming conventions, composition over inheritance, dependency injection |
| `architecture.md` | Separation of concerns, dependency direction (inward), single source of truth, module boundaries, interface contracts |

### Backend
| File | What it enforces |
|------|-----------------|
| `api-design.md` | REST resource naming, consistent response envelope, pagination strategy, HTTP status codes, request validation, API versioning |
| `error-handling.md` | Custom exception classes, structured error responses, no silent swallowing, error context in logs, fail fast at boundaries |
| `security.md` | OWASP top 10 prevention, secrets in env vars only, auth on all mutations, parameterized queries, CORS whitelisting, dependency auditing |
| `database.md` | One model per table, constraints at DB level, no N+1 queries, eager loading, transactions for multi-table writes, connection pooling |
| `alembic.md` | Idempotent migrations, reversible up/down, dangerous operation safety, enum handling, migration workflow |

### Frontend
| File | What it enforces |
|------|-----------------|
| `frontend.md` | Single API client, Zustand/store patterns, TypeScript strictness, error display to users, controlled forms, centralized routing |
| `frontend-consistency.md` | Reuse before create, no bubble development, design system tokens only, visual consistency across pages, shared pattern extraction |

### Process
| File | What it enforces |
|------|-----------------|
| `testing.md` | Test pyramid (unit > integration > E2E), Arrange-Act-Assert, deterministic tests, regression tests for bugs, test isolation |
| `performance.md` | Profile before optimizing, batch queries, pagination everywhere, debounce inputs, lazy load routes, cache with TTL |
| `git-workflow.md` | Imperative commit messages, one change per commit, feature branches, small PRs, pre-commit lint/test |
| `llm-prompts.md` | Jinja2 templates in `prompts/` directory, versioned with comments, composable with includes, no hardcoded prompt strings |

---

## Skills Reference

Skills are invoked on demand with `/skill-name` in Claude Code.

| Skill | Invoke with | What it does |
|-------|-------------|-------------|
| `review` | `/review` | Reviews all uncommitted changes against project rules — run before committing |
| `fix-issue` | `/fix-issue 123` | Reads the GitHub issue, investigates the codebase, implements a fix, writes tests, creates a PR |
| `review-pr` | `/review-pr 456` | Reviews a PR for correctness, architecture, security, and test coverage with structured feedback |

### Creating your own skills

Add a directory with a `SKILL.md` to `.claude/skills/`:

```
.claude/skills/your-skill/
└── SKILL.md
```

Use `disable-model-invocation: true` in frontmatter for workflows with side effects that should only run when explicitly invoked.

---

## Agents Reference

Agents run in isolated context windows, keeping your main conversation clean.

| Agent | Purpose | Invoke with |
|-------|---------|-------------|
| `security-reviewer` | Audits code for injection, auth flaws, exposed secrets, insecure dependencies | "Use the security-reviewer agent to review these changes" |

### Creating your own agents

Add a markdown file to `.claude/agents/`:

```markdown
---
name: your-agent
description: What this agent specializes in
tools: Read, Grep, Glob, Bash
---

System prompt for the agent...
```

---

## Hooks Reference

Hooks run automatically at specific points in Claude's workflow. Unlike rules (advisory), hooks are **deterministic** — they execute every time, no exceptions.

| Hook | Trigger | What it does |
|------|---------|-------------|
| `lint-on-edit.sh` | After file edit | Runs the appropriate linter (ruff for Python, ESLint for JS/TS) |

Register hooks in `.claude/settings.json`:

```json
{
  "hooks": {
    "PostToolUse": [
      {
        "matcher": "Edit|Write",
        "command": ".claude/hooks/lint-on-edit.sh \"$TOOL_INPUT_FILE_PATH\""
      }
    ]
  }
}
```

---

## How Claude Code Memory Works

Understanding the hierarchy helps you put instructions in the right place:

```
Priority (highest to lowest):
┌─────────────────────────────────────────────────┐
│  .claude/rules/*.md    — Project rules (this repo)│
│  .claude/CLAUDE.md     — Project instructions     │
│  CLAUDE.md             — Project root instructions │
│  ~/.claude/rules/*.md  — User-level rules         │
│  ~/.claude/CLAUDE.md   — User global preferences  │
│  Auto memory           — Claude's own learnings   │
└─────────────────────────────────────────────────┘
```

- **Rules** = standards the whole team follows (checked into git)
- **CLAUDE.md** = project commands, style, architecture (checked into git)
- **CLAUDE.local.md** = personal overrides (auto-gitignored)
- **Auto memory** = Claude's notes from working sessions (local only)

More specific instructions take precedence over broader ones.

---

## For Repo Maintainers: Enabling the Template

After pushing this repo to GitHub, enable the template feature so others (or you) can create new repos from it with one click:

1. Go to your repo on GitHub
2. Click **Settings** (top navigation bar)
3. Under **General**, check **"Template repository"**
4. Save

That's it. The repo now shows a green **"Use this template"** button instead of the usual "Code" button. Anyone with access can create a new repo from it — no cloning, no manual copying.

You can also use the template via CLI without visiting GitHub:

```bash
gh repo create my-new-project --template YOUR_USERNAME/claude-playbook --public --clone
```

---

## Contributing

Contributions welcome. If you have rules that have proven valuable across real projects, open a PR.

Guidelines:
- Rules must be **generic and framework-agnostic** — no project-specific file paths or class names
- Each rule should prevent a **concrete, common problem** — not generic advice like "write clean code"
- Keep rules actionable: "Never query inside a loop" is enforceable; "Write performant code" is not
- One topic per file, descriptive filename

---

## License

[MIT](LICENSE) — use, modify, and distribute freely.
