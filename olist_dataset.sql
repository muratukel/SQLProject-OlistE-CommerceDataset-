select * from customers 

select * from geolocation 

select * from order_items

select * from order_payments

select * from order_reviews

select * from  orders 

select * from products

select * from sellers 

select * from category_name_translation

--Case 1 : Sipariş Analizi
--Case 1:  Order Analysis

--Question 1 : 

--Aylık olarak order dağılımını inceleyiniz. Tarih verisi için order_approved_at kullanılmalıdır.
--Examine the monthly order distribution. Date data should be based on 'order_approved_at'.

select 
	count(distinct  order_id) order_count,
	to_char(order_approved_at,'yyyy-mm') as month
from orders
where order_approved_at is not null
group by 2
order by 1 desc


--Question 2 : 

--Aylık olarak order status kırılımında order sayılarını inceleyiniz. Sorgu sonucunda çıkan outputu Power BI ile görselleştiriniz. 
--Dramatik bir düşüşün ya da yükselişin olduğu aylar var mı? Veriyi inceleyerek yorumlayınız.

--Examine the monthly order status breakdown in terms of order counts. Visualize the output of the query with Power BI. 
--Are there any months with a dramatic decrease or increase? Interpret the data based on your analysis.

select 
	to_char(order_approved_at,'yyyy-mm') as month,
	order_status,
	count(distinct order_id) as order_count	
from orders
where order_approved_at is not null
group by 1,2
order by 1 desc

--Question 3 : 
--Ürün kategorisi kırılımında sipariş sayılarını inceleyiniz. 
--Examine the order counts by product category.

select 
	p.product_category_name,
	count(o.order_id) as order_id
from orders as o
left join order_items as oi on o.order_id = oi.order_id
left join products as p on p.product_id = oi.product_id
where o.order_status != 'cancelled' and p.product_category_name is not null
group by 1
order by 2 desc

---Özel günlerde öne çıkan kategoriler nelerdir? Örneğin yılbaşı, sevgililer günü..
--What are the prominent categories on special occasions? For example, New Year's Eve, Valentine's Day...

--Karnaval başlangıcı kategoriye göre sipariş sayısı 1.çözüm
--The order count by category at the beginning of the carnival - Solution 1
select 
    distinct p.product_category_name,
    count(o.order_id) as order_count
from orders as o
left join order_items as oi on o.order_id = oi.order_id
left join products as p on p.product_id = oi.product_id
where o.order_status != 'cancelled' 
    and (
        to_char(o.order_delivered_customer_date, 'yyyy-mm-dd') between '2016-02-01' and '2016-03-01'
        or to_char(o.order_delivered_customer_date, 'yyyy-mm-dd') between '2017-02-01' and '2017-03-01'
        or to_char(o.order_delivered_customer_date, 'yyyy-mm-dd') between '2018-02-01' and '2018-03-01'
    )
    and p.product_category_name is not null
group by 1 
order by 2 desc


--Karnaval başlangıcı kategoriye göre sipariş sayısı 2.çözüm
--The order count by category at the beginning of the carnival along with the carnival name - Solution 2
select
        count(o.order_id) as order_count,
        p.product_category_name,
           case
        when to_char(order_approved_at, 'yyyy-mm-dd') between '2016-02-05' and '2016-02-10' then 'Brezilya Karnavalı'
        when to_char(order_approved_at, 'yyyy-mm-dd') between '2017-02-24' and '2017-03-01' then 'Brezilya Karnavalı'
        when to_char(order_approved_at, 'yyyy-mm-dd') between '2018-02-09' and '2018-02-14' then 'Brezilya Karnavalı'
        else 'Diğer'
    end as rio_date
from orders as o
left join order_items as oi 
on oi.order_id=o.order_id
left join products as p
on p.product_id=oi.product_id
where o.order_status != 'cancelled' 
and to_char(order_approved_at,'yyyy-mm-dd') between '2016-02-05' and '2016-02-10'
or to_char(order_approved_at,'yyyy-mm-dd') between '2017-02-24' and '2017-03-01'
or to_char(order_approved_at,'yyyy-mm-dd') between '2018-02-09' and '2018-02-14'
group by 2,3
order by 1 desc


--Karnaval başlangıcında kategorilere verilen toplam sipariş sayısı ve kategorilere göre verilen toplam sipariş sayısı karşılaştırılması 3.çözüm
--The comparison of the total order count by categories at the beginning of the carnival and the total order count by categories - Solution 3

