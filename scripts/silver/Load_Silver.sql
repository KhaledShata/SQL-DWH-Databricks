TRUNCATE TABLE `sales-crm-erp`.silver.crm_cust_info;
INSERT INTO `sales-crm-erp`.silver.crm_cust_info(
  cst_id, 
  cst_key, 
  cst_firstname, 
  cst_lastname, 
  cst_gndr, 
  cst_marital_status,
  cst_create_date
)
select 
cst_id, 
cst_key, 
TRIM(cst_firstname) as cst_firstname, 
TRIM(cst_lastname) as cst_lastname, 
CASE WHEN UPPER(TRIM(cst_gndr))='F' THEN 'Female' 
     WHEN UPPER(TRIM(cst_gndr))='M' THEN 'Male' 
     ELSE 'N/A' END as cst_gndr, 
CASE WHEN UPPER(TRIM(cst_marital_status))='S' THEN 'Single' 
     WHEN UPPER(TRIM(cst_marital_status)) ='M' THEN 'Married'
    ELSE 'N/A' END as cst_marital_status, 
cst_create_date
from (
select * , row_number() over (partition by cst_id order by cst_create_date desc) as recent_record
from `sales-crm-erp`.bronze.crm_cust_info
) where recent_record = 1 and cst_id is not null;



TRUNCATE TABLE `sales-crm-erp`.silver.crm_prd_info;
INSERT INTO `sales-crm-erp`.silver.crm_prd_info(
  prd_id, 
  prd_key,
  cat_id,
  prd_nm, 
  prd_cost,
  prd_line,
  prd_start_dt,
  prd_end_dt
)
select 
prd_id, 
substring(prd_key,7,LEN(prd_key)) as prd_key, -- to be able to join the two tables later  
REPLACE(substring(prd_key,1,5), '-', '_') as cat_id, -- to be able to join the two tables later  
prd_nm, 
coalesce(prd_cost, 0) as prd_cost,
CASE UPPER(TRIM(prd_line))
    WHEN 'M' THEN 'Mountain'
    WHEN 'R' THEN 'Road'
    WHEN 'S' THEN 'Other Sales'
    WHEN 'T' THEN 'Touring'
    ELSE 'N/A'
END AS prd_line,
prd_start_dt, 
LEAD(prd_start_dt) OVER(PArtition by prd_key order by prd_start_dt)-1 as prd_end_dt
from `sales-crm-erp`.bronze.crm_prd_info;


TRUNCATE TABLE `sales-crm-erp`.silver.crm_sales_details;
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

from `sales-crm-erp`.bronze.crm_sales_details;



TRUNCATE TABLE `sales-crm-erp`.silver.erp_cust_az12;
 INSERT INTO `sales-crm-erp`.silver.erp_cust_az12
 (CID,
 BDATE,
 GEN)
select 
CASE WHEN CID LIKE 'NAS%'  THEN SUBSTRING(CID,4,LEN(CID))
ELSE CID
END AS CID ,
CASE WHEN BDATE > GETDATE() THEN NULL
     ELSE BDATE
END AS BDATE,
CASE WHEN UPPER(TRIM(GEN)) IN ('M','MALE') THEN 'Male'
     WHEN UPPER(TRIM(GEN)) IN ('F','FEMALE') THEN 'Female'
     ELSE 'N/A' 
END AS GEN
FROM
 `sales-crm-erp`.bronze.erp_cust_az12;



TRUNCATE TABLE `sales-crm-erp`.silver.erp_loc_a101;
INSERT INTO `sales-crm-erp`.silver.erp_loc_a101
(CID,
CNTRY)
SELECT
REPLACE(CID, '-', '') AS CID, 
CASE WHEN UPPER(TRIM(CNTRY)) = 'DE' THEN 'Deutschland'
     WHEN UPPER(TRIM(CNTRY)) in ( 'US' , 'USA') THEN 'United States '
     WHEN TRIM(CNTRY) = '' OR CNTRY IS NULL THEN 'N/A'
    ELSE TRIM(CNTRY)
END AS CNTRY
FROM 
`sales-crm-erp`.bronze.erp_loc_a101;



TRUNCATE TABLE `sales-crm-erp`.silver.erp_px_cat_g1v2;
INSERT INTO`sales-crm-erp`.silver.erp_px_cat_g1v2
(ID,
CAT,
SUBCAT,
MAINTENANCE)
SELECT
ID,
CAT,
SUBCAT,
MAINTENANCE
FROM `sales-crm-erp`.bronze.erp_px_cat_g1v2;



