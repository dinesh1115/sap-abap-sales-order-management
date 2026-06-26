*&---------------------------------------------------------------------*
*& Class: ZCX_SO_EXCEPTION
*& Description: Custom exception for Sales Order module
*&---------------------------------------------------------------------*
CLASS zcx_so_exception DEFINITION
  PUBLIC
  INHERITING FROM cx_static_check
  FINAL
  CREATE PUBLIC.

  PUBLIC SECTION.
    INTERFACES if_t100_message.

    CONSTANTS:
      BEGIN OF customer_not_found,
        msgid TYPE symsgid VALUE 'ZSO',
        msgno TYPE symsgno VALUE '001',
        attr1 TYPE scx_attrname VALUE 'MV_CUSTOMER_ID',
        attr2 TYPE scx_attrname VALUE '',
        attr3 TYPE scx_attrname VALUE '',
        attr4 TYPE scx_attrname VALUE '',
      END OF customer_not_found,

      BEGIN OF material_not_found,
        msgid TYPE symsgid VALUE 'ZSO',
        msgno TYPE symsgno VALUE '002',
        attr1 TYPE scx_attrname VALUE 'MV_MATERIAL_ID',
        attr2 TYPE scx_attrname VALUE '',
        attr3 TYPE scx_attrname VALUE '',
        attr4 TYPE scx_attrname VALUE '',
      END OF material_not_found,

      BEGIN OF insufficient_stock,
        msgid TYPE symsgid VALUE 'ZSO',
        msgno TYPE symsgno VALUE '003',
        attr1 TYPE scx_attrname VALUE 'MV_MATERIAL_ID',
        attr2 TYPE scx_attrname VALUE 'MV_REQUIRED_QTY',
        attr3 TYPE scx_attrname VALUE 'MV_AVAILABLE_QTY',
        attr4 TYPE scx_attrname VALUE '',
      END OF insufficient_stock,

      BEGIN OF invalid_status,
        msgid TYPE symsgid VALUE 'ZSO',
        msgno TYPE symsgno VALUE '004',
        attr1 TYPE scx_attrname VALUE 'MV_ORDER_ID',
        attr2 TYPE scx_attrname VALUE 'MV_STATUS',
        attr3 TYPE scx_attrname VALUE '',
        attr4 TYPE scx_attrname VALUE '',
      END OF invalid_status,

      BEGIN OF no_authorization,
        msgid TYPE symsgid VALUE 'ZSO',
        msgno TYPE symsgno VALUE '005',
        attr1 TYPE scx_attrname VALUE '',
        attr2 TYPE scx_attrname VALUE '',
        attr3 TYPE scx_attrname VALUE '',
        attr4 TYPE scx_attrname VALUE '',
      END OF no_authorization,

      BEGIN OF order_not_found,
        msgid TYPE symsgid VALUE 'ZSO',
        msgno TYPE symsgno VALUE '006',
        attr1 TYPE scx_attrname VALUE 'MV_ORDER_ID',
        attr2 TYPE scx_attrname VALUE '',
        attr3 TYPE scx_attrname VALUE '',
        attr4 TYPE scx_attrname VALUE '',
      END OF order_not_found,

      BEGIN OF validation_error,
        msgid TYPE symsgid VALUE 'ZSO',
        msgno TYPE symsgno VALUE '007',
        attr1 TYPE scx_attrname VALUE 'MV_DETAILS',
        attr2 TYPE scx_attrname VALUE '',
        attr3 TYPE scx_attrname VALUE '',
        attr4 TYPE scx_attrname VALUE '',
      END OF validation_error,

      BEGIN OF number_range_error,
        msgid TYPE symsgid VALUE 'ZSO',
        msgno TYPE symsgno VALUE '008',
        attr1 TYPE scx_attrname VALUE '',
        attr2 TYPE scx_attrname VALUE '',
        attr3 TYPE scx_attrname VALUE '',
        attr4 TYPE scx_attrname VALUE '',
      END OF number_range_error.

    DATA:
      mv_customer_id  TYPE zde_customer_id,
      mv_material_id  TYPE zde_material_id,
      mv_order_id     TYPE zde_order_id,
      mv_status       TYPE zde_order_status,
      mv_required_qty TYPE menge_d,
      mv_available_qty TYPE menge_d,
      mv_details      TYPE char255.

    METHODS constructor
      IMPORTING
        textid   LIKE if_t100_message=>t100key OPTIONAL
        previous LIKE previous OPTIONAL
        mv_customer_id  TYPE zde_customer_id OPTIONAL
        mv_material_id  TYPE zde_material_id OPTIONAL
        mv_order_id     TYPE zde_order_id OPTIONAL
        mv_status       TYPE zde_order_status OPTIONAL
        mv_required_qty TYPE menge_d OPTIONAL
        mv_available_qty TYPE menge_d OPTIONAL
        mv_details      TYPE char255 OPTIONAL.

  PROTECTED SECTION.
  PRIVATE SECTION.
ENDCLASS.

CLASS zcx_so_exception IMPLEMENTATION.
  METHOD constructor ##needed.
    super->constructor( previous = previous ).
    me->mv_customer_id   = mv_customer_id.
    me->mv_material_id   = mv_material_id.
    me->mv_order_id      = mv_order_id.
    me->mv_status        = mv_status.
    me->mv_required_qty  = mv_required_qty.
    me->mv_available_qty = mv_available_qty.
    me->mv_details       = mv_details.

    CLEAR me->textid.
    IF textid IS INITIAL.
      if_t100_message=>t100key = if_t100_message=>default_textid.
    ELSE.
      if_t100_message=>t100key = textid.
    ENDIF.
  ENDMETHOD.
ENDCLASS.
