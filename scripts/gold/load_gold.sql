/*
===============================================================================
DDL Script: Create Gold Views
===============================================================================
Script Purpose:
    This script creates views for the Gold layer in the data warehouse. 
    The Gold layer represents the final dimension and fact tables (Star Schema)

    Each view performs transformations and combines data from the Silver layer 
    to produce a clean, enriched, and business-ready dataset.

Usage:
    - These views can be queried directly for analytics and reporting.
===============================================================================
*/
DROP VIEW IF EXISTS  `sales-crm-erp`.gold.dim_customers;
CREATE VIEW `sales-crm-erp`.gold.dim_customers AS
select 
ROW_NUMBER() OVER (ORDER BY cst_id) AS customer_key, 
ci.cst_id AS customer_id, 
ci.cst_key AS customer_number,
ci.cst_firstname AS first_name,
ci.cst_lastname AS last_name,
ck.CNTRY as country,
ci.cst_marital_status as marital_status,
CASE WHEN ci.cst_gndr!='N/A' THEN ci.cst_gndr
     ELSE coalesce(cj.GEN, 'N/A')
END AS gender,
cj.BDATE as birthdate,
ci.cst_create_date as create_date
from `sales-crm-erp`.silver.crm_cust_info ci
left join `sales-crm-erp`.silver.erp_cust_az12 cj on ci.cst_key=cj.CID
left join `sales-crm-erp`.silver.erp_loc_a101 ck on ci.cst_key=ck.CID;




DROP VIEW IF EXISTS  `sales-crm-erp`.gold.dim_products;
CREATE VIEW  `sales-crm-erp`.gold.dim_products AS 
select 
ROW_NUMBER() OVER (ORDER BY pr.prd_start_dt, pr.prd_key) as product_key,
pr.prd_id as product_id, 
pr.prd_key as product_number, 
pr.prd_nm as product_name, 
pr.cat_id as category_id, 
pc.CAT as category, 
pc.SUBCAT as subcategory, 
pc.MAINTENANCE,
pr.prd_cost as cost, 
pr.prd_line as product_line, 
pr.prd_start_dt as start_date
from `sales-crm-erp`.silver.crm_prd_info pr
left join `sales-crm-erp`.silver.erp_px_cat_g1v2 pc on pr.cat_id = pc.ID
WHERE pr.prd_end_dt is null ;  




DROP VIEW IF EXISTS  `sales-crm-erp`.gold.fact_sales;
CREATE VIEW `sales-crm-erp`.gold.fact_sales AS 
select 
sls_ord_num as order_number,
pr.product_key, 
cu.customer_key, 
sls_order_dt as order_date, 
sls_ship_dt as shipping_date, 
sls_due_dt as due_date, 
sls_sales as sales_amount, 
sls_quantity as quantity,
sls_price as price
from  `sales-crm-erp`.silver.crm_sales_details sd
left join `sales-crm-erp`.gold.dim_products pr on sd.sls_prd_key = pr.product_number
left join `sales-crm-erp`.gold.dim_customers cu on sd.sls_cust_id = cu.customer_id;




