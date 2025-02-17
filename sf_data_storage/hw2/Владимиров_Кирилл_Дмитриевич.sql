--Данные были просто импортированны из файлов, без дополнительной обработки


--Задача 1
--Вывести все уникальные бренды, у которых стандартная стоимость выше 1500 долларов.

--Преобразование standard_cost из строк в числа
UPDATE "transaction"
SET standard_cost_numeric =
    CASE
        WHEN standard_cost IS NOT NULL AND standard_cost <> ''
        THEN CAST(REPLACE(standard_cost, ',', '.') AS NUMERIC)
        ELSE NULL
    END;

ALTER TABLE "transaction" DROP COLUMN standard_cost;
ALTER TABLE "transaction" RENAME COLUMN standard_cost_numeric TO standard_cost;

--Решение
SELECT DISTINCT brand
FROM transaction
WHERE standard_cost::NUMERIC > 1500;
--OHM Cycles
--Trek Bicycles
--Solex
--Giant Bicycles



--Задача 2
--Вывести все подтвержденные транзакции за период '2017-04-01' по '2017-04-09' включительно.

SELECT count(*)
FROM "transaction";
--20000

--Преобразование transaction_date из строк в дату
ALTER TABLE "transaction"
ALTER COLUMN transaction_date TYPE DATE
USING TO_DATE(transaction_date, 'DD.MM.YYYY');

--Решение
SELECT *
FROM "transaction"
WHERE order_status = 'Approved'
AND transaction_date BETWEEN '2017-04-01' AND '2017-04-09';

SELECT count(*)
FROM "transaction"
WHERE order_status = 'Approved'
AND transaction_date BETWEEN '2017-04-01' AND '2017-04-09';
--531



--Задача 3
--Вывести все профессии у клиентов из сферы IT или Financial Services, которые начинаются с фразы 'Senior'.

--Решение
SELECT DISTINCT job_title
FROM customer
WHERE job_industry_category IN ('IT', 'Financial Services')
AND job_title LIKE 'Senior%';
--Senior Cost Accountant
--Senior Developer
--Senior Editor
--Senior Financial Analyst
--Senior Quality Engineer
--Senior Sales Associate


--Задача 4
--Вывести все бренды, которые закупают клиенты, работающие в сфере Financial Services

--Решение
SELECT DISTINCT t.brand
FROM transaction t
JOIN customer c ON t.customer_id = c.customer_id
WHERE c.job_industry_category = 'Financial Services'
  AND t.brand IS NOT NULL
  AND t.brand <> '';
--OHM Cycles
--Trek Bicycles
--WeareA2B
--Solex
--Norco Bicycles
--Giant Bicycles



--Задача 5
--Вывести 10 клиентов, которые оформили онлайн-заказ продукции из брендов 'Giant Bicycles', 'Norco Bicycles', 'Trek Bicycles'.

--Решение
SELECT DISTINCT c.customer_id, c.first_name, c.last_name
FROM transaction t
JOIN customer c ON t.customer_id = c.customer_id
WHERE t.online_order = TRUE
  AND t.brand IN ('Giant Bicycles', 'Norco Bicycles', 'Trek Bicycles')
LIMIT 10;
--742	Dexter	Robelin
--3123	Tina	Riggulsford
--20	Basile	Firth
--1894	Patten	Laytham
--3426	Ron	Dilon
--1179	Kerry	Pashenkov
--3491	Leanna	Cromb
--2201	Trisha	Basset
--1521	Pernell	Duffett
--2431	Alvy	Tyndall


--Задача 6
--Вывести всех клиентов, у которых нет транзакций.

--Решение
SELECT c.customer_id, c.first_name, c.last_name
FROM customer c
LEFT JOIN transaction t ON c.customer_id = t.customer_id
WHERE t.transaction_id IS NULL;
--3565	Charyl	Pottiphar
--3535	Bren	Dabbes
--3647	Carlyle	Frape
--3903	Dayna	Cawthera
--3519	Aldus	Kenningley
--3612	Normand	Matous
--3652	Aldrich	Camble
--3949	Costa	Sleightholm
--3704	Haslett	Ropars
--3989	Nicolas	Burdass

