select 
ci.cst_id, 
ci.cst_key,
ci.cst_firstname,
ci.cst_lastname,
ci.cst_marital_status,
ci.cst_gndr,
ci.cst_create_date,
cj.BDATE, 
cj.GEN,
ck.CNTRY
from `sales-crm-erp`.silver.crm_cust_info ci
left join `sales-crm-erp`.silver.erp_cust_az12 cj on ci.cst_key=cj.CID
left join `sales-crm-erp`.silver.erp_loc_a101 ck on ci.cst_key=ck.CID;
 -- left join because if somecustomers doesnt have birthday date saved i also want to retrieve them

-- check for duplicate records 
select cst_id, count(*)
from (
    select 
ci.cst_id, 
ci.cst_key,
ci.cst_firstname,
ci.cst_lastname,
ci.cst_marital_status,
ci.cst_gndr,
ci.cst_create_date,
cj.BDATE, 
cj.GEN,
ck.CNTRY
from `sales-crm-erp`.silver.crm_cust_info ci
left join `sales-crm-erp`.silver.erp_cust_az12 cj on ci.cst_key=cj.CID
left join `sales-crm-erp`.silver.erp_loc_a101 ck on ci.cst_key=ck.CID
) group by cst_id having count(*)>1;


-- We have two tables giving the gender info, we must do data integration, lets check confliction at the beggining
select distinct
ci.cst_gndr,
cj.GEN
from `sales-crm-erp`.silver.crm_cust_info ci
left join `sales-crm-erp`.silver.erp_cust_az12 cj on ci.cst_key=cj.CID 
left join `sales-crm-erp`.silver.erp_loc_a101 ck on ci.cst_key=ck.CID;
-- suppose we got back the business and they said crm is more accurate than erp
select distinct
ci.cst_gndr,
cj.GEN, 
CASE WHEN ci.cst_gndr!='N/A' THEN ci.cst_gndr
     ELSE coalesce(cj.GEN, 'N/A')
END AS GENDER
from `sales-crm-erp`.silver.crm_cust_info ci
left join `sales-crm-erp`.silver.erp_cust_az12 cj on ci.cst_key=cj.CID 
left join `sales-crm-erp`.silver.erp_loc_a101 ck on ci.cst_key=ck.CID;

-----------------
--Finaliyizing and Giving friendly names ( Following Name Convension), also decide columns order
DROP VIEW IF EXISTS  `sales-crm-erp`.gold.dim_customers;

CREATE VIEW `sales-crm-erp`.gold.dim_customers AS
select 
ROW_NUMBER() OVER (ORDER BY cst_id) AS customer_key, --adding surrogate key
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



