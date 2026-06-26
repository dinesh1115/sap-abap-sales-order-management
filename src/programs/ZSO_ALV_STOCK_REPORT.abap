*&---------------------------------------------------------------------*
*& Report: ZSO_ALV_STOCK_REPORT
*& Description: ALV report for inventory stock levels
*&---------------------------------------------------------------------*
REPORT zso_alv_stock_report.

SELECTION-SCREEN BEGIN OF BLOCK b1 WITH FRAME TITLE TEXT-001.
  PARAMETERS: p_mat   TYPE zde_material_id,
              p_plant TYPE werks_d DEFAULT '1000'.
  PARAMETERS: p_low   TYPE menge_d DEFAULT 10.
SELECTION-SCREEN END OF BLOCK b1.

INITIALIZATION.
  TEXT-001 = 'Stock Filters'.

DATA: gt_stock TYPE zcl_so_inventory_api=>tt_stock_info,
      go_alv   TYPE REF TO cl_salv_table.

START-OF-SELECTION.
  TRY.
      zcl_so_auth_check=>check_display( ).

      gt_stock = zcl_so_inventory_api=>get_stock(
        iv_material_id = p_mat
        iv_plant       = p_plant ).

      IF gt_stock IS INITIAL.
        MESSAGE 'No stock records found' TYPE 'S' DISPLAY LIKE 'W'.
        RETURN.
      ENDIF.

      cl_salv_table=>factory(
        IMPORTING
          r_salv_table = go_alv
        CHANGING
          t_table      = gt_stock ).

      DATA(lo_cols) = go_alv->get_columns( ).
      lo_cols->set_optimize( abap_true ).

      DATA(lo_functions) = go_alv->get_functions( ).
      lo_functions->set_all( abap_true ).

      DATA(lo_display) = go_alv->get_display_settings( ).
      lo_display->set_striped_pattern( abap_true ).
      lo_display->set_list_header( 'Inventory Stock Report' ).

      " Color low stock rows
      DATA(lo_column) = lo_cols->get_column( 'STOCK_QTY' ).
      lo_column->set_long_text( 'Stock Quantity' ).

      LOOP AT gt_stock INTO DATA(ls_stock).
        DATA(lv_row) = sy-tabix.
        IF ls_stock-stock_qty < p_low.
          go_alv->get_columns( )->get_column( 'STOCK_QTY' )->set_color(
            VALUE #( col = 6 int = 1 ) ).
        ENDIF.
      ENDLOOP.

      go_alv->display( ).

    CATCH zcx_so_exception INTO DATA(lx_error).
      MESSAGE lx_error->get_text( ) TYPE 'E'.
  ENDTRY.
