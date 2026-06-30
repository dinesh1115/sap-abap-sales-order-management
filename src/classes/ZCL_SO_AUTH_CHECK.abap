*&---------------------------------------------------------------------*
*& Class: ZCL_SO_AUTH_CHECK
*& Description: Authorization checks for Sales Order module.  ..
*&---------------------------------------------------------------------*
CLASS zcl_so_auth_check DEFINITION
  PUBLIC
  FINAL
  CREATE PUBLIC.

  PUBLIC SECTION.
    CLASS-METHODS check_authorization
      IMPORTING
        iv_activity TYPE activ_auth
      RAISING
        zcx_so_exception.

    CLASS-METHODS check_create
      RAISING zcx_so_exception.

    CLASS-METHODS check_change
      RAISING zcx_so_exception.

    CLASS-METHODS check_display
      RAISING zcx_so_exception.

    CLASS-METHODS check_delete
      RAISING zcx_so_exception.

  PRIVATE SECTION.
    CLASS-METHODS do_check
      IMPORTING
        iv_activity TYPE activ_auth
      RAISING
        zcx_so_exception.
ENDCLASS.

CLASS zcl_so_auth_check IMPLEMENTATION.
  METHOD check_authorization.
    do_check( iv_activity ).
  ENDMETHOD.

  METHOD check_create.
    do_check( zcl_so_constants=>actvt-create ).
  ENDMETHOD.

  METHOD check_change.
    do_check( zcl_so_constants=>actvt-change ).
  ENDMETHOD.

  METHOD check_display.
    do_check( zcl_so_constants=>actvt-display ).
  ENDMETHOD.

  METHOD check_delete.
    do_check( zcl_so_constants=>actvt-delete ).
  ENDMETHOD.

  METHOD do_check.
    AUTHORITY-CHECK OBJECT 'Z_SO_ORDER'
      ID 'ACTVT' FIELD iv_activity.
    IF sy-subrc <> 0.
      RAISE EXCEPTION TYPE zcx_so_exception
        EXPORTING
          textid = zcx_so_exception=>no_authorization.
    ENDIF.
  ENDMETHOD.
ENDCLASS.
