---
paths:
  - "**/prompts/**/*"
  - "**/*.{j2,jinja,jinja2}"
---

# LLM Prompt Management

<!-- Path-scoped to prompt files. Before 2026-09-20 this loaded in every session, -->
<!-- including projects with no LLM calls at all. Delete this file if that is yours. -->
<!-- Added 2026-02-15, scoped 2026-09-20. -->

## Prompts are files, not string literals

- Every prompt is a template file under `prompts/`, organised by feature.
- No f-strings, no concatenation, no prompts in database rows or environment variables.
- This is what makes a prompt change reviewable in a diff.

```
prompts/
├── common/
│   ├── safety_guidelines.j2
│   └── output_format.j2
└── coach/
    ├── system.j2
    └── workout_plan.j2
```

## Template structure

```jinja2
{#- Feature: coach workout planning -#}
{#- Model: claude-sonnet-5 -#}
{#- Version: 1.2 -#}

You are a fitness coach helping {{ user_name }} plan their workouts.

{% if goals %}
Their goals are:
{% for goal in goals %}
- {{ goal }}
{% endfor %}
{% endif %}
```

- Header comment records the feature, the target model, and the version.
- Conditionals keep empty sections out of the rendered prompt.
- Shared instructions live in `prompts/common/` and are pulled in with `{% include %}`.

## Handling

- Document the variables each template expects, and type them where they are rendered.
- Use the `default` filter for optional values.
- Validate or escape user input before it reaches a template.
- A `jinja2.Environment` with a `FileSystemLoader` is enough. Do not build a prompt framework.
