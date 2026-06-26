# Number Range ZSO_ORDER

## SNRO — Create Number Range Object

| Setting | Value |
|---------|-------|
| Object | ZSO_ORDER |
| Description | Sales Order Number |
| Domain | ZDE_ORDER_ID (CHAR10) |

## Interval

| Field | Value |
|-------|-------|
| No | 01 |
| From Number | 1000000001 |
| To Number | 1999999999 |
| Current Number | 1000000001 |
| External | No |

## SNUM — Assign to Client

Assign interval 01 to your client (e.g. 100).

## Usage in Code

```abap
CALL FUNCTION 'NUMBER_GET_NEXT'
  EXPORTING
    nr_range_nr = '01'
    object      = 'ZSO_ORDER'
  IMPORTING
    number      = lv_order_id.
```
