select 
sls_ord_num,
sls_prd_key, 
sls_cust_id, 
sls_order_dt, 
sls_ship_dt, 
sls_due_dt, 
sls_sales, 
sls_quantity,
sls_price
from  `sales-crm-erp`.silver.crm_sales_details;

CREATE VIEW `sales-crm-erp`.gold.fact_sales AS 
select 
sls_ord_num as order_number,
pr.product_key, -- we removed the sls_prd_key and instead got the surrogate key from the other table to join on
cu.customer_key, -- we removed the sls_cust_id and instead got the surrogate key from the other table to join on
sls_order_dt as order_date, 
sls_ship_dt as shipping_date, 
sls_due_dt as due_date, 
sls_sales as sales_amount, 
sls_quantity as quantity,
sls_price as price
from  `sales-crm-erp`.silver.crm_sales_details sd
left join `sales-crm-erp`.gold.dim_products pr on sd.sls_prd_key = pr.product_number
left join `sales-crm-erp`.gold.dim_customers cu on sd.sls_cust_id = cu.customer_id;


