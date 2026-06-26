# Authorization Object Z_SO_ORDER

## SU21 — Create Authorization Object

| Field | Description |
|-------|-------------|
| ACTVT | Activity (01=Create, 02=Change, 03=Display, 06=Delete) |

Object Class: `AAAB` (or custom class)

## PFCG — Role Template

Create role `Z_SO_ORDER_ALL` with:

| Object | Field | Value |
|--------|-------|-------|
| Z_SO_ORDER | ACTVT | 01, 02, 03, 06 |

Assign role to your development user.

## SU24 — Object-Program Assignment

Assign `Z_SO_ORDER` to:
- Class `ZCL_SO_AUTH_CHECK`
- Package `ZSO_INV_MGMT`

## Development Shortcut

For sandbox/dev only, you can temporarily bypass auth checks by assigning
SAP_ALL or creating a permissive role. Do not use in production.
