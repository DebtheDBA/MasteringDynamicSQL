USE AutoDealershipDemo
GO

/* Now let's look at connecting to other servers */

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
DECLARE @SQL nvarchar(max)

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

/* add insert statement */
CREATE TABLE #Person (Person_First_Name varchar(50), Person_Last_Name varchar(50))

DECLARE @SQL nvarchar(max)
BEGIN TRY 
	SELECT @SQL = N'SELECT 
		a.*  
	FROM OPENROWSET(
		''SQLNCLI11'', 
		''Server=chihuahua;database=Superheroes;uid=andy_local;pwd=andy_local'',
		''SELECT First_Name, Last_Name FROM dbo.Person Where Person_ID <= 11''
	) AS a';  

	INSERT INTO #Person
	EXECUTE sp_executesql @SQL
END TRY
BEGIN CATCH
	
	SELECT 'Cannot access Chihuahua: ' + ERROR_MESSAGE() AS CaughtErrorMessage

END CATCH
GO

/* add the insert to the dynamic sql */
DROP TABLE IF EXISTS #Person

DECLARE @SQL nvarchar(max)
BEGIN TRY 
	SELECT @SQL = N'INSERT INTO #Person
	SELECT 
		a.*  
	FROM OPENROWSET(
		''SQLNCLI11'', 
		''Server=chihuahua;database=Superheroes;uid=andy_local;pwd=andy_local'',
		''SELECT First_Name, Last_Name FROM dbo.Person Where Person_ID <= 11''
	) AS a';  

	EXECUTE sp_executesql @SQL
END TRY
BEGIN CATCH
	
	SELECT 'Error running statement: ' + ERROR_MESSAGE() AS CaughtErrorMessage

END CATCH
GO

/* error when the database exists but the object doesn't */
DECLARE @SQL nvarchar(max)
--CREATE TABLE #Person (Person_First_Name varchar(50), Person_Last_Name varchar(50))

BEGIN TRY 
	SELECT @SQL = N'SELECT 
		a.*  
	FROM OPENROWSET(
		''SQLNCLI11'', 
		''Server=localhost;database=Superheroes;uid=andy_local;pwd=andy_local'',
		''SELECT First_Name, Last_Name FROM dbo.Persona Where Person_ID <= 11''
	) AS a';  

	INSERT INTO #Person
	EXECUTE sp_executesql @SQL
END TRY
BEGIN CATCH
	
	SELECT ERROR_MESSAGE() as CaughtErrorMessage

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

