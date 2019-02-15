01. Problem

CREATE TABLE Users
(
	Id INT PRIMARY KEY IDENTITY,
	Username NVARCHAR(30) NOT NULL UNIQUE,
	[Password] NVARCHAR(30) NOT NULL, 
	[Name] NVARCHAR(50),
	Gender CHAR(1) CHECK(Gender = 'M' OR Gender = 'F'),
	BirthDate DATETIME,
	Age INT,
	Email NVARCHAR(50) NOT NULL
)

CREATE TABLE Status
(
	Id INT PRIMARY KEY IDENTITY,
	Label VARCHAR(30) NOT NULL
)

CREATE TABLE Departments
(
	Id INT PRIMARY KEY IDENTITY,
	[Name] NVARCHAR(50) NOT NULL
)

CREATE TABLE Employees
(
	Id INT PRIMARY KEY IDENTITY,
	FirstName NVARCHAR(25),
	LastName NVARCHAR(25),
	Gender CHAR(1) CHECK (Gender = 'M' OR Gender = 'F'),
	BirthDate DATETIME,
	Age INT,
	DepartmentId INT NOT NULL FOREIGN KEY REFERENCES Departments(Id)
)

CREATE TABLE Categories
(
	Id INT PRIMARY KEY IDENTITY,
	[Name] VARCHAR(50) NOT NULL,
	DepartmentId INT FOREIGN KEY REFERENCES Departments(Id)
)

CREATE TABLE Reports
(
	Id INT PRIMARY KEY IDENTITY,
	CategoryId INT NOT NULL FOREIGN KEY REFERENCES Categories(Id),
	StatusId INT NOT NULL FOREIGN KEY REFERENCES Status(Id),
	OpenDate DATETIME NOT NULL,
	CloseDate DATETIME,
	[Description] VARCHAR(200), 
	UserId INT NOT NULL FOREIGN KEY REFERENCES Users(Id),
	EmployeeId INT FOREIGN KEY REFERENCES Employees(Id)
)


02.Problem
INSERT INTO Employees (FirstName, LastName,	Gender,	Birthdate,	DepartmentId)
VALUES 
('Marlo',	'O’Malley',	'M',	'9/21/1958', 1),
('Niki',	'Stanaghan',	'F',	'11/26/1969',	4),
('Ayrton',	'Senna',	'M',	'03/21/1960', 	9),
('Ronnie',	'Peterson',	'M',	'02/14/1944',	9),
('Giovanna',	'Amati',	'F',	'07/20/1959',	5)

INSERT INTO Reports (CategoryId,	StatusId,	OpenDate,	CloseDate,	[Description],	UserId,	EmployeeId)
VALUES
(1,	1,	'04/13/2017', NULL,	'Stuck Road on Str.133',	6,	2),
(6,	3,	'09/05/2015',	'12/06/2015',	'Charity trail running',	3,	5),
(14,	2,	'09/07/2015', NULL,	'Falling bricks on Str.58',	5,	2),
(4,	3,	'07/03/2017',	'07/06/2017',	'Cut off streetlight on Str.11',	1,	1)


03.Problem
UPDATE Reports
SET StatusId = 2
WHERE StatusId = 1 AND CategoryId = 4

04.Problem
DELETE FROM Reports
WHERE StatusId = 4

05.Problem
SELECT Username, Age FROM Users
ORDER BY Age, UserName DESC

06.Problem
SELECT Description, OpenDate FROM Reports
WHERE EmployeeId IS NULL
ORDER BY OpenDate, Description

07.Problem
SELECT e.FirstName, e.LastName,	r.Description,	FORMAT(r.OpenDate, 'yyyy-MM-dd') AS OpenDate FROM Employees AS e
JOIN Reports AS r ON r.EmployeeId = e.Id
ORDER BY e.Id, OpenDate, r.Id

08.Problem
SELECT c.Name AS CategoryName, COUNT(*) AS ReportsNumber FROM Categories AS c
JOIN Reports AS r ON r.CategoryId = c.Id
GROUP BY c.Name
ORDER BY ReportsNumber DESC, CategoryName

