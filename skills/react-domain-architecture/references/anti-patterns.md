# Anti-patterns

## core importing modules

Bad: `core/ui/header.tsx` imports `modules/auth`.
Cost: core is no longer reusable, and cycles appear.
Fix: pass data through props or context set up in `core/app`. Compose in `core/app`.

## Deep imports across modules

Bad: `import { InvoiceTable } from '@/modules/invoices/components/invoice-table'`.
Cost: internals become public, so refactors break other modules.
Fix: export it from `modules/invoices/index.ts` if it is truly shared, then import from `@/modules/invoices`.

## A shared/common folder

Bad: `modules/shared/` or `src/common/`.
Cost: a second core with no rules.
Fix: generic code goes in `core/`. Domain code goes in its owning module.

## Domain logic in core

Bad: `core/lib/calculate-invoice-total.ts`.
Cost: core fills with domain code and modules lose ownership.
Fix: move it to `modules/invoices/`.

## One module per page

Bad: `modules/invoice-list/`, `modules/invoice-detail/`.
Cost: a domain is split and its parts import each other's internals.
Fix: one `invoices` module with two pages.

## Barrel that exports everything

Bad: `index.ts` with `export *` from every file.
Cost: no real public API, circular imports, bigger bundles.
Fix: export only what other modules or `core/app` use.

## Premature extraction to core

Bad: moving a component to `core/ui` because two modules use it.
Cost: core fills with one-off code.
Fix: wait for a third user and a domain-free meaning, or compose in a page.

## Mixed file casing

Bad: `InvoiceTable.tsx` beside `use-invoices.ts`.
Cost: case-insensitive file systems hide rename bugs that fail on Linux CI.
Fix: use kebab-case for every file and folder. Keep PascalCase for component names in code.

## Cross-module state through globals

Bad: module A writes to a global store that module B reads.
Cost: hidden coupling.
Fix: B's public API accepts the value, or `core/app` wires them together.
