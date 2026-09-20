---
paths:
  - "**/*.{tsx,jsx,vue,svelte,css,scss}"
  - "**/components/**/*"
---

# Frontend Consistency

<!-- Path-scoped. Loads only when Claude opens a UI file. -->
<!-- Why this rule exists: Claude builds each screen correctly and each one slightly -->
<!-- differently. Nothing in the code says "this already exists". This does. -->
<!-- Added 2026-02-15, scoped and trimmed 2026-09-20. -->

## Search before building

- Before creating a component, search the codebase for one that already does something similar. Search by what it does, not by what it might be called.
- If an existing component does most of the job, add a prop. Do not build a parallel version.
- When the same pattern appears in a second place, extract it and change both call sites.

These are each built once: search input with debounce, user row with avatar, confirmation dialog, empty state, page header, paginated list wrapper.

## Match what is already there

- Open the closest existing page side by side and match its card padding, heading sizes, gaps, and button placement.
- Use the design system's tokens. Never a hardcoded hex value, never `gap-[13px]`, never an arbitrary font size.
- The component library is the authority. Extend its components with a wrapper or a variant rather than hand-building an alternative.

## Consistency across pages

- Similar pages share a layout. Lists share a row component.
- Loading looks the same everywhere. Pick a spinner or a skeleton and use it throughout.
- Empty states and error states each follow one pattern.
- Changing a shared pattern means updating every instance, not only the screen in front of you.
