# Contributing

Every skill follows the structure defined in [docs/skill-anatomy.md](docs/skill-anatomy.md). Read it before adding a skill.

## Add a skill

1. Copy `_template/` to `skills/<name>/`, or run `scripts/new-skill.sh <name>`.
   Use `<language>-project-structure` or `<framework>-architecture` for `<name>`.
2. Make sure the `name` in `SKILL.md` frontmatter matches the folder name.
3. Fill in every section and replace all `{PLACEHOLDERS}`. Follow the comment block at the top of the template, then delete it.
4. Keep the `SKILL.md` section headings and order unchanged. Keep `SKILL.md` under 150 lines.
5. Fill in the three required reference files: `references/full-tree.md`, `references/anti-patterns.md`, `references/growth-stages.md`. Link each from `SKILL.md` with a note on when to read it.
6. Add optional folders (`templates/`, `examples/`, `scripts/`, `evals/`, `agents/openai.yaml`) only if needed. Never add them empty, and mention each one in `SKILL.md`.
7. Keep the skill self-contained. Refer to other skills by name, never by relative path.
8. Validate: `npx skills add ./ --list`. Your skill must appear in the output.
9. Add a row to the Skills table in `README.md`.
10. Open a pull request. CI runs the same validation.

## Style

- Short imperative sentences.
- Every rule must be something an agent can act on when creating a file.
