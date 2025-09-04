/*
==================================================================================
Quality Checks
==================================================================================
Script Purpose:
  This script performs various quality checks for data consistency, accuracy,
  and standarization across the 'silver' schemas. It includes checks for:
  -  Null or duplicate primary keys.
  -  Unwanted spaces in string fields.
  -  Data standarization and Consistency,
  -  Invalid date ranges and orders.
  -  Data consistency between related fields.

Usage Notes:
  -  Run these checks after data loading Silver layer.
  -  Investigate and resolver any discrepancies found during the checks.
==================================================================================
*/


/* 
=========================================
REVISANDO INFORMACION TABLA crm_cust_info
=========================================
*/

----------------
--Bronze Layer--
----------------

SELECT * FROM bronze.crm_cust_info

-- Revisar nulos o duplicados en primary key
-- Expectation: No Result
SELECT cst_id, COUNT(*)
FROM bronze.crm_cust_info
GROUP BY cst_id
HAVING COUNT(*) > 1 OR cst_id IS NULL


-- Check for unwanted spaces (each column)
-- Expectation: No Results
SELECT cst_firstname
FROM bronze.crm_cust_info
WHERE cst_firstname != TRIM(cst_firstname)


-- Data Standarization & Consistency
SELECT DISTINCT cst_marital_status
FROM bronze.crm_cust_info


----------------
--Silver Layer--
----------------

SELECT * FROM silver.crm_cust_info

-- Revisar nulos o duplicados en primary key
-- Expectation: No Result
SELECT cst_id, COUNT(*)
FROM silver.crm_cust_info
GROUP BY cst_id
HAVING COUNT(*) > 1 OR cst_id IS NULL


-- Check for unwanted Spaces (each column)
-- Expectation: No Results
SELECT cst_firstname
FROM silver.crm_cust_info
WHERE cst_firstname != TRIM(cst_firstname)


-- Data Standarization & Consistency
SELECT DISTINCT cst_gndr
FROM silver.crm_cust_info



/* 
========================================
REVISANDO INFORMACION TABLA crm_prd_info
========================================
*/

----------------
--Bronze Layer--
----------------

SELECT * FROM bronze.crm_prd_info

-- Revisar nulos o duplicados en primary key
-- Expectation: No Result
SELECT prd_id, COUNT(*)
FROM bronze.crm_prd_info
GROUP BY prd_id
HAVING COUNT(*) > 1 OR prd_id IS NULL


-- Check for unwanted spaces (each column)
-- Expectation: No Results
SELECT prd_nm
FROM bronze.crm_prd_info
WHERE prd_nm != TRIM(prd_nm)


-- Check for NULLs or Negative Numbers
-- Expectation: No Results
SELECT prd_cost
FROM bronze.crm_prd_info
WHERE prd_cost <0 OR prd_cost IS NULL


-- Data Standarization & Consistency
SELECT DISTINCT prd_line
FROM bronze.crm_prd_info


-- Check for invalid Date Orders
SELECT * 
FROM bronze.crm_prd_info
WHERE prd_start_dt > prd_end_dt

----------------
--Silver Layer--
----------------

SELECT * FROM silver.crm_prd_info

-- Revisar nulos o duplicados en primary key
-- Expectation: No Result
SELECT prd_id, COUNT(*)
FROM silver.crm_prd_info
GROUP BY prd_id
HAVING COUNT(*) > 1 OR prd_id IS NULL


-- Check for unwanted spaces (each column)
-- Expectation: No Results
SELECT prd_nm
FROM silver.crm_prd_info
WHERE prd_nm != TRIM(prd_nm)


-- Check for NULLs or Negative Numbers
-- Expectation: No Results
SELECT prd_cost
FROM silver.crm_prd_info
WHERE prd_cost <0 OR prd_cost IS NULL


-- Data Standarization & Consistency
SELECT DISTINCT prd_line
FROM silver.crm_prd_info


-- Check for invalid Date Orders
SELECT * 
FROM silver.crm_prd_info
WHERE prd_start_dt > prd_end_dt


/* 
=============================================
REVISANDO INFORMACION TABLA crm_sales_details
=============================================
*/

----------------
--Bronze Layer--
----------------

SELECT * FROM bronze.crm_sales_details

