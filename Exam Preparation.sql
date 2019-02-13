CREATE TABLE Cities(
Id INT PRIMARY KEY IDENTITY,
Name NVARCHAR(20) NOT NULL,
CountryCode CHAR(2) NOT NULL
)
 
CREATE TABLE Hotels(
Id INT PRIMARY KEY IDENTITY,
Name NVARCHAR(30) NOT NULL,
CityId INT FOREIGN KEY REFERENCES Cities(Id) NOT NULL,
EmployeeCount INT NOT NULL,
BaseRate DECIMAL(15,2)
)
 
CREATE TABLE Rooms(
Id INT PRIMARY KEY IDENTITY,
Price DECIMAL(15,2) NOT NULL,
TYPE NVARCHAR(20) NOT NULL,
Beds INT NOT NULL,
HotelId INT FOREIGN KEY REFERENCES Hotels(Id) NOT NULL
)
 
CREATE TABLE Trips(
Id INT PRIMARY KEY IDENTITY,
RoomId INT FOREIGN KEY REFERENCES Rooms(Id) NOT NULL,
BookDate DATE NOT NULL,
ArrivalDate DATE NOT NULL,
ReturnDate DATE NOT NULL,
CancelDate DATE,
CONSTRAINT CK_BookDate_ArrivalDate CHECK (BookDate < ArrivalDate),
CONSTRAINT CK_ArrivalDate_ReturnDate CHECK (ArrivalDate < ReturnDate),
)
 
CREATE TABLE Accounts(
Id INT PRIMARY KEY IDENTITY,
FirstName NVARCHAR(50) NOT NULL,
MiddleName NVARCHAR(20),
LastName NVARCHAR(50) NOT NULL,
CityId INT FOREIGN KEY REFERENCES Cities(Id) NOT NULL,
BirthDate DATE NOT NULL,
Email NVARCHAR(100) UNIQUE NOT NULL
)
 
CREATE TABLE AccountsTrips(
AccountId INT FOREIGN KEY REFERENCES Accounts(Id) NOT NULL,
TripId INT FOREIGN KEY REFERENCES Trips(Id) NOT NULL,
Luggage INT CHECK(Luggage >= 0)
CONSTRAINT PK_AccountsTrips PRIMARY KEY (AccountId, TripId)
)
 
 
--Insert
INSERT INTO Accounts(FirstName, MiddleName, LastName, CityId, BirthDate, Email)
VALUES ('John', 'Smith', 'Smith', 34, '1975-07-21', 'j_smith@gmail.com'),
('Gosho', NULL, 'Petrov', 11, '1978-05-16', 'g_petrov@gmail.com'),
('Ivan', 'Petrovich', 'Pavlov', 59, '1849-09-26', 'i_pavlov@softuni.bg'),
('Friedrich', 'Wilhelm', 'Nietzsche', 2, '1844-10-15', 'f_nietzsche@softuni.bg')
 
INSERT INTO Trips(RoomId, BookDate, ArrivalDate, ReturnDate, CancelDate)
VALUES (101, '2015-04-12','2015-04-14', '2015-04-20',   '2015-02-02'),
(102, '2015-07-07','2015-07-15',    '2015-07-22',   '2015-04-29'),
(103, '2013-07-17','2013-07-23',    '2013-07-24',   NULL),
(104, '2012-03-17','2012-03-31',    '2012-04-01',   '2012-01-10'),
(109, '2017-08-07','2017-08-28',    '2017-08-29',   NULL)
 
--Update
UPDATE Rooms
SET Price += Price * 0.14
WHERE HotelId IN (5, 7, 9)
 
--Delete
DELETE FROM AccountsTrips
WHERE AccountId = 47
 
--5
SELECT Id, Name FROM Cities
WHERE CountryCode = 'BG'
ORDER BY Name
 
--6
SELECT FirstName + ' ' + ISNULL(MiddleName + ' ', '') + LastName AS FullName,
DATEPART(YEAR, BirthDate) AS Birthyear
 FROM Accounts
WHERE DATEPART(YEAR, BirthDate) > 1991
ORDER BY Birthyear DESC, FullName
 
--7
SELECT FirstName, LastName, FORMAT(BirthDate, 'MM-dd-yyyy'), c.Name AS Hometown, Email  FROM Accounts AS a
JOIN Cities AS c
ON c.Id = a.CityId
WHERE Email LIKE 'e%'
ORDER BY c.Name DESC
 
