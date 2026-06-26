# OData Service Setup — ZSO_ODATA_SRV

## SEGW Project Configuration

1. Transaction **SEGW** → Create project `ZSO_ODATA_SRV`
2. Import or create the following entities:

### Entity: SalesOrder
| Property | Type | Key | Source |
|----------|------|-----|--------|
| OrderId | Edm.String | Yes | ZCDS_SO_ORDER_HDR-ORDER_ID |
| CustomerId | Edm.String | | ZCDS_SO_ORDER_HDR-CUSTOMER_ID |
| OrderDate | Edm.DateTime | | ZCDS_SO_ORDER_HDR-ORDER_DATE |
| Status | Edm.String | | ZCDS_SO_ORDER_HDR-STATUS |
| TotalAmount | Edm.Decimal | | ZCDS_SO_ORDER_HDR-TOTAL_AMOUNT |
| Currency | Edm.String | | ZCDS_SO_ORDER_HDR-CURRENCY |

### Entity: SalesOrderItem
| Property | Type | Key | Source |
|----------|------|-----|--------|
| OrderId | Edm.String | Yes | ZCDS_SO_ORDER_ITEM-ORDER_ID |
| ItemNo | Edm.String | Yes | ZCDS_SO_ORDER_ITEM-ITEM_NO |
| MaterialId | Edm.String | | ZCDS_SO_ORDER_ITEM-MATERIAL_ID |
| Quantity | Edm.Decimal | | ZCDS_SO_ORDER_ITEM-QUANTITY |
| UnitPrice | Edm.Decimal | | ZCDS_SO_ORDER_ITEM-UNIT_PRICE |
| NetAmount | Edm.Decimal | | ZCDS_SO_ORDER_ITEM-NET_AMOUNT |

### Entity: Inventory
| Property | Type | Key | Source |
|----------|------|-----|--------|
| MaterialId | Edm.String | Yes | ZCDS_SO_INVENTORY-MATERIAL_ID |
| Plant | Edm.String | Yes | ZCDS_SO_INVENTORY-PLANT |
| StorageLoc | Edm.String | Yes | ZCDS_SO_INVENTORY-STORAGE_LOC |
| Description | Edm.String | | ZCDS_SO_INVENTORY-DESCRIPTION |
| StockQty | Edm.Decimal | | ZCDS_SO_INVENTORY-STOCK_QTY |

### Entity: Customer
Source: `ZCDS_SO_CUSTOMER` — GET only

### Entity: Material
Source: `ZCDS_SO_MATERIAL` — GET only

## Associations
- `SalesOrder` 1..* `SalesOrderItem` (via OrderId)
- `SalesOrder` *..1 `Customer` (via CustomerId)

## CRUD Mapping
| Entity | GET | POST | PUT | DELETE |
|--------|-----|------|-----|--------|
| SalesOrder | Auto (CDS) | DPC_EXT create | DPC_EXT update | DPC_EXT delete |
| SalesOrderItem | Auto (CDS) | — | — | — |
| Inventory | Auto (CDS) | — | — | — |
| Customer | Auto (CDS) | — | — | — |
| Material | Auto (CDS) | — | — | — |

## Activation
1. Generate runtime artifacts in SEGW
2. `/IWFND/MAINT_SERVICE` → Add Service → System Alias LOCAL → `ZSO_ODATA_SRV`
3. Test in Gateway Client: `/IWFND/GW_CLIENT`

## Sample OData Calls

```
GET  /sap/opu/odata/sap/ZSO_ODATA_SRV/SalesOrderSet
GET  /sap/opu/odata/sap/ZSO_ODATA_SRV/SalesOrderSet('1000000001')
GET  /sap/opu/odata/sap/ZSO_ODATA_SRV/InventorySet
POST /sap/opu/odata/sap/ZSO_ODATA_SRV/SalesOrderSet
     { "CustomerId": "C0001", "MaterialId": "MAT-001", "Quantity": "2" }
```
