
USE master;
GO

DROP DATABASE IF EXISTS SOCCER_CA_MEZLI;
GO

CREATE DATABASE SOCCER_CA_MEZLI;
GO

USE SOCCER_CA_MEZLI;
GO

CREATE TABLE Teams(
	TeamID INT NOT NULL IDENTITY(1, 1) PRIMARY KEY,
	TeamName NVARCHAR(100) NOT NULL,
	PhysicalAddress NVARCHAR(200) NOT NULL,
	ContactPhoneNumber NVARCHAR(15) NOT NULL,
	EmailAddress NVARCHAR(100) NOT NULL UNIQUE,
	Password NVARCHAR(100) NOT NULL
);

CREATE TABLE Tournaments(
	TournamentID INT NOT NULL IDENTITY(1, 1) PRIMARY KEY,
	TournamentName NVARCHAR(100) NOT NULL,
	TournamentDescription NVARCHAR(300) NOT NULL,
	LocationAddress NVARCHAR(200) NOT NULL,
	StartingDate DATETIME NOT NULL,
	EndingDate DATETIME NOT NULL,
	RegistrationCloseDate DATETIME NOT NULL,
	RegistrationCost MONEY NOT NULL
);

CREATE TABLE Registration(
	--RegistrationID INT NOT NULL PRIMARY KEY,
	AmountPaid MONEY NOT NULL,
	PaymentDate DATETIME NOT NULL DEFAULT(GETDATE()),
	TournamentID INT NOT NULL FOREIGN KEY REFERENCES Tournaments(TournamentID),
	TeamID INT NOT NULL FOREIGN KEY REFERENCES Teams(TeamID),
	PRIMARY KEY (TournamentID, TeamID) 
);
GO



--BUSINESS REQUIREMENTS OR CONSTRAINTS 

--Teams will use their email address to log in to the system, so there must not be any duplicate email address es in the table
--ALTER TABLE Teams
--ADD CONSTRAINT UQ_Team_Email UNIQUE (EmailAddress);

--Payments Payment date must always be the current system date
--ALTER TABLE Registration
--ADD CONSTRAINT CurrentDate_Registration_PaymentDate DEFAULT (GETDATE()) FOR PaymentDate;

--Teams cannot register to a tournament after the Registration Close Date
ALTER TABLE Tournaments
ADD CONSTRAINT CHK_Tournament_RegistrationCloseDate CHECK (RegistrationCloseDate <= GETDATE());

--Teams cannot register to a tournament more than one time
-- THIS IS SOLVED WHEN THE TABLE IN CREATED WITH THE COMBINATION OF PK AND FK FOR BOTH ATTRIBUTES 


GO

-- INDEX CONSTRAINTS
--tournaments table on Name
CREATE INDEX IDX_Tournaments_Name 
	ON Tournaments (TournamentName);

--Teams table on Team Name and Email Address
CREATE INDEX IDX_Teams_NameAndEmail
	ON Teams (TeamName, EmailAddress);

GO

-- DELETING INDEX CONSTRAINTS JUST IN CASE IS NEEDED

--DROP INDEX IDX_Tournaments_Name ON Tournaments;

--DROP INDEX IDX_Teams_NameAndEmail ON Teams;

--GO

-- STORED PROCEDURES

--Create a STORED PROCEDURE to allow a third party mobile application to DELETE from the Teams.
CREATE PROCEDURE PROC_Delete_Teams(
	@TeamID INT
)
AS
	BEGIN
		DELETE FROM dbo.Teams WHERE TeamID = @TeamID;
	END
GO 

--Create a STORED PROCEDURE to allow a third party mobile application to DELETE from the Tournament table
CREATE PROCEDURE PROC_Delete_Tournaments(
	@TournamentID INT
)
AS
	BEGIN
		DELETE FROM Tournaments WHERE TournamentID = @TournamentID;
	END
GO

--DELETING PROCEDURES JUST IN CASE IS NEEDED
/*
DROP PROCEDURE PROC_Delete_Teams;
GO

DROP PROCEDURE PROC_Delete_Tournaments;
GO
*/

-- VIEWS

--Create a VIEW that shows all the Registrations so far, ordered by DATE from newest to oldest.

CREATE VIEW VW_Registration_ShowRegistrationsByDateDESC
AS
	SELECT * FROM Registration 
GO
SELECT * FROM VW_Registration_ShowRegistrationsByDateDESC ORDER BY PaymentDate DESC;
GO

--SECOND VERSION FOR THE VIEW
--CREATE VIEW VW_Registration_ShowRegistrationsByDateDESC_VERSION2

--AS
--	SELECT Teams.TeamID, Registration.PaymentDate, Registration.AmountPaid
--	FROM Registration -- first primary
--		INNER JOIN Teams -- then secondary
--		ON Registration.TeamID = Teams.TeamID
--	ORDER BY Registration.PaymentDate DESC;
--GO

--DELETING VIEW JUST IN CASE IS NEEDED 
--DROP VIEW VW_Registration_ShowRegistrationsByDateDESC;
--GO

-- FUCTIONS
--Create a function that returns the local server time, plus/minus a specified offset of hours. Example: calling func_getTime(‘9:00pm’,-3) must return ‘6:00pm’

CREATE FUNCTION FN_LocalServerTimeInTheWorld(
	@OffSet INT,
	@Time DATETIME
)
RETURNS DATETIME
AS
	BEGIN
		DECLARE @Result DATETIME;
		SELECT @Result = DATEADD(HOUR, @OffSet, @Time);	
		RETURN @Result;
	END
GO

	
/**************************
/ INSERTING DATA
**************************/

INSERT INTO Teams(TeamName, PhysicalAddress, ContactPhoneNumber, EmailAddress, Password) 
		VALUES('Go Tigers', 
				'255 Billy Jean St., Toronto, ON, M6K 3A2', 
				'741-608-3120',
				'contact@gotigers22.com',
				'Qwerty!1234+');

INSERT INTO Tournaments(TournamentName, TournamentDescription, LocationAddress, StartingDate, EndingDate, RegistrationCloseDate, RegistrationCost) 
		VALUES('Canada Soccer Summer Cup', 
				'Family friendly event!', 
				'170 Princes Blvd, Toronto, ON, M6K 3C3',
				'2020-06-01',
				'2020-06-30',
				'2020-05-25',
				15);
				
INSERT INTO Registration(AmountPaid, PaymentDate, TournamentID, TeamID) 
		VALUES(1200,
				GETDATE(),
				1, 
				1);

/**************************
/ QUERYING DATA
**************************/

SELECT * FROM Teams;

SELECT * FROM Tournaments;

SELECT * FROM Registration;

GO

