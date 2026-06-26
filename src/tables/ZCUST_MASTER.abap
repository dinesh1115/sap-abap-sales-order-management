*&---------------------------------------------------------------------*
*& Table: ZCUST_MASTER
*& Description: Customer Master (Simplified)
*&---------------------------------------------------------------------*

* FIELD NAME      | DATA ELEMENT   | TYPE    | LENGTH | KEY | DESCRIPTION
* ----------------|----------------|---------|--------|-----|------------------
* MANDT           | MANDT          | CLNT    | 3      | X   | Client
* CUSTOMER_ID     | ZDE_CUSTOMER_ID| CHAR    | 10     | X   | Customer Number
* NAME            | NAME1_GP       | CHAR    | 40     |     | Customer Name
* CITY            | ORT01_GP       | CHAR    | 40     |     | City
* COUNTRY         | LAND1_GP       | CHAR    | 3      |     | Country
