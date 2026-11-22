# Growth stages

## Prototype

What `django-admin startproject` and `startapp` give you, lightly tidied.

```
manage.py
mysite/            # settings.py, urls.py, asgi.py, wsgi.py
blog/              # startapp output: models.py, views.py, admin.py, tests.py
templates/
```

Stay here with 1-2 apps, one developer, one environment.
Move up when: a second or third app appears, you need different local and production settings, or you add a DRF API.
Moves:

1. Rename `mysite/` to `config/` (update `manage.py`, `asgi.py`, `wsgi.py`, `ROOT_URLCONF`, `WSGI_APPLICATION`).
2. Turn `settings.py` into `settings/{base,local,production,test}.py`.
3. Create `apps/` and `git mv blog apps/blog`; set `name = "apps.blog"` and `label = "blog"` in `apps.py`; update `INSTALLED_APPS`. Keeping `label` leaves tables and migration history intact.
4. Create `core/` only when the first shared base model or mixin exists.

## Mid-size

The default layout in SKILL.md.
Stay while each app is a handful of files per role and one person can hold an app in their head.
Move up when any of these is true:

- `models.py` or `views.py` passes ~300 lines or ~5 classes.
- An app owns two domains that change independently.
- Several apps form an obvious group (orders, payments, shipping).
- You need a versioned public API or a second deployable.

## Large, one deployable

Restructure one app at a time; the project runs after each step.

1. Split files into packages: `models.py` -> `models/{__init__,order,order_item}.py` with `__init__` re-exporting every model (migrations and `app.Model` refs keep working). Same for `services/`, `views/`, `tests/`.
2. Version the API: `api/v1/{serializers,views,urls}.py`; include as `path("api/v1/", ...)`. Add `v2/` beside it, never edit `v1` contracts.
3. Split an app that owns two domains: create the new app, move models with `SeparateDatabaseAndState` migrations (state-only on one side, no table change), then move code.
4. Group apps: `apps/commerce/{orders,payments}/`; set `name = "apps.commerce.orders"` and keep `label = "orders"`.
5. Keep `core/` flat; grow by concern (`core/pagination.py`), not by domain.

## Large, multiple deployables

When a worker, admin site, or public API must deploy separately:

1. Keep one repo and one `apps/` tree. Add entrypoints: `config/settings/worker.py`, `config/urls_admin.py`, a second `asgi` module.
2. Pick the process with `DJANGO_SETTINGS_MODULE`; each deployable enables only the `INSTALLED_APPS` and URLs it needs.
3. Move genuinely shared, domain-free code to an installable package (`libs/` or a private wheel). Never deep-import across deployables.
4. Extract a true service (own repo and database) only on a team boundary; the app layout inside each service stays this skill.
