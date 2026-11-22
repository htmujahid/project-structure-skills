# Templates and HTML

Applies to server-rendered Django. Skip for API-only projects.

## Views

Pick one style per project: class-based (`ListView`, `DetailView`, `CreateView`, `UpdateView`, `DeleteView`, `TemplateView`, `FormView`) or function-based. Views stay thin: parse request, call selectors/services, render.

```python
class OrderListView(LoginRequiredMixin, ListView):
    template_name = "orders/order_list.html"
    paginate_by = 25
    def get_queryset(self): return selectors.orders_for_user(user=self.request.user)
```

- Mixins shared across apps: `core/mixins.py`. Function decorators: `core/decorators.py`.
- Use `get_object_or_404`. Use `redirect("orders:detail", pk=order.pk)` after POST.
- Async views (`async def`) only for I/O fan-out; keep ORM calls through async ORM methods.
- HTML views and API views never share a file; HTML in `views.py`, API in `api/views.py`.

## URLs

- `app_name` in every `urls.py`; routes: `path("", ..., name="list")`, `path("<int:pk>/", ..., name="detail")`.
- `config/urls.py` includes each app once, plus admin, auth, debug toolbar (DEBUG only), static/media in DEBUG, and `i18n_patterns` when translated.

## Forms

- `forms.py` per app. `ModelForm` for models, `Form` for everything else, `formset_factory`/`inlineformset_factory` for sets.
- Validate fields in `clean_<field>`, cross-field in `clean`. Business rules in services; the form's `save()` may call one.
- Render with `django-crispy-forms`/`django-widget-tweaks` or custom partials `templates/partials/_field.html`.

## Templates

```
templates/                     # project-wide
  base.html                    # blocks: title, content, extra_head, extra_js
  404.html  500.html  403.html
  registration/                # login, logout, password reset overrides
  partials/_messages.html  _pagination.html
apps/orders/templates/orders/
  order_list.html  order_detail.html  order_form.html  _order_row.html
```

- App templates always inside `<app>/` subfolder. Extend `base.html`. Partials start with `_`.
- Use `{% include %}` for fragments, `{% extends %}` for layouts. Django 6 template partials (`{% partialdef %}`) may replace many `_` fragments.
- Use `{% url %}`, `{% static %}`, `{% csrf_token %}`, `{% trans %}`. No queries or business rules in templates.
- Reusable UI components via `django-cotton` or `{% include ... with %}`; keep in `templates/components/`.

## Template tags and filters

`apps/orders/templatetags/order_tags.py` (with `__init__.py`), `register = template.Library()`. Presentational only; use `simple_tag`, `inclusion_tag`, `filter`. Shared tags in `core/templatetags/`. Restart the dev server after adding a new templatetags package.

## Static files

- App assets in `apps/<app>/static/<app>/`; project assets in `static/`.
- `STATICFILES_DIRS` for project, `STATIC_ROOT` for `collectstatic` output (gitignored), WhiteNoise or CDN in production.
- Frontend bundlers (Vite, esbuild, Tailwind CLI) output into `static/dist/`; source in `frontend/` at project root.

## htmx and partial responses

Return partial templates for htmx requests (`request.htmx` via `django-htmx`); put fragments in `_*.html`; one view can render full page or fragment based on header.

## Messages, errors, SEO

`django.contrib.messages` rendered in `base.html`. Error pages in root `templates/`. `sitemaps` and `robots.txt` as `core` views or static.

## Context

Pass finished data in context. Global values only through `context_processors`.
