*&---------------------------------------------------------------------*
*& Class: ZCL_SO_ORDER_API
*& Description: Sales Order management API
*&---------------------------------------------------------------------*
CLASS zcl_so_order_api DEFINITION
  PUBLIC
  FINAL
  CREATE PUBLIC.

  PUBLIC SECTION.
    TYPES:
      BEGIN OF ty_order_with_items,
        header TYPE zso_hdr,
        items  TYPE STANDARD TABLE OF zso_item WITH EMPTY KEY,
      END OF ty_order_with_items,
      tt_order_header TYPE STANDARD TABLE OF zso_hdr WITH EMPTY KEY.

    CLASS-METHODS create_order
      IMPORTING
        iv_customer_id TYPE zde_customer_id
        it_items       TYPE zcl_so_validator=>tt_order_item_input
        iv_order_date  TYPE dats DEFAULT sy-datum
      RETURNING
        VALUE(rv_order_id) TYPE zde_order_id
      RAISING
        zcx_so_exception.

    CLASS-METHODS confirm_order
      IMPORTING
        iv_order_id TYPE zde_order_id
      RAISING
        zcx_so_exception.

    CLASS-METHODS cancel_order
      IMPORTING
        iv_order_id TYPE zde_order_id
      RAISING
        zcx_so_exception.

    CLASS-METHODS delete_order
      IMPORTING
        iv_order_id TYPE zde_order_id
      RAISING
        zcx_so_exception.

    CLASS-METHODS get_order
      IMPORTING
        iv_order_id TYPE zde_order_id
      RETURNING
        VALUE(rs_order) TYPE ty_order_with_items
      RAISING
        zcx_so_exception.

    CLASS-METHODS get_orders
      IMPORTING
        iv_customer_id TYPE zde_customer_id OPTIONAL
        iv_status      TYPE zde_order_status OPTIONAL
        iv_date_from   TYPE dats OPTIONAL
        iv_date_to     TYPE dats OPTIONAL
      RETURNING
        VALUE(rt_orders) TYPE tt_order_header.

    CLASS-METHODS log_action
      IMPORTING
        iv_order_id TYPE zde_order_id
        iv_action   TYPE char10
        iv_details  TYPE char255 OPTIONAL.

  PRIVATE SECTION.
    CLASS-METHODS get_next_order_id
      RETURNING
        VALUE(rv_order_id) TYPE zde_order_id
      RAISING
        zcx_so_exception.

    CLASS-METHODS build_order_items
      IMPORTING
        iv_order_id TYPE zde_order_id
        it_input    TYPE zcl_so_validator=>tt_order_item_input
      RETURNING
        VALUE(rt_items) TYPE STANDARD TABLE OF zso_item
      RAISING
        zcx_so_exception.

    CLASS-METHODS calculate_total
      IMPORTING
        it_items TYPE STANDARD TABLE OF zso_item
      RETURNING
        VALUE(rv_total) TYPE wertv8.
ENDCLASS.

