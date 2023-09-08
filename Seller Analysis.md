# Case 3 : Seller Analysis 🔍
## 💼 Question 1 :
### Which sellers deliver orders to customers the fastest? Provide the top 5.

````sql
select 
	distinct s.seller_id,
	 extract(day from age(order_delivered_customer_date, order_purchase_timestamp)) as delivered_day,
  	 extract(hour from age(order_delivered_customer_date, order_purchase_timestamp)) as delivered_hour,
  	 extract(minute from age(order_delivered_customer_date, order_purchase_timestamp)) as delivered_minute
from orders as o
join order_items as oi 
	on oi.order_id=o.order_id
join sellers as s 
	on s.seller_id=oi.seller_id
where o.order_status='delivered' 
	and extract (day from age(order_delivered_customer_date,order_purchase_timestamp)) is not null 
	and extract(day from age(order_delivered_customer_date, order_purchase_timestamp)) = 0
order by 3 asc , 4 asc
limit 5
````

| seller_id                        | delivered_day | delivered_hour | delivered_minute |
|----------------------------------|---------------|----------------|------------------|
| b92e3c8f9738272ff7c59e111e108d7c | 0             | 0              | 2                |
| 46dc3b2cc0980fb8ec44634e21d2718e | 0             | 0              | 10               |
| 955fee9216a65b617aa5c0531780ce60 | 0             | 0              | 12               |
| 1835b56ce799e6a4dc4eddc053f04066 | 0             | 0              | 15               |
| 8b321bb669392f5163d04c59e235e066 | 0             | 0              | 18               |

### 💬 Examine the order counts of these sellers along with the reviews and ratings for their products, and provide an analysis.

````sql
with seller as 
(
select 
     distinct s.seller_id,	
	extract(day from age(order_delivered_customer_date, order_purchase_timestamp)) as delivered_day,
  	 extract(hour from age(order_delivered_customer_date, order_purchase_timestamp)) as delivered_hour,
  	 extract(minute from age(order_delivered_customer_date, order_purchase_timestamp)) as delivered_minute
from orders as o
join order_items as oi 
	on oi.order_id=o.order_id
join sellers as s 
	on s.seller_id=oi.seller_id
where o.order_status='delivered' 
		and extract (day from age(order_delivered_customer_date,order_purchase_timestamp)) is not null 
			and extract(day from age(order_delivered_customer_date, order_purchase_timestamp)) = 0
order by 3 asc , 4 asc
limit 5 
) 
select 
	s.*,
	count(distinct oi.order_id) as order_count,
	round(avg(ov.review_score),2) as avg_review_score,
	count(distinct ov.review_comment_message) as total_review_comment_message
from seller as s
left join order_items as oi
	on oi.seller_id=s.seller_id
left join order_reviews as ov
	on ov.order_id=oi.order_id
where ov.review_comment_message is not null	
group by 1,2,3,4
order by s.delivered_hour asc , s.delivered_minute asc
````

| seller_id                        | delivered_day | delivered_hour | delivered_minute | order_count | avg_review_score | total_review_comment_message |
|----------------------------------|---------------|----------------|------------------|-------------|------------------|------------------------------|
| b92e3c8f9738272ff7c59e111e108d7c | 0             | 0              | 2                | 27          | 3.56             | 27                           |
| 46dc3b2cc0980fb8ec44634e21d2718e | 0             | 0              | 10               | 193         | 3.77             | 190                          |
| 955fee9216a65b617aa5c0531780ce60 | 0             | 0              | 12               | 479         | 3.61             | 468                          |
| 1835b56ce799e6a4dc4eddc053f04066 | 0             | 0              | 15               | 190         | 3.08             | 188                          |
| 8b321bb669392f5163d04c59e235e066 | 0             | 0              | 18               | 395         | 3.58             | 384                          |

## 💼 Question 2 :
### What sellers sell products in more categories? Do sellers with more categories also have a higher order count?

````sql
select 
	s.seller_id,
	count( distinct p.product_category_name) as category_count,
	count(distinct o.order_id) as order_count
from sellers as s
left join order_items as oi 
	on oi.seller_id=s.seller_id
left join products as p 
	on p.product_id=oi.product_id
left join orders as o 
	on o.order_id=oi.order_id
where p.product_category_name is not null
group by 1
order by  2 desc
limit 10
````

| seller_id                        | category_count | order_count |
|----------------------------------|----------------|-------------|
| b2ba3715d723d245138f291a6fe42594 | 27             | 337         |
| 955fee9216a65b617aa5c0531780ce60 | 23             | 1287        |
| 4e922959ae960d389249c378d1c939f5 | 23             | 405         |
| 1da3aeb70d7989d1e6d9b0e887f97c23 | 21             | 265         |
| f8db351d8c4c4c22c6835c19a46f01b0 | 19             | 665         |
| 18a349e75d307f4b4cc646a691ed4216 | 17             | 121         |
| 6edacfd9f9074789dad6d62ba7950b9c | 15             | 208         |
| 70a12e78e608ac31179aea7f8422044b | 15             | 315         |
| 7178f9f4dd81dcef02f62acdf8151e01 | 14             | 203         |
| 8b28d096634035667e8263d57ba3368c | 14             | 143         |

# SELLER ANALYSİS DASHBOARD 📊📈🛒

![image](https://github.com/muratukel/SQLProject-OlistE-CommerceDataset-/assets/136103635/35bbf8b3-f296-4d5f-921b-46c9dd1dbfed)