SELECT COUNT(*)
FROM customer c
LEFT JOIN transaction t ON c.customer_id = t.customer_id
WHERE t.transaction_id IS NULL;
--507


--Задача 7
--Вывести всех клиентов из IT, у которых транзакции с максимальной стандартной стоимостью.


--Найти всех клиентов из IT
SELECT c.customer_id, c.first_name, c.last_name, t.standard_cost
FROM customer c
JOIN transaction t ON c.customer_id = t.customer_id
WHERE c.job_industry_category = 'IT';
--1791	Ninon	Van Der Hoog	829.51
--479	Blythe	Keighley		7.21
--255	Keeley	Kruger			594.68
--1210	Shandie	Sprigg			215.03
--1694	Tonnie	McLinden		141.40

--Найти максимальную стандартную стоимость для клиентов из IT
WITH it_customers AS (
    SELECT c.customer_id, c.first_name, c.last_name, t.standard_cost
    FROM customer c
    JOIN transaction t ON c.customer_id = t.customer_id
    WHERE c.job_industry_category = 'IT'
)
SELECT MAX(standard_cost) AS max_cost
FROM it_customers;
--1759.85

--Решение
WITH it_customers AS (
    SELECT c.customer_id, c.first_name, c.last_name, t.standard_cost
    FROM customer c
    JOIN transaction t ON c.customer_id = t.customer_id
    WHERE c.job_industry_category = 'IT'
),
max_standard_cost AS (
    SELECT MAX(standard_cost) AS max_cost
    FROM it_customers
)
SELECT customer_id, first_name, last_name, standard_cost
FROM it_customers
WHERE standard_cost = (SELECT max_cost FROM max_standard_cost);
--3473	Sanderson	Alloway		1759.85
--893	Gibby		Fearnley	1759.85
--3151	Thorn		Choffin		1759.85
--34	Jephthah	Bachmann	1759.85
--2913	Padraic		Bonnar		1759.85
--1918	Devin		Sandeson	1759.85
--1672	Sharla		Creebo		1759.85
--975	Goldarina	Rzehorz		1759.85
--1773	Nickolas	Guittet		1759.85

WITH it_customers AS (
    SELECT c.customer_id, c.first_name, c.last_name, t.standard_cost
    FROM customer c
    JOIN transaction t ON c.customer_id = t.customer_id
    WHERE c.job_industry_category = 'IT'
),
max_standard_cost AS (
    SELECT MAX(standard_cost) AS max_cost
    FROM it_customers
)
SELECT COUNT(*)
FROM it_customers
WHERE standard_cost = (SELECT max_cost FROM max_standard_cost);
--9



--Задача 8
--Вывести всех клиентов из сферы IT и Health, у которых есть подтвержденные транзакции за период '2017-07-07' по '2017-07-17'.

--Решение
SELECT DISTINCT c.customer_id, c.first_name, c.last_name
FROM customer c
JOIN transaction t ON c.customer_id = t.customer_id
WHERE c.job_industry_category IN ('IT', 'Health')
  AND t.order_status = 'Approved'
  AND t.transaction_date BETWEEN '2017-07-07' AND '2017-07-17';
--22	Deeanne		Durtnell
--28	Fee			Zellmer
--41	Basilius	Coupe
--47	Matthew		Jeaycock
--104	Odille		Panketh
--235	Leona		Phateplace
--239	Wells		Pressman
--249	D'arcy		Slay

SELECT COUNT(*)
FROM customer c
JOIN transaction t ON c.customer_id = t.customer_id
WHERE c.job_industry_category IN ('IT', 'Health')
  AND t.order_status = 'Approved'
  AND t.transaction_date BETWEEN '2017-07-07' AND '2017-07-17';
--124
















