---
name: {NAME}
description: Use when creating, moving, or naming files and folders in a {FRAMEWORK} project. Covers directory layout, naming, module boundaries, config and test placement, and growth from prototype to large.
license: MIT
---

<!--
HOW TO FILL THIS TEMPLATE
1. Replace every {PLACEHOLDER}. {NAME} is the skill name (kebab-case),
   {FRAMEWORK} the language or framework, {VERSION} the version covered.
2. Replace each "Fill in:" line with real content, then delete the line.
3. Write short imperative sentences. Every rule must be actionable when an
   agent creates a file ("Put X in Y"), not descriptive.
4. Keep this file under 150 lines. Move full trees and long lists to
   references/. Link each reference with a one-line note on when to read it.
   Optional folders (assets/, examples/, scripts/, evals/) must be
   mentioned in this file or removed. See docs/skill-anatomy.md.
5. Delete this comment block when done.
Naming: `<language>-project-structure` or `<framework>-architecture`.
-->

# {FRAMEWORK} project structure

## Target version

Written for {FRAMEWORK} {VERSION} on {DATE}.
Fill in: version covered, date, and any version-specific behavior that changes layout.

## Follow the repo first

Read the existing tree before creating files. If the project already has conventions, use them, even where they differ from this skill.
Fill in: what to check first (config files, existing folders, lint rules).

## Default directory layout

```
{ROOT}/
  {folder}/   # one-line rationale
```

Fill in: the tree, with one line of rationale per top-level folder.
Read [references/full-tree.md](references/full-tree.md) when you need the expanded tree with every subfolder.

## Naming conventions

- Files: Fill in.
- Exports: Fill in.
- Modules / components: Fill in.
- Routes: Fill in.
- Tests: Fill in.

## Dependency direction

Fill in: which layers may import which. State the allowed direction as a rule, for example "Features import shared. Shared never imports features."

## Where things live

- Config: Fill in.
- Env vars: Fill in.
- Shared types: Fill in.
- Global state: Fill in.

## Tests

Fill in: where tests go (colocated or mirrored tree), file naming pattern, and where fixtures and helpers live.

## Structure at three sizes

Read [references/growth-stages.md](references/growth-stages.md) when deciding whether to restructure.

### Prototype

Fill in: the minimal layout, when it is enough.

### Mid-size

Fill in: the layout to adopt next.
Signal to move up: Fill in a concrete, checkable trigger (file count, team size, duplicated code).

### Large

Fill in: the layout for scale.
Signal to move up: Fill in a concrete trigger.

Grow by moving files, not by rewriting them. Fill in: how to migrate between sizes.

## Anti-patterns

Fill in 5 to 10 rules. Read [references/anti-patterns.md](references/anti-patterns.md) when reviewing a layout or before moving files.

- Do not Fill in.
- Do not Fill in.
- Do not Fill in.
- Do not Fill in.
- Do not Fill in.