--8
SELECT c.Name, COUNT(h.Id) AS HotelCount FROM Cities AS c
LEFT JOIN Hotels AS h
ON h.CityId = c.Id
GROUP BY c.Name
ORDER BY HotelCount DESC, c.Name
 
--9
SELECT r.Id, r.Price, h.Name, c.Name FROM Rooms AS r
JOIN Hotels AS h
ON h.Id = r.HotelId
JOIN Cities AS c
ON c.Id = h.CityId
WHERE TYPE = 'First Class'
ORDER BY r.Price DESC, r.Id
 
 
--10
 
SELECT a.Id, a.FirstName + ' ' + a.LastName,
MAX(DATEDIFF(DAY, ArrivalDate, ReturnDate)) AS LongestTrip
,MIN(DATEDIFF(DAY, ArrivalDate, ReturnDate)) AS ShortestTrip
FROM Accounts AS a
JOIN AccountsTrips AS at
ON a.Id = at.AccountId
JOIN Trips AS t
ON t.Id = at.TripId
WHERE a.MiddleName IS NULL AND t.CancelDate IS NULL
GROUP BY a.Id, a.FirstName + ' ' + a.LastName, AccountId
ORDER BY  LongestTrip DESC, AccountId
 
--11
SELECT TOP(5) c.Id,c.Name, c.CountryCode, COUNT(a.Id) AS COUNT FROM Cities AS c
JOIN Accounts AS a
ON a.CityId = c.Id
GROUP BY c.Name, c.CountryCode, c.Id
ORDER BY COUNT DESC
 
--12
 
SELECT a.Id, a.Email, c.Name, COUNT(t.Id) AS TripsCount FROM Accounts AS a
JOIN AccountsTrips AS at
ON at.AccountId = a.Id
JOIN Trips AS t
ON t.Id = at.TripId
JOIN Rooms AS r
ON r.Id = t.RoomId
JOIN Hotels AS h
ON h.Id = r.HotelId
JOIN Cities AS c
ON c.Id = h.CityId
WHERE c.Id = a.CityId
GROUP BY  a.Id, a.Email, c.Name
ORDER BY TripsCount DESC, a.Id
 
--13
SELECT TOP(10) c.Id, c.Name, SUM(h.BaseRate + r.Price) AS TotalRevenue,
 COUNT(t.Id) AS TripCount FROM Cities AS c
JOIN Hotels AS h
ON h.CityId = c.Id
JOIN Rooms AS r
ON r.HotelId = h.Id
JOIN Trips AS t
ON t.RoomId = r.Id
WHERE DATEPART(YEAR, t.BookDate) = 2016
GROUP BY c.Id, c.Name
ORDER BY TotalRevenue DESC, TripCount DESC
 
--14
SELECT t.Id,
h.Name,
r.TYPE,
CASE
WHEN t.CancelDate IS  NOT NULL
THEN 0.00
ELSE
SUM(h.BaseRate + r.Price)
END AS Revenue
FROM Trips AS t
JOIN Rooms AS r
ON r.Id = t.RoomId
JOIN Hotels AS h
ON h.Id = r.HotelId
JOIN AccountsTrips AS at
ON at.TripId= t.Id
GROUP BY t.Id, h.Name,r.TYPE, t.CancelDate
ORDER BY r.TYPE, t.Id
 
--15
SELECT r.Id, r.Email, r.CountryCode, r.Trips
    FROM(
    SELECT a.Id, a.Email, c.CountryCode, COUNT(*) AS Trips,
    DENSE_RANK() OVER (PARTITION BY c.CountryCode ORDER BY COUNT(*) DESC, a.Id) AS TripsRank
      FROM Accounts AS a
      JOIN AccountsTrips AS [at] ON [at].AccountId = a.Id
      JOIN Trips AS t ON t.Id = at.TripId
      JOIN Rooms AS r ON r.Id = t.RoomId
      JOIN Hotels AS h ON h.Id = r.HotelId
      JOIN Cities AS c ON c.Id = h.CityId
      GROUP BY c.CountryCode, a.Email, a.Id) AS r
      WHERE r.TripsRank = 1
      ORDER BY r.Trips DESC, r.Id ASC
 
