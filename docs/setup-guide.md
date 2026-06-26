# Setup Guide

Step-by-step instructions to deploy this project in your SAP system (S/4HANA, ECC, or BTP ABAP Environment).

---

## Prerequisites

- SAP system with ABAP 7.50+ (7.52+ recommended for CDS)
- SAP ADT (Eclipse) installed
- Developer key / authorization for Z-object creation
- Optional: abapGit plugin for ADT

---

## Step 1: Create Package

1. Open ADT → Right-click project → New → ABAP Package
2. Name: `ZSO_INV_MGMT`
3. Description: `Sales Order & Inventory Management`
4. Transport: Local or assign to transport request

---

## Step 2: Create DDIC Objects

Create in this order (dependencies matter):

### Domains
- `ZSO_ORDER_STATUS` — CHAR2, fixed values OP/CF/DL/CA

### Data Elements
- `ZDE_ORDER_ID` — CHAR10, domain ZSO_ORDER_ID
- `ZDE_CUSTOMER_ID` — CHAR10
- `ZDE_MATERIAL_ID` — CHAR18
- `ZDE_ORDER_STATUS` — CHAR2, domain ZSO_ORDER_STATUS
- (Create remaining elements per `src/tables/` definitions)

### Tables
Copy definitions from `src/tables/` folder. Create in SE11 or ADT:

1. `ZCUST_MASTER`
2. `ZMAT_MASTER`
3. `ZINV_STOCK`
4. `ZSO_HDR`
5. `ZSO_ITEM`
6. `ZSO_LOG`

Activate each table after creation.

### Foreign Keys
- `ZSO_HDR-CUSTOMER_ID` → `ZCUST_MASTER-CUSTOMER_ID`
- `ZSO_ITEM-ORDER_ID` → `ZSO_HDR-ORDER_ID`
- `ZSO_ITEM-MATERIAL_ID` → `ZMAT_MASTER-MATERIAL_ID`
- `ZINV_STOCK-MATERIAL_ID` → `ZMAT_MASTER-MATERIAL_ID`

---

## Step 3: Number Range

1. Transaction `SNRO` → Create object `ZSO_ORDER`
2. Set interval: From `1000000001` To `1999999999`
3. Transaction `SNUM` → assign interval to client

See `src/config/number-range.md` for details.

---

## Step 4: Message Class

1. Transaction `SE91` → Create message class `ZSO`
2. Add messages per `src/config/message-class.md`

---

## Step 5: Authorization Object

1. Transaction `SU21` → Create object `Z_SO_ORDER`
2. Add field `ACTVT` (activity)
3. Transaction `SU24` → Add to program classes
4. Create role in `PFCG` with activities 01, 02, 03, 06

See `src/config/authorization.md`.

---

## Step 6: ABAP Classes

Create classes from `src/classes/` in this order:

1. `ZCL_SO_CONSTANTS`
2. `ZCX_SO_EXCEPTION`
3. `ZCL_SO_AUTH_CHECK`
4. `ZCL_SO_VALIDATOR`
5. `ZCL_SO_INVENTORY_API`
6. `ZCL_SO_ORDER_API`

Activate each class. Run unit tests if available.

---

## Step 7: Programs

Create and activate programs from `src/programs/`:

1. `ZSO_LOAD_SAMPLE_DATA` — run first to load test data
2. `ZSO_CREATE_ORDER`
3. `ZSO_MAINTAIN_STOCK`
4. `ZSO_ORDER_DISPLAY`
5. `ZSO_ALV_OPEN_ORDERS`
6. `ZSO_ALV_STOCK_REPORT`

---

## Step 8: CDS Views

Create in ADT (Eclipse) from `src/cds/`:

1. `ZCDS_SO_ORDER_HDR`
2. `ZCDS_SO_ORDER_ITEM`
3. `ZCDS_SO_INVENTORY`
4. `ZCDS_SO_ORDER_FULL`

Activate SQL view and CDS view for each.

---

## Step 9: OData Service

1. Transaction `SEGW` → Create project `ZSO_ODATA_SRV`
2. Import CDS entities or create manually
3. Copy DPC/MPC extension code from `src/odata/`
4. Generate runtime artifacts
5. `/IWFND/MAINT_SERVICE` → Add service → Activate

Test in Gateway Client (`/IWFND/GW_CLIENT`).

---

## Step 10: Load Sample Data & Test

```
1. Execute ZSO_LOAD_SAMPLE_DATA
2. Execute ZSO_CREATE_ORDER — create order for customer C0001
3. Execute ZSO_ALV_OPEN_ORDERS — verify order appears
4. Confirm order via API or ZSO_ORDER_DISPLAY
5. Execute ZSO_ALV_STOCK_REPORT — verify stock reduced
6. Test OData: GET /SalesOrderSet
```

---

## Using abapGit (Alternative)

If you have abapGit installed:

1. Fork/clone this repository
2. In ADT: abapGit → Online → pull repository URL
3. Assign package `ZSO_INV_MGMT`
4. Activate all objects
5. Follow Steps 3–5 (config objects) manually if not in repo

---

## Troubleshooting

| Issue | Solution |
|-------|----------|
| CDS activation fails | Check ABAP version ≥ 7.50; verify table names |
| AUTHORITY-CHECK fails | Assign role with Z_SO_ORDER in PFCG |
| Number range error | Run SNUM to assign interval |
| OData 403 | Check Gateway service activation and user authorizations |
| Short dump CX_SY_OPEN_SQL_DB | Verify tables activated and client set |

---

## System Requirements

| Component | Minimum |
|-----------|---------|
| ABAP | 7.50 SP 00 |
| HANA | 1.0 SPS 12 (or any DB for non-HANA) |
| Gateway | 2.0 SP 08 (for OData) |
| ADT | 3.0+ |
