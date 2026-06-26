# Data Model

## Entity Relationship Diagram

```
ZCUST_MASTER ──────────────┐
  CUSTOMER_ID (PK)          │
  NAME, CITY, COUNTRY       │
                            │ 1
                            │
                            ▼ *
                         ZSO_HDR ──────────────┐
                           ORDER_ID (PK)       │ 1
                           CUSTOMER_ID (FK)   │
                           ORDER_DATE          │
                           STATUS              │
                           TOTAL_AMOUNT        │
                           CREATED_BY/AT       │
                                              │
                                              ▼ *
                                           ZSO_ITEM
                                             ORDER_ID (FK)
                                             ITEM_NO (PK)
                                             MATERIAL_ID (FK) ──► ZMAT_MASTER
                                             QUANTITY                 MATERIAL_ID (PK)
                                             UNIT_PRICE               DESCRIPTION
                                             NET_AMOUNT               PRICE, UOM
                                             PLANT

ZMAT_MASTER ──────────────┐
  MATERIAL_ID (PK)        │
  DESCRIPTION             │ 1
  PRICE, UOM              │
                          ▼ *
                       ZINV_STOCK
                         MATERIAL_ID (FK)
                         PLANT (PK)
                         STORAGE_LOC (PK)
                         STOCK_QTY
                         UOM

ZSO_LOG (audit)
  LOG_ID (PK)
  ORDER_ID
  ACTION
  USERNAME
  TIMESTAMP
  DETAILS
```

---

## Table Definitions

### ZSO_HDR — Sales Order Header

| Field | Type | Key | Description |
|-------|------|-----|-------------|
| MANDT | CLNT | X | Client |
| ORDER_ID | CHAR10 | X | Order number (from number range) |
| CUSTOMER_ID | CHAR10 | | Customer reference |
| ORDER_DATE | DATS | | Order date |
| STATUS | CHAR2 | | OPEN / CF / DL / CA |
| TOTAL_AMOUNT | CURR15 | | Total order value |
| CURRENCY | CUKY | | Currency key |
| CREATED_BY | UNAME | | Created by user |
| CREATED_AT | TIMESTAMPL | | Creation timestamp |
| CHANGED_BY | UNAME | | Last changed by |
| CHANGED_AT | TIMESTAMPL | | Last change timestamp |

### ZSO_ITEM — Sales Order Item

| Field | Type | Key | Description |
|-------|------|-----|-------------|
| MANDT | CLNT | X | Client |
| ORDER_ID | CHAR10 | X | Order reference |
| ITEM_NO | NUMC6 | X | Item number (000010, 000020...) |
| MATERIAL_ID | CHAR18 | | Material reference |
| QUANTITY | QUAN13 | | Order quantity |
| UNIT_PRICE | CURR15 | | Price per unit |
| NET_AMOUNT | CURR15 | | Line total |
| UOM | UNIT | | Unit of measure |
| PLANT | WERKS | | Plant |

### ZINV_STOCK — Inventory Stock

| Field | Type | Key | Description |
|-------|------|-----|-------------|
| MANDT | CLNT | X | Client |
| MATERIAL_ID | CHAR18 | X | Material |
| PLANT | WERKS | X | Plant |
| STORAGE_LOC | LGORT | X | Storage location |
| STOCK_QTY | QUAN13 | | Available quantity |
| UOM | UNIT | | Unit of measure |

### ZMAT_MASTER — Material Master (simplified)

| Field | Type | Key | Description |
|-------|------|-----|-------------|
| MANDT | CLNT | X | Client |
| MATERIAL_ID | CHAR18 | X | Material number |
| DESCRIPTION | CHAR40 | | Short text |
| PRICE | CURR15 | | Standard price |
| UOM | UNIT | | Base unit |
| CURRENCY | CUKY | | Price currency |

### ZCUST_MASTER — Customer Master (simplified)

| Field | Type | Key | Description |
|-------|------|-----|-------------|
| MANDT | CLNT | X | Client |
| CUSTOMER_ID | CHAR10 | X | Customer number |
| NAME | CHAR40 | | Customer name |
| CITY | CHAR40 | | City |
| COUNTRY | CHAR3 | | Country code |

### ZSO_LOG — Audit Log

| Field | Type | Key | Description |
|-------|------|-----|-------------|
| MANDT | CLNT | X | Client |
| LOG_ID | NUMC10 | X | Log entry ID |
| ORDER_ID | CHAR10 | | Related order |
| ACTION | CHAR10 | | CREATE / UPDATE / CONFIRM / CANCEL |
| USERNAME | UNAME | | User who performed action |
| TIMESTAMP | TIMESTAMPL | | When |
| DETAILS | CHAR255 | | Additional info |

---

## Status Codes

| Code | Constant | Description |
|------|----------|-------------|
| OP | STATUS_OPEN | Order created, editable |
| CF | STATUS_CONFIRMED | Stock issued |
| DL | STATUS_DELIVERED | Delivery completed |
| CA | STATUS_CANCELLED | Order cancelled |

---

## Number Ranges

| Object | Description | From | To |
|--------|-------------|------|-----|
| ZSO_ORDER | Sales Order ID | 1000000001 | 1999999999 |
