# Architecture

## Design Principles

1. **Layered architecture** — UI/Reports → Service Layer → Data Layer
2. **Single responsibility** — Each class handles one domain (orders vs inventory)
3. **No SQL in UI** — Programs call API classes only
4. **Fail fast** — Validations and auth checks before any DB write
5. **Audit trail** — Every create/update/cancel logged to `ZSO_LOG`

---

## Layer Details

### 1. Presentation Layer

| Component | Access Pattern |
|-----------|---------------|
| ALV Reports | Read via CDS views or API `get_orders()` |
| CRUD Programs | Write via `ZCL_SO_ORDER_API` / `ZCL_SO_INVENTORY_API` |
| OData / Fiori | Read/write via SEGW DPC extensions calling API classes |

### 2. Service Layer

```
ZCL_SO_ORDER_API
├── create_order( )      → validate → check stock → insert hdr/items → log
├── confirm_order( )     → re-check stock → reserve/issue → update status
├── cancel_order( )      → restore stock if confirmed → update status
├── update_order( )      → only if status = OPEN
├── get_order( )         → single order with items
└── get_orders( )        → list with filters

ZCL_SO_INVENTORY_API
├── check_availability( )
├── reserve_stock( )
├── issue_stock( )
├── release_stock( )
├── replenish_stock( )
└── get_stock( )
```

### 3. Cross-Cutting Concerns

| Concern | Implementation |
|---------|---------------|
| Validation | `ZCL_SO_VALIDATOR` — customer, material, qty, price checks |
| Authorization | `ZCL_SO_AUTH_CHECK` — object `Z_SO_ORDER`, activities 01/02/03/06 |
| Exceptions | `ZCX_SO_EXCEPTION` — typed exceptions with message texts |
| Constants | `ZCL_SO_CONSTANTS` — status codes, action codes |
| Logging | `ZCL_SO_ORDER_API=>log_action( )` → `ZSO_LOG` |

---

## Order Lifecycle

```
                    ┌──────────┐
                    │   OPEN   │ ← create_order()
                    └────┬─────┘
                         │ confirm_order()
                         ▼
                  ┌─────────────┐
                  │  CONFIRMED  │ ← stock issued
                  └──────┬──────┘
                         │ deliver (future)
                         ▼
                  ┌─────────────┐
                  │  DELIVERED  │
                  └─────────────┘

  Any status ──cancel_order()──► CANCELLED (stock restored if was CONFIRMED)
```

---

## Stock Flow

```
Available Stock (ZINV_STOCK-STOCK_QTY)
    │
    ├── create_order (OPEN)     → no stock change
    ├── confirm_order           → STOCK_QTY -= ordered qty
    └── cancel (was CONFIRMED)  → STOCK_QTY += restored qty
```

---

## Authorization Model

| Activity | Code | Allows |
|----------|------|--------|
| Display | 03 | View orders, ALV reports |
| Create | 01 | Create new orders |
| Change | 02 | Update, confirm, cancel |
| Delete | 06 | Delete OPEN orders |

Object: `Z_SO_ORDER` with field `ACTVT`

---

## Error Handling

All API methods raise `ZCX_SO_EXCEPTION` with specific message IDs:

| Exception | When |
|-----------|------|
| `customer_not_found` | Invalid customer ID |
| `material_not_found` | Invalid material ID |
| `insufficient_stock` | Qty > available stock |
| `invalid_status` | Action not allowed for current status |
| `no_authorization` | AUTHORITY-CHECK failed |
| `order_not_found` | Order ID does not exist |
| `validation_error` | General validation failure |
