-- WITH ENCRYPTION
CREATE VIEW dbo.AssigneeByTasksCount WITH ENCRYPTION
AS
SELECT TOP (100) PERCENT e.first_name, e.last_name, COUNT(*) AS 'Tasks'
FROM dbo.Progress AS p INNER JOIN
dbo.Status AS s ON s.id = p.status INNER JOIN
dbo.Employee AS e ON e.id = p.assignee
WHERE (s.name <> 'Done')
GROUP BY e.id, e.first_name, e.last_name;
-- WITH CHECK OPTION
CREATE VIEW dbo.EngineeringBranch
AS
SELECT DISTINCT managers.first_name + ' ' + managers.last_name,
e.first_name + ' ' + e.last_name
FROM Employee as managers
JOIN Employee as e
ON e.is_manager = 'FALSE'
JOIN OrgUnit as ou
ON ou.employee_id = managers.id
JOIN OrgUnit as ou2
ON ou2.employee_id = e.id
JOIN OrgUnit as ou3
ON ou.team_id = ou2.team_id
JOIN Team as t
ON ou.team_id = t.id
WHERE managers.is_manager = 'TRUE' and t.name = 'Engineering'
WITH CHECK OPTION
