# Request lifecycle plumbing

Where middleware, guards, interceptors, pipes, filters, and custom decorators live, how to bind them, and in what order they run.

## Execution order

```
middleware -> guards -> interceptors (pre) -> pipes -> handler
           -> interceptors (post) -> exception filters
```

Among multiple bindings of the same kind: global first, then controller, then handler. Filters run in reverse (handler-level catches first). An exception thrown anywhere after middleware is handled by filters.

## Placement rule

- Used by 2+ modules: `common/<kind>/`.
- Used by one module: inside that module (`modules/auth/oidc/oidc-redirect.filter.ts`).
- Belongs to a technical capability: inside its infra module (`infra/rate-limit/` owns the throttler guard setup).

## Binding

Bind global plumbing as providers in `app.module.ts` so DI works:

```ts
providers: [
  { provide: APP_PIPE, useClass: ValidationPipe },
  { provide: APP_GUARD, useClass: ThrottlerGuard },
  { provide: APP_INTERCEPTOR, useClass: ResponseEnvelopeInterceptor },
  { provide: APP_FILTER, useClass: AllExceptionsFilter },
]
```

Use `app.useGlobalPipes(...)` in `main.ts` only for instances that need constructor arguments but no injection. Never register the same thing in both places. Bind narrower scopes with `@UseGuards`, `@UsePipes`, `@UseInterceptors`, `@UseFilters` on the controller or handler.

## Middleware

- Lives in `common/middleware/`, named `request-id.middleware.ts`.
- Class middleware (`NestMiddleware`) when it needs DI; a plain function otherwise.
- Register in the module's `configure(consumer: MiddlewareConsumer)` — usually `AppModule`. There is no global DI token for middleware.
- Use middleware only for raw request concerns (request id, raw-body capture, low-level logging). If it needs to know the route or user, it is a guard or interceptor.

## Guards

- Implement `CanActivate`. Name `jwt-auth.guard.ts`, class `JwtAuthGuard`.
- Auth guard is global (`APP_GUARD`); opt out per route with a `@Public()` metadata decorator read via `Reflector`.
- Role and policy checks: a guard reads metadata (`@Roles('admin')`); the rules themselves live in a `*.policy.ts` in the owning module so they are unit-testable without a request.
- Order matters: when two global guards exist, register authentication before authorization.

## Interceptors

- Implement `NestInterceptor`. Name `response-envelope.interceptor.ts`.
- Use for: logging/timing, response mapping (envelopes), serialization (`ClassSerializerInterceptor`), timeouts, caching.
- Pair a global interceptor with an opt-out metadata decorator in the same folder (`skip-envelope.decorator.ts`).

## Pipes

- Global `ValidationPipe` with `{ whitelist: true, transform: true }` bound via `APP_PIPE`.
- DTO validation rules live on the DTO classes (`class-validator`), in the module's `*.dto.ts`. On NestJS 12 a Standard Schema (e.g. zod) passed to `@Body()` works too; pick one style per repo.
- Custom pipes in `common/pipes/` only when reused (`trim-strings.pipe.ts`); a one-off parse pipe sits next to its controller.
- Prefer built-ins (`ParseIntPipe`, `ParseUUIDPipe`) inline in the param decorator over custom pipes.

## Exception filters

- Global `AllExceptionsFilter` in `common/filters/` shapes every error response (and logs).
- Narrow filters translate a specific error class: `query-failed.filter.ts` maps database unique-violation to 409.
- A filter for one flow lives in that module: an OIDC filter that redirects instead of returning JSON belongs in `modules/auth/oidc/`.

## Custom exceptions

- Extend `HttpException`. Name `duplicate-value.exception.ts`, class `DuplicateValueException`.
- Shared across modules: `common/errors/`. Specific to a feature: in that module.
- Services throw these; controllers and filters translate. Never throw raw strings or generic `Error` across a module boundary.

## Custom decorators

- `common/decorators/`, one per file.
- Param decorators (`current-user.decorator.ts`) extract from the request what a guard attached.
- Metadata decorators wrap `SetMetadata` (`public.decorator.ts`, `roles.decorator.ts`) and are read by a guard or interceptor with `Reflector`. Keep the decorator and its reader's key constant in one file.