09.Problem
SELECT c.Name AS CategoryName, COUNT(e.Id) AS [Employees Number] FROM Categories AS c
JOIN Departments AS d ON d.Id = c.DepartmentId
JOIN Employees AS e ON e.DepartmentId = d.Id
GROUP BY c.Name
ORDER BY CategoryName

10.Problem
SELECT CONCAT(e.FirstName, ' ', e.LastName) AS Name,
	 COUNT(r.UserId) AS [Users Number]
FROM Employees AS e
LEFT JOIN Reports AS r ON r.EmployeeId = e.Id
GROUP BY CONCAT(e.FirstName, ' ', e.LastName)
ORDER BY [Users Number] DESC, Name


11.Problem
SELECT r.OpenDate, r.Description, u.Email AS [Reporter Email] FROM Reports AS r
JOIN Categories AS c ON c.Id = r.CategoryId
JOIN Departments AS d ON d.Id = c.DepartmentId
JOIN Users AS u ON u.Id = r.UserId
WHERE r.CloseDate IS NULL AND 
	  LEN(r.Description) > 20 AND
	  r.Description LIKE '%str%' AND
	  d.Name IN ('Infrastructure', 'Emergency', 'Roads Maintenance') 
ORDER BY r.[OpenDate], [Reporter Email], r.Id

12.Problem
SELECT DISTINCT c.Name AS [Category Name] FROM Users AS u
JOIN Reports AS r ON r.UserId = u.Id
JOIN Categories  AS c ON c.Id = r.CategoryId 
WHERE DATEPART(DAY, u.BirthDate) = DATEPART(DAY, r.OpenDate) AND  DATEPART(MONTH, u.BirthDate) = DATEPART(MONTH, r.OpenDate)
ORDER BY [Category Name]

13.Problem
SELECT Username FROM Users
WHERE Id IN 
(SELECT DigitUsersEnd.UserId FROM
(SELECT u.Id AS UserId, u.Username, c.Id AS CategoryId FROM Users AS u 
	JOIN Reports AS r ON r.UserId = u.Id
	JOIN Categories AS c ON c.Id = r.CategoryId
	WHERE u.Username LIKE '%[1-9]') AS DigitUsersEnd
WHERE CAST(RIGHT(DigitUsersEnd.Username, 1) AS INT) = DigitUsersEnd.CategoryId)
OR Id IN 
(SELECT DigitUsersStart.UserId FROM
	(SELECT u.Id AS UserId, u.Username, c.Id AS CategoryId FROM Users AS u 
	JOIN Reports AS r ON r.UserId = u.Id
	JOIN Categories AS c ON c.Id = r.CategoryId
	WHERE u.Username LIKE '[1-9]%') AS DigitUsersStart
WHERE CAST(LEFT(DigitUsersStart.Username, 1) AS INT) = DigitUsersStart.CategoryId)
ORDER BY Username


14.Problem
SELECT [EmpName],
        CONCAT(Closed, '/', Opened) AS [Closed Open Reports]
  FROM (SELECT 
		CONCAT(e.FirstName, ' ' ,e.LastName) AS [EmpName],
		e.Id AS EmpId,
		COUNT(r.CloseDate) AS Closed,
		COUNT(r.OpenDate) AS Opened
		FROM Employees AS e
		INNER JOIN Reports AS r
		ON r.EmployeeId = e.Id
		WHERE DATEPART(year, r.OpenDate) = 2016
		OR DATEPART(year, r.CloseDate) = 2016
		GROUP BY CONCAT(e.FirstName, ' ', e.LastName), e.Id) AS epcount
INNER JOIN Employees AS e ON e.Id = epcount.EmpId
ORDER BY [EmpName], e.Id

15.Problem
SELECT d.Name AS [Department Name], 
ISNULL(CAST(AVG(DATEDIFF(DAY, r.OpenDate, r.CloseDate)) AS VARCHAR(50)), 'no info') AS [Average Duration] FROM Departments AS d
JOIN Categories AS c ON c.DepartmentId = d.Id
JOIN Reports AS r ON r.CategoryId = c.Id
GROUP BY d.Name
ORDER BY [Department Name]