CLASS zcl_so_order_api IMPLEMENTATION.
  METHOD create_order.
    DATA: ls_header TYPE zso_hdr,
          lt_items  TYPE STANDARD TABLE OF zso_item,
          lv_item   TYPE zcl_so_validator=>ty_order_item_input.

    zcl_so_auth_check=>check_create( ).
    zcl_so_validator=>validate_customer( iv_customer_id ).
    zcl_so_validator=>validate_order_items( it_items ).

    " Check stock availability for all items
    LOOP AT it_items INTO lv_item.
      DATA(lv_plant) = COND werks_d(
        WHEN lv_item-plant IS NOT INITIAL THEN lv_item-plant
        ELSE zcl_so_constants=>default_plant ).
      IF zcl_so_inventory_api=>check_availability(
           iv_material_id = lv_item-material_id
           iv_plant       = lv_plant
           iv_quantity    = lv_item-quantity ) = abap_false.
        RAISE EXCEPTION TYPE zcx_so_exception
          EXPORTING
            textid           = zcx_so_exception=>insufficient_stock
            mv_material_id   = lv_item-material_id
            mv_required_qty  = lv_item-quantity
            mv_available_qty = zcl_so_inventory_api=>get_available_qty(
              iv_material_id = lv_item-material_id
              iv_plant       = lv_plant ).
      ENDIF.
    ENDLOOP.

    rv_order_id = get_next_order_id( ).

    ls_header-mandt       = sy-mandt.
    ls_header-order_id    = rv_order_id.
    ls_header-customer_id = iv_customer_id.
    ls_header-order_date  = iv_order_date.
    ls_header-status      = zcl_so_constants=>status-open.
    ls_header-currency    = zcl_so_constants=>default_currency.
    ls_header-created_by  = sy-uname.
    GET TIME STAMP FIELD ls_header-created_at.

    lt_items = build_order_items(
      iv_order_id = rv_order_id
      it_input    = it_items ).
    ls_header-total_amount = calculate_total( lt_items ).

    INSERT zso_hdr FROM ls_header.
    INSERT zso_item FROM TABLE lt_items.

    log_action(
      iv_order_id = rv_order_id
      iv_action   = zcl_so_constants=>action-create
      iv_details  = |Customer: { iv_customer_id }, Items: { lines( lt_items ) }| ).
  ENDMETHOD.

  METHOD confirm_order.
    DATA: ls_header TYPE zso_hdr,
          lt_items  TYPE STANDARD TABLE OF zso_item.

    zcl_so_auth_check=>check_change( ).
    ls_header = zcl_so_validator=>validate_order_exists( iv_order_id ).

    IF ls_header-status <> zcl_so_constants=>status-open.
      RAISE EXCEPTION TYPE zcx_so_exception
        EXPORTING
          textid      = zcx_so_exception=>invalid_status
          mv_order_id = iv_order_id
          mv_status   = ls_header-status.
    ENDIF.

    SELECT * FROM zso_item
      WHERE order_id = @iv_order_id
      INTO TABLE @lt_items.

    LOOP AT lt_items INTO DATA(ls_item).
      zcl_so_inventory_api=>issue_stock(
        iv_material_id = ls_item-material_id
        iv_plant       = ls_item-plant
        iv_quantity    = ls_item-quantity ).
    ENDLOOP.

    ls_header-status     = zcl_so_constants=>status-confirmed.
    ls_header-changed_by = sy-uname.
    GET TIME STAMP FIELD ls_header-changed_at.
    MODIFY zso_hdr FROM ls_header.

    log_action(
      iv_order_id = iv_order_id
      iv_action   = zcl_so_constants=>action-confirm ).
  ENDMETHOD.

  METHOD cancel_order.
    DATA: ls_header TYPE zso_hdr,
          lt_items  TYPE STANDARD TABLE OF zso_item.

    zcl_so_auth_check=>check_change( ).
    ls_header = zcl_so_validator=>validate_order_exists( iv_order_id ).

    IF ls_header-status = zcl_so_constants=>status-cancelled.
      RAISE EXCEPTION TYPE zcx_so_exception
        EXPORTING
          textid      = zcx_so_exception=>invalid_status
          mv_order_id = iv_order_id
          mv_status   = ls_header-status.
    ENDIF.

    IF ls_header-status = zcl_so_constants=>status-confirmed.
      SELECT * FROM zso_item
        WHERE order_id = @iv_order_id
        INTO TABLE @lt_items.
      LOOP AT lt_items INTO DATA(ls_item).
        zcl_so_inventory_api=>release_stock(
          iv_material_id = ls_item-material_id
          iv_plant       = ls_item-plant
          iv_quantity    = ls_item-quantity ).
      ENDLOOP.
    ENDIF.

    ls_header-status     = zcl_so_constants=>status-cancelled.
    ls_header-changed_by = sy-uname.
    GET TIME STAMP FIELD ls_header-changed_at.
    MODIFY zso_hdr FROM ls_header.

    log_action(
      iv_order_id = iv_order_id
      iv_action   = zcl_so_constants=>action-cancel ).
  ENDMETHOD.

  METHOD delete_order.
    zcl_so_auth_check=>check_delete( ).
    DATA(ls_header) = zcl_so_validator=>validate_order_exists( iv_order_id ).
    zcl_so_validator=>validate_status_for_change( ls_header-status ).

    DELETE FROM zso_item WHERE order_id = iv_order_id.
    DELETE FROM zso_hdr  WHERE order_id = iv_order_id.

    log_action(
      iv_order_id = iv_order_id
      iv_action   = zcl_so_constants=>action-delete ).
  ENDMETHOD.

  METHOD get_order.
    zcl_so_auth_check=>check_display( ).
    rs_order-header = zcl_so_validator=>validate_order_exists( iv_order_id ).
    SELECT * FROM zso_item
      WHERE order_id = @iv_order_id
      INTO TABLE @rs_order-items.
  ENDMETHOD.

  METHOD get_orders.
    zcl_so_auth_check=>check_display( ).
    SELECT * FROM zso_hdr
      WHERE ( @iv_customer_id IS INITIAL OR customer_id = @iv_customer_id )
        AND ( @iv_status IS INITIAL OR status = @iv_status )
        AND ( @iv_date_from IS INITIAL OR order_date >= @iv_date_from )
        AND ( @iv_date_to IS INITIAL OR order_date <= @iv_date_to )
      ORDER BY order_date DESCENDING, order_id DESCENDING
      INTO TABLE @rt_orders.
  ENDMETHOD.

  METHOD log_action.
    DATA: ls_log TYPE zso_log,
          lv_id  TYPE numc10.

    SELECT MAX( log_id ) FROM zso_log INTO @lv_id.
    lv_id = lv_id + 1.

    ls_log-mandt     = sy-mandt.
    ls_log-log_id    = lv_id.
    ls_log-order_id  = iv_order_id.
    ls_log-action    = iv_action.
    ls_log-username  = sy-uname.
    GET TIME STAMP FIELD ls_log-timestamp.
    ls_log-details   = iv_details.

    INSERT zso_log FROM ls_log.
  ENDMETHOD.

  METHOD get_next_order_id.
    CALL FUNCTION 'NUMBER_GET_NEXT'
      EXPORTING
        nr_range_nr = '01'
        object      = 'ZSO_ORDER'
      IMPORTING
        number      = rv_order_id
      EXCEPTIONS
        OTHERS      = 1.
    IF sy-subrc <> 0.
      RAISE EXCEPTION TYPE zcx_so_exception
        EXPORTING
          textid = zcx_so_exception=>number_range_error.
    ENDIF.
  ENDMETHOD.

  METHOD build_order_items.
    DATA: lv_item_no TYPE posnr VALUE '000000',
          ls_mat     TYPE zmat_master.

    lv_item_no = '000000'.
    LOOP AT it_input INTO DATA(ls_input).
      lv_item_no = lv_item_no + zcl_so_constants=>item_increment.

      SELECT SINGLE * FROM zmat_master
        WHERE material_id = @ls_input-material_id
        INTO @ls_mat.

      APPEND VALUE #(
        mandt       = sy-mandt
        order_id    = iv_order_id
        item_no     = lv_item_no
        material_id = ls_input-material_id
        quantity    = ls_input-quantity
        unit_price  = COND #( WHEN ls_input-unit_price IS NOT INITIAL
                              THEN ls_input-unit_price
                              ELSE ls_mat-price )
        net_amount  = ls_input-quantity * COND wertv8(
                          WHEN ls_input-unit_price IS NOT INITIAL
                          THEN ls_input-unit_price
                          ELSE ls_mat-price )
        uom         = ls_mat-uom
        plant       = COND #( WHEN ls_input-plant IS NOT INITIAL
                              THEN ls_input-plant
                              ELSE zcl_so_constants=>default_plant )
      ) TO rt_items.
    ENDLOOP.
  ENDMETHOD.

  METHOD calculate_total.
    LOOP AT it_items INTO DATA(ls_item).
      rv_total = rv_total + ls_item-net_amount.
    ENDLOOP.
  ENDMETHOD.
ENDCLASS.
