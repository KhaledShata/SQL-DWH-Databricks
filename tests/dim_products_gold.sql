select 
pr.prd_id, 
pr.prd_key, 
pr.cat_id, 
pr.prd_nm, 
pr.prd_cost, 
pr.prd_line, 
pr.prd_start_dt, 
pr.prd_end_dt, -- we will remove this later
pc.CAT, 
pc.SUBCAT, 
pc.MAINTENANCE
from `sales-crm-erp`.silver.crm_prd_info pr
left join `sales-crm-erp`.silver.erp_px_cat_g1v2 pc on pr.cat_id = pc.ID
WHERE pr.prd_end_dt is null ; -- only keeping most recent active products ( based on business requirement)


-- check uniquness 
select prd_key, count(*) from (
select 
pr.prd_id, 
pr.prd_key, 
pr.cat_id, 
pr.prd_nm, 
pr.prd_cost, 
pr.prd_line, 
pr.prd_start_dt, 
pc.CAT, 
pc.SUBCAT, 
pc.MAINTENANCE
from `sales-crm-erp`.silver.crm_prd_info pr
left join `sales-crm-erp`.silver.erp_px_cat_g1v2 pc on pr.cat_id = pc.ID
WHERE pr.prd_end_dt is null )
group by prd_key having count(*) > 1;

----------
CREATE VIEW  `sales-crm-erp`.gold.dim_products AS 
select 
ROW_NUMBER() OVER (ORDER BY pr.prd_start_dt, pr.prd_key) as product_key, --surrogate primary key
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

select * from  `sales-crm-erp`.gold.dim_products;


