*&---------------------------------------------------------------------*
*& Class: ZCL_SO_VALIDATOR
*& Description: Input validation for Sales Order module
*&---------------------------------------------------------------------*
CLASS zcl_so_validator DEFINITION
  PUBLIC
  FINAL
  CREATE PUBLIC.

  PUBLIC SECTION.
    TYPES:
      BEGIN OF ty_order_item_input,
        material_id TYPE zde_material_id,
        quantity    TYPE menge_d,
        unit_price  TYPE wertv8,
        plant       TYPE werks_d,
      END OF ty_order_item_input,
      tt_order_item_input TYPE STANDARD TABLE OF ty_order_item_input WITH EMPTY KEY.

    CLASS-METHODS validate_customer
      IMPORTING
        iv_customer_id TYPE zde_customer_id
      RAISING
        zcx_so_exception.

    CLASS-METHODS validate_material
      IMPORTING
        iv_material_id TYPE zde_material_id
      RAISING
        zcx_so_exception.

    CLASS-METHODS validate_order_items
      IMPORTING
        it_items TYPE tt_order_item_input
      RAISING
        zcx_so_exception.

    CLASS-METHODS validate_quantity
      IMPORTING
        iv_quantity TYPE menge_d
      RAISING
        zcx_so_exception.

    CLASS-METHODS validate_order_exists
      IMPORTING
        iv_order_id TYPE zde_order_id
      RETURNING
        VALUE(rs_header) TYPE zso_hdr
      RAISING
        zcx_so_exception.

    CLASS-METHODS validate_status_for_change
      IMPORTING
        iv_status TYPE zde_order_status
      RAISING
        zcx_so_exception.

  PRIVATE SECTION.
ENDCLASS.

CLASS zcl_so_validator IMPLEMENTATION.
  METHOD validate_customer.
    IF iv_customer_id IS INITIAL.
      RAISE EXCEPTION TYPE zcx_so_exception
        EXPORTING
          textid     = zcx_so_exception=>validation_error
          mv_details = 'Customer ID is required'.
    ENDIF.

    SELECT SINGLE @abap_true FROM zcust_master
      WHERE customer_id = @iv_customer_id
      INTO @DATA(lv_exists).
    IF sy-subrc <> 0.
      RAISE EXCEPTION TYPE zcx_so_exception
        EXPORTING
          textid         = zcx_so_exception=>customer_not_found
          mv_customer_id = iv_customer_id.
    ENDIF.
  ENDMETHOD.

  METHOD validate_material.
    IF iv_material_id IS INITIAL.
      RAISE EXCEPTION TYPE zcx_so_exception
        EXPORTING
          textid     = zcx_so_exception=>validation_error
          mv_details = 'Material ID is required'.
    ENDIF.

    SELECT SINGLE @abap_true FROM zmat_master
      WHERE material_id = @iv_material_id
      INTO @DATA(lv_exists).
    IF sy-subrc <> 0.
      RAISE EXCEPTION TYPE zcx_so_exception
        EXPORTING
          textid         = zcx_so_exception=>material_not_found
          mv_material_id = iv_material_id.
    ENDIF.
  ENDMETHOD.

  METHOD validate_quantity.
    IF iv_quantity IS INITIAL OR iv_quantity < 0.
      RAISE EXCEPTION TYPE zcx_so_exception
        EXPORTING
          textid     = zcx_so_exception=>validation_error
          mv_details = 'Quantity must be greater than zero'.
    ENDIF.
  ENDMETHOD.

  METHOD validate_order_items.
    IF it_items IS INITIAL.
      RAISE EXCEPTION TYPE zcx_so_exception
        EXPORTING
          textid     = zcx_so_exception=>validation_error
          mv_details = 'At least one order item is required'.
    ENDIF.

    LOOP AT it_items INTO DATA(ls_item).
      validate_material( ls_item-material_id ).
      validate_quantity( ls_item-quantity ).
      IF ls_item-unit_price < 0.
        RAISE EXCEPTION TYPE zcx_so_exception
          EXPORTING
            textid     = zcx_so_exception=>validation_error
            mv_details = 'Unit price cannot be negative'.
      ENDIF.
    ENDLOOP.
  ENDMETHOD.

  METHOD validate_order_exists.
    SELECT SINGLE * FROM zso_hdr
      WHERE order_id = @iv_order_id
      INTO @rs_header.
    IF sy-subrc <> 0.
      RAISE EXCEPTION TYPE zcx_so_exception
        EXPORTING
          textid      = zcx_so_exception=>order_not_found
          mv_order_id = iv_order_id.
    ENDIF.
  ENDMETHOD.

  METHOD validate_status_for_change.
    IF iv_status <> zcl_so_constants=>status-open.
      RAISE EXCEPTION TYPE zcx_so_exception
        EXPORTING
          textid    = zcx_so_exception=>invalid_status
          mv_status = iv_status.
    ENDIF.
  ENDMETHOD.
ENDCLASS.
