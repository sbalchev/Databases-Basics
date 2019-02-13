CREATE TABLE Students(
 StudentID INT NOT NULL,
 Name NVARCHAR(50)
)

CREATE TABLE Exams(
 ExamId INT NOT NULL,
 Name NVARCHAR(50)
)

ALTER TABLE Students 
ADD CONSTRAINT PK_StudentId
PRIMARY KEY(StuDentId)

ALTER TABLE Exams
ADD CONSTRAINT PK_ExamId
PRIMARY KEY (ExamId)

CREATE TABLE StudentsExams(
 StudentID INT NOT NULL,
 ExamID INT NOT NULL
)

ALTER TABLE StudentsExams
ADD CONSTRAINT PK_StudentsExamsId
PRIMARY KEY (StudentID,ExamID)

ALTER TABLE StudentsExams
ADD CONSTRAINT FK_Students FOREIGN KEY (StudentID)
REFERENCES Students(StudentID)

ALTER TABLE StudentsExams
ADD CONSTRAINT FK_Exams FOREIGN KEY (ExamID)
REFERENCES Exams(ExamID)

INSERT INTO Students VALUES
(1,'Mila'),
(2,'Toni'),
(3,'Ron')

INSERT INTO Exams VALUES
(101,'SpringMVC'),
(102,'Neo4j'),
(103,'Oracle 11g')

INSERT INTO StudentsExams VALUES
(1,101),
(1,102),
(2,101),
(3,103),
(2,102),
(2,103)