*&---------------------------------------------------------------------*
*& Table: ZINV_STOCK
*& Description: Inventory Stock
*&---------------------------------------------------------------------*

* FIELD NAME      | DATA ELEMENT   | TYPE    | LENGTH | KEY | DESCRIPTION
* ----------------|----------------|---------|--------|-----|------------------
* MANDT           | MANDT          | CLNT    | 3      | X   | Client
* MATERIAL_ID     | ZDE_MATERIAL_ID| CHAR    | 18     | X   | Material Number
* PLANT           | WERKS_D        | CHAR    | 4      | X   | Plant
* STORAGE_LOC     | LGORT_D        | CHAR    | 4      | X   | Storage Location
* STOCK_QTY       | MENGE_D        | QUAN    | 13     |     | Stock Quantity
* UOM             | MEINS          | UNIT    | 3      |     | Unit of Measure

* Foreign Keys:
*   MATERIAL_ID -> ZMAT_MASTER-MATERIAL_ID
