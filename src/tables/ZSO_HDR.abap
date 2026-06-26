*&---------------------------------------------------------------------*
*& Table: ZSO_HDR
*& Description: Sales Order Header
*& Delivery Class: A (Application table)
*&---------------------------------------------------------------------*
* Create in SE11 / ADT with the following structure:

* FIELD NAME      | DATA ELEMENT   | TYPE    | LENGTH | KEY | DESCRIPTION
* ----------------|----------------|---------|--------|-----|------------------
* MANDT           | MANDT          | CLNT    | 3      | X   | Client
* ORDER_ID        | ZDE_ORDER_ID   | CHAR    | 10     | X   | Sales Order Number
* CUSTOMER_ID     | ZDE_CUSTOMER_ID| CHAR    | 10     |     | Customer Number
* ORDER_DATE      | DATS           | DATS    | 8      |     | Order Date
* STATUS          | ZDE_ORDER_STATUS| CHAR   | 2      |     | Order Status
* TOTAL_AMOUNT    | WERTV8         | CURR    | 15     |     | Total Amount
* CURRENCY        | WAERS          | CUKY    | 5      |     | Currency
* CREATED_BY      | UNAME          | CHAR    | 12     |     | Created By
* CREATED_AT      | TIMESTAMPL     | TIMESTAMPL| 8    |     | Created At
* CHANGED_BY      | UNAME          | CHAR    | 12     |     | Changed By
* CHANGED_AT      | TIMESTAMPL     | TIMESTAMPL| 8    |     | Changed At

* Technical Settings:
*   Data Class: APPL0
*   Size Category: 0
*   Buffering: Not allowed

* Indexes:
*   ZSO_HDR~Z01 on CUSTOMER_ID
*   ZSO_HDR~Z02 on STATUS, ORDER_DATE

* Foreign Keys:
*   CUSTOMER_ID -> ZCUST_MASTER-CUSTOMER_ID

* Table Maintenance (SM30):
*   Maintenance allowed, automatic transport
