# GraphQL

Layout for `@nestjs/graphql` (Apollo driver). Default to code-first: decorators generate the schema.

## Setup

- Register `GraphQLModule.forRoot` in `app.module.ts`. If driver options grow (plugins, subscriptions, complexity), move setup to `infra/graphql/graphql.module.ts` with its own `graphql.config.ts`.
- `autoSchemaFile: join(process.cwd(), 'src/schema.gql')`. Commit the generated file so schema changes show up in diffs.

## Per-module layout

A resolver replaces or sits beside the controller; everything else is unchanged:

```
modules/posts/
  posts.module.ts
  posts.resolver.ts        # thin: delegates to the service
  posts.service.ts
  posts.repository.ts
  posts.loader.ts          # dataloaders for relation fields
  post.entity.ts           # DB entity
  post.model.ts            # @ObjectType exposed to the schema
  post.input.ts            # @InputType: CreatePostInput, UpdatePostInput
  post.args.ts             # @ArgsType for list filters/pagination
```

## Naming

- `*.resolver.ts` exporting `PostsResolver`; one resolver per object type.
- `*.model.ts` for `@ObjectType` classes, `*.input.ts` for `@InputType`, `*.args.ts` for `@ArgsType`. Suffix the classes: `PostModel` or `Post`, `CreatePostInput`, `ListPostsArgs`.
- Enums and shared scalars used by 2+ modules: `common/graphql/`.

## Rules

- Resolvers are controllers: validate, authorize, call the service, map. No business logic, no repository access.
- Do not decorate the DB entity with `@ObjectType` once the API and storage shapes diverge; keep `post.entity.ts` and `post.model.ts` separate and map in the service or resolver.
- Resolve relations with `@ResolveField` + a dataloader (`posts.loader.ts`, request-scoped) to avoid N+1. Never query inside a loop.
- Inputs are DTOs: `class-validator` rules apply through the global `ValidationPipe`.

## Guards, interceptors, filters

- HTTP guards break on GraphQL context. A shared guard calls `GqlExecutionContext.create(context)` to read the request; keep that adaptation inside the guard in `common/guards/` so both stacks use one class.
- Map errors in a GraphQL-aware filter or `formatError` in the driver config, not in resolvers.

## Subscriptions

- Enable in the driver config. Provide a `PubSub` instance from `infra/graphql/` (Redis-backed in multi-instance deployments) and inject it; do not instantiate `PubSub` per module.
- `@Subscription` methods live in the feature resolver next to the mutations that publish.

## Hybrid REST + GraphQL

Both can coexist in one app. A module may have both `posts.controller.ts` and `posts.resolver.ts`; they share the same service. Keep response envelopes (interceptors) REST-only — skip them for GraphQL paths.

## Schema-first

If the repo already has `.graphql` files and `typePaths`, it is schema-first: keep `.graphql` files next to their module, generate types into a single `src/graphql.ts` with the definitions factory, and do not mix in code-first decorators.
