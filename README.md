# project-structure-skills

A collection of agent skills, one per language or framework, that teach how to lay out a project: folder structure, file naming, module boundaries, where config and tests live, and how to grow from small to large without rewriting.

## Install

Install all skills:

```sh
npx skills add <owner>/project-structure-skills
```

Install a single skill:

```sh
npx skills add <owner>/project-structure-skills --skill <skill-name>
```

List available skills:

```sh
npx skills add <owner>/project-structure-skills --list
```

## Skills

| Skill | Level | Covers |
| ----- | ----- | ------ |
| [react-layered-architecture](skills/react-layered-architecture) | Small to mid | Plain React SPA (no meta-framework) grouped by technical layer: pages, components, hooks, services |
| [react-domain-architecture](skills/react-domain-architecture) | Mid to large | Plain React SPA grouped by business domain: `modules/` for domains, `core/` for shared infrastructure |
| [nextjs-layered-architecture](skills/nextjs-layered-architecture) | Small to mid | Full-stack Next.js App Router grouped by technical layer: components, actions, services, queries, db |
| [nextjs-domain-architecture](skills/nextjs-domain-architecture) | Mid to large | Full-stack Next.js App Router grouped by domain: route groups with `_components`, `_actions`, `_queries`, `_services`, with shared `components/`, `lib/`, `db/` outside `app/` |

## Naming

There are two kinds of skill:

- `<language>-project-structure`: language-level layout, independent of framework (for example `go-project-structure`).
- `<framework>-architecture`: framework-specific layout and boundaries (for example `nextjs-architecture`).

## Contributing

Copy `_template/`, fill it in, and validate with `npx skills add ./ --list`. See [CONTRIBUTING.md](CONTRIBUTING.md).

## License

[MIT](LICENSE)
