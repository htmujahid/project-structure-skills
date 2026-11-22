# Settings and config

## Settings package

```
config/settings/
  __init__.py     # empty
  base.py         # everything shared
  local.py        # from .base import *; DEBUG = True, debug toolbar, console email
  production.py   # from .base import *; security, caching, storage, Sentry
  test.py         # from .base import *; fast hashers, locmem email, no migrations optional
```

- `manage.py` defaults to `config.settings.local`; `asgi.py`/`wsgi.py` default to `config.settings.production`; pytest sets `config.settings.test`.
- `DJANGO_SETTINGS_MODULE` selects the file. Never branch on `DEBUG` to change structure.
- Read env in `base.py` only (`django-environ` or `os.environ`). Everything else imports `from django.conf import settings`.
- `.env.example` lists every var. `.env` is gitignored. Secrets never have defaults in `production.py`.

## Sections of base.py, in order

1. Paths: `BASE_DIR = Path(__file__).resolve().parents[2]`.
2. Core: `SECRET_KEY`, `DEBUG`, `ALLOWED_HOSTS`, `ROOT_URLCONF = "config.urls"`, `WSGI_APPLICATION`, `ASGI_APPLICATION`.
3. Apps: split into `DJANGO_APPS`, `THIRD_PARTY_APPS`, `LOCAL_APPS`; `INSTALLED_APPS = DJANGO_APPS + THIRD_PARTY_APPS + LOCAL_APPS`.
4. Middleware: security first, whitenoise, sessions, common, CSRF, auth, messages, clickjacking, custom last.
5. Templates: `DIRS = [BASE_DIR / "templates"]`, `APP_DIRS = True`, context processors.
6. Database: `DATABASES = {"default": env.db()}`; `CONN_MAX_AGE`, `CONN_HEALTH_CHECKS`.
7. Auth: `AUTH_USER_MODEL`, validators, `LOGIN_URL`, `LOGIN_REDIRECT_URL`, `PASSWORD_HASHERS`.
8. i18n: `LANGUAGE_CODE`, `USE_I18N`, `USE_TZ = True`, `LOCALE_PATHS = [BASE_DIR / "locale"]`.
9. Static and media: `STATIC_URL`, `STATICFILES_DIRS`, `STATIC_ROOT`, `MEDIA_ROOT`, `STORAGES`.
10. Cache, sessions, email, logging.
11. Third party: `REST_FRAMEWORK`, `SPECTACULAR_SETTINGS`, `CELERY_*`, `CHANNEL_LAYERS`, CORS.

## Production settings

`SECURE_SSL_REDIRECT`, `SESSION_COOKIE_SECURE`, `CSRF_COOKIE_SECURE`, `SECURE_HSTS_SECONDS`, `SECURE_PROXY_SSL_HEADER`, `CSRF_TRUSTED_ORIGINS`. Run `manage.py check --deploy` in CI.

## Middleware

- Project-wide middleware in `core/middleware.py` (request id, timezone, current-user context). App-specific middleware lives in the app as `middleware.py`.
- Class or function style, matching the project convention. Keep them thin and fast.

## Context processors

Global template variables only (site name, feature flags). `core/context_processors.py` for shared, `<app>/context_processors.py` for app-owned. Never query heavily in them.

## Logging

One `LOGGING` dict in `base.py`; JSON formatter in production; per-app loggers via `logging.getLogger(__name__)`.

## Cache

`CACHES` in settings (Redis in production, locmem in local). Cache in selectors or with `cache_page`/`cached_property`; key helper in the owning app's `cache.py`.

## Storage

`STORAGES` setting for default and staticfiles backends (S3, whitenoise manifest). Custom backends in `core/storage.py`. Uploads use `upload_to` callables defined next to the model.

## i18n

Wrap strings with `gettext_lazy as _` in models/forms and `gettext` in functions. Run `makemessages` into root `locale/`. Templates use `{% trans %}` and `{% blocktrans %}`.

## ASGI and WSGI

`config/asgi.py` exposes `application`; use `ProtocolTypeRouter` when Channels is present. Serve with Gunicorn (WSGI) or Uvicorn/Daphne (ASGI); Gunicorn config in `gunicorn.conf.py` at root.

## Dependencies

`pyproject.toml` with dependency groups (`dev`, `test`, `prod`) or `requirements/{base,local,production}.txt`. Pin and lock.