with rio_orders as (
  select count(o.order_id) as order_count,
    p.product_category_name,
    case
      when to_char(order_approved_at, 'yyyy-mm-dd') between '2016-02-05' and '2016-02-10' then 'Brezilya Karnavalı'
      when to_char(order_approved_at, 'yyyy-mm-dd') between '2017-02-24' and '2017-03-01' then 'Brezilya Karnavalı'
      when to_char(order_approved_at, 'yyyy-mm-dd') between '2018-02-09' and '2018-02-14' then 'Brezilya Karnavalı'
      else 'Diğer'
    end as rio
  from orders as o
  left join order_items as oi on oi.order_id = o.order_id
  left join products as p on p.product_id = oi.product_id
  left join category_name as cn on p.product_category_name = cn.product_category_name
  where o.order_status != 'cancelled' 
    and (
      to_char(order_approved_at, 'yyyy-mm-dd') between '2016-02-05' and '2016-02-10'
      or to_char(order_approved_at, 'yyyy-mm-dd') between '2017-02-24' and '2017-03-01'
      or to_char(order_approved_at, 'yyyy-mm-dd') between '2018-02-09' and '2018-02-14'
    )
  group by 2, 3
),
category_orders as (
  select count(o.order_id) as order_count,
    p.product_category_name
  from orders as o
  left join order_items as oi on o.order_id = oi.order_id
  left join products as p on oi.product_id = p.product_id
  left join category_name as c on c.product_category_name = p.product_category_name
  where o.order_status != 'cancelled' and p.product_category_name is not null
  group by 2
)
select  co.product_category_name, 
        co.order_count as total_order_count, 
        ro.order_count as carnaval_date_order_count
from category_orders as co
left join rio_orders as ro on ro.product_category_name = co.product_category_name
order by co.order_count desc






--Question 4 : 

--Haftanın günleri(pazartesi, perşembe) ve ay günleri (ayın 1’i,2’si gibi) bazında order sayılarını inceleyiniz.
--Yazdığınız sorgunun outputu ile Power BI da bir görsel oluşturup yorumlayınız.

--Analyze order counts based on weekdays (e.g., Monday, Thursday) and month days (e.g., 1st, 2nd of the month). 
--Create a visualization in Power BI with the output of the query you have written and provide an interpretation

;
--Haftanın günleri bazında order sayıları
--Order counts based on days of the week.

select 
	to_char(order_approved_at, 'Day') as day_of_week ,
  	count(order_id) as order_count  
from orders 
group by 1
order by 2 desc;


--Ayın günleri bazında order sayıları
--Order counts based on days of the month

select 
  to_char(order_approved_at, 'DD') as day_of_month,
  count(order_id) as order_count
from orders 
group by 1
order by 2 desc;

--Haftanın ve ayın günlerinin olduğu order sayılarının analiz edilmesi
--Analysis of order counts based on days of the week and days of the month.

select 
  to_char(order_approved_at, 'Day') as day_of_week,
  to_char(order_approved_at, 'DD') as day_of_month,
  count(order_id) as order_count  
from orders 
group by 1, 2
order by 3 desc;


--Haftanın ve ayın günlerinin olduğu order sayılarının analiz edilmesi(case when çözümü) 
--Analysis of order counts based on days of the week and days of the month (using CASE WHEN solution)

select count(order_id) as order_count,
       case
           when extract(dow from order_approved_at) = 1 then 'MONDAY'
           when extract(dow from order_approved_at) = 2 then 'TUESDAY'
           when extract(dow from order_approved_at) = 3 then 'WEDNESDAY'
           when extract(dow from order_approved_at) = 4 then 'THURSDAY'
           when extract(dow from order_approved_at) = 5 then 'FRIDAY'
           when extract(dow from order_approved_at) = 6 then 'SATURDAY'
           when extract(dow from order_approved_at) = 0 then 'SUNDAY'
       end as day_of_week,
       extract(day from order_approved_at) as day_of_month
from orders
group by day_of_week, day_of_month
order by order_count  desc;




--Case 2 : Müşteri Analizi

--Question 1 : 

--Hangi şehirlerdeki müşteriler daha çok alışveriş yapıyor? 
--Müşterinin şehrini en çok sipariş verdiği şehir olarak belirleyip analizi ona göre yapınız. 

--Which cities do customers shop more in?
--Determine the customer's city with the highest number of orders and perform the analysis based on that.

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

-------------------------------------------------------------------------------------------------------------------------------------

--Question 2 : 

--TR:
/*
Müşteri bazlı siparişlerin kategorilerini inceleyiniz. Müşteriler genellikle aynı kategorideki ürünlerin siparişini mi veriyor? 
Her müşteri için sipariş kategori yüzdesini hesaplayın. 
*/

