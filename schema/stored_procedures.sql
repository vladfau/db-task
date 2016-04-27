-- Count and group tasks by status for engineer
CREATE PROCEDURE CountMyTasks @FN AS VARCHAR(60),
                              @LN AS VARCHAR(60)
AS
SELECT s.name, COUNT(*) as 'Task Count'
  FROM Progress AS p
  JOIN Employee AS e
  ON e.id = p.assignee
  JOIN Status as s
  on s.id = p.status
  WHERE e.first_name = @FN and e.last_name = @LN
  GROUP BY s.name
  ORDER BY 'Task Count' DESC
GO

EXEC CountMyTasks @FN='Core', @LN='Fixer'

-- Do I need to work?
USE serviceCenterMain
DROP PROCEDURE DoIHaveOpenTasks
GO
CREATE PROCEDURE DoIHaveOpenTasks @FN AS VARCHAR(60),
                  @LN AS VARCHAR(60),
                  @r AS VARCHAR(15) OUTPUT
AS
BEGIN
IF (SELECT COUNT(*)
  FROM Progress AS p
  JOIN Employee AS e
  ON e.id = p.assignee
  JOIN Status as s
  on s.id = p.status
  WHERE (s.name <> 'Done' and s.name <> 'Closed' and e.first_name = @FN and e.last_name = @LN)) <> 0
SET @r='Yes'
ELSE
SET @r='Nope, relax'
END
GO


DECLARE @res AS VARCHAR(100);

EXEC DoIHaveOpenTasks 'Core', 'Fixer', @res OUTPUT;
select @res;
