--Системы хранения и обработки данных. Домашнее задание 3 (vo_HW)

--1. customer.csv:
--
--customer_id: 			Уникальный идентификатор клиента.
--first_name: 			Имя клиента.
--last_name: 			Фамилия клиента.
--gender: 				Пол.
--dob: 					Дата рождения.
--job_title: 			Должность или профессия.
--job_industry_category: Сфера деятельности.
--wealth_segment: 		Сегмент благосостояния
--deceased_indicator: 	Флаг актуального клиента
--owns_car: 			Флаг наличия автомобиля
--address: 				Адрес проживания
--postcode: 			Почтовый индекс
--state: 				Штаты
--country: 				Страна проживания
--property_valuation:	Оценка имущества
--
--
--2. transaction.csv:
--
--transaction_id:	id транзакции
--product_id:		id продукта
--customer_id:		id клиента
--transaction_date:	Дата транзакции
--online_order:		Флаг онлайн-заказа
--order_status:		Статус транзакции
--brand:			Бренд
--product_line:		Линейка продуктов
--product_class:	Класс продукта
--product_size:		Размер продукта
--list_price:		Цена
--standard_cost:	Стандартная стоимость



--Задача 1
--Вывести распределение (количество) клиентов по сферам деятельности, отсортировав результат по убыванию количества. — (1 балл)

SELECT job_industry_category, COUNT(*) AS customer_count
FROM customer
WHERE job_industry_category IS NOT NULL AND job_industry_category != 'n/a'
GROUP BY job_industry_category
ORDER BY customer_count DESC;
--Manufacturing			799
--Financial Services	774
--Health				602
--Retail				358
--Property				267
--IT					223
--Entertainment			136
--Argiculture			113
--Telecommunications	72



--Задача 2
--Найти сумму транзакций за каждый месяц по сферам деятельности, отсортировав по месяцам и по сфере деятельности. — (1 балл)

SELECT
    TO_CHAR(t.transaction_date, 'YYYY-MM') AS transaction_month,
    c.job_industry_category,
    SUM(CAST(REPLACE(t.list_price, ',', '.') AS NUMERIC)) AS total_transaction_amount
FROM
    transaction t
JOIN
    customer c ON t.customer_id = c.customer_id
WHERE
    t.order_status = 'Approved'
    AND c.job_industry_category IS NOT NULL
    AND c.job_industry_category != 'n/a'
GROUP BY
    transaction_month,
    c.job_industry_category
ORDER BY
    transaction_month,
    c.job_industry_category;




--Задача 3
--Вывести количество онлайн-заказов для всех брендов в рамках подтвержденных заказов клиентов из сферы IT. — (1 балл)

SELECT
    t.brand,
    COUNT(*) AS online_order_count
FROM
    transaction t
JOIN
    customer c ON t.customer_id = c.customer_id
WHERE
    t.online_order = TRUE
    AND t.order_status = 'Approved'
    AND c.job_industry_category = 'IT'
    AND t.brand IS NOT NULL
    AND t.brand <> ''
GROUP BY
    t.brand
ORDER BY
    online_order_count DESC;
--Solex				101
--Norco Bicycles	92
--WeareA2B			90
--Giant Bicycles	89
--Trek Bicycles		82
--OHM Cycles		78







--Задача 4
--Найти по всем клиентам сумму всех транзакций (list_price), максимум, минимум и количество транзакций, 
--отсортировав результат по убыванию суммы транзакций и количества клиентов. 
--Выполните двумя способами: используя только group by и используя только оконные функции. Сравните результат. — (2 балла)

SELECT
    c.customer_id,
    c.first_name,
    c.last_name,
    COUNT(t.transaction_id) AS transaction_count,
    SUM(CAST(REPLACE(t.list_price, ',', '.') AS NUMERIC)) AS total_amount,
    MAX(CAST(REPLACE(t.list_price, ',', '.') AS NUMERIC)) AS max_amount,
    MIN(CAST(REPLACE(t.list_price, ',', '.') AS NUMERIC)) AS min_amount
FROM
    customer c
LEFT JOIN
    transaction t ON c.customer_id = t.customer_id
GROUP BY
    c.customer_id, c.first_name, c.last_name
