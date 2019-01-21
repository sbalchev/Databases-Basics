CREATE TABLE People(
Id INT PRIMARY KEY IDENTITY,
Name NVARCHAR(200) NOT NULL,
Picture VARBINARY(max),
Height FLOAT(2),
Weight FLOAT(2),
Gender NVARCHAR(1) NOT NULL,
Birthdate DATE NOT NULL,
Biography NVARCHAR(max)
)

INSERT INTO People(Name, Picture, Height, Weight, Gender, Birthdate, Biography) VALUES ('Ivan', NULL, 1.78, 86.6, 'm', '1982-01-22', 'no bio')
INSERT INTO People(Name, Picture, Height, Weight, Gender, Birthdate, Biography) VALUES ('Dragan', NULL, 1.98, 88.6, 'm', '1982-11-09', 'no bio')
INSERT INTO People(Name, Picture, Height, Weight, Gender, Birthdate, Biography) VALUES ('Petkan', NULL, 1.48, 66.6, 'm', '1986-01-02', 'no bio')
INSERT INTO People(Name, Picture, Height, Weight, Gender, Birthdate, Biography) VALUES ('Yordan', NULL, 1.68, 85.6, 'm', '1985-12-12', 'no bio')
INSERT INTO People(Name, Picture, Height, Weight, Gender, Birthdate, Biography) VALUES ('Mitko', NULL, 1.88, 97.6, 'm', '1982-01-12', 'no bio')
