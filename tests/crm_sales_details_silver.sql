select * from `sales-crm-erp`.bronze.crm_sales_details;

-- check for extra spaces
select * from `sales-crm-erp`.bronze.crm_sales_details
where sls_ord_num!=TRIM(sls_ord_num);

-- check whether sls_prd_key can be joined successfully with crm_prd_info
select * from `sales-crm-erp`.bronze.crm_sales_details
where sls_prd_key NOT IN (SELECT prd_key from `sales-crm-erp`.silver.crm_prd_info);

-- check whether sls_cust_id can be joined successfully with crm_cust_info
select * from `sales-crm-erp`.bronze.crm_sales_details
where sls_cust_id NOT IN (SELECT cst_id from `sales-crm-erp`.silver.crm_cust_info);

-- Checking Dates attributes 
select sls_order_dt from `sales-crm-erp`.bronze.crm_sales_details
where sls_order_dt<=0;

--converting 0 to nulls in dates
select NULLIF(sls_order_dt,0) as sls_order_dt from `sales-crm-erp`.bronze.crm_sales_details
where sls_order_dt<=0;

-- dates are written as 20101229 
--check that all of them are of length 8 before transformation
select NULLIF(sls_order_dt,0) as sls_order_dt from `sales-crm-erp`.bronze.crm_sales_details where sls_order_dt<=0 or LEN(sls_order_dt)!=8;

-- you can check also for date range depending on our business
select NULLIF(sls_order_dt,0) as sls_order_dt from `sales-crm-erp`.bronze.crm_sales_details where sls_order_dt>20500101 or sls_order_dt<20050101;

--Check for invalid date order
select * from `sales-crm-erp`.bronze.crm_sales_details where sls_order_dt>sls_ship_dt or sls_ship_dt>sls_due_dt;


-- Transformation Query: Fixing dates issue 20101229 to 2010-12-29
select 
sls_ord_num,
sls_prd_key,
sls_cust_id, 

CASE WHEN sls_order_dt=0 or LEN(sls_order_dt)!=8 THEN NULL 
     ELSE to_date(CAST(sls_order_dt AS STRING), 'yyyyMMdd')
END AS sls_order_dt,

CASE WHEN sls_ship_dt=0 or LEN(sls_ship_dt)!=8 THEN NULL 
     ELSE to_date(CAST(sls_ship_dt AS STRING), 'yyyyMMdd')
END AS sls_ship_dt,

CASE WHEN sls_due_dt=0 or LEN(sls_due_dt)!=8 THEN NULL 
    ELSE to_date(CAST(sls_due_dt AS STRING), 'yyyyMMdd')
END AS sls_due_dt, 
sls_sales, 
sls_quantity, 
sls_price 
from 
`sales-crm-erp`.bronze.crm_sales_details;


-- Checking Sales, QUantity , Price 
--  sales = Quantity * Price ( negative zeros, nulls are not allowed)
select sls_sales,sls_quantity,sls_price from `sales-crm-erp`.bronze.crm_sales_details 
where sls_sales != sls_quantity*sls_price 
or sls_sales is NULL or sls_quantity is NULL or sls_price is NULL
or sls_sales <=0 or sls_quantity <=0 or sls_price <=0
order by sls_sales,sls_quantity,sls_price;

-- communicating with business about issues in sls_sales, sls_price
-- if sales is -ve,null,zero then derive it using quantity and price
-- if price is zero,null then derive it using sales and quantity
-- if price is negative, convert it to positive
select * from (
select 
sls_sales as old_sls_sales,
CASE WHEN sls_sales IS NULL OR sls_sales <=0 OR sls_sales!=sls_quantity*ABS(sls_price) THEN sls_quantity*ABS(sls_price)
ELSE sls_sales
END AS sls_sales,
sls_quantity,
sls_price as old_sls_price,
CASE WHEN sls_price IS NULL OR sls_price <=0 THEN sls_sales/NULLIF(sls_quantity,0)
    ELSE sls_price
END AS sls_price
from `sales-crm-erp`.bronze.crm_sales_details 
)
where old_sls_sales!=sls_sales or old_sls_price!=sls_price;


------------------------------------------------
-- before insertion check if DDL needs to be modified ( here now order_dt,ship_dt,due_dt are dates not integers)
INSERT INTO `sales-crm-erp`.silver.crm_sales_details
(sls_ord_num,
sls_prd_key,
sls_cust_id, 
sls_order_dt,
sls_ship_dt,
sls_due_dt, 
sls_sales,
sls_quantity,
sls_price)

select 
sls_ord_num,
sls_prd_key,
sls_cust_id, 

CASE WHEN sls_order_dt=0 or LEN(sls_order_dt)!=8 THEN NULL 
     ELSE to_date(CAST(sls_order_dt AS STRING), 'yyyyMMdd')
END AS sls_order_dt,

CASE WHEN sls_ship_dt=0 or LEN(sls_ship_dt)!=8 THEN NULL 
     ELSE to_date(CAST(sls_ship_dt AS STRING), 'yyyyMMdd')
END AS sls_ship_dt,

CASE WHEN sls_due_dt=0 or LEN(sls_due_dt)!=8 THEN NULL 
    ELSE to_date(CAST(sls_due_dt AS STRING), 'yyyyMMdd')
END AS sls_due_dt, 

CASE WHEN sls_sales IS NULL OR sls_sales <=0 OR sls_sales!=sls_quantity*ABS(sls_price)  THEN sls_quantity*ABS(sls_price)
     ELSE sls_sales
END AS sls_sales,

sls_quantity, 
CASE WHEN sls_price IS NULL OR sls_price <=0 THEN sls_sales/NULLIF(sls_quantity,0)
     ELSE sls_price
END AS sls_price
 
from 
`sales-crm-erp`.bronze.crm_sales_details;

-- After insertion run quality checks by running all queries in this file but in silver layer not bronze


