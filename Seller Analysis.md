# 🔍 Seller Analysis 
## Question 1 :
### Which sellers deliver orders to customers the fastest? Provide the top 5.
`````sql
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

### Examine the order counts of these sellers along with the reviews and ratings for their products, and provide an analysis.
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

## Question 2 :
### What sellers sell products in more categories? Do sellers with more categories also have a higher order count?
