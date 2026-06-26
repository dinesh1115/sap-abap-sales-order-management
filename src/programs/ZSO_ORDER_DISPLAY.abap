*&---------------------------------------------------------------------*
*& Report: ZSO_ORDER_DISPLAY
*& Description: Display sales order header and items
*&---------------------------------------------------------------------*
REPORT zso_order_display.

SELECTION-SCREEN BEGIN OF BLOCK b1 WITH FRAME TITLE TEXT-001.
  PARAMETERS: p_order TYPE zde_order_id OBLIGATORY.
  PARAMETERS: p_conf  AS CHECKBOX DEFAULT abap_false.
  PARAMETERS: p_canc  AS CHECKBOX DEFAULT abap_false.
SELECTION-SCREEN END OF BLOCK b1.

INITIALIZATION.
  TEXT-001 = 'Order Selection'.

START-OF-SELECTION.
  TRY.
      IF p_conf = abap_true.
        zcl_so_order_api=>confirm_order( p_order ).
        COMMIT WORK AND WAIT.
        MESSAGE |Order { p_order } confirmed| TYPE 'S'.
      ELSEIF p_canc = abap_true.
        zcl_so_order_api=>cancel_order( p_order ).
        COMMIT WORK AND WAIT.
        MESSAGE |Order { p_order } cancelled| TYPE 'S'.
      ENDIF.

      DATA(ls_order) = zcl_so_order_api=>get_order( p_order ).

      WRITE: / 'Order ID:    ', ls_order-header-order_id,
             / 'Customer:    ', ls_order-header-customer_id,
             / 'Date:        ', ls_order-header-order_date,
             / 'Status:      ', ls_order-header-status,
             / 'Total:       ', ls_order-header-total_amount, ls_order-header-currency,
             / 'Created By:  ', ls_order-header-created_by,
             /.

      WRITE: / 'Items:',
             / 'Item', 10 'Material', 25 'Qty', 40 'Price', 55 'Net Amount', 70 'Plant'.
      ULINE.

      LOOP AT ls_order-items INTO DATA(ls_item).
        WRITE: / ls_item-item_no, 10 ls_item-material_id,
                 25 ls_item-quantity, ls_item-uom,
                 40 ls_item-unit_price,
                 55 ls_item-net_amount,
                 70 ls_item-plant.
      ENDLOOP.

    CATCH zcx_so_exception INTO DATA(lx_error).
      ROLLBACK WORK.
      MESSAGE lx_error->get_text( ) TYPE 'E'.
  ENDTRY.
