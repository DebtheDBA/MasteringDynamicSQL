USE AutoDealershipDemo
GO


/* Let's look at connecting to other servers */

/* OPENROWSET to a server that exists */
DECLARE @SQL NVARCHAR(MAX)

SELECT @SQL = N'SELECT 
	a.*  
FROM OPENROWSET(
    ''SQLNCLI11'', 
    ''Server=localhost;database=Superheroes;uid=andy_local;pwd=andy_local'',
    ''SELECT * FROM dbo.Person Where Person_ID <= 11''
) AS a';  

EXECUTE sp_executesql @SQL
GO

/* OPENROWSET to a server that doesn't exist */
DECLARE @SQL NVARCHAR(MAX)

SELECT @SQL = N'SELECT 
	a.*  
FROM OPENROWSET(
    ''SQLNCLI11'', 
    ''Server=chihuahua;database=Superheroes;uid=andy_local;pwd=andy_local'',
    ''SELECT * FROM dbo.Person Where Person_ID <= 11''
) AS a';  

EXECUTE sp_executesql @SQL
GO

/* Catch the error nicely */
DECLARE @SQL nvarchar(max)
BEGIN TRY 

	SELECT @SQL = N'SELECT 
		a.*  
	FROM OPENROWSET(
		''SQLNCLI11'', 
		''Server=chihuahua;database=Superheroes;uid=andy_local;pwd=andy_local'',
		''SELECT * FROM dbo.Person Where Person_ID <= 11''
	) AS a';  

	EXECUTE sp_executesql @SQL

END TRY
BEGIN CATCH
	
	SELECT 'Cannot access Chihuahua' AS CaughtErrorMessage

END CATCH
GO


/* cursor for all servers */
DROP TABLE IF EXISTS #Person
CREATE TABLE #Person (Servername nvarchar(128), Person_First_Name varchar(50), Person_Last_Name varchar(50))

DECLARE @SQL nvarchar(max), @servername varchar(50)

DECLARE server_cursor SCROLL CURSOR FOR
SELECT *
FROM (VALUES ('chihuahua'), ('localhost')
	) as dogs(servername)

OPEN server_cursor

FETCH FIRST FROM server_cursor INTO @servername

WHILE @@FETCH_STATUS = 0
BEGIN 

	BEGIN TRY 
		SELECT @SQL = N'INSERT INTO #Person
		SELECT 
			a.*  
		FROM OPENROWSET(
			''SQLNCLI11'', 
			''Server=' + @servername + ';database=Superheroes;uid=andy_local;pwd=andy_local'',
			''SELECT @@servername, First_Name, Last_Name FROM dbo.Person Where Person_ID <= 11''
		) AS a';  

		EXECUTE sp_executesql @SQL
	END TRY
	BEGIN CATCH
	
		SELECT 'Cannot access ' + @servername + ': ' + ERROR_MESSAGE() AS CaughtErrorMessage

	END CATCH

	FETCH NEXT FROM server_cursor INTO @servername
END

CLOSE server_cursor
DEALLOCATE server_cursor

SELECT * FROM #Person
GO


/* 
Here's the fun part with dynamic SQL and error handling - 
You could get different messages, making it harder to troubleshoot.

NOTE: Run all of this together!!!
*/

USE Superheroes
GO

/* This proc will throw an error and return a single null column */
CREATE OR ALTER PROCEDURE dbo.fakeProc
AS
BEGIN
	
    THROW 51000, 'Don''t catch me ', 1;
    SELECT NULL AS ColumnA;

END
GO

GRANT EXECUTE ON dbo.fakeProc TO andy_local
GO

EXEC dbo.fakeProc
GO

/* switch back to the regular database */

USE AutoDealershipDemo
GO

/* Add the data from the dynamic SQL to a temp table */
DROP TABLE IF EXISTS #Person
CREATE TABLE #Person (Person_First_Name varchar(50), Person_Last_Name varchar(50))


DECLARE @SQL NVARCHAR(max)
SELECT @SQL = N'SELECT 
	a.*  
FROM OPENROWSET(
    ''SQLNCLI11'', 
    ''Server=localhost;database=Superheroes;uid=andy_local;pwd=andy_local'',
    ''EXEC dbo.fakeProc''
) AS a';  

BEGIN TRY 

    INSERT INTO #Person
    EXEC sp_executesql @sql

    END TRY
BEGIN CATCH
	
	SELECT ERROR_NUMBER() AS ErrorNumber, 
		'Error running statement: ' + ERROR_MESSAGE() AS CaughtErrorMessage

END CATCH
GO

DECLARE @SQL NVARCHAR(max)

SELECT @SQL = N'INSERT INTO #Person
SELECT 
	a.*  
FROM OPENROWSET(
    ''SQLNCLI11'', 
    ''Server=localhost;database=Superheroes;uid=andy_local;pwd=andy_local'',
    ''EXECUTE dbo.fakeProc''
) AS a';  

BEGIN TRY 

    EXEC sp_executesql @sql

    END TRY
BEGIN CATCH
	
	SELECT ERROR_NUMBER() AS ErrorNumber, 
		'Error running statement: ' + ERROR_MESSAGE() AS CaughtErrorMessage

END CATCH
GO

/* code clean up */
USE Superheroes
DROP PROCEDURE IF EXISTS dbo.fakeProc
GO
