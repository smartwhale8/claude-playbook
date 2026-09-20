# Engineering Principles

<!-- Core rule. Loads in every session. Added 2026-02-15, cut from 749 to ~180 words -->
<!-- on 2026-09-20. The removed material restated DRY, YAGNI, KISS and SRP, which the -->
<!-- model already applies without being told. What remains is the judgement calls it -->
<!-- gets wrong: when NOT to extract, and where to stop validating. -->

## When to extract, and when not to

- The test for duplication: if one copy changes, must the other change too? If yes, extract it. If no, they are independent and stay separate.
- Two functions that merely look alike are not duplication. Merging them couples two things that have no reason to change together.
- Code that needs five parameters and three flags to serve different callers is not reusable. It is coupled.

## Validate at the boundary only

- Validate at system boundaries: user input, API requests, responses from external services, file reads.
- Inside those boundaries, trust the data. Re-validating in every internal function hides the business logic in noise.

## Signatures

- A function name containing "and" is doing two things. Split it.
- Multiple boolean parameters make call sites unreadable. `fn(true, false, true)` should be named options or separate functions.
- Dependencies arrive as parameters. A function that constructs its own dependencies cannot be tested.
