# 🎯👤 Customer Analysis
## 🖇️ Question 1 :
### Which cities do customers shop more in? Determine the customer's city with the highest number of orders and perform the analysis based on that.
````sql
with order_counts as (
        select o.customer_id,
               customer_city,
               count(order_id) as order_count
          from orders as o
          left join customers as c
            on c.customer_id = o.customer_id
         group by 1,2
         order by 3 desc
       ),
       customer_city_rn as (
        select row_number() over (partition by customer_id order by order_count desc) as rn,
               customer_id,
               customer_city
          from order_counts
       ),
       customer_city as (
        select customer_id,
               customer_city
          from customer_city_rn
         where rn = 1
       ) 
select cc.customer_city,
       count(o.order_id) as order_count
  from orders as o
  left join customer_city as cc
    on o.customer_id = cc.customer_id
 group by 1
 order by 2 desc
````
| customer_city         | order_count |
|-----------------------|-------------|
| sao paulo             | 15,540      |
| rio de janeiro        | 6,882       |
| belo horizonte        | 2,773       |
| brasilia              | 2,131       |
| curitiba              | 1,521       |
| campinas              | 1,444       |
| porto alegre          | 1,379       |
| salvador              | 1,245       |
| guarulhos             | 1,189       |
| sao bernardo do campo | 938         |

## ❗ the first ten lines are shown.

## 🖇️ Question 2 :
### Examine orders based on customers and their categories. Do customers typically order products from the same category. Calculate the order category percentage for each customer.

### Examining customer-specific orders and their categories.
````sql
select 
	c.customer_id as customer_count,
	count(o.order_id) as order_count,
	p.product_category_name	
from customers as c
left join orders as o 
	on o.customer_id=c.customer_id
left join order_items as oi 
	on oi.order_id=o.order_id
left join products as p 
	on p.product_id=oi.product_id
group by 1,3
order by 2 desc
````
| customer_count                        | order_count | product_category_name    |
|---------------------------------------|-------------|--------------------------|
| fc3d1daec319d62d49bfb5e1f83123e9      | 21          | beleza_saude             |
| bd5d39761aa56689a265d95d8d32b8be      | 20          | automotivo               |
| be1b70680b9f9694d8c70f41fa3dc92b      | 20          | informatica_acessorios   |
| adb32467ecc74b53576d9d13a5a55891      | 15          | ferramentas_jardim       |
| 10de381f8a8d23fff822753305f71cae      | 15          | moveis_decoracao         |
| a7693fba2ff9583c78751f2b66ecab9d      | 14          | telefonia                |
| d5f2b3f597c7ccafbb5cac0bcc3d6024      | 14          | ferramentas_jardim       |
| 7d321bd4e8ba1caf74c4c1aabd9ae524      | 13          | telefonia                |
| 9eb3d566e87289dcb0acf28e1407c839      | 12          | utilidades_domesticas    |
| 91f92cfee46b79581b05aa974dd57ce5      | 12          | relogios_presentes       |

## ❗ the first ten lines are shown.

## 🖇️ Question 3 :
### Calculate the order category percentage for each customer. For example, if customer X has 20 orders, and this person placed 10 of them (50%) in the fashion category, 6 of them (30%) in the cosmetics category, and 4 of them (20%) in the food category.

###Calculating and analyzing the order category percentage of customers total order counts by categories.
````sql
with customer_order as
	(
		select 
			distinct c.customer_unique_id,
			p.product_category_name,
			count(distinct o.order_id) as order_count
		from customers as c
		left join orders as o 
	 		on o.customer_id = c.customer_id
		left join order_items as oi 
	 		on oi.order_id = o.order_id
		left join products as p 
	 		on p.product_id = oi.product_id
		group by 1,2
		order by 3 desc
	),
	customers_total_order as
	(
		select 
			distinct c.customer_unique_id,
			count(distinct o.order_id) as order_count_
		from customers as c
		left join orders as o 
			on o.customer_id = c.customer_id
		group by 1
		order by order_count_ desc
	)
select 
	co.customer_unique_id,
	co.product_category_name,
	co.order_count,
	cto.order_count_,
	row_number() over (partition by co.customer_unique_id order by co.order_count desc) as row_number,
	round((co.order_count * 1.0 / cto.order_count_ * 1.0),2)*100 as category_ratio
from customer_order as co
left join customers_total_order as cto 
	on cto.customer_unique_id = co.customer_unique_id
order by cto.order_count_ desc
````
| customer_unique_id              | product_category_name                  | order_count | order_count_ | row_number | category_ratio |
|--------------------------------|----------------------------------------|-------------|--------------|------------|----------------|
| 8d50f5eadf50201ccdcedfb9e2ac8455 | esporte_lazer                          | 11          | 17           | 1          | 65.00          |
| 8d50f5eadf50201ccdcedfb9e2ac8455 |                                        | 2           | 17           | 3          | 12.00          |
| 8d50f5eadf50201ccdcedfb9e2ac8455 | fashion_bolsas_e_acessorios            | 3           | 17           | 2          | 18.00          |
| 8d50f5eadf50201ccdcedfb9e2ac8455 | construcao_ferramentas_ferramentas     | 1           | 17           | 4          | 6.00           |
| 3e43e6105506432c953e165fb2acf44c | moveis_decoracao                       | 3           | 9            | 2          | 33.00          |
| 3e43e6105506432c953e165fb2acf44c | informatica_acessorios                 | 1           | 9            | 5          | 11.00          |
| 3e43e6105506432c953e165fb2acf44c | utilidades_domesticas                 | 1           | 9            | 3          | 11.00          |
| 3e43e6105506432c953e165fb2acf44c | casa_construcao                        | 1           | 9            | 4          | 11.00          |
| 3e43e6105506432c953e165fb2acf44c | cama_mesa_banho                        | 4           | 9            | 1          | 44.00          |
| 1b6c7548a2a1f9037c1fd3ddfed95f33 | papelaria                              | 1           | 7            | 2          | 14.00          |

## ❗ the first ten lines are shown.
#  CUSTOMER ANALYSİS DASHBOARD 📊📈📉 

![image](https://github.com/muratukel/SQLProject-OlistE-CommerceDataset-/assets/136103635/8d40f166-bfd5-40ad-b42a-5a2ed238e98b)

