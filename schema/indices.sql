-- Покрывающий индекс на запрос
-- SELECT quantity from Inventory WHERE quantity > 10;
-- Скриншоты: ncl_q_before, ncl_q_after
CREATE NONCLUSTERED INDEX ncl_quantity on Inventory(quantity);

-- Индекс на JOIN
-- SELECT p.id, s.name FROM Progress as p
-- JOIN Status as s on p.status = s.id
-- Скриншоты: cl_name_before, cl_name_after
CREATE CLUSTERED INDEX cl_name ON Status([id,name]);


-- Кластерный индекс на запрос с like
-- SELECT * FROM Inventory WHERE name LIKE 'iPhone%'
-- Скриншоты ncl_invlike_before, ncl_invlike_after
CREATE CLUSTERED INDEX cl_name ON Inventory([name]);
