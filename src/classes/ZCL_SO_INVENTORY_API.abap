*&---------------------------------------------------------------------*
*& Class: ZCL_SO_INVENTORY_API
*& Description: Inventory management API
*&---------------------------------------------------------------------*
CLASS zcl_so_inventory_api DEFINITION
  PUBLIC
  FINAL
  CREATE PUBLIC.

  PUBLIC SECTION.
    TYPES:
      BEGIN OF ty_stock_info,
        material_id  TYPE zde_material_id,
        description  TYPE maktx,
        plant        TYPE werks_d,
        storage_loc  TYPE lgort_d,
        stock_qty    TYPE menge_d,
        uom          TYPE meins,
      END OF ty_stock_info,
      tt_stock_info TYPE STANDARD TABLE OF ty_stock_info WITH EMPTY KEY.

    CLASS-METHODS check_availability
      IMPORTING
        iv_material_id TYPE zde_material_id
        iv_plant       TYPE werks_d DEFAULT zcl_so_constants=>default_plant
        iv_quantity    TYPE menge_d
      RETURNING
        VALUE(rv_available) TYPE abap_bool
      RAISING
        zcx_so_exception.

    CLASS-METHODS get_available_qty
      IMPORTING
        iv_material_id TYPE zde_material_id
        iv_plant       TYPE werks_d DEFAULT zcl_so_constants=>default_plant
      RETURNING
        VALUE(rv_qty) TYPE menge_d.

    CLASS-METHODS issue_stock
      IMPORTING
        iv_material_id TYPE zde_material_id
        iv_plant       TYPE werks_d
        iv_quantity    TYPE menge_d
        iv_storage_loc TYPE lgort_d DEFAULT zcl_so_constants=>default_storage_loc
      RAISING
        zcx_so_exception.

    CLASS-METHODS release_stock
      IMPORTING
        iv_material_id TYPE zde_material_id
        iv_plant       TYPE werks_d
        iv_quantity    TYPE menge_d
        iv_storage_loc TYPE lgort_d DEFAULT zcl_so_constants=>default_storage_loc
      RAISING
        zcx_so_exception.

    CLASS-METHODS replenish_stock
      IMPORTING
        iv_material_id TYPE zde_material_id
        iv_plant       TYPE werks_d
        iv_quantity    TYPE menge_d
        iv_uom         TYPE meins
        iv_storage_loc TYPE lgort_d DEFAULT zcl_so_constants=>default_storage_loc
      RAISING
        zcx_so_exception.

    CLASS-METHODS get_stock
      IMPORTING
        iv_material_id TYPE zde_material_id OPTIONAL
        iv_plant       TYPE werks_d OPTIONAL
      RETURNING
        VALUE(rt_stock) TYPE tt_stock_info.

  PRIVATE SECTION.
    CLASS-METHODS get_stock_record
      IMPORTING
        iv_material_id TYPE zde_material_id
        iv_plant       TYPE werks_d
        iv_storage_loc TYPE lgort_d
      CHANGING
        cs_stock TYPE zinv_stock
      RAISING
        zcx_so_exception.
ENDCLASS.

