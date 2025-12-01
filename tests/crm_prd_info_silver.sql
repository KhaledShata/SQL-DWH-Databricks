select * from `sales-crm-erp`.bronze.crm_prd_info;


-- Check for duplicates/Null values in primary key
select prd_id , count(*) from `sales-crm-erp`.bronze.crm_prd_info group by prd_id having count(*) > 1 or prd_id is null;
-- Nothing required


-- the category from another table id apparently is included in the prd_key ( first 5chars)
-- CO-RF CO is category, RF is subcategory
select prd_key from  `sales-crm-erp`.bronze.crm_prd_info; --      prd_key=CO-RF-FR-R92B-58
select distinct id from `sales-crm-erp`.bronze.erp_px_cat_g1v2; --    id=CO_RF
select * from `sales-crm-erp`.bronze.crm_sales_details; --       sls_prd_key=BK-R93R-62


-- Transformation Query: Adding category id and prd_key
select 
prd_id, 
prd_key,
REPLACE(substring(prd_key,1,5), '-', '_') as cat_id, -- to be able to join the two tables later  
substring(prd_key,7,LEN(prd_key)) as prd_key, -- to be able to join the two tables later  
prd_nm, 
prd_cost,
prd_line,
prd_start_dt, 
prd_end_dt
from `sales-crm-erp`.bronze.crm_prd_info;

--check for nulls or negative numbers
select * from `sales-crm-erp`.bronze.crm_prd_info where prd_nm!=TRIM(prd_nm);
select * from `sales-crm-erp`.bronze.crm_prd_info where prd_cost<0 or prd_cost is NULL;

-- Transformation Query: Replacing nulls with 0 in prd_cost
select 
prd_id, 
REPLACE(substring(prd_key,1,5), '-', '_') as cat_id, -- to be able to join the two tables later  
substring(prd_key,7,LEN(prd_key)) as prd_key, -- to be able to join the two tables later  
prd_nm, 
coalesce(prd_cost, 0) as prd_cost,
prd_line,
prd_start_dt, 
prd_end_dt
from `sales-crm-erp`.bronze.crm_prd_info;



-- check possible values in prd_line
select distinct prd_line from `sales-crm-erp`.bronze.crm_prd_info;

-- Transformation Query: Give friendly name to prd_line
select 
prd_id, 
REPLACE(substring(prd_key,1,5), '-', '_') as cat_id, -- to be able to join the two tables later  
substring(prd_key,7,LEN(prd_key)) as prd_key, -- to be able to join the two tables later  
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
prd_end_dt
from `sales-crm-erp`.bronze.crm_prd_info;

--check invalid date orders
-- FYI : start and end dates holds the product price within this range
--end date is null , means thats the current price 
select * from `sales-crm-erp`.bronze.crm_prd_info where prd_start_dt is null ; -- Rule start date cannot be null, no issue
select * from `sales-crm-erp`.bronze.crm_prd_info where prd_end_dt<prd_start_dt;
select * from `sales-crm-erp`.bronze.crm_prd_info where prd_key like 'AC-HE-HL-U509%';  -- for closer look

-- problem, end date should always be after start date
-- for every product ignore written end dates, the end date will be the next record start date -1 
select 
prd_id, 
prd_key,
prd_nm, 
prd_start_dt, 
prd_end_dt, 
LEAD(prd_start_dt) OVER(PArtition by prd_key order by prd_start_dt)-1 as prd_end_test
from `sales-crm-erp`.bronze.crm_prd_info
where prd_key like 'AC-HE-HL-U509%'; 

-- Transformation Query: New end date
select 
prd_id, 
REPLACE(substring(prd_key,1,5), '-', '_') as cat_id, -- to be able to join the two tables later  
substring(prd_key,7,LEN(prd_key)) as prd_key, -- to be able to join the two tables later  
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
------------------------------------------------
-- before insertion check if DDL needs to be modified ( here we added new column cat_id)
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

select * from `sales-crm-erp`.silver.crm_prd_info;

-- After insertion run quality checks by running all queries in this file but in silver layer not bronze


