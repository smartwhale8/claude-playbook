# Frontend Consistency

Rules to prevent component drift, visual patchwork, and reinventing what already exists.

## Reuse Before Create

- Before building any new component, **search the codebase** for existing components that do something similar — search by functionality, not just name
- If an existing component does 80% of what you need, extend it with props — don't create a parallel version
- If two components share the same core pattern (e.g., search modal with debounced input, user list with avatars, confirmation dialog), extract a shared component and have both use it
- When building a feature-specific component, ask: "Could another feature need this?" If yes, build it as a general-purpose component from the start and place it in the shared components directory
- Keep a mental (or actual) inventory of what exists: common patterns like search inputs, user pickers, empty states, loading skeletons, confirmation dialogs, list items with avatars — these should each be built once

## No Bubble Development

- Every new component must visually match the rest of the application — same spacing, same card styles, same button variants, same typography scale
- Before styling a new page or section, open an existing similar page side-by-side and match: card padding, header sizes, gap between elements, button placement, empty state messaging
- Never hardcode colors, font sizes, spacing, or border radius — always use the design system's tokens/variables (Tailwind classes, CSS variables, theme tokens)
- If you find yourself writing custom CSS or inline styles for basic layout and visual properties, you're likely diverging — use the established utility classes and component library props instead

## Design System as Source of Truth

- The component library (HeroUI, MUI, Chakra, Shadcn, etc.) is the authority on how things look and behave — use its components and their built-in props before building custom alternatives
- Spacing scale: use the system's spacing tokens consistently (e.g., `gap-3`, `p-4`, `space-y-2`) — don't invent sizes like `gap-[13px]` or `mb-[22px]`
- Color palette: use semantic color tokens (`primary`, `danger`, `default-400`) — never hardcode hex values or use one-off colors that don't exist in the theme
- Typography: use the established size scale (`text-sm`, `text-lg`) — don't mix in arbitrary sizes
- Border radius, shadows, transitions: use the system's defaults — custom values create subtle visual inconsistency that accumulates

## Pattern Consistency Across Pages

- Similar pages must follow the same layout pattern: if settings pages use single-column `max-w-xl` with cards, every settings-like page does the same
- Lists of items should use the same row component or at minimum the same visual structure: avatar size, name/subtitle placement, action button position
- Empty states should look the same everywhere: same illustration style (or icon), same text size, same vertical positioning
- Loading states should be consistent: if one list uses a centered Spinner, all lists use a centered Spinner — don't mix spinners, skeletons, and shimmer across pages
- Error states should follow one pattern: same color (danger), same text size, same position relative to the failed action

## Shared Patterns to Extract

When you see these patterns appearing in more than one place, extract them:

- **User search with debounce**: One shared component that accepts `onSelect`, `placeholder`, and optional `filter` — not rebuilt per feature
- **User row / user card**: Avatar + name + subtitle + optional action — one component, used everywhere users are listed
- **Confirmation dialog**: "Are you sure?" modal with configurable title, message, confirm/cancel actions — not a new modal per feature
- **Empty state**: Icon + title + description + optional action button — one component, not custom JSX per page
- **Page header**: Title + optional subtitle + optional action buttons — consistent across all pages
- **List with pagination/infinite scroll**: Shared wrapper that handles loading more, empty state, and error state

## Preventing Drift Over Time

- When modifying an existing pattern (e.g., changing how cards look), update ALL instances — not just the one you're working on. Partial updates create visual inconsistency.
- When adding a new page, start by copying the structure of the most similar existing page — then modify. Don't start from scratch.
- If the design system's component doesn't do what you need, extend it properly (wrapper component, custom variant) — don't replace it with a hand-built alternative in one place
- Periodically review: if the same visual pattern exists in 3+ places with slight variations, consolidate into one shared component and refactor all usages

## Anti-Patterns

- Building a search input from scratch when the same debounced-search-with-results pattern exists in another component
- Using different card padding (`p-3` in one place, `p-5` in another, `p-4` elsewhere) across the same type of content
- Creating a custom modal for each feature instead of using a shared configurable modal
- Hardcoding `className="text-[#8b8b8b]"` instead of using `text-default-400` from the theme
- Building a user avatar + name display inline with raw JSX when a `UserRow` or `UserChip` component already exists (or should exist)
- Each page inventing its own loading/error/empty states instead of using shared components
- Using `fetch` or raw `axios` in one component while the rest of the app uses the shared API client
