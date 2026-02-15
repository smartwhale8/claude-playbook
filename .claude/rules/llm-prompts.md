# LLM Prompt Management

Standards for organizing, versioning, and maintaining LLM prompts in applications.

## Jinja2 Templates for Prompts

- Store all LLM prompts as Jinja2 template files (`.j2` or `.jinja2` extension) — never hardcode prompts as string literals in application code
- Template location: `prompts/` directory at the project root, organized by feature:
  ```
  prompts/
  ├── coach/
  │   ├── system.j2
  │   ├── workout_plan.j2
  │   └── nutrition_advice.j2
  ├── moderation/
  │   ├── content_review.j2
  │   └── toxicity_check.j2
  └── summarization/
      └── thread_summary.j2
  ```
- This enables: version control diffs, code review of prompt changes, template reuse, and clear separation of prompts from code

## Template Structure

Each template should have a clear structure:

```jinja2
{#- Feature: Coach workout planning -#}
{#- Model: claude-sonnet-4-5-20250929 -#}
{#- Version: 1.2 -#}

You are a fitness coach helping {{ user_name }} plan their workouts.

{% if fitness_level %}
The user's fitness level is: {{ fitness_level }}
{% endif %}

{% if goals %}
Their goals are:
{% for goal in goals %}
- {{ goal }}
{% endfor %}
{% endif %}

{{ instructions }}
```

- Header comment: feature name, target model, version
- Use Jinja2 variables (`{{ }}`) for dynamic content — user data, context, retrieved information
- Use conditionals (`{% if %}`) for optional sections — don't include empty sections
- Use loops (`{% for %}`) for lists of items — examples, goals, history entries

## Prompt Versioning

- Prompt changes are code changes — they go through the same review process as application code
- Use meaningful commit messages for prompt changes: "Improve coach tone for beginner users" — not "update prompt"
- When a prompt change significantly affects behavior, note it in the PR description
- Keep a version comment in each template header to track iterations

## Prompt Composition

- Break large prompts into reusable partials using Jinja2 includes:
  ```jinja2
  {% include "common/safety_guidelines.j2" %}
  {% include "common/output_format.j2" %}
  ```
- System prompts, user message templates, and output format instructions should be separate templates
- Shared instructions (safety, formatting, tone) live in `prompts/common/` and are included where needed

## Variables and Context

- Define a clear interface for each template: document what variables it expects
- Use Jinja2's `default` filter for optional variables: `{{ tone | default("friendly") }}`
- Never pass unsanitized user input directly into prompt templates — escape or validate first
- Keep template variables typed in the application code that renders them

## Anti-Patterns

- Never concatenate prompts with f-strings or `+` in application code — use Jinja2 templates
- Never store prompts in database rows or environment variables — they belong in version-controlled files
- Never duplicate prompt text across templates — extract shared sections into includes
- Don't over-engineer prompt pipelines — a simple `jinja2.Environment` with `FileSystemLoader` is sufficient for most projects
