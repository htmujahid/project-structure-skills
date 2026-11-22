# Django REST Framework API

DRF code lives in each app's `api/` package. Pick ONE view style for the whole project, then keep every other file identical between styles.

## Shared layout (both styles)

```
apps/orders/api/
  __init__.py
  serializers.py    # OrderSerializer, OrderCreateSerializer, OrderListSerializer
  views.py          # class-based OR function-based (never both)
  urls.py           # app_name = "orders-api"
  permissions.py    # IsOrderOwner
  filters.py        # OrderFilter (django-filter)
  throttles.py      # OrderBurstThrottle
  pagination.py     # only if the app needs its own
```

Project-wide pieces in `core/`: `pagination.py`, `permissions.py`, `exceptions.py` (`custom_exception_handler`), `renderers.py`, `parsers.py`.

Mount in `config/urls.py`:

```python
path("api/v1/", include("apps.orders.api.urls")),
path("api/schema/", SpectacularAPIView.as_view(), name="schema"),
path("api/docs/", SpectacularSwaggerView.as_view(url_name="schema")),
```

## Choosing a style

| Style | Use when | Building blocks |
| ----- | -------- | --------------- |
| Class-based (default) | CRUD resources, many endpoints, team of several | `ModelViewSet`, `ReadOnlyModelViewSet`, `GenericViewSet` + mixins, `generics.*APIView`, `APIView`, `DefaultRouter` |
| Function-based | Few endpoints, RPC or webhook style, explicit control, small team | `@api_view([...])`, `@permission_classes`, `@throttle_classes`, `@authentication_classes` |

Rules once chosen:

- Same style in every app. Document the choice in the README.
- One documented exception is allowed (a webhook as a function in a class-based project). Put it in `api/webhooks.py`.
- Shared behavior: class-based uses mixins in `core/mixins.py`; function-based uses decorators in `core/decorators.py`.

## Class-based

```python
# api/views.py
class OrderViewSet(viewsets.ModelViewSet):
    permission_classes = [IsAuthenticated, IsOrderOwner]
    filterset_class = OrderFilter
    ordering_fields = ["created_at", "total"]

    def get_queryset(self):
        return selectors.orders_for_user(user=self.request.user)

    def get_serializer_class(self):
        return {"list": OrderListSerializer, "create": OrderCreateSerializer}.get(
            self.action, OrderSerializer)

    def perform_create(self, serializer):
        serializer.instance = services.place_order(user=self.request.user, **serializer.validated_data)

    @action(detail=True, methods=["post"])
    def cancel(self, request, pk=None): ...
```

```python
# api/urls.py
router = DefaultRouter()
router.register("orders", OrderViewSet, basename="order")
app_name = "orders-api"
urlpatterns = router.urls
```

- Generics (`ListCreateAPIView`, `RetrieveUpdateDestroyAPIView`) when a resource lacks full CRUD or needs plain `path()` URLs.
- `APIView` for non-resource endpoints (login, search, health).
- Override `get_queryset`, `get_serializer_class`, `perform_*`; never override `list/create` to reimplement them.

## Function-based

```python
# api/views.py
@api_view(["GET", "POST"])
@permission_classes([IsAuthenticated])
def order_list(request):
    if request.method == "GET":
        qs = selectors.orders_for_user(user=request.user)
        page = paginator.paginate_queryset(qs, request)
        return paginator.get_paginated_response(OrderListSerializer(page, many=True).data)
    serializer = OrderCreateSerializer(data=request.data)
    serializer.is_valid(raise_exception=True)
    order = services.place_order(user=request.user, **serializer.validated_data)
    return Response(OrderSerializer(order).data, status=status.HTTP_201_CREATED)

@api_view(["GET", "PATCH", "DELETE"])
@permission_classes([IsAuthenticated, IsOrderOwner])
def order_detail(request, pk): ...
```

```python
# api/urls.py
app_name = "orders-api"
urlpatterns = [
    path("orders/", views.order_list, name="order-list"),
    path("orders/<int:pk>/", views.order_detail, name="order-detail"),
    path("orders/<int:pk>/cancel/", views.order_cancel, name="order-cancel"),
]
```

- One function per endpoint per URL; branch on `request.method` only for the same resource.
- Fetch with `get_object_or_404(selectors.orders_for_user(user=request.user), pk=pk)` so scoping happens in the queryset; for extra object rules call `IsOrderOwner().has_object_permission(request, None, obj)` and raise `PermissionDenied`.
- Use `@extend_schema` on each function for OpenAPI.

## Serializers (both styles)

- One serializer per use: `OrderSerializer` (read), `OrderCreateSerializer`/`OrderUpdateSerializer` (write), `OrderListSerializer` (slim). Always list `fields` explicitly.
- Validation of shape and single-field rules in the serializer; business rules in services.
- `create()`/`update()` in serializers delegate to services, or the view calls the service with `validated_data`.
- Nested writes go through services; use nested serializers read-only.
- Input-only serializers (`serializers.Serializer`) for actions and RPC payloads.

## Authentication, permissions, throttling

- Defaults in `REST_FRAMEWORK` settings: authentication (Session, JWT via simplejwt, or Token), `DEFAULT_PERMISSION_CLASSES = [IsAuthenticated]`, throttle rates, pagination, filter backends, schema class, exception handler.
- Object-level rules in `permissions.py` (`has_object_permission`). Reuse domain permission functions between HTML views and API.
- Auth endpoints live in `apps/users/api/` (login, refresh, register, me).

## Filtering, search, ordering, pagination

- `django-filter` `FilterSet` in `filters.py`; `SearchFilter` and `OrderingFilter` in view attributes (class) or applied in the selector (function).
- Global `DEFAULT_PAGINATION_CLASS` from `core/pagination.py` (cursor for feeds, page-number for admin-ish lists).

## Versioning

`URLPathVersioning` or separate includes. Version at the package: `api/v1/`, `api/v2/` once the first breaking change appears; never edit v1 contracts. Shared serializers move to `api/common/` or stay in v1 and are subclassed.

## Errors

`core/exceptions.py` provides `custom_exception_handler` mapping domain exceptions (`OutOfStock` -> 409) and Django `ValidationError` to a consistent JSON envelope.

## Documentation

`drf-spectacular` for OpenAPI; `@extend_schema` on views, `SPECTACULAR_SETTINGS` in base settings; export schema in CI.

## Files, uploads, websockets, webhooks

- Uploads: `FileField`/`ImageField` with `MultiPartParser`; storage via `STORAGES`.
- Webhooks: signature check in `api/webhooks.py`, enqueue a task, return 200 fast.
- Long-running work returns 202 plus a status URL; the task lives in `tasks.py`.

## Tests

`apps/orders/tests/test_api.py` using `APIClient` and `force_authenticate`; parametrize on status codes; assert query counts. Same tests work for either view style.
