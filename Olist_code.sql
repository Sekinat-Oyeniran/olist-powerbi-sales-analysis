USE  model 

SELECT *
FROM dbo.olist_products_dataset; 


SELECT * 
FROM olist_order_items_dataset; 

SELECT DISTINCT"""product_id"""
FROM dbo.olist_order_items_dataset; 

SELECT DISTINCT "product_category_name_english"
FROM dbo.product_category_name_translation; 

SELECT * 
FROM olist_order_payments_dataset;  

SELECT DISTINCT """order_id""" 
FROM olist_order_payments_dataset; 

SELECT * 
FROM olist_orders_dataset; 

 SELECT DISTINCT """order_id"""
FROM olist_orders_dataset;


SELECT product_category_name_english
FROM dbo.product_category_name_translation; 


SELECT * 
FROM dbo.olist_customers_dataset; 

SELECT DISTINCT """customer_state"""
FROM dbo.olist_customers_dataset;

SELECT * 
FROM dbo.olist_geolocation_dataset 

SELECT DISTINCT["geolocation_state"]
FROM dbo.olist_geolocation_dataset; 

SELECT * 
FROM dbo.olist_sellers_dataset;


SELECT DISTINCT ["seller_state"]
FROM dbo.olist_sellers_dataset; 


-- Find the total price of each product in descending order to verify the most popularly demanded products --

SELECT 
	product_category_name_english, 
	SUM(CAST(oi.["price"] AS NUMERIC(10, 2))) AS total_price
FROM 
	dbo.olist_order_items_dataset AS oi 
INNER JOIN dbo.olist_products_dataset AS pd  
ON oi.["product_id"] = pd.["product_id"] 
INNER JOIN dbo.product_category_name_translation AS pc 
ON pd.["product_category_name"] = pc.product_category_name
GROUP BY product_category_name_english 
ORDER BY total_price DESC;


-- The distribution of products within each state --

SELECT 
	aa.product_category_name_english, 
	aa.["seller_state"], 
	SUM(aa.[total_price]) AS overall_price
FROM(
	SELECT product_category_name_english, 
	["seller_state"],
	SUM(CAST(oi.["price"] AS NUMERIC(10, 2))) AS total_price
FROM 
	dbo.olist_order_items_dataset AS oi 
INNER JOIN dbo.olist_products_dataset AS pd  
ON oi.["product_id"] = pd.["product_id"] 
INNER JOIN dbo.product_category_name_translation AS pc 
ON pd.["product_category_name"] = pc.product_category_name
INNER JOIN olist_sellers_dataset AS sd 
ON oi.["seller_id"] = sd.["seller_id"] 
GROUP BY product_category_name_english, ["seller_state"]) aa
GROUP BY aa.product_category_name_english,aa.["seller_state"] 
ORDER BY overall_price DESC;  


-- Finding the sum of price by seller state in descending order --

SELECT 
    sd.["seller_state"], 
    SUM(CAST(oi.["price"] AS NUMERIC(10, 2))) AS total_price
FROM 
    dbo.olist_order_items_dataset AS oi 
INNER JOIN dbo.olist_products_dataset AS pd  
    ON oi.["product_id"] = pd.["product_id"] 
INNER JOIN dbo.product_category_name_translation AS pc 
    ON pd.["product_category_name"] = pc.product_category_name
INNER JOIN dbo.olist_sellers_dataset AS sd 
    ON oi.["seller_id"] = sd.["seller_id"] 
GROUP BY 
    sd.["seller_state"]
ORDER BY 
    total_price DESC;


-- Total Price Distribution Across Brazilian States and Cities --
SELECT 
    sd.["seller_state"],
    sd.["seller_city"],
    SUM(CAST(oi.["price"] AS NUMERIC(10, 2))) AS total_price
FROM 
    dbo.olist_order_items_dataset AS oi 
INNER JOIN dbo.olist_products_dataset AS pd  
    ON oi.["product_id"] = pd.["product_id"]
INNER JOIN dbo.product_category_name_translation AS pc 
    ON pd.["product_category_name"] = pc.product_category_name
INNER JOIN dbo.olist_sellers_dataset AS sd 
    ON oi.["seller_id"] = sd.["seller_id"] 
GROUP BY 
    sd.["seller_state"],
    sd.["seller_city"]
ORDER BY 
    total_price DESC;



-- Ranking these products to see the top 5 popularly demanded products in each state --

With top_five_products As 
(SELECT pc.product_category_name_english, sd.["seller_state"], SUM(CAST(oi.["price"] AS NUMERIC(10,2))) AS overall_price,
ROW_NUMBER() OVER(partition by sd.["seller_state"] ORDER BY SUM(CAST(oi.["price"] AS NUMERIC(10, 2))) DESC) AS state_rank
FROM dbo.olist_products_dataset AS pd
INNER JOIN dbo.product_category_name_translation AS pc
ON pd.["product_category_name"] = pc.product_category_name
INNER JOIN dbo.olist_order_items_dataset AS oi 
ON pd.["product_id"] = oi.["product_id"]
INNER JOIN dbo.olist_sellers_dataset AS sd
ON oi.["seller_id"] = sd.["seller_id"] 
GROUP BY pc.product_category_name_english, sd.["seller_state"]
)
 
SELECT product_category_name_english, ["seller_state"], overall_price, state_rank
FROM top_five_products 
WHERE state_rank <= 5
ORDER BY overall_price DESC; 


