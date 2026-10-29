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

## Naming

There are two kinds of skill:

- `<language>-project-structure`: language-level layout, independent of framework (for example `go-project-structure`).
- `<framework>-architecture`: framework-specific layout and boundaries (for example `nextjs-architecture`).

## Contributing

Copy `_template/`, fill it in, and validate with `npx skills add ./ --list`. See [CONTRIBUTING.md](CONTRIBUTING.md).

## License

[MIT](LICENSE)
