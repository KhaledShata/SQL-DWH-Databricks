select * from `sales-crm-erp`.bronze.crm_cust_info;


-- Check for duplicates/Null values in primary key
-- solution : Only choose the newest record in case of duplicates
select cst_id, Count(*) as count from `sales-crm-erp`.bronze.crm_cust_info
group by cst_id sort by count desc;

select * from `sales-crm-erp`.bronze.crm_cust_info where cst_id is null;
select * from `sales-crm-erp`.bronze.crm_cust_info where cst_id =29466; 

-- Transformation Query: lets keep most recent record of duplicates
select * from (
select * , row_number() over (partition by cst_id order by cst_create_date desc) as recent_record
from `sales-crm-erp`.bronze.crm_cust_info
) where recent_record = 1; --only keeping most recent record of customers


--check for extra spaces (for all string type fields)
-- solution : Trim all string fields
select cst_firstname from `sales-crm-erp`.bronze.crm_cust_info 
where cst_firstname != trim(cst_firstname);

select cst_lastname from `sales-crm-erp`.bronze.crm_cust_info 
where cst_lastname != trim(cst_lastname);
--etc

-- Transformation Query: lets trim all strings
select 
cst_id, 
cst_key, 
TRIM(cst_firstname) as cst_firstname, 
TRIM(cst_lastname) as cst_lastname, 
cst_gndr, 
cst_marital_status,  
cst_create_date
from (
select * , row_number() over (partition by cst_id order by cst_create_date desc) as recent_record
from `sales-crm-erp`.bronze.crm_cust_info
) where recent_record = 1 and cst_id is not null; --only keeping most recent record of customers


--check for consistensy and standarization
-- solution for our project : we wont use abbreivations ( F -- Female, M -- male)
select distinct cst_gndr from `sales-crm-erp`.bronze.crm_cust_info ;
select distinct cst_marital_status from `sales-crm-erp`.bronze.crm_cust_info ;

-- Transformation Query: Denormalizing Gender, marital status
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

-------------------------------------------------
-- Before insertion, make sure if DDL needs to be modified
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

Select * from `sales-crm-erp`.silver.crm_cust_info;
-- After insertion run quality checks by running all queries in this file but in silver layer not bronze



