# Anti-patterns

## Fetching inside components

Bad: `useEffect(() => { fetch('/api/users') ... })` in `user-list.tsx`.
Cost: no reuse, hard to test, duplicated error handling.
Fix: write the request and a `useUsers` hook in `queries/user.queries.ts`, and call the hook.

## Inline query keys

Bad: `useQuery({ queryKey: ['users', id] })` in two files.
Cost: invalidation misses entries when keys drift.
Fix: define `userKeys` in `queries/user.queries.ts` and use it everywhere, including `invalidateQueries`.

## Upward imports

Bad: `components/header.tsx` imports from `pages/`.
Cost: circular dependencies and tangled layers.
Fix: pass data in via props, or move the shared code down a layer.

## Everything in components/

Bad: 80 files in `components/`, half used by one page.
Cost: nothing is findable and ownership is unclear.
Fix: keep single-page components beside that page. Group the rest into subfolders.

## Catch-all folders

Bad: `common/`, `misc/`, `helpers/`.
Cost: they become a dumping ground.
Fix: name the folder by role (`utils/`, `hooks/`) or by what it holds.

## Barrels everywhere

Bad: an `index.ts` re-exporting every file in every folder.
Cost: slow builds, circular imports, unclear origins.
Fix: import files directly. Add a barrel only where there is a deliberate public surface.

## Server data in local or global state

Bad: copying query results into `useState` or `store/`.
Cost: stale copies and manual cache logic.
Fix: read data from the query hook. Keep `store/` for client-only state.

## Mixed file casing

Bad: `UserCard.tsx` beside `use-users.ts`.
Cost: case-insensitive file systems hide rename bugs that fail on Linux CI.
Fix: use kebab-case for every file and folder. Keep PascalCase for component names in code.

## Deep relative imports

Bad: `import { Button } from '../../../components/ui/button'`.
Cost: moving a file breaks imports.
Fix: use `@/components/ui/button`.