16.Problem
WITH cte
AS
(SELECT d.Id, COUNT(r.Id) AS total FROM Departments AS d
JOIN Categories AS c ON c.DepartmentId = d.Id
JOIN Reports AS r ON r.CategoryId = c.Id
GROUP BY d.Id)


SELECT d.Name AS [Department Name], c.Name AS [Category Name], ROUND((CAST(COUNT(r.Id) AS FLOAT) * 100 / cte.total),0)  AS Percentage
FROM cte 
JOIN Departments AS d ON d.Id = cte.Id
JOIN Categories AS c ON c.DepartmentId = d.Id
JOIN Reports AS r ON r.CategoryId = c.Id
GROUP BY d.Name, c.Name, cte.total
ORDER BY d.Name



17.Problem
CREATE FUNCTION udf_GetReportsCount(@employeeId INT, @statusId INT) 
RETURNS INT
AS
BEGIN
	DECLARE @ReportsCount INT = 
	(SELECT COUNT(*) FROM Reports 
	WHERE StatusId  = @statusId AND EmployeeId = @employeeId)

	RETURN @ReportsCount
END


18.Problem
CREATE PROC usp_AssignEmployeeToReport @employeeId INT, @reportId INT
AS 
BEGIN
	DECLARE @employeeDep INT = 
	(SELECT e.DepartmentId FROM Employees AS e
	WHERE e.Id = @employeeId)

	DECLARE @reportDep INT = 
	(SELECT c.DepartmentId FROM Reports AS r
	JOIN Categories AS c ON c.Id = r.CategoryId
	WHERE r.Id = @reportId)

	IF(@employeeDep = @reportDep)
	BEGIN
	UPDATE Reports
	SET EmployeeId = @employeeId
	WHERE Id = @reportId
	END
	ELSE
	BEGIN
		RAISERROR('Employee doesn''t belong to the appropriate department!', 16, 1)
	END
END


19.Problem
CREATE TRIGGER TR_CloseReports ON Reports AFTER UPDATE
AS
	DECLARE @completedStatusId int = (SELECT Id
					  FROM [Status]
					  WHERE Label = 'completed')

	UPDATE Reports
	SET StatusId = @completedStatusId
	WHERE Id = (SELECT Id
		    FROM inserted AS i
		    WHERE CloseDate IS NOT NULL)


20.Problem
WITH CTE_FilteredCategories
AS
(
SELECT c.[Name] AS [Category Name], s.Label
FROM Categories AS c
INNER JOIN Reports AS r ON r.CategoryId = c.Id
INNER JOIN [Status] AS s on s.Id = r.StatusId
WHERE r.StatusId IN (SELECT Id FROM [Status] WHERE Label IN ('waiting', 'in progress'))
)

SELECT  c.[Name] AS [Category Name], 
		COUNT(r.Id) AS [Reports Number], 
		[Main Status] =
				CASE
					WHEN (SELECT COUNT(cte.[Category Name])
					      FROM CTE_FilteredCategories AS cte 
					      WHERE cte.Label = 'in progress' 
					      AND cte.[Category Name] = c.[Name]) 
					      > 
					     (SELECT COUNT(cte.[Category Name])
					      FROM CTE_FilteredCategories AS cte 
					      WHERE cte.Label = 'waiting' 
					      AND cte.[Category Name] = c.[Name])
					THEN 'in progress'

					WHEN (SELECT COUNT(cte.[Category Name])
					      FROM CTE_FilteredCategories AS cte 
					      WHERE cte.Label = 'in progress' 
					      AND cte.[Category Name] = c.[Name]) 
					      < 
					      (SELECT COUNT(cte.[Category Name])
					      FROM CTE_FilteredCategories AS cte 
					      WHERE cte.Label = 'waiting' 
					      AND cte.[Category Name] = c.[Name])
					THEN 'waiting'
					ELSE 'equal'
				END 
FROM Categories AS c
INNER JOIN Reports AS r ON r.CategoryId = c.Id
WHERE r.StatusId IN (SELECT Id FROM [Status] WHERE Label IN ('waiting', 'in progress'))
GROUP BY c.[Name]
ORDER BY C.[Name], [Reports Number], [Main Status]