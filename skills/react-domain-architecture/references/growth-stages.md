# Growth stages

## Prototype

Do not use modules yet. Use the `react-layered-architecture` skill, or a flat `src/`.
Move up when: there are 3+ distinct business areas, or more than one person works on the app.

## Mid-size

```
src/
  core/
  modules/
    auth/
    invoices/
    customers/
```

Use 2 to 6 modules. Keep each module flat until it passes about 8 files, then add `pages/`, `components/`, `hooks/`, `queries/`, `types/`.
Move up when any of these is true:

- A module passes about 20 files.
- Two teams edit the same module.
- Modules import each other's internal files.

## Large

- Give big modules subfolders.
- Split a module that holds two domains into two modules.
- Enforce boundaries with lint rules: no `core -> modules`, no deep module imports.
- Extract `core/` into a workspace package only when a second app needs it.

Moves, one at a time:

1. Add the lint rule and fix violations.
2. Add `index.ts` to every module and switch outside imports to it.
3. Split the module. Move files, then update imports.
4. The app keeps working after each step.
