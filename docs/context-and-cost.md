# Context and cost

Almost every practice in this playbook follows from one constraint: Claude's
context window fills fast, and quality degrades as it fills. Instructions get
lost, earlier decisions get forgotten, and mistakes increase. Tokens are the
bill; context is the reason the work gets worse.

## See where it goes

| Command | Shows |
|---|---|
| `/context` | What is in the window now, by source. Start here. |
| `/usage` | Token counts, cost, and a breakdown by skill, subagent, plugin, and MCP server. |
| `/skill-doctor` | Per-skill context cost and which skills have never fired. |
| `/doctor` | Proposed cuts to CLAUDE.md for content derivable from the code. |
| `/insights` | An HTML report on how your recent sessions actually went. |

Run `/context` once on your own project before changing anything. The number is
usually a surprise.

## Session habits

**Clear between unrelated tasks.** `/clear` is the highest-value habit. Stale
context from a finished task costs tokens on every subsequent message and
distracts from the current one. Use `/rename` first if you want to come back.

**Stop early when it goes wrong.** `Esc` interrupts and preserves context.
`Esc Esc` or `/rewind` restores the conversation, the code, or both.

**Two corrections is the limit.** After correcting the same mistake twice, the
window holds two failed approaches that will shape the third. Clear and rewrite
the prompt with what you learned. A clean session with a better prompt beats a
long session with accumulated corrections, almost every time.

**Compact with instructions.** `/compact Focus on the API changes` tells Claude
what to preserve. You can also set standing instructions in CLAUDE.md:

```markdown
## Compact instructions
When compacting, preserve the full list of modified files and the test commands.
```

**Ask aside.** `/btw` answers a question without adding it to history.

## Structural savings

These are worth more than the session habits, because they apply to every
session automatically.

**Scope your rules.** A rule without `paths:` frontmatter loads in every
session. Restructuring this playbook's rules cut its always-loaded footprint
from about 9,400 tokens to about 1,700, with no rule removed. See
[choosing a component](choosing-a-component.md).

**Move procedures into skills.** A skill's body loads only when the skill runs.
Its description loads always, so keep descriptions to one sentence.

**Delegate reading.** A subagent's forty file reads stay in the subagent. Only
the summary comes back. The `explorer` agent here runs on Haiku, because reading
and summarizing does not need a frontier model.

**Prefer a CLI over an MCP server.** `gh`, `aws`, `gcloud`, and `sentry-cli` add
nothing to context. An MCP server adds tool names for every tool it exposes,
even with schemas deferred. Run `/mcp` and disable what you are not using.

**Filter output in a hook.** Instead of Claude reading a 10,000-line log, a
`PreToolUse` hook can rewrite the command to grep for errors first. That is tens
of thousands of tokens down to hundreds.

## Model and effort

Model and effort are separate choices.

| | Use for |
|---|---|
| Haiku 4.5 | Reading, summarizing, mechanical edits |
| Sonnet 5 | Most coding |
| Opus 5 | Architecture, hard debugging, security review |
| Fable 5.1 | The longest and hardest runs |

Effort runs `low`, `medium`, `high`, `xhigh`, `max`, set with `/effort` or the
slider in `/model`. Thinking tokens bill as output, and the default budget can
reach tens of thousands per request, so lowering effort on routine work is a
direct saving.

For subagents, set `model:` per agent. `CLAUDE_CODE_SUBAGENT_MODEL` supplies a
default only for agents that name no model, and does not reach the built-in
`Explore` and `Plan` agents. `CLAUDE_CODE_SUBAGENT_MODEL_FORCE=1` overrides every
definition. Leaving every subagent on your session model is a common way to
overspend.

## Caps for unattended runs

```bash
claude -p "..." --max-turns 10 --max-budget-usd 2.00
```

`--output-format json` returns `total_cost_usd` per invocation, so a script can
track its own spend.

## Where the cost actually comes from

Long sessions dominate. Claude Code sends the whole conversation with every
request, so a one-line question in a session that has been open all day still
draws on the entire history. The prompt cache reduces the rate, not the volume,
and a break longer than the cache lifetime misses it entirely.

This is the same reason `/clear` is the first recommendation. It is a quality
measure that happens to be the largest cost measure too.
