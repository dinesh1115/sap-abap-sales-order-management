<div align="center">

# SAP ABAP Sales Order & Inventory Management

**Enterprise-style SAP module for sales order processing and real-time inventory control**

[![SAP ABAP](https://img.shields.io/badge/SAP-ABAP%207.50%2B-blue?logo=sap)](https://www.sap.com)
[![SAP HANA](https://img.shields.io/badge/Database-SAP%20HANA-0faa3f)](https://www.sap.com/products/technology-platform/hana.html)
[![OData](https://img.shields.io/badge/API-OData%2FSEGW-orange)](https://www.sap.com)
[![License](https://img.shields.io/badge/License-MIT-green)](LICENSE)

[Setup Guide](docs/setup-guide.md) · [Architecture](docs/architecture.md) · [Data Model](docs/data-model.md) · [OData](src/odata/ODATA_SETUP.md)

</div>

---

## About

A modular SAP ABAP reference implementation that demonstrates enterprise development patterns — layered OO ABAP, CDS views on HANA, ALV reporting, and OData services for Fiori integration.

Built as a portfolio project to showcase end-to-end custom application design without coupling UI logic directly to the database.

---

## Highlights

| Sales Orders | Inventory | Integration |
|:-------------|:----------|:------------|
| Create, confirm, cancel | Stock check & issue | OData for Fiori / UI5 |
| Line-item management | Reserve & replenish | CDS views on HANA |
| Auto order numbering | Low-stock ALV alerts | Full audit logging |

---

## Tech Stack

```
SAP ABAP (OO)  ·  SAP HANA  ·  CDS Views  ·  ALV  ·  OData/SEGW  ·  ADT  ·  Git/abapGit
```

| Layer | Technologies |
|:------|:-------------|
| **Runtime** | SAP ABAP 7.50+ |
| **Database** | SAP HANA |
| **Data Model** | DDIC Z-tables, domains, data elements |
| **Data Access** | Open SQL, Core Data Services |
| **Business Logic** | OO ABAP classes, custom exceptions |
| **Reporting** | ALV (`CL_SALV_TABLE`) |
| **API** | OData via SEGW |
| **Tooling** | SAP ADT, Git, abapGit |

---

## Architecture

```
  ALV Reports ──────┐         ┌────── Fiori / UI5
  ZSO_ALV_*         │         │
                    ▼         ▼
              CDS Views    OData Service
              ZCDS_SO_*    ZSO_ODATA_SRV
                    │         │
                    └────┬────┘
                         ▼
              ┌──────────────────────┐
              │   Business API Layer  │
              │  ZCL_SO_ORDER_API     │
              │  ZCL_SO_INVENTORY_API │
              │  ZCL_SO_VALIDATOR     │
              │  ZCL_SO_AUTH_CHECK    │
              └──────────┬───────────┘
                         ▼
              ┌──────────────────────┐
              │   Custom Z-Tables     │
              │  ZSO_HDR · ZSO_ITEM  │
              │  ZINV_STOCK · ZSO_LOG │
              └──────────────────────┘
```

<details>
<summary><strong>Design principles</strong></summary>

<br>

- **Layered separation** — UI and OData never write SQL directly
- **Single responsibility** — dedicated classes for orders vs. inventory
- **Fail-fast** — validation and `AUTHORITY-CHECK` before any DB write
- **Audit trail** — every action logged to `ZSO_LOG`

→ Full details in [docs/architecture.md](docs/architecture.md)

</details>

---

## Repository Structure

```
sap-abap-sales-order-management/
│
├── docs/                    # Documentation
│   ├── architecture.md
│   ├── data-model.md
│   └── setup-guide.md
│
└── src/
    ├── tables/              # 6 DDIC Z-tables
    ├── classes/             # 6 OO ABAP classes
    ├── programs/            # 6 reports (CRUD + ALV)
    ├── cds/                 # 6 CDS views
    ├── odata/               # OData DPC extension
    └── config/              # Auth, messages, number ranges
```

---

## Quick Start

> **Prerequisites:** SAP ABAP 7.50+, SAP ADT, authorization for Z-objects

| Step | Action |
|:-----|:-------|
| **1** | Import objects into package `ZSO_INV_MGMT` → [Setup Guide](docs/setup-guide.md) |
| **2** | Configure number range, message class, auth object → [Config](src/config/) |
| **3** | Run `ZSO_LOAD_SAMPLE_DATA` to seed demo data |
| **4** | Run `ZSO_CREATE_ORDER` — customer `C0001`, material `MAT-001` |
| **5** | Run `ZSO_ALV_OPEN_ORDERS` to view orders |
| **6** | Activate OData in `/IWFND/MAINT_SERVICE` → [OData Setup](src/odata/ODATA_SETUP.md) |

---

## Module Reference

<details open>
<summary><strong>Programs</strong></summary>

<br>

| Program | Type | Description |
|:--------|:-----|:------------|
| `ZSO_LOAD_SAMPLE_DATA` | Report | Load demo customers, materials, stock |
| `ZSO_CREATE_ORDER` | Report | Create sales order with line items |
| `ZSO_MAINTAIN_STOCK` | Report | Add or update inventory quantities |
| `ZSO_ORDER_DISPLAY` | Report | Display, confirm, or cancel an order |
| `ZSO_ALV_OPEN_ORDERS` | ALV | Filterable order list with drill-down |
| `ZSO_ALV_STOCK_REPORT` | ALV | Stock overview with low-stock highlight |

</details>

<details>
<summary><strong>Service Classes</strong></summary>

<br>

| Class | Responsibility |
|:------|:---------------|
| `ZCL_SO_ORDER_API` | Create, confirm, cancel, delete, retrieve orders |
| `ZCL_SO_INVENTORY_API` | Availability check, issue, release, replenish |
| `ZCL_SO_VALIDATOR` | Input and business-rule validation |
| `ZCL_SO_AUTH_CHECK` | Centralized `AUTHORITY-CHECK` |
| `ZCX_SO_EXCEPTION` | Typed application exceptions |
| `ZCL_SO_CONSTANTS` | Status codes, actions, shared constants |

</details>

<details>
<summary><strong>CDS Views</strong></summary>

<br>

| View | Description |
|:-----|:------------|
| `ZCDS_SO_ORDER_HDR` | Sales order header |
| `ZCDS_SO_ORDER_ITEM` | Order items with material info |
| `ZCDS_SO_INVENTORY` | Stock with material description |
| `ZCDS_SO_CUSTOMER` | Customer master |
| `ZCDS_SO_MATERIAL` | Material master |
| `ZCDS_SO_ORDER_FULL` | Header-to-items association |

</details>

<details>
<summary><strong>OData Service</strong></summary>

<br>

| Property | Value |
|:---------|:------|
| Service | `ZSO_ODATA_SRV` |
| Entities | `SalesOrder`, `SalesOrderItem`, `Inventory`, `Customer`, `Material` |
| Operations | CRUD on orders · Read on inventory & master data |

</details>

---

## Documentation

| Document | Description |
|:---------|:------------|
| [Setup Guide](docs/setup-guide.md) | Step-by-step SAP deployment |
| [Architecture](docs/architecture.md) | Layers, order lifecycle, stock flow |
| [Data Model](docs/data-model.md) | Tables, keys, relationships |
| [OData Setup](src/odata/ODATA_SETUP.md) | SEGW configuration |
| [Authorization](src/config/authorization.md) | Auth object & roles |
| [Number Ranges](src/config/number-range.md) | Order ID setup |

---

## Author

**Dinesh** — SAP ABAP Developer



---

<div align="center">

**[⬆ Back to top](#sap-abap-sales-order--inventory-management)**

</div>