-- Revisar fechas invalidas
SELECT 
NULLIF(sls_order_dt, 0) AS sls_order_dt  -- NULLIF: si el valor es nulo, lo reemplaza (por 0)
FROM bronze.crm_sales_details
WHERE sls_order_dt <= 0
OR LEN(sls_order_dt) != 8
OR sls_order_dt > 20500101  -- Revisando outliers superiores
OR sls_order_dt < 19000101  -- Revisando outliers inferiores


-- Revisar que la fecha de orden no sea mayor que la fecha ship y due
SELECT * 
FROM bronze.crm_sales_details
WHERE sls_order_dt > sls_ship_dt OR sls_order_dt > sls_due_dt


-- Revisar consistencia de datos: entre Sales, Quantity y Price
-- >> Sales = Quantity * Price
-- >> Los valores no deberian ser NULL, zero or negative
SELECT DISTINCT 
	sls_sales AS old_sls_sales,
	sls_quantity,
	sls_price AS old_sls_price,

	CASE WHEN sls_sales IS NULL OR sls_sales <= 0 OR sls_sales != sls_quantity * ABS(sls_price) THEN sls_quantity * ABS(sls_price)
		ELSE sls_sales
	END AS sls_sales,
	CASE WHEN sls_price IS NULL OR sls_price <= 0 THEN sls_sales/NULLIF(sls_quantity,0)
		ELSE sls_price
	END AS sls_price

FROM bronze.crm_sales_details
WHERE sls_sales != sls_quantity * sls_price
OR sls_sales IS NULL OR sls_quantity IS NULL OR sls_price IS NULL
OR sls_sales <= 0 OR sls_quantity <= 0 OR sls_price <= 0
ORDER BY sls_sales, sls_quantity, sls_price


----------------
--Silver Layer--
----------------

SELECT * FROM silver.crm_prd_info

-- Revisar que la fecha de orden no sea mayor que la fecha ship y due
SELECT * 
FROM silver.crm_sales_details
WHERE sls_order_dt > sls_ship_dt OR sls_order_dt > sls_due_dt


-- Revisar consistencia de datos: entre Sales, Quantity y Price
-- >> Sales = Quantity * Price
-- >> Los valores no deberian ser NULL, zero or negative
SELECT DISTINCT 
	sls_sales,
	sls_quantity,
	sls_price
FROM silver.crm_sales_details
WHERE sls_sales != sls_quantity * sls_price
OR sls_sales IS NULL OR sls_quantity IS NULL OR sls_price IS NULL
OR sls_sales <= 0 OR sls_quantity <= 0 OR sls_price <= 0
ORDER BY sls_sales, sls_quantity, sls_price



/* 
=============================================
REVISANDO INFORMACION TABLA erp_cust_az12
=============================================
*/

----------------
--Bronze Layer--
----------------

-- Identificar fechas fuera de rango
SELECT DISTINCT
bdate
FROM bronze.erp_cust_az12
WHERE BDATE < '1924-01-01' OR BDATE > GETDATE()


-- Data standarization & Consistency
SELECT DISTINCT gen
FROM bronze.erp_cust_az12


----------------
--Silver Layer--
----------------

-- Identificar fechas fuera de rango
SELECT DISTINCT
bdate
FROM silver.erp_cust_az12
WHERE BDATE < '1924-01-01' OR BDATE > GETDATE() -- Se mantiene a los clientes más viejos


-- Data standarization & Consistency
SELECT DISTINCT gen
FROM silver.erp_cust_az12



/* 
=========================================
REVISANDO INFORMACION TABLA erp_loc_a101
=========================================
*/

----------------
--Bronze Layer--
----------------

-- Data standarization & Consistency
SELECT DISTINCT 
	CNTRY
FROM bronze.erp_loc_a101
ORDER BY cntry


----------------
--Silver Layer--
----------------

-- Data standarization & Consistency
SELECT DISTINCT 
	CNTRY
FROM silver.erp_loc_a101


/* 
===========================================
REVISANDO INFORMACION TABLA erp_px_cat_g1v2
===========================================
*/

----------------
--Bronze Layer--
----------------

-- Check for unwanted spaces (each column)
SELECT * FROM bronze.erp_px_cat_g1v2
WHERE CAT != TRIM(CAT) OR SUBCAT != TRIM(SUBCAT) OR MAINTENANCE != TRIM(MAINTENANCE)

-- Data standarization & Consistency
SELECT DISTINCT 
	MAINTENANCE
FROM bronze.erp_px_cat_g1v2
