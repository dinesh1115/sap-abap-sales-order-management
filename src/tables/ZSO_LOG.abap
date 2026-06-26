*&---------------------------------------------------------------------*
*& Table: ZSO_LOG
*& Description: Sales Order Audit Log
*&---------------------------------------------------------------------*

* FIELD NAME      | DATA ELEMENT   | TYPE    | LENGTH | KEY | DESCRIPTION
* ----------------|----------------|---------|--------|-----|------------------
* MANDT           | MANDT          | CLNT    | 3      | X   | Client
* LOG_ID          | NUMC10         | NUMC    | 10     | X   | Log Entry ID
* ORDER_ID        | ZDE_ORDER_ID   | CHAR    | 10     |     | Order Number
* ACTION          | CHAR10         | CHAR    | 10     |     | Action Code
* USERNAME        | UNAME          | CHAR    | 12     |     | User Name
* TIMESTAMP       | TIMESTAMPL     | TIMESTAMPL| 8    |     | Timestamp
* DETAILS         | CHAR255        | CHAR    | 255    |     | Details

* Index:
*   ZSO_LOG~Z01 on ORDER_ID
