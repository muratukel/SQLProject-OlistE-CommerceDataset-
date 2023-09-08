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

## 💵 Question 2 
### Calculate the number of successful orders and the total successful payment amount by payment type. Sort them from the most used payment type to the least used payment type
