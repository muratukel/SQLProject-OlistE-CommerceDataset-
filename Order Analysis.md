## Case 1 : Order Analysis 📊

# 📉 Question 1 : 
### Examine the monthly order distribution. Date data should be based on 'order_approved_at'.

````sql
select 
	count(distinct  order_id) order_count,
	to_char(order_approved_at,'yyyy-mm') as month
from orders
where order_approved_at is not null
group by 2
order by 1 desc
````
| order_count | month    |
|------------|----------|
| 7395       | 2017-11  |
| 7288       | 2018-03  |
| 7187       | 2018-01  |
| 7066       | 2018-05  |
| 6778       | 2018-04  |
| 6706       | 2018-02  |
| 6620       | 2018-08  |
| 6176       | 2018-07  |
| 6164       | 2018-06  |
| 5832       | 2017-12  |
| 4590       | 2017-10  |
| 4348       | 2017-08  |
| 4301       | 2017-09  |
| 3974       | 2017-07  |
| 3693       | 2017-05  |
| 3252       | 2017-06  |
| 2689       | 2017-03  |
| 2374       | 2017-04  |
| 1765       | 2017-02  |
| 760        | 2017-01  |
| 320        | 2016-10  |
| 1          | 2018-09  |
| 1          | 2016-12  |
| 1          | 2016-09  |

# 📅 Question 2 :
### Examine the monthly order status breakdown in terms of order counts. Visualize the output of the query with Power BI. Are there any months with a dramatic decrease or increase? Interpret the data based on your analysis.
````sql
select 
	to_char(order_approved_at,'yyyy-mm') as month,
	order_status,
	count(distinct order_id) as order_count	
from orders
where order_approved_at is not null
group by 1,2
order by 1 desc
````
| month    | order_status | order_count |
|----------|--------------|-------------|
| 2018-09  | shipped      | 1           |
| 2018-08  | canceled     | 32          |
| 2018-08  | delivered    | 6504        |
| 2018-08  | invoiced     | 24          |
| 2018-08  | shipped      | 47          |
| 2018-08  | unavailable  | 13          |
| 2018-07  | canceled     | 39          |
| 2018-07  | delivered    | 6050        |
| 2018-07  | invoiced     | 12          |
| 2018-07  | processing   | 1           |

### ❗ the first ten lines are shown.

# 📈 Question 3 :
### Examine the order counts by product category.
````sql
select 
	p.product_category_name,
	count(o.order_id) as order_id
from orders as o
left join order_items as oi on o.order_id = oi.order_id
left join products as p on p.product_id = oi.product_id
where o.order_status != 'cancelled' and p.product_category_name is not null
group by 1
order by 2 desc
````
| product_category_name     | order_id |
|---------------------------|----------|
| cama_mesa_banho           | 11115    |
| beleza_saude              | 9670     |
| esporte_lazer             | 8641     |
| moveis_decoracao          | 8334     |
| informatica_acessorios    | 7827     |
| utilidades_domesticas     | 6964     |
| relogios_presentes        | 5991     |
| telefonia                 | 4545     |
| ferramentas_jardim        | 4347     |
| automotivo                | 4235     |

###❗ the first ten lines are shown.

# 🎉 Question 4 :
### What are the prominent categories on special occasions? For example, New Year's Eve, Valentine's Day...

The order count by category at the beginning of the carnival - Solution 1

````sql
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
````
| product_category_name     | order_count |
|---------------------------|-------------|
| cama_mesa_banho           | 820         |
| informatica_acessorios    | 773         |
| esporte_lazer             | 742         |
| beleza_saude              | 730         |
| moveis_decoracao          | 618         |
| telefonia                 | 440         |
| utilidades_domesticas     | 395         |
| automotivo                | 342         |
| ferramentas_jardim        | 341         |
| relogios_presentes        | 317         |

### ❗ the first ten lines are shown.

The order count by category at the beginning of the carnival along with the carnival name - Solution 2

````sql
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
````
| order_count | product_category_name   | rio_date            |
|-------------|-------------------------|---------------------|
| 207         | cama_mesa_banho         | Brezilya Karnavalı  |
| 155         | informatica_acessorios  | Brezilya Karnavalı  |
| 143         | esporte_lazer           | Brezilya Karnavalı  |
| 127         | beleza_saude            | Brezilya Karnavalı  |
| 120         | moveis_decoracao        | Brezilya Karnavalı  |
| 89          | ferramentas_jardim      | Brezilya Karnavalı  |
| 84          | utilidades_domesticas   | Brezilya Karnavalı  |
| 81          | telefonia               | Brezilya Karnavalı  |
| 61          | relogios_presentes      | Brezilya Karnavalı  |
| 59          | eletronicos             | Brezilya Karnavalı  |

