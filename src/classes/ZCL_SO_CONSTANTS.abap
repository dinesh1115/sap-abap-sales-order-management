*&---------------------------------------------------------------------*
*& Class: ZCL_SO_CONSTANTS
*& Description: Constants for Sales Order & Inventory Management
*&---------------------------------------------------------------------*
CLASS zcl_so_constants DEFINITION
  PUBLIC
  FINAL
  CREATE PUBLIC.

  PUBLIC SECTION.
    " Order Status
    CONSTANTS:
      BEGIN OF status,
        open       TYPE zde_order_status VALUE 'OP',
        confirmed  TYPE zde_order_status VALUE 'CF',
        delivered  TYPE zde_order_status VALUE 'DL',
        cancelled  TYPE zde_order_status VALUE 'CA',
      END OF status.

    " Audit Actions
    CONSTANTS:
      BEGIN OF action,
        create  TYPE char10 VALUE 'CREATE',
        update  TYPE char10 VALUE 'UPDATE',
        confirm TYPE char10 VALUE 'CONFIRM',
        cancel  TYPE char10 VALUE 'CANCEL',
        delete  TYPE char10 VALUE 'DELETE',
      END OF action.

    " Authorization Activities
    CONSTANTS:
      BEGIN OF actvt,
        create  TYPE activ_auth VALUE '01',
        change  TYPE activ_auth VALUE '02',
        display TYPE activ_auth VALUE '03',
        delete  TYPE activ_auth VALUE '06',
      END OF actvt.

    " Auth Object
    CONSTANTS:
      auth_object TYPE string VALUE 'Z_SO_ORDER'.

    " Defaults
    CONSTANTS:
      default_plant        TYPE werks_d VALUE '1000',
      default_storage_loc  TYPE lgort_d VALUE '0001',
      default_currency     TYPE waers VALUE 'USD',
      item_increment       TYPE posnr VALUE '000010'.

    " Message Class
    CONSTANTS:
      msg_class TYPE symsgid VALUE 'ZSO'.

ENDCLASS.

CLASS zcl_so_constants IMPLEMENTATION.
ENDCLASS.
