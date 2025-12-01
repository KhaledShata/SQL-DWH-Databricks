select * from `sales-crm-erp`.bronze.erp_cust_az12;

-- we should be able to join this table with crm_cust_info on CID
select COUNT(*) from  `sales-crm-erp`.bronze.erp_cust_az12 where CID LIKE 'NAS%';
select COUNT(*) from  `sales-crm-erp`.bronze.erp_cust_az12 where CID NOT LIKE 'NAS%';

-- however in erp_cust_az12 some records has an extra 'NAS' at the bginning of CID which needs to be removed

select CID FROM (
select 
CASE WHEN CID LIKE 'NAS%'  THEN SUBSTRING(CID,4,LEN(CID))
ELSE CID
END AS CID ,
BDATE,
GEN 
FROM
 `sales-crm-erp`.bronze.erp_cust_az12)
where CID NOT IN (Select distinct cst_key from `sales-crm-erp`.silver.crm_cust_info );


-- check out of rangec dates
select BDATE from  `sales-crm-erp`.bronze.erp_cust_az12
WHERE BDATE < '1924-01-01' OR BDATE > GETDATE();

-- we will replace bdates in future to null since that is 100% incorrect
select 
CASE WHEN CID LIKE 'NAS%'  THEN SUBSTRING(CID,4,LEN(CID))
ELSE CID
END AS CID ,
CASE WHEN BDATE > GETDATE() THEN NULL
     ELSE BDATE
END AS BDATE,
GEN 
FROM
 `sales-crm-erp`.bronze.erp_cust_az12;

-- check consistency in gen
select distinct GEN from `sales-crm-erp`.bronze.erp_cust_az12;

-- Clean up gen
select distinct GEN,
CASE WHEN UPPER(TRIM(GEN)) IN ('M','MALE') THEN 'Male'
     WHEN UPPER(TRIM(GEN)) IN ('F','FEMALE') THEN 'Female'
     ELSE 'N/A' 
END AS GEN
from `sales-crm-erp`.bronze.erp_cust_az12;

-- Transformation Query
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


 ---------------------------------
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

 SELECT * from `sales-crm-erp`.silver.erp_cust_az12;

