*&---------------------------------------------------------------------*
*& Table: ZMAT_MASTER
*& Description: Material Master (Simplified)
*&---------------------------------------------------------------------*

* FIELD NAME      | DATA ELEMENT   | TYPE    | LENGTH | KEY | DESCRIPTION
* ----------------|----------------|---------|--------|-----|------------------
* MANDT           | MANDT          | CLNT    | 3      | X   | Client
* MATERIAL_ID     | ZDE_MATERIAL_ID| CHAR    | 18     | X   | Material Number
* DESCRIPTION     | MAKTX          | CHAR    | 40     |     | Material Description
* PRICE           | WERTV8         | CURR    | 15     |     | Standard Price
* UOM             | MEINS          | UNIT    | 3      |     | Base Unit
* CURRENCY        | WAERS          | CUKY    | 5      |     | Currency
