-- Task 3. Basic queries

-- Task 3.1. Joins

-- Simple
-- Get managers
SELECT t.name, e.first_name, e.last_name
FROM OrgUnit AS ou
JOIN Team AS t
ON t.id = ou.team_id
JOIN Employee AS e
ON e.id = ou.employee_id and e.is_manager = 'TRUE'
ORDER BY t.id, e.id;

-- Self-join
-- create hierarhy: select managers and associate them with their subordinates
SELECT DISTINCT managers.first_name, managers.last_name, e.first_name, e.last_name
FROM Employee as managers
JOIN Employee as e
ON e.is_manager = 'FALSE'
JOIN OrgUnit as ou
ON ou.employee_id = managers.id
JOIN OrgUnit as ou2
ON ou2.employee_id = e.id
JOIN OrgUnit as ou3
ON ou.team_id = ou2.team_id
WHERE managers.is_manager = 'TRUE';

-- Task 3.2 Predicates

-- LIKE
-- Each team has similar phone number format, so we can get them
-- such way
SELECT (SELECT id FROM Team where name = 'Engineering'), e.id
FROM Employee AS e
WHERE e.phone LIKE '2%';

-- BETWEEN
SELECT *
FROM Progress as p
JOIN Status as s
ON p.status = s.id
WHERE p.status BETWEEN (SELECT id FROM Status WHERE name = 'Open') AND (SELECT id FROM Status WHERE name = 'Done')

-- IN
SELECT *
FROM Employee as e
JOIN OrgUnit as ou
ON e.id = ou.employee_id
WHERE ou.team_id IN ((SELECT id FROM Team WHERE name = 'Reception'),
                     (SELECT id FROM Team WHERE name = 'Engineering'))
ORDER BY e.id


-- Task 3.3 Case
-- print labels for inventory depending on whats left
SELECT name, quantity, "Level" =
  CASE
    WHEN quantity = 0 THEN 'Empty'
    WHEN quantity < 5 THEN 'Low'
    WHEN quantity < 7 THEN 'Medium'
  ELSE 'Good'
  END
FROM Inventory
ORDER BY Inventory.quantity;

-- Task 3.4 Special predicates
-- coalesce
SELECT p.id,
  COALESCE(p.assignee,
       COALESCE(
            (SELECT e.id
            FROM employee as e
            JOIN OrgUnit as ou
            ON ou.employee_id = e.id
            JOIN Team as t
            ON t.id = ou.team_id
            WHERE t.name = 'Engineering' and e.is_manager = 'TRUE'),
            (SELECT e.id
            FROM employee as e
            JOIN OrgUnit as ou
            ON ou.employee_id = e.id
            JOIN Team as t
            ON t.id = ou.team_id
            WHERE t.name = 'Administration' and e.is_manager = 'TRUE'))) as Asignee
FROM Progress as p;

-- if any open tasks, plz work message
SELECT IIF(SUM(IIF(s.name = 'Done', 1, 0)) != 0, 'Yep, work', 'Nope, relax') As 'Should I work?'
FROM Progress as p
JOIN Status AS s
ON s.id = p.id

-- cast + isnull
SELECT ISNULL(CAST(assignee AS varchar), 'None') AS VarCharColumnAssignee FROM Progress;

-- Task 3.5 Strings
-- HAVING + Strings
SELECT SUBSTRING(name, 0, (CHARINDEX('_', name))) as 'Brand', SUM(quantity)
FROM Inventory
GROUP BY SUBSTRING(name, 0, (CHARINDEX('_', name)))
HAVING SUM(quantity) >= 15

-- Task 3.6 Datetimes
-- some simple example
INSERT INTO ServiceOrder
VALUES (1, SYSDATETIME(), 1), (1, DATETIME2FROMPARTS(2016, 03, 12, 12, 50, 10, 0, 0),  2)

-- get today's tasks and clients
SELECT task_id, oi.name, c.first_name, c.last_name
FROM
(SELECT
    DATEPART(yyyy, update_date) as oy,
    DATEPART(m, update_date) as om,
    DATEPART(d, update_date) as od,
    id as task_id
    FROM Progress) a
JOIN (SELECT GETDATE() as today) b
ON a.oy = DATEPART(yyyy, today)
AND a.om = DATEPART(m, today)
AND a.od = DATEPART(d, today)
JOIN OrderItem as oi
ON oi.id = task_id
JOIN ServiceOrder as so
ON oi.id = so.orderitem_id
JOIN Client as c
ON so.client_id = c.id


-- Task 3.7 GROUP BY

-- Count different broken items
SELECT dt.name, count(device_type_id) as 'Quantity'
FROM OrderItem as oi
JOIN DeviceType as dt
ON oi.device_type_id = dt.id
GROUP BY (dt.name)

