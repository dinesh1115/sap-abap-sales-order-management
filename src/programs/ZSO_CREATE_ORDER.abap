*&---------------------------------------------------------------------*
*& Report: ZSO_CREATE_ORDER
*& Description: Create a new sales order with items
*&---------------------------------------------------------------------*
REPORT zso_create_order.

TABLES: zso_hdr.

SELECTION-SCREEN BEGIN OF BLOCK b1 WITH FRAME TITLE TEXT-001.
  PARAMETERS: p_cust TYPE zde_customer_id OBLIGATORY.
SELECTION-SCREEN END OF BLOCK b1.

SELECTION-SCREEN BEGIN OF BLOCK b2 WITH FRAME TITLE TEXT-002.
  PARAMETERS: p_mat1 TYPE zde_material_id,
              p_qty1 TYPE menge_d,
              p_mat2 TYPE zde_material_id,
              p_qty2 TYPE menge_d,
              p_mat3 TYPE zde_material_id,
              p_qty3 TYPE menge_d.
SELECTION-SCREEN END OF BLOCK b2.

INITIALIZATION.
  TEXT-001 = 'Customer'.
  TEXT-002 = 'Order Items (up to 3)'.

START-OF-SELECTION.
  DATA: lt_items TYPE zcl_so_validator=>tt_order_item_input,
        lv_order TYPE zde_order_id.

  TRY.
      IF p_mat1 IS NOT INITIAL AND p_qty1 > 0.
        APPEND VALUE #( material_id = p_mat1 quantity = p_qty1 ) TO lt_items.
      ENDIF.
      IF p_mat2 IS NOT INITIAL AND p_qty2 > 0.
        APPEND VALUE #( material_id = p_mat2 quantity = p_qty2 ) TO lt_items.
      ENDIF.
      IF p_mat3 IS NOT INITIAL AND p_qty3 > 0.
        APPEND VALUE #( material_id = p_mat3 quantity = p_qty3 ) TO lt_items.
      ENDIF.

      lv_order = zcl_so_order_api=>create_order(
        iv_customer_id = p_cust
        it_items       = lt_items ).

      COMMIT WORK AND WAIT.

      MESSAGE |Order { lv_order } created successfully| TYPE 'S'.

    CATCH zcx_so_exception INTO DATA(lx_error).
      ROLLBACK WORK.
      MESSAGE lx_error->get_text( ) TYPE 'E'.
  ENDTRY.
