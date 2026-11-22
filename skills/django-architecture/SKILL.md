---
name: django-architecture
description: Use when creating, moving, or naming files in a Django project built from separate apps, with or without Django REST Framework (class-based or function-based). Covers project package, settings split, one-app-per-domain layout, models, services and selectors, views, forms, templates, DRF serializers and viewsets, admin, signals, management commands, Celery, Channels, migrations, tests, and growth from prototype to large.
license: MIT
---

# Django architecture

Django project organized as small, focused apps. The project package (`config/`) holds only wiring. Each business domain is one app under `apps/`. Shared non-domain code lives in `core/`. One project can serve HTML pages, a DRF API, WebSockets, and background workers from this layout.

## Target version

Written for Django 5.2 LTS and 6.0 with Django REST Framework 3.16+ (Python 3.12+) on 2026-11-22. Django 6 adds built-in background tasks, CSP middleware, and template partials; none change the layout. Apps, settings, and URL conventions are stable across both.

## Follow the repo first

Read the tree before creating files. Check `manage.py` for `DJANGO_SETTINGS_MODULE`, `INSTALLED_APPS` for how apps are named (`apps.users` vs `users`), `AUTH_USER_MODEL`, and whether views and DRF code are class-based or function-based. If the repo keeps apps at the top level, follow that until the move in growth stages.

## Default directory layout

```
manage.py
pyproject.toml          # deps, ruff, pytest config
.env.example            # every env var, no secrets
config/                 # project package: wiring only, no business code
  settings/             # base.py, local.py, production.py, test.py
  urls.py  asgi.py  wsgi.py  celery.py
apps/                   # one app per business domain
  users/
    apps.py  models.py  admin.py  services.py  selectors.py
    forms.py  views.py  urls.py  signals.py  tasks.py
    api/                # DRF layer: serializers, views, urls, permissions
    migrations/  tests/  management/commands/  templates/users/
core/                   # shared, domain-free: base models, mixins, pagination, utils
templates/              # project-wide layouts: base.html, errors, partials
static/                 # project-wide assets
locale/                 # translation catalogs
```

Read [references/full-tree.md](references/full-tree.md) when you need the expanded tree. Read [references/app-anatomy.md](references/app-anatomy.md) before adding a file to an app or splitting a file into a package.

- Create an app with `python manage.py startapp users apps/users`, then set `name = "apps.users"` and `label = "users"` in `apps.py`.
- Add a file on first use. Do not create empty ones. An app starts with `apps.py`, `models.py`, `migrations/`, and grows.
- One app = one domain noun or capability (`orders`, `billing`, `notifications`). Never one app for the whole site, never one app per model.
- Turn `models.py`, `views.py`, `tests.py` into packages only past ~300 lines or ~5 classes of one kind.

## Naming conventions

- Apps, modules, folders: lowercase snake_case, plural domain nouns: `apps/orders/`, `order_items`. Python modules are never kebab-case.
- Models: singular PascalCase (`Order`, `OrderItem`); tables stay Django default `orders_order`. Fields snake_case. Related names plural: `related_name="items"`.
- Files by role: `models.py`, `services.py`, `selectors.py`, `forms.py`, `admin.py`, `signals.py`, `tasks.py`, `urls.py`, `permissions.py`, `filters.py`, `consumers.py`, `managers.py`.
- Views: `OrderListView`, `OrderDetailView` (CBV); `order_list`, `order_detail` (FBV). DRF: `OrderViewSet`, `OrderSerializer`, `OrderCreateSerializer`.
- URL names: `app_name = "orders"` and names `list`, `detail`, `create`: reversed as `orders:detail`.
- Templates: `templates/<app>/<model>_<action>.html` inside the app, namespaced by app folder: `orders/order_detail.html`. Partials start with `_`: `_order_row.html`.
- Settings: UPPER_SNAKE. Env vars prefixed by purpose: `DATABASE_URL`, `DJANGO_SECRET_KEY`.
- Tests: `tests/test_<module>.py`, functions `test_<behavior>`; factories in `tests/factories.py`.

## Dependency direction

```
config -> apps -> core
```

