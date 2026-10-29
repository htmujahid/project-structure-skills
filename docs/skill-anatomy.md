# Skill anatomy

Every skill in this repo has the same shape, so an agent reading any skill finds the same things in the same place. Language skills (`*-project-structure`) and framework skills (`*-architecture`) use the same anatomy. The difference is content, not shape.

## Tree

```
skills/<name>/
├── SKILL.md                 REQUIRED. Frontmatter + body under 150 lines, fixed section order
├── references/              REQUIRED. Deep material the agent reads on demand
│   ├── full-tree.md         REQUIRED. Complete annotated tree for a large project
│   ├── anti-patterns.md     REQUIRED. Each anti-pattern with bad example, cost, and fix
│   ├── growth-stages.md     REQUIRED. Prototype -> mid -> large: signals and concrete moves
│   └── <topic>.md           Optional. Any number of extra topic files
├── assets/                  OPTIONAL. Files copied into the project: starter files, feature modules, config
├── examples/                OPTIONAL. Small complete layouts as real file trees
├── scripts/                 OPTIONAL. Helpers such as a structure checker or scaffolder
├── evals/                   OPTIONAL. Prompts and expected outcomes
└── agents/
    └── openai.yaml          OPTIONAL. UI metadata for agents that read it
```

## Required

Identical in every skill, no exceptions.

### SKILL.md

- Frontmatter has `name`, `description`, and `license`. All three are non-empty. `name` matches the folder name.
- The body is under 150 lines.
- The section headings follow the order in `_template/SKILL.md`. Do not rename, reorder, or remove them.
- Link every file under `references/` that the agent is expected to read. Add a one-line note on when to read it.

### references/

Must contain `full-tree.md`, `anti-patterns.md`, and `growth-stages.md`. May contain additional topic files, for example `monorepo.md` or `testing.md`.

## Optional

Add a folder only when the framework or language needs it. Never add one empty.

| Folder | Use for | SKILL.md must say |
| ------ | ------- | ----------------- |
| `assets/` | Files the agent copies into the user project: a canonical feature module, config files, an env example. Put copyable files here, not in `references/`. | When to copy each one. |
| `examples/` | Small complete layouts at one or more sizes, as real file trees with minimal placeholder contents. | When to look at them. |
| `scripts/` | Helpers such as a structure checker or scaffolder. Must run with no setup beyond the framework's own toolchain. | The exact command to run. |
| `evals/` | Prompts and expected outcomes that test the skill triggers and produces the right layout. | That they exist, and how to run them if runnable. |
| `agents/openai.yaml` | UI metadata for agents that read it. | Nothing. Not read by the agent at run time. |

## Rules

- Everything a skill needs lives inside its own directory. Use no cross-skill relative paths. Refer to another skill by name only.
- `SKILL.md` links every file under `references/` that it expects the agent to read, with a one-line note on when to read it.
- `SKILL.md` mentions every optional folder. Remove unmentioned folders, since they are dead weight.
- Do not create empty folders or stub files in a real skill. Fill in the required references before merging.