--16
SELECT
  TripId,
  SUM(Luggage) AS Luggage,
  '$' + CONVERT(VARCHAR(10), SUM(Luggage) *
                             CASE WHEN SUM(Luggage) > 5
                               THEN 5
                             ELSE 0 END) AS Fee
FROM Trips
  JOIN AccountsTrips AT ON Trips.Id = AT.TripId
GROUP BY TripId
HAVING SUM(Luggage) > 0
ORDER BY Luggage DESC
 
--17
SELECT t.Id, a.FirstName +' '+ ISNULL(a.MiddleName+' ', '') + LastName AS FullName,
c.Name AS [FROM],
hc.Name AS [TO],
CASE
WHEN t.CancelDate IS NOT NULL THEN 'Canceled'
ELSE CONVERT(VARCHAR(10),DATEDIFF(DAY, ArrivalDate, ReturnDate)) + ' days'
END AS Duration
 FROM Trips AS t
 JOIN Rooms AS r
 ON r.Id = t.RoomId
 JOIN Hotels AS h
 ON h.Id = r.HotelId
 JOIN Cities AS hc
 ON hc.Id = h.CityId
JOIN AccountsTrips AS at
ON at.TripId = t.Id
JOIN Accounts AS a
ON a.Id = at.AccountId
JOIN Cities AS c
ON c.Id = a.CityId
ORDER BY FullName, t.Id
 
--18
GO
 
 
SELECT dbo.udf_GetAvailableRoom(112, '2011-12-17', 2)
SELECT dbo.udf_GetAvailableRoom(94, '2015-07-26', 3)
 
ALTER FUNCTION udf_GetAvailableRoom(@HotelId INT, @DATE DATETIME2, @People INT) RETURNS VARCHAR(MAX)
AS BEGIN
   DECLARE @AvailableRoom NVARCHAR(MAX)= (SELECT TOP(1) CONCAT('Room ', r.Id, ': ', r.TYPE,' (', r.Beds, ' beds) - $', (h.BaseRate + r.Price) * @People)
                  FROM Hotels AS h
                  JOIN Rooms AS r
                  ON r.HotelId = h.Id
                  JOIN Trips AS t
                  ON t.RoomId = r.Id
                  WHERE @DATE NOT BETWEEN t.ArrivalDate AND t.ReturnDate
                  AND h.Id = @HotelId AND r.Beds > @People
                  AND t.CancelDate IS NULL
                  ORDER BY r.Price DESC)
 
        IF(@AvailableRoom IS NULL)
        BEGIN
           RETURN 'No rooms available'
        END
       
          RETURN @AvailableRoom
END
 
 
--19
GO
CREATE PROCEDURE usp_SwitchRoom(@TripId INT, @TargetRoomId INT)
AS
BEGIN
 
DECLARE @HotelId INT = (SELECT TOP(1) r.HotelId
                               FROM Trips AS t
                               JOIN Rooms AS r
                               ON r.Id = t.RoomId
                               WHERE t.Id = @TripId)
     
     DECLARE @TargetRoomHotelId INT = (SELECT TOP(1) r.HotelId
                                        FROM Rooms AS r
                                        WHERE r.Id = @TargetRoomId)
 
IF(@HotelId != @TargetRoomHotelId)
BEGIN
RAISERROR('Target room is in another hotel!', 16, 1)
    RETURN
END
 
  DECLARE @NumberOfPeople INT = (SELECT COUNT(*)
                                      FROM AccountsTrips AS at
                                      WHERE at.TripId = @TripId)
 
    IF((SELECT TOP(1) r.Beds FROM Rooms AS r WHERE r.Id = @TargetRoomId) < @NumberOfPeople)
    BEGIN
     RAISERROR('Not enough beds in target room!', 16, 1)
    RETURN
    END
 
UPDATE Trips
SET RoomId = @TargetRoomId
WHERE Id = @TripId
 
END
 
EXEC usp_SwitchRoom 10, 11
SELECT RoomId FROM Trips WHERE Id = 10
 
EXEC usp_SwitchRoom 10, 7
EXEC usp_SwitchRoom 10, 8
 
--20
CREATE TRIGGER tr_CancelTrip ON Trips
INSTEAD OF DELETE
AS
UPDATE Trips
SET CancelDate = GETDATE()
WHERE Id IN (SELECT Id FROM deleted WHERE CancelDate IS NULL)
