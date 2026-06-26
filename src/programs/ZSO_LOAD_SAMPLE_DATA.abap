*&---------------------------------------------------------------------*
*& Report: ZSO_LOAD_SAMPLE_DATA
*& Description: Load demo customers, materials, and stock data
*&---------------------------------------------------------------------*
REPORT zso_load_sample_data.

SELECTION-SCREEN BEGIN OF BLOCK b1 WITH FRAME TITLE TEXT-001.
  PARAMETERS: p_clear AS CHECKBOX DEFAULT abap_false.
SELECTION-SCREEN END OF BLOCK b1.

INITIALIZATION.
  TEXT-001 = 'Options'.

START-OF-SELECTION.
  IF p_clear = abap_true.
    DELETE FROM zso_item.
    DELETE FROM zso_hdr.
    DELETE FROM zso_log.
    DELETE FROM zinv_stock.
    DELETE FROM zmat_master.
    DELETE FROM zcust_master.
    COMMIT WORK AND WAIT.
    MESSAGE 'Existing data cleared' TYPE 'S'.
  ENDIF.

  PERFORM load_customers.
  PERFORM load_materials.
  PERFORM load_stock.
  COMMIT WORK AND WAIT.
  MESSAGE 'Sample data loaded successfully' TYPE 'S'.

FORM load_customers.
  DATA lt_cust TYPE STANDARD TABLE OF zcust_master.
  lt_cust = VALUE #(
    ( customer_id = 'C0001' name = 'Acme Corporation'  city = 'New York'    country = 'US' )
    ( customer_id = 'C0002' name = 'Global Tech Ltd'   city = 'London'      country = 'GB' )
    ( customer_id = 'C0003' name = 'Sunrise Industries' city = 'Mumbai'     country = 'IN' )
    ( customer_id = 'C0004' name = 'Nordic Supplies'   city = 'Stockholm'   country = 'SE' )
    ( customer_id = 'C0005' name = 'Pacific Traders'   city = 'Singapore'   country = 'SG' )
  ).
  MODIFY zcust_master FROM TABLE lt_cust.
ENDFORM.

FORM load_materials.
  DATA lt_mat TYPE STANDARD TABLE OF zmat_master.
  lt_mat = VALUE #(
    ( material_id = 'MAT-001' description = 'Laptop Computer 15in'  price = '899.00'  uom = 'EA' currency = 'USD' )
    ( material_id = 'MAT-002' description = 'Wireless Mouse'        price = '29.99'   uom = 'EA' currency = 'USD' )
    ( material_id = 'MAT-003' description = 'USB-C Docking Station' price = '149.50'  uom = 'EA' currency = 'USD' )
    ( material_id = 'MAT-004' description = 'Monitor 27in 4K'       price = '449.00'  uom = 'EA' currency = 'USD' )
    ( material_id = 'MAT-005' description = 'Mechanical Keyboard'   price = '79.99'   uom = 'EA' currency = 'USD' )
    ( material_id = 'MAT-006' description = 'Office Chair Ergonomic' price = '349.00' uom = 'EA' currency = 'USD' )
    ( material_id = 'MAT-007' description = 'HDMI Cable 2m'       price = '12.99'   uom = 'EA' currency = 'USD' )
    ( material_id = 'MAT-008' description = 'Webcam HD 1080p'     price = '59.99'   uom = 'EA' currency = 'USD' )
  ).
  MODIFY zmat_master FROM TABLE lt_mat.
ENDFORM.

FORM load_stock.
  DATA lt_stock TYPE STANDARD TABLE OF zinv_stock.
  lt_stock = VALUE #(
    ( material_id = 'MAT-001' plant = '1000' storage_loc = '0001' stock_qty = '50'  uom = 'EA' )
    ( material_id = 'MAT-002' plant = '1000' storage_loc = '0001' stock_qty = '200' uom = 'EA' )
    ( material_id = 'MAT-003' plant = '1000' storage_loc = '0001' stock_qty = '75'  uom = 'EA' )
    ( material_id = 'MAT-004' plant = '1000' storage_loc = '0001' stock_qty = '30'  uom = 'EA' )
    ( material_id = 'MAT-005' plant = '1000' storage_loc = '0001' stock_qty = '100' uom = 'EA' )
    ( material_id = 'MAT-006' plant = '1000' storage_loc = '0001' stock_qty = '25'  uom = 'EA' )
    ( material_id = 'MAT-007' plant = '1000' storage_loc = '0001' stock_qty = '500' uom = 'EA' )
    ( material_id = 'MAT-008' plant = '1000' storage_loc = '0001' stock_qty = '80'  uom = 'EA' )
  ).
  MODIFY zinv_stock FROM TABLE lt_stock.
ENDFORM.
