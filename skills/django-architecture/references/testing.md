# Testing

## Tooling

`pytest` + `pytest-django` + `factory_boy` (or `model_bakery`) + `pytest-cov`. Config in `pyproject.toml`:

```toml
[tool.pytest.ini_options]
DJANGO_SETTINGS_MODULE = "config.settings.test"
python_files = ["test_*.py"]
addopts = "--reuse-db --strict-markers"
```

## Layout

```
conftest.py                       # project fixtures: api_client, user, auth_client
apps/orders/tests/
  conftest.py                     # app fixtures
  factories.py                    # OrderFactory, OrderItemFactory
  test_models.py
  test_services.py
  test_selectors.py
  test_views.py                   # HTML
  test_api.py                     # DRF
  test_tasks.py
  test_commands.py
core/tests/
tests/e2e/                        # cross-app flows, Playwright optional
```

Delete the generated `tests.py` when creating `tests/`. A `tests/__init__.py` is unnecessary with pytest rootdir conftest, but add one if two apps share test module names.

## What to test where

- Services and selectors: direct calls with factories; assert DB state, raised exceptions, query counts (`django_assert_num_queries`).
- Models: constraints, managers, properties with real logic.
- HTML views: `client.get/post`, assert status, template used (`assertTemplateUsed`), context, redirects.
- API: `APIClient`, `force_authenticate`; assert status, payload, permissions (401/403/404), pagination, filters. The same tests apply to class- and function-based views.
- Tasks: call the function directly (`task.apply()` / `CELERY_TASK_ALWAYS_EAGER` in test settings).
- Commands: `call_command` with `StringIO` output.
- Consumers: `WebsocketCommunicator` with `@pytest.mark.asyncio`.
- Admin: smoke-test changelist and add pages once.

## Database

`@pytest.mark.django_db` or `db` fixture; `transaction=True` only for `on_commit` or concurrency tests (`django_capture_on_commit_callbacks`). Test settings use fast `MD5PasswordHasher`.

## Quality gates in CI

`ruff check` + `ruff format --check`, `mypy`/`pyright` with `django-stubs`, `pytest --cov`, `manage.py makemigrations --check --dry-run`, `manage.py check --deploy` against production settings.
