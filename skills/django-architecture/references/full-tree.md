# Full tree

A large Django project: HTML + DRF API + Channels + Celery, single deployable. Class-based DRF shown; a function-based variant is noted under `api/`.

```
.
├── manage.py
├── pyproject.toml                 # deps, ruff, pytest, coverage
├── uv.lock                        # or requirements/*.txt
├── .env.example
├── Dockerfile
├── compose.yaml
├── conftest.py                    # project-wide pytest fixtures
├── config/
│   ├── __init__.py                # imports celery app
│   ├── settings/
│   │   ├── __init__.py
│   │   ├── base.py                # shared; reads env via django-environ
│   │   ├── local.py               # DEBUG, debug toolbar, console email
│   │   ├── production.py          # security, caching, storage, sentry
│   │   └── test.py                # fast hasher, in-memory email, sqlite/pg
│   ├── urls.py                    # only include() lines + admin + schema
│   ├── asgi.py                    # ProtocolTypeRouter: http + websocket
│   ├── wsgi.py
│   ├── celery.py                  # Celery app, autodiscover_tasks
│   └── routing.py                 # websocket URL router, aggregates apps
├── core/                          # shared, domain-free
│   ├── models.py                  # TimeStampedModel, UUIDModel, SoftDeleteModel
│   ├── managers.py
│   ├── pagination.py              # DRF pagination classes
│   ├── permissions.py             # generic DRF permissions (IsOwner)
│   ├── exceptions.py              # custom_exception_handler, domain errors
│   ├── middleware.py              # request-id, timezone
│   ├── mixins.py                  # view mixins
│   ├── validators.py
│   ├── storage.py
│   ├── templatetags/
│   │   └── core_tags.py
│   └── tests/
├── apps/
│   ├── users/
│   │   ├── __init__.py
│   │   ├── apps.py                # name="apps.users", label="users", ready()
│   │   ├── models.py              # User(AbstractUser), Profile
│   │   ├── managers.py            # UserManager
│   │   ├── services.py            # register_user, change_email
│   │   ├── selectors.py           # get_user_by_email, active_users
│   │   ├── forms.py
│   │   ├── views.py               # HTML views
│   │   ├── urls.py                # app_name = "users"
│   │   ├── admin.py
│   │   ├── signals.py             # connected in apps.ready()
│   │   ├── tasks.py               # Celery tasks
│   │   ├── consumers.py           # Channels consumers
│   │   ├── routing.py
│   │   ├── api/
│   │   │   ├── __init__.py
│   │   │   ├── serializers.py
│   │   │   ├── views.py           # ViewSets (class) or @api_view funcs
│   │   │   ├── urls.py            # router (class) or urlpatterns (function)
│   │   │   ├── permissions.py
│   │   │   ├── filters.py         # django-filter FilterSet
│   │   │   └── throttles.py
│   │   ├── migrations/
│   │   │   ├── __init__.py
│   │   │   └── 0001_initial.py
│   │   ├── management/
│   │   │   └── commands/
│   │   │       ├── __init__.py    # (and management/__init__.py)
│   │   │       └── create_demo_users.py
│   │   ├── templates/users/
│   │   │   ├── login.html
│   │   │   └── _avatar.html
│   │   ├── static/users/
│   │   ├── templatetags/
│   │   │   └── user_tags.py
│   │   ├── fixtures/
│   │   └── tests/
│   │       ├── conftest.py
│   │       ├── factories.py
│   │       ├── test_models.py
│   │       ├── test_services.py
│   │       ├── test_views.py
│   │       └── test_api.py
│   ├── orders/                    # same shape; models split when large
│   │   ├── models/
│   │   │   ├── __init__.py        # re-exports Order, OrderItem
│   │   │   ├── order.py
│   │   │   └── order_item.py
│   │   ├── services/
│   │   │   ├── __init__.py
│   │   │   ├── checkout.py
│   │   │   └── refunds.py
│   │   └── ...
│   └── notifications/
├── templates/                     # project-wide
│   ├── base.html
│   ├── 404.html
│   ├── 500.html
│   └── partials/
│       └── _pagination.html
├── static/                        # project-wide source assets
├── staticfiles/                   # collectstatic output, gitignored
├── media/                         # user uploads, gitignored
├── locale/
│   └── es/LC_MESSAGES/django.po
├── docs/
└── tests/
    └── e2e/                       # cross-app flows
```

Notes:

- Function-based API variant: `api/views.py` holds `@api_view` functions, `api/urls.py` a plain `urlpatterns` list. All other files stay identical.
- `routing.py`, `consumers.py`, `tasks.py` appear only in apps that need them.
- `staticfiles/` and `media/` are build/runtime output. Never commit them.