CLASS zcl_so_inventory_api IMPLEMENTATION.
  METHOD check_availability.
    DATA(lv_qty) = get_available_qty(
      iv_material_id = iv_material_id
      iv_plant       = iv_plant ).
    rv_available = boolc( lv_qty >= iv_quantity ).
  ENDMETHOD.

  METHOD get_available_qty.
    SELECT SINGLE stock_qty FROM zinv_stock
      WHERE material_id = @iv_material_id
        AND plant       = @iv_plant
      INTO @rv_qty.
    IF sy-subrc <> 0.
      rv_qty = 0.
    ENDIF.
  ENDMETHOD.

  METHOD issue_stock.
    DATA ls_stock TYPE zinv_stock.

    zcl_so_validator=>validate_material( iv_material_id ).
    zcl_so_validator=>validate_quantity( iv_quantity ).

    get_stock_record(
      EXPORTING
        iv_material_id = iv_material_id
        iv_plant       = iv_plant
        iv_storage_loc = iv_storage_loc
      CHANGING
        cs_stock = ls_stock ).

    IF ls_stock-stock_qty < iv_quantity.
      RAISE EXCEPTION TYPE zcx_so_exception
        EXPORTING
          textid           = zcx_so_exception=>insufficient_stock
          mv_material_id   = iv_material_id
          mv_required_qty  = iv_quantity
          mv_available_qty = ls_stock-stock_qty.
    ENDIF.

    ls_stock-stock_qty = ls_stock-stock_qty - iv_quantity.
    MODIFY zinv_stock FROM ls_stock.
  ENDMETHOD.

  METHOD release_stock.
    DATA ls_stock TYPE zinv_stock.

    zcl_so_validator=>validate_material( iv_material_id ).
    zcl_so_validator=>validate_quantity( iv_quantity ).

    SELECT SINGLE * FROM zinv_stock
      WHERE material_id  = @iv_material_id
        AND plant        = @iv_plant
        AND storage_loc  = @iv_storage_loc
      INTO @ls_stock.

    IF sy-subrc = 0.
      ls_stock-stock_qty = ls_stock-stock_qty + iv_quantity.
      MODIFY zinv_stock FROM ls_stock.
    ELSE.
      ls_stock-mandt       = sy-mandt.
      ls_stock-material_id = iv_material_id.
      ls_stock-plant       = iv_plant.
      ls_stock-storage_loc = iv_storage_loc.
      ls_stock-stock_qty   = iv_quantity.
      SELECT SINGLE uom FROM zmat_master
        WHERE material_id = @iv_material_id
        INTO @ls_stock-uom.
      INSERT zinv_stock FROM ls_stock.
    ENDIF.
  ENDMETHOD.

  METHOD replenish_stock.
    DATA ls_stock TYPE zinv_stock.

    zcl_so_validator=>validate_material( iv_material_id ).
    zcl_so_validator=>validate_quantity( iv_quantity ).

    SELECT SINGLE * FROM zinv_stock
      WHERE material_id  = @iv_material_id
        AND plant        = @iv_plant
        AND storage_loc  = @iv_storage_loc
      INTO @ls_stock.

    IF sy-subrc = 0.
      ls_stock-stock_qty = ls_stock-stock_qty + iv_quantity.
      ls_stock-uom       = iv_uom.
      MODIFY zinv_stock FROM ls_stock.
    ELSE.
      ls_stock-mandt       = sy-mandt.
      ls_stock-material_id = iv_material_id.
      ls_stock-plant       = iv_plant.
      ls_stock-storage_loc = iv_storage_loc.
      ls_stock-stock_qty   = iv_quantity.
      ls_stock-uom         = iv_uom.
      INSERT zinv_stock FROM ls_stock.
    ENDIF.
  ENDMETHOD.

  METHOD get_stock.
    SELECT s~material_id,
           m~description,
           s~plant,
           s~storage_loc,
           s~stock_qty,
           s~uom
      FROM zinv_stock AS s
      INNER JOIN zmat_master AS m
        ON s~material_id = m~material_id
      WHERE ( @iv_material_id IS INITIAL OR s~material_id = @iv_material_id )
        AND ( @iv_plant IS INITIAL OR s~plant = @iv_plant )
      INTO TABLE @rt_stock.
  ENDMETHOD.

  METHOD get_stock_record.
    SELECT SINGLE * FROM zinv_stock
      WHERE material_id  = @iv_material_id
        AND plant        = @iv_plant
        AND storage_loc  = @iv_storage_loc
      INTO @cs_stock.
    IF sy-subrc <> 0.
      RAISE EXCEPTION TYPE zcx_so_exception
        EXPORTING
          textid         = zcx_so_exception=>material_not_found
          mv_material_id = iv_material_id.
    ENDIF.
  ENDMETHOD.
ENDCLASS.
