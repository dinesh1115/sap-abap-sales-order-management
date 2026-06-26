*&---------------------------------------------------------------------*
*& Class: ZCL_ZSO_ODATA_SRV_DPC_EXT
*& Description: OData Data Provider Extension for Sales Order Service
*& Service: ZSO_ODATA_SRV (create in SEGW first, then extend DPC)
*&---------------------------------------------------------------------*
CLASS zcl_zso_odata_srv_dpc_ext DEFINITION
  PUBLIC
  INHERITING FROM zcl_zso_odata_srv_dpc
  FINAL
  CREATE PUBLIC.

  PUBLIC SECTION.
    METHODS salesorderset_create_entity
        REDEFINITION.
    METHODS salesorderset_update_entity
        REDEFINITION.
    METHODS salesorderset_delete_entity
        REDEFINITION.

  PROTECTED SECTION.
  PRIVATE SECTION.
ENDCLASS.

CLASS zcl_zso_odata_srv_dpc_ext IMPLEMENTATION.
  METHOD salesorderset_create_entity.
    DATA: ls_entity TYPE zcl_zso_odata_srv_mpc=>ts_salesorder,
          lt_items  TYPE zcl_so_validator=>tt_order_item_input,
          lv_order  TYPE zde_order_id.

    io_data_provider->read_entry_data( IMPORTING es_data = ls_entity ).

    TRY.
        APPEND VALUE #(
          material_id = ls_entity-material_id
          quantity    = ls_entity-quantity
        ) TO lt_items.

        lv_order = zcl_so_order_api=>create_order(
          iv_customer_id = ls_entity-customer_id
          it_items       = lt_items ).

        COMMIT WORK.

        ls_entity-order_id = lv_order.
        ls_entity-status   = zcl_so_constants=>status-open.
        er_entity          = ls_entity.

      CATCH zcx_so_exception INTO DATA(lx_error).
        ROLLBACK WORK.
        RAISE EXCEPTION TYPE /iwbep/cx_mgw_busi_exception
          EXPORTING
            textid  = /iwbep/cx_mgw_busi_exception=>business_error
            message = lx_error->get_text( ).
    ENDTRY.
  ENDMETHOD.

  METHOD salesorderset_update_entity.
    DATA ls_entity TYPE zcl_zso_odata_srv_mpc=>ts_salesorder.

    io_data_provider->read_entry_data( IMPORTING es_data = ls_entity ).

    TRY.
        CASE ls_entity-status.
          WHEN zcl_so_constants=>status-confirmed.
            zcl_so_order_api=>confirm_order( ls_entity-order_id ).
          WHEN zcl_so_constants=>status-cancelled.
            zcl_so_order_api=>cancel_order( ls_entity-order_id ).
        ENDCASE.
        COMMIT WORK.
        er_entity = ls_entity.

      CATCH zcx_so_exception INTO DATA(lx_error).
        ROLLBACK WORK.
        RAISE EXCEPTION TYPE /iwbep/cx_mgw_busi_exception
          EXPORTING
            textid  = /iwbep/cx_mgw_busi_exception=>business_error
            message = lx_error->get_text( ).
    ENDTRY.
  ENDMETHOD.

  METHOD salesorderset_delete_entity.
    DATA(lv_key) = it_key_tab[ 1 ]-value.

    TRY.
        zcl_so_order_api=>delete_order( lv_key ).
        COMMIT WORK.

      CATCH zcx_so_exception INTO DATA(lx_error).
        ROLLBACK WORK.
        RAISE EXCEPTION TYPE /iwbep/cx_mgw_busi_exception
          EXPORTING
            textid  = /iwbep/cx_mgw_busi_exception=>business_error
            message = lx_error->get_text( ).
    ENDTRY.
  ENDMETHOD.
ENDCLASS.
