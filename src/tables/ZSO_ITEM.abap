*&---------------------------------------------------------------------*
*& Table: ZSO_ITEM
*& Description: Sales Order Item
*&---------------------------------------------------------------------*

* FIELD NAME      | DATA ELEMENT   | TYPE    | LENGTH | KEY | DESCRIPTION
* ----------------|----------------|---------|--------|-----|------------------
* MANDT           | MANDT          | CLNT    | 3      | X   | Client
* ORDER_ID        | ZDE_ORDER_ID   | CHAR    | 10     | X   | Sales Order Number
* ITEM_NO         | POSNR          | NUMC    | 6      | X   | Item Number
* MATERIAL_ID     | ZDE_MATERIAL_ID| CHAR    | 18     |     | Material Number
* QUANTITY        | MENGE_D        | QUAN    | 13     |     | Order Quantity
* UNIT_PRICE      | WERTV8         | CURR    | 15     |     | Unit Price
* NET_AMOUNT      | WERTV8         | CURR    | 15     |     | Net Amount
* UOM             | MEINS          | UNIT    | 3      |     | Unit of Measure
* PLANT           | WERKS_D        | CHAR    | 4      |     | Plant

* Foreign Keys:
*   ORDER_ID    -> ZSO_HDR-ORDER_ID
*   MATERIAL_ID -> ZMAT_MASTER-MATERIAL_ID