### ❗ the first ten lines are shown.

The comparison of the total order count by categories at the beginning of the carnival and the total order count by categories - Solution 3

````sql
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
````
| product_category_name   | total_order_count | carnaval_date_order_count |
|-------------------------|-------------------|---------------------------|
| cama_mesa_banho         | 11115             | 207                       |
| beleza_saude            | 9670              | 127                       |
| esporte_lazer           | 8641              | 143                       |
| moveis_decoracao        | 8334              | 120                       |
| informatica_acessorios  | 7827              | 155                       |
| utilidades_domesticas   | 6964              | 84                        |
| relogios_presentes      | 5991              | 61                        |
| telefonia               | 4545              | 81                        |
| ferramentas_jardim      | 4347              | 89                        |
| automotivo              | 4235              | 57                        |

### ❗ the first ten lines are shown.

#  Question 5 :
### Analyze order counts based on weekdays (e.g., Monday, Thursday) and month days (e.g., 1st, 2nd of the month).Create a visualization in Power BI with the output of the query you have written and provide an interpretation.

### Order counts based on days of the week.
````sql
select 
	to_char(order_approved_at, 'Day') as day_of_week ,
  	count(order_id) as order_count  
from orders 
group by 1
order by 2 desc;
````
| day_of_week | order_count |
|-------------|-------------|
| Tuesday     | 19154       |
| Wednesday   | 15786       |
| Thursday    | 15471       |
| Friday      | 14659       |
| Monday      | 13001       |
| Saturday    | 12196       |
| Sunday      | 9014        |
|             | 160         |

### Order counts based on days of the month
````sql
select 
  to_char(order_approved_at, 'DD') as day_of_month,
  count(order_id) as order_count
from orders 
group by 1
order by 2 desc;
````
| day_of_month | order_count |
|--------------|-------------|
| 24           | 4315        |
| 05           | 3970        |
| 07           | 3644        |
| 16           | 3525        |
| 18           | 3497        |
| 25           | 3465        |
| 20           | 3443        |
| 15           | 3443        |
| 06           | 3409        |
| 14           | 3351        |
| 13           | 3346        |
| 10           | 3333        |
| 08           | 3306        |
| 17           | 3306        |
| 27           | 3281        |
| 26           | 3259        |
| 09           | 3226        |
| 11           | 3213        |
| 01           | 3170        |
| 03           | 3168        |
| 12           | 3123        |
| 28           | 3104        |
| 19           | 3097        |
| 02           | 3086        |
| 04           | 3000        |
| 22           | 2971        |
| 23           | 2933        |
| 21           | 2790        |
| 29           | 2519        |
| 30           | 2346        |
| 31           | 1642        |
|              | 160         |

### Analysis of order counts based on days of the week and days of the month.
````sql
select 
  to_char(order_approved_at, 'Day') as day_of_week,
  to_char(order_approved_at, 'DD') as day_of_month,
  count(order_id) as order_count  
from orders 
group by 1, 2
order by 3 desc;
````
| day_of_week | day_of_month | order_count |
|-------------|--------------|-------------|
| Tuesday     | 24           | 1577        |
| Thursday    | 05           | 1113        |
| Friday      | 24           | 1112        |
| Saturday    | 25           | 962         |
| Tuesday     | 07           | 951         |
| Tuesday     | 05           | 878         |
| Tuesday     | 12           | 865         |
| Tuesday     | 17           | 845         |
| Wednesday   | 25           | 815         |
| Tuesday     | 06           | 809         |

### ❗ the first ten lines are shown.
### Analysis of order counts based on days of the week and days of the month (using CASE WHEN solution)
````sql
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
````
| order_count | day_of_week | day_of_month |
|-------------|-------------|--------------|
| 1577        | TUESDAY     | 24           |
| 1113        | THURSDAY    | 5            |
| 1112        | FRIDAY      | 24           |
| 962         | SATURDAY    | 25           |
| 951         | TUESDAY     | 7            |
| 878         | TUESDAY     | 5            |
| 865         | TUESDAY     | 12           |
| 845         | TUESDAY     | 17           |
| 815         | WEDNESDAY   | 25           |
| 809         | TUESDAY     | 6            |

### ❗ the first ten lines are shown.

# ORDER ANALYSİS DASHBOARD 
![image](https://github.com/muratukel/SQLProject-OlistE-CommerceDataset-/assets/136103635/06392279-5cc5-470e-852d-b1e2ed9b1fca)

