-- Task 4 Triggers

-- Trigger which sets manager of eng division as default
-- assignee for any progress
CREATE TRIGGER AddDefaultAssigneeWhenProgressCreated
ON Progress
AFTER INSERT
AS
IF EXISTS (SELECT * FROM Progress WHERE assignee is NULL)
BEGIN
UPDATE Progress
SET assignee = COALESCE(
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
            WHERE t.name = 'Administration' and e.is_manager = 'TRUE'))
WHERE assignee is NULL
RETURN
END;
GO

-- Trigger which makes each new progress actually New
CREATE TRIGGER MakeProgressNew
ON Progress
AFTER INSERT
AS
BEGIN
    UPDATE Progress
    SET status=(SELECT id FROM Status WHERE name='New')
    WHERE status IS NULL
END;
GO

-- Trigger which creates progress for each new OrderItem
CREATE TRIGGER CreateProgressForOrderItem
ON OrderItem
INSTEAD OF INSERT
AS
DECLARE @id int
DECLARE @progress_id int
BEGIN
     INSERT OrderItem
     SELECT name, device_type_id, issue, progress_id, is_warranty, serial
       FROM inserted;

     SELECT @id = IDENT_CURRENT('OrderItem')

     INSERT INTO Progress(update_date) VALUES (SYSDATETIME());

     SELECT @progress_id = IDENT_CURRENT('Progress')

     UPDATE OrderItem
     SET progress_id=@progress_id
     WHERE id=@id;
END;
GO
-- disable removal of opened orders
CREATE TRIGGER RemoveOnlyDone
ON OrderItem
INSTEAD OF DELETE
AS
DECLARE @status varchar(100)
BEGIN
  SELECT @status = s.name
    FROM OrderItem AS oi
    JOIN Progress as p
    ON p.id = oi.id
    JOIN Status as s
    ON p.status = s.id
    JOIN deleted as d
    ON d.id = oi.id
    WHERE oi.id = d.id;
  IF (@status != 'Closed')
  BEGIN
  RAISERROR('Cannot delete opened order. Please close it first', -1, -1)
  END;
  ELSE
  DELETE FROM OrderItem
  WHERE id = (SELECT id FROM deleted);
END;
GO

-- take only existing items from inventory
CREATE TRIGGER TakeItemFromInventory
ON Inventory
AFTER UPDATE
AS
IF (SELECT quantity FROM inserted) < 0
BEGIN
RAISERROR ('No such inventory item left', -1, -1);
ROLLBACK TRANSACTION;
RETURN;
END;
GO



-- disable 2+ mangers for 1 department
CREATE TRIGGER OnlySingleManager
ON OrgUnit
AFTER INSERT
AS
IF (SELECT COUNT(*)
    FROM OrgUnit as ou
    JOIN Employee as e
    ON e.id = ou.employee_id
    JOIN inserted as ou2
    ON ou2.team_id = ou.team_id
    JOIN Employee as e2
    ON e2.id = ou2.employee_id
    WHERE e.is_manager = 'TRUE' and e2.is_manager = 'TRUE') >= 2
    BEGIN
        RAISERROR ('Cannot add one more manager for department with manager', -1, -1);
        ROLLBACK TRANSACTION;
        RETURN;
    END;
GO
