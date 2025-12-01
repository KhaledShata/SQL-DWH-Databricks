/*
===============================================================================
DDL Script: Create Silver Tables
===============================================================================
Script Purpose:
    This script creates tables in the 'silver' schema, dropping existing tables 
    if they already exist.
	  Run this script to re-define the DDL structure of 'bronze' Tables
===============================================================================
*/

-- Table: erp_cust_az12 --
DROP TABLE IF EXISTS `sales-crm-erp`.silver.erp_cust_az12;

CREATE TABLE `sales-crm-erp`.silver.erp_cust_az12 (
  CID STRING,
  BDATE DATE,
  GEN STRING,
  dwh_create_date TIMESTAMP DEFAULT current_timestamp()
)
USING delta
TBLPROPERTIES ('delta.feature.allowColumnDefaults' = 'supported');




-- Table: crm_sales_details --
DROP TABLE IF EXISTS `sales-crm-erp`.silver.crm_sales_details;

CREATE TABLE `sales-crm-erp`.silver.crm_sales_details (
  sls_ord_num STRING,
  sls_prd_key STRING,
  sls_cust_id STRING,
  sls_order_dt DATE,
  sls_ship_dt DATE,
  sls_due_dt DATE,
  sls_sales BIGINT,
  sls_quantity BIGINT,
  sls_price BIGINT,
  dwh_create_date TIMESTAMP DEFAULT current_timestamp()
)
USING delta
TBLPROPERTIES ('delta.feature.allowColumnDefaults' = 'supported');



-- Table: erp_px_cat_g1v2 --
DROP TABLE IF EXISTS `sales-crm-erp`.silver.erp_px_cat_g1v2;

CREATE TABLE `sales-crm-erp`.silver.erp_px_cat_g1v2 (
  ID STRING,
  CAT STRING,
  SUBCAT STRING,
  MAINTENANCE STRING,
  dwh_create_date TIMESTAMP DEFAULT current_timestamp()
)
USING delta
TBLPROPERTIES ('delta.feature.allowColumnDefaults' = 'supported');




-- Table: crm_prd_info --
DROP TABLE IF EXISTS `sales-crm-erp`.silver.crm_prd_info;

CREATE TABLE `sales-crm-erp`.silver.crm_prd_info (
  prd_id BIGINT,
  prd_key STRING,
  cat_id STRING,
  prd_nm STRING,
  prd_cost BIGINT,
  prd_line STRING,
  prd_start_dt DATE,
  prd_end_dt DATE,
  dwh_create_date TIMESTAMP DEFAULT current_timestamp()
)
USING delta
TBLPROPERTIES ('delta.feature.allowColumnDefaults' = 'supported');




-- Table: crm_cust_info --
DROP TABLE IF EXISTS `sales-crm-erp`.silver.crm_cust_info;

CREATE TABLE `sales-crm-erp`.silver.crm_cust_info (
  cst_id STRING,
  cst_key STRING,
  cst_firstname STRING,
  cst_lastname STRING,
  cst_marital_status STRING,
  cst_gndr STRING,
  cst_create_date DATE,
  dwh_create_date TIMESTAMP DEFAULT current_timestamp()
)
USING delta
TBLPROPERTIES ('delta.feature.allowColumnDefaults' = 'supported');




-- Table: erp_loc_a101 --
DROP TABLE IF EXISTS `sales-crm-erp`.silver.erp_loc_a101;

CREATE TABLE `sales-crm-erp`.silver.erp_loc_a101 (
  CID STRING,
  CNTRY STRING,
  dwh_create_date TIMESTAMP DEFAULT current_timestamp()
)
USING delta
TBLPROPERTIES ('delta.feature.allowColumnDefaults' = 'supported');