- `core/` imports from no app. `config/` imports from apps only in `urls.py` and settings lists.
- Inside an app: `views / api / admin / tasks / signals -> services, selectors -> models`. Models import nothing from views, forms, or services.
- An app reaches another app through its public `services.py` and `selectors.py`, never its views or private helpers. Foreign keys use string refs: `"billing.Invoice"`.
- Two apps that need each other mean a missing concept. Extract a third app, or decouple with a signal or event.
- Business rules live in `services.py` (writes) and `selectors.py` (reads). Views, serializers, admin actions, tasks, and commands all call them.

## API style: class-based or function-based

Read [references/drf-api.md](references/drf-api.md) before the first DRF file and whenever choosing a view style.

- Pick ONE style per project and write it down in the repo's README or CLAUDE.md. Do not mix styles within an app.
- Class-based (default): `ModelViewSet` + `DefaultRouter` for resources; generics or `APIView` for custom endpoints.
- Function-based: `@api_view` + `@permission_classes` functions with explicit `urlpatterns`; fits small, RPC-like APIs.
- Same rule for HTML: CBV (`ListView`, `CreateView`) or FBV, not both.
- Both styles share everything else: `serializers.py`, `permissions.py`, `filters.py`, services, selectors, URL names.

## Where things live

Read the matching reference before the first file of each kind:

- [references/data-layer.md](references/data-layer.md): models, managers, querysets, services, selectors, signals, transactions, migrations, custom user.
- [references/settings-and-config.md](references/settings-and-config.md): settings split, env, middleware, logging, cache, storage, security, i18n, ASGI/WSGI.
- [references/templates-and-html.md](references/templates-and-html.md): views, forms, templates, template tags, context processors, static, htmx.
- [references/admin-and-commands.md](references/admin-and-commands.md): admin, management commands, system checks, fixtures.
- [references/async-and-realtime.md](references/async-and-realtime.md): Celery or Django tasks, periodic jobs, Channels consumers, async views.
- [references/testing.md](references/testing.md): pytest-django layout, factories, API tests, e2e.

Quick rules: URL includes in `config/urls.py` only (`path("orders/", include("apps.orders.urls"))`, `path("api/v1/", include("apps.orders.api.urls"))`). Custom user model `users.User` before the first migration. Secrets from env only, read in `settings/base.py` only.

## Tests

- Tests live in the app: `apps/orders/tests/` with `test_models.py`, `test_services.py`, `test_views.py`, `test_api.py`, `conftest.py`, `factories.py`.
- Use pytest-django. Test services and selectors without HTTP; test views and API through the test client.
- Project-wide fixtures go in the root `conftest.py`. Cross-app flows go in `tests/e2e/` at the root.

## Structure at three sizes

Read [references/growth-stages.md](references/growth-stages.md) when deciding whether to restructure.

### Prototype

CLI default: project package with apps at the top level, one `settings.py`. Enough for 1-2 apps and no API.
Signal to move up: a second app appears, or you need distinct local and production settings.

### Mid-size

The default layout above: `config/`, `apps/`, `core/`, split settings.
Signal to move up: an app passes ~15 files per layer, or apps form a clear group.

### Large

Group apps by domain (`apps/commerce/{orders,payments}/`), split fat apps into `models/`, `services/`, `api/v1/`, add `libs/` or a second deployable (worker, admin site).

Grow by moving files and fixing imports, not by rewriting. Never move an app after its migrations ship without setting `label` to keep table names.

## Anti-patterns

Read [references/anti-patterns.md](references/anti-patterns.md) when reviewing a layout or before moving files.

- Do not put business logic in views, serializers, signals, or `save()` overrides. Use services.
- Do not import another app's views or private modules. Use its services and selectors.
- Do not run queries in templates, serializers, or loops without `select_related` / `prefetch_related`.
- Do not mix FBV and CBV, or ViewSets and `@api_view`, in the same app.
- Do not use the default `User` model when starting a project.
- Do not create a `utils.py` or `common` dumping ground; use `core/` modules by concern.
- Do not edit applied migrations or hand-delete them. Add a new one.
- Do not read `os.environ` outside settings. Do not commit `.env`.
- Do not use signals for same-app control flow. Call the service.
