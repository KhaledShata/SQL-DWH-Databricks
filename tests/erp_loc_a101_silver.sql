select * from `sales-crm-erp`.bronze.erp_loc_a101;

-- we should be able ot join this table with crm_cust_info on cst_key = CID
select cst_key from `sales-crm-erp`.silver.crm_cust_info;

-- Removing extra dash from cid to be able to join
SELECT
REPLACE(CID, '-', '') AS CID, 
CNTRY
FROM 
`sales-crm-erp`.bronze.erp_loc_a101
WHERE REPLACE(CID, '-', '') NOT IN (select distinct cst_key from `sales-crm-erp`.silver.crm_cust_info);

--checking cntry
SELECT
distinct CNTRY
FROM 
`sales-crm-erp`.bronze.erp_loc_a101;

-- fixing null, abbreviations,inconsistnecy
SELECT
REPLACE(CID, '-', '') AS CID, 
CASE WHEN UPPER(TRIM(CNTRY)) = 'DE' THEN 'Deutschland'
     WHEN UPPER(TRIM(CNTRY)) in ( 'US' , 'USA') THEN 'United States '
     WHEN TRIM(CNTRY) = '' OR CNTRY IS NULL THEN 'N/A'
    ELSE TRIM(CNTRY)
END AS CNTRY
FROM 
`sales-crm-erp`.bronze.erp_loc_a101;

-----------------------------------------
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



