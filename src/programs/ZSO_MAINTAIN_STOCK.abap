*&---------------------------------------------------------------------*
*& Report: ZSO_MAINTAIN_STOCK
*& Description: Add or update inventory stock
*&---------------------------------------------------------------------*
REPORT zso_maintain_stock.

SELECTION-SCREEN BEGIN OF BLOCK b1 WITH FRAME TITLE TEXT-001.
  PARAMETERS: p_mat   TYPE zde_material_id OBLIGATORY,
              p_plant TYPE werks_d DEFAULT '1000' OBLIGATORY,
              p_sloc  TYPE lgort_d DEFAULT '0001' OBLIGATORY,
              p_qty   TYPE menge_d OBLIGATORY,
              p_uom   TYPE meins DEFAULT 'EA' OBLIGATORY.
SELECTION-SCREEN END OF BLOCK b1.

INITIALIZATION.
  TEXT-001 = 'Stock Details'.

START-OF-SELECTION.
  TRY.
      zcl_so_inventory_api=>replenish_stock(
        iv_material_id = p_mat
        iv_plant       = p_plant
        iv_quantity    = p_qty
        iv_uom         = p_uom
        iv_storage_loc = p_sloc ).

      COMMIT WORK AND WAIT.
      MESSAGE |Stock updated for material { p_mat }| TYPE 'S'.

    CATCH zcx_so_exception INTO DATA(lx_error).
      ROLLBACK WORK.
      MESSAGE lx_error->get_text( ) TYPE 'E'.
  ENDTRY.
