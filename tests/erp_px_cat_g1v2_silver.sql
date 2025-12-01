select * from `sales-crm-erp`.bronze.erp_px_cat_g1v2;

-- we should be able to connect this table with cat_id on prd_key and ID
select cat_id from  `sales-crm-erp`.silver.crm_prd_info;
select ID from  `sales-crm-erp`.bronze.erp_px_cat_g1v2;



-- check unwanted spaces
select CAT from `sales-crm-erp`.bronze.erp_px_cat_g1v2
WHERE CAT!=TRIM(CAT) or SUBCAT!=TRIM(SUBCAT) or MAINTENANCE!=TRIM(MAINTENANCE);


-- check maintainance consistency
select distinct CAT from `sales-crm-erp`.bronze.erp_px_cat_g1v2;
select distinct SUBCAT from `sales-crm-erp`.bronze.erp_px_cat_g1v2;
select distinct MAINTENANCE from `sales-crm-erp`.bronze.erp_px_cat_g1v2;

-- all is good, no transformation required
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


select * from `sales-crm-erp`.silver.erp_px_cat_g1v2;

