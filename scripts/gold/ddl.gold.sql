CREATE VIEW gold.dim_customers AS
SELECT ROW_NUMBER() OVER(ORDER BY ci.cst_id) AS customer_key,
		ci.[cst_id] AS customer_id,
		ci.[cst_key] AS customer_number,
		ci.[cst_firstname] AS first_name,
		ci.[cst_lastname] AS last_name,
		la.CNTRY AS country,
		ci.[cst_marital_status] AS marital_status,
	    CASE WHEN cst_gndr != 'n/a' THEN ci.[cst_gndr]
				ELSE COALESCE(ca.GEN, 'n/a')
		END AS gender,
		ca.BDATE AS birthdate,
		ci.[cst_create_date] AS create_date	
FROM silver.crm_cust_info AS ci
LEFT JOIN silver.erp_cust_az12 AS ca
ON ci.[cst_key] = ca.CID
LEFT JOIN silver.erp_loc_a101 AS la
ON ci.[cst_key] = la.CID;


CREATE VIEW gold.dim_product AS
SELECT  ROW_NUMBER() OVER(ORDER BY prd_start_dt,prd_key ) AS product_key,
		prd_id AS product_id,
        prd_key AS product_number,
		prd_nm AS product_name,
		cat_id AS category_id,
		cat AS category,
		SUBCAT AS subcategory,
		maintenance,
		prd_cost AS cost,
		prd_line AS product_line,
		prd_start_dt AS start_date
FROM silver.crm_prd_info AS ci
LEFT JOIN silver.erp_px_cat_g1v2 AS eg
ON ci.cat_id = eg.ID
WHERE prd_end_dt IS NULL;


CREATE VIEW gold.fact_sales AS
SELECT [sls_ord_num] AS order_number,
		product_key,
		customer_key,
		[sls_order_dt] AS order_date,
		[sls_ship_dt] AS shipping_date,
		[sls_due_dt] AS due_date,
		[sls_sales] AS sales_amount,
		[sls_quantity] AS quantity,
		[sls_price] AS price
FROM silver.crm_sales_details
LEFT JOIN gold.dim_product
ON sls_prd_key = product_number
LEFT JOIN gold.dim_customers
ON sls_cust_id = customer_id;