--ENG:
/*
Examine orders based on customers and their categories. Do customers typically order products from the same category?
Calculate the order category percentage for each customer.
*/

--QUERY

--Müşteri bazlı siparişlerin kategorilerinin incelenmesi
--Examining customer-specific orders and their categories.
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

--TR:

/*
Her müşteri için sipariş kategori yüzdesini hesaplayın.Örneğin x müşterisinin 20 tane siparişi var ve bu kişi 
siparişinin 10 tanesini (%50’sini) moda  kategorisinden, 6 tanesini (%30’unu) kozmetik kategorisinden ve 4 
tanesini (%20’sini) yiyecek kategorisinden verdi. 
*/

--ENG:
/*
Calculate the order category percentage for each customer. For example, if customer X has 20 orders, 
and this person placed 10 of them (50%) in the fashion category, 
6 of them (30%) in the cosmetics category, and 4 of them (20%) in the food category.
*/

--TR:
--Müşterilerin toplam sipariş sayısının kategorilere göre sipariş kategori yüzdesi hesaplanıp incelenmesi.
--ENG:
--Calculating and analyzing the order category percentage of customers total order counts by categories.

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

--------------------------------------------------------------------------------------------------------------------------------------

--Case 3: Satıcı Analizi(++)

--Question 1 : 
--Siparişleri en hızlı şekilde müşterilere ulaştıran satıcılar kimlerdir? Top 5 getiriniz. 
--Which sellers deliver orders to customers the fastest? Provide the top 5.

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





  
--Bu satıcıların order sayıları ile ürünlerindeki yorumlar ve puanlamaları inceleyiniz ve yorumlayınız.
--Examine the order counts of these sellers along with the reviews and ratings for their products, and provide an analysis

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

--------------------------------------------------------------------------------------------------------------------------------------

--Question 2 : 
 --Hangi satıcılar daha fazla kategoriye ait ürün satışı yapmaktadır? Fazla kategoriye sahip satıcıların order sayıları da fazla mı? 

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


--------------------------------------------------------------------------------------------------------------------------------------

--Case 4 : Payment Analizi

--Question 1 : 

--Ödeme yaparken taksit sayısı fazla olan kullanıcılar en çok hangi bölgede yaşamaktadır? Bu çıktıyı yorumlayınız.
--Which region do users with the highest number of installments live in when making payments? Please interpret this output.

select 
	op.payment_installments,
	c.customer_city,
	count(c.customer_id) as customer_count
from order_payments as op
left join orders as o 
	on o.order_id=op.order_id
left join customers as c 
	on c.customer_id=o.customer_id 
group by 1,2
order by 1 desc , 3 desc
limit 18	
--------------------------------------------------------------------------------------------------------------------------------------

--Question 2 : 

--Ödeme tipine göre başarılı order sayısı ve toplam başarılı ödeme tutarını hesaplayınız. 
--En çok kullanılan ödeme tipinden en az olana göre sıralayınız.
   
select 
	op.payment_type,
	count(o.order_id) as order_count,
	sum(op.payment_value) as total_payment
from order_payments as op
left join orders as o 
	on o.order_id=op.order_id
where o.order_status not in ('cancelled','unavailable') 
group by 1
order by order_count desc

--------------------------------------------------------------------------------------------------------------------------------------

--Question 3 : 
 --Tek çekimde ve taksitle ödenen siparişlerin kategori bazlı analizini yapınız. 
  --En çok hangi kategorilerde taksitle ödeme kullanılmaktadır?

with one_shot as (
    select
        distinct order_id
    from
        order_payments
    where
        payment_installments = 1
), installment as (
    select
        distinct order_id
    from
        order_payments
    where
        payment_installments > 1
), product_category as (
    select
        distinct oi.order_id,
        p.product_category_name
    from
        order_items as oi
    left join
        products as p on p.product_id = oi.product_id
)
select
    pc.product_category_name,
    count(distinct one_shot.order_id) as one_shot_total_order,
    count(distinct installment.order_id) as installment_total_order
from
    product_category as pc
left join
    one_shot on one_shot.order_id = pc.order_id
left join
    installment on installment.order_id = pc.order_id
group by
    1
order by
    3 desc;


--case when solution

select 
  p.product_category_name,
  count(distinct case when op.payment_installments = 1 then op.order_id end) as one_shot_total_order, 
  count(distinct case when op.payment_installments > 1 then op.order_id end) as installment_total_order
from 
  order_payments as op 
  left join order_items as oi on oi.order_id = op.order_id
  left join products as p on p.product_id = oi.product_id
group by 1
order by 3 desc;




