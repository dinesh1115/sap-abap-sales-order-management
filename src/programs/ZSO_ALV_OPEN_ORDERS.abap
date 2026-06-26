*&---------------------------------------------------------------------*
*& Report: ZSO_ALV_OPEN_ORDERS
*& Description: ALV report for sales orders with filters
*&---------------------------------------------------------------------*
REPORT zso_alv_open_orders.

TABLES: zso_hdr.

SELECTION-SCREEN BEGIN OF BLOCK b1 WITH FRAME TITLE TEXT-001.
  SELECT-OPTIONS: s_cust   FOR zso_hdr-customer_id,
                  s_status FOR zso_hdr-status,
                  s_date   FOR zso_hdr-order_date.
SELECTION-SCREEN END OF BLOCK b1.

INITIALIZATION.
  TEXT-001 = 'Selection Criteria'.
  s_status-sign   = 'I'.
  s_status-option = 'EQ'.
  s_status-low    = zcl_so_constants=>status-open.
  APPEND s_status.

CLASS lcl_event_handler DEFINITION.
  PUBLIC SECTION.
    METHODS on_double_click FOR EVENT double_click OF cl_salv_events_table
      IMPORTING row column.
ENDCLASS.

CLASS lcl_event_handler IMPLEMENTATION.
  METHOD on_double_click.
    READ TABLE gt_orders INTO DATA(ls_order) INDEX row.
    CHECK sy-subrc = 0.
    SUBMIT zso_order_display WITH p_order = ls_order-order_id AND RETURN.
  ENDMETHOD.
ENDCLASS.

DATA gt_orders TYPE zcl_so_order_api=>tt_order_header.
DATA go_alv    TYPE REF TO cl_salv_table.
DATA go_events TYPE REF TO lcl_event_handler.

START-OF-SELECTION.
  PERFORM fetch_data.
  PERFORM display_alv.

FORM fetch_data.
  TRY.
      zcl_so_auth_check=>check_display( ).

      SELECT * FROM zso_hdr
        WHERE customer_id IN @s_cust
          AND status      IN @s_status
          AND order_date  IN @s_date
        ORDER BY order_date DESCENDING, order_id DESCENDING
        INTO TABLE @gt_orders.

      IF gt_orders IS INITIAL.
        MESSAGE 'No orders found for selection' TYPE 'S' DISPLAY LIKE 'W'.
      ENDIF.

    CATCH zcx_so_exception INTO DATA(lx_error).
      MESSAGE lx_error->get_text( ) TYPE 'E'.
  ENDTRY.
ENDFORM.

FORM display_alv.
  CHECK gt_orders IS NOT INITIAL.

  cl_salv_table=>factory(
    IMPORTING
      r_salv_table = go_alv
    CHANGING
      t_table      = gt_orders ).

  DATA(lo_cols) = go_alv->get_columns( ).
  lo_cols->set_optimize( abap_true ).

  DATA(lo_functions) = go_alv->get_functions( ).
  lo_functions->set_all( abap_true ).

  DATA(lo_display) = go_alv->get_display_settings( ).
  lo_display->set_striped_pattern( abap_true ).
  lo_display->set_list_header( 'Sales Orders' ).

  go_events = NEW lcl_event_handler( ).
  SET HANDLER go_events->on_double_click FOR go_alv->get_event( ).

  go_alv->display( ).
ENDFORM.
