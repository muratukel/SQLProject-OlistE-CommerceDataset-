# Case 4 : Payment Analysis 💸
## 💰 Question 1
### Which region do users with the highest number of installments live in when making payments? Please interpret this output.
````sql
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
````
| payment_installments | customer_city           | customer_count |
|----------------------|-------------------------|----------------|
| 24                   | "assai"                 | 1              |
| 24                   | "bage"                  | 1              |
| 24                   | "barra mansa"           | 1              |
| 24                   | "brasilia"              | 1              |
| 24                   | "campina grande"        | 1              |
| 24                   | "dores de campos"       | 1              |
| 24                   | "guaruja"               | 1              |
| 24                   | "iguatu"                | 1              |
| 24                   | "jaguariuna"            | 1              |
| 24                   | "jatai"                 | 1              |
| 24                   | "porto alegre"          | 1              |
| 24                   | "rio de janeiro"        | 1              |
| 24                   | "salvador"              | 1              |
| 24                   | "sao joao de meriti"    | 1              |
| 24                   | "sorocaba"              | 1              |
| 24                   | "vargem grande paulista"| 1              |
| 24                   | "vespasiano"            | 1              |
| 24                   | "vilhena"               | 1              |

## 💳 Question 2 
### Calculate the number of successful orders and the total successful payment amount by payment type. Sort them from the most used payment type to the least used payment type.
````sql
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
````
| payment_type  | order_count | total_payment  |
| ------------- | ----------- | --------------- |
| credit_card   | 76,349      | $12,447,417.87 |
| boleto        | 19,634      | $2,844,306.40  |
| voucher       | 5,728       | $375,539.32    |
| debit_card    | 1,523       | $215,129.02    |
| not_defined   | 3           | $0.00          |

# 💵 Question 3
## Analyze orders paid in single payment and in installments by category. In which categories is installment payment used the most?
````sql
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
````
| product_category_name   | one_shot_total_order | installment_total_order |
|------------------------|----------------------|-------------------------|
| cama_mesa_banho         | 3,535                | 5,965                   |
| beleza_saude            | 3,880                | 5,006                   |
| relogios_presentes      | 1,890                | 3,794                   |
| esporte_lazer           | 4,299                | 3,480                   |
| moveis_decoracao        | 3,152                | 3,353                   |
| utilidades_domesticas   | 2,732                | 3,197                   |
| informatica_acessorios  | 4,177                | 2,562                   |
| cool_stuff             | 1,451                | 2,217                   |
| brinquedos              | 1,902                | 2,008                   |
| perfumaria              | 1,238                | 1,945                   |

### ❗ the first ten lines are shown.
# PAYMENT ANALYSİS DASHBOARD 💳📊
![image](https://github.com/muratukel/SQLProject-OlistE-CommerceDataset-/assets/136103635/1b7c26c6-b28b-4edb-810e-ee18ac22aeda)