ORDER BY
    total_amount DESC,
    transaction_count DESC;


WITH transaction_stats AS (
    SELECT
        c.customer_id,
        c.first_name,
        c.last_name,
        t.transaction_id,
        CAST(REPLACE(t.list_price, ',', '.') AS NUMERIC) AS list_price,
        COUNT(t.transaction_id) OVER (PARTITION BY c.customer_id) AS transaction_count,
        SUM(CAST(REPLACE(t.list_price, ',', '.') AS NUMERIC)) OVER (PARTITION BY c.customer_id) AS total_amount,
        MAX(CAST(REPLACE(t.list_price, ',', '.') AS NUMERIC)) OVER (PARTITION BY c.customer_id) AS max_amount,
        MIN(CAST(REPLACE(t.list_price, ',', '.') AS NUMERIC)) OVER (PARTITION BY c.customer_id) AS min_amount
    FROM
        customer c
    LEFT JOIN
        transaction t ON c.customer_id = t.customer_id
)
SELECT DISTINCT
    customer_id,
    first_name,
    last_name,
    transaction_count,
    total_amount,
    max_amount,
    min_amount
FROM
    transaction_stats
ORDER BY
    total_amount DESC,
    transaction_count DESC;




--Задача 5
--Найти имена и фамилии клиентов с минимальной/максимальной суммой транзакций за весь период 
--(сумма транзакций не может быть null). Напишите отдельные запросы для минимальной и максимальной суммы. — (2 балла)


SELECT
    c.customer_id,
    c.first_name,
    c.last_name,
    total_amount
FROM (
    SELECT
        t.customer_id,
        SUM(CAST(REPLACE(t.list_price, ',', '.') AS NUMERIC)) AS total_amount
    FROM
        transaction t
    GROUP BY
        t.customer_id
) AS customer_totals
JOIN customer c ON c.customer_id = customer_totals.customer_id
ORDER BY
    total_amount DESC
LIMIT 1;


SELECT
    c.customer_id,
    c.first_name,
    c.last_name,
    total_amount
FROM (
    SELECT
        t.customer_id,
        SUM(CAST(REPLACE(t.list_price, ',', '.') AS NUMERIC)) AS total_amount
    FROM
        transaction t
    GROUP BY
        t.customer_id
) AS customer_totals
JOIN customer c ON c.customer_id = customer_totals.customer_id
ORDER BY
    total_amount ASC
LIMIT 1;





--Задача 6
--Вывести только самые первые транзакции клиентов. Решить с помощью оконных функций. — (1 балл)

WITH RankedTransactions AS (
    SELECT
        t.transaction_id,
        t.customer_id,
        t.transaction_date,
        t.product_id,
        t.list_price,
        ROW_NUMBER() OVER (PARTITION BY t.customer_id ORDER BY t.transaction_date) AS rn
    FROM
        transaction t
)
SELECT
    rt.transaction_id,
    rt.customer_id,
    rt.transaction_date,
    rt.product_id,
    rt.list_price
FROM
    RankedTransactions rt
WHERE
    rt.rn = 1
ORDER BY
    rt.customer_id;






--Задача 7
--Вывести имена, фамилии и профессии клиентов, между транзакциями которых был максимальный интервал (интервал вычисляется в днях) — (2 балла).


WITH TransactionIntervals AS (
    SELECT
        t.customer_id,
        c.first_name,
        c.last_name,
        c.job_title,
        t.transaction_date,
        LAG(t.transaction_date) OVER (PARTITION BY t.customer_id ORDER BY t.transaction_date) AS previous_transaction_date
    FROM
        transaction t
    JOIN
        customer c ON t.customer_id = c.customer_id
),
IntervalsWithDiff AS (
    SELECT
        customer_id,
        first_name,
        last_name,
        job_title,
        transaction_date,
        previous_transaction_date,
        (transaction_date - previous_transaction_date) AS interval_days
    FROM
        TransactionIntervals
)
SELECT
    customer_id,
    first_name,
    last_name,
    job_title,
    interval_days
FROM
    IntervalsWithDiff
WHERE
    interval_days IS NOT NULL
ORDER BY
    interval_days DESC
LIMIT 1;

