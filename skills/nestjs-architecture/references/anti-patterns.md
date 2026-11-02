# Anti-patterns

## Business logic in controllers, resolvers, or gateways

Bad: order total calculation inside `orders.controller.ts`.
Cost: the queue processor and the GraphQL resolver cannot reuse it; testing needs HTTP.
Fix: controllers validate, authorize, call the service, map the response. Rules live in `orders.service.ts` or `order.policy.ts`.

## Reaching into another module

Bad: `OrdersService` injects `UsersRepository` or imports `user.entity.ts` for a query.
Cost: the users module can no longer change its storage; the DI graph hides the coupling.
Fix: import `UsersModule` and inject the service it exports. If you need data it does not expose, add a method to its public service.

## forwardRef as a habit

Bad: `forwardRef(() => OrdersModule)` on both sides to ship a feature.
Cost: the cycle is still there; init order bugs and untestable modules follow.
Fix: extract the shared concept into a third module both import, or invert with an event.

## @Global() by default

Bad: marking `UsersModule` global so nobody has to import it.
Cost: dependencies disappear from `imports:` arrays; tests must build the world.
Fix: reserve `@Global()` for true app-wide infra (config, logger). Features are always imported explicitly.

## A SharedModule dumping ground

Bad: `shared.module.ts` exporting twenty unrelated providers, imported everywhere.
Cost: every module depends on everything; no boundary survives.
Fix: one infra module per concern (`infra/redis/`, `infra/storage/`); `common/` holds only DI-free plumbing classes.

## process.env everywhere

Bad: `process.env.REDIS_URL` read inside a service.
Cost: no validation, no defaults, config drift between modules, broken tests.
Fix: `registerAs` config files colocated with their module; inject via `ConfigService` or `@Inject(databaseConfig.KEY)`. Validate once in `ConfigModule.forRoot`.

## Returning entities from controllers

Bad: `return this.usersRepository.findOne(id)` straight to JSON.
Cost: password hashes and internal columns leak the day someone adds one.
Fix: map to a response DTO or a `*.view.ts`, or use `ClassSerializerInterceptor` with `@Exclude/@Expose` on the entity.

## Single-module plumbing in common/

Bad: `common/filters/oidc-redirect.filter.ts` used only by the OIDC flow.
Cost: `common/` stops meaning "shared"; nobody dares delete anything in it.
Fix: keep it in `modules/auth/oidc/`. Promote to `common/` on the second consumer.

## utils/ and helpers/ folders

Bad: `src/utils/index.ts` with date, string, and crypto helpers.
Cost: an import magnet with no owner that every module silently couples to.
Fix: `<name>.util.ts` next to its main user; move a file to `common/` when a second module needs it.

## Double-registered global pipes

Bad: `app.useGlobalPipes(new ValidationPipe())` in `main.ts` and `APP_PIPE` in `app.module.ts`.
Cost: every request validates twice; options drift between the two copies.
Fix: one binding, as an `APP_PIPE` provider so it participates in DI. `main.ts` keeps only what needs no injection (adapters, swagger, listen).

## One module for the whole app

Bad: thirty controllers and services all registered in `app.module.ts`.
Cost: no feature boundaries, giant test modules, merge conflicts in one file.
Fix: one module per feature under `modules/`; `app.module.ts` only imports modules and binds global plumbing.
