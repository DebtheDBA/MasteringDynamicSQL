/*******************************/
/* Mastering Dynamic SQL Demos */
/*******************************/

USE AutoDealershipDemo
GO

--- Turn on Execute Plans (Ctrl + M)

/* I tend to use nvarchar(max) a lot. 

WHY?
1. sp_executesql parameter is Unicode so I want to match
2. If I don't know the size of the query that's going to 
	be built, I need to be able to handle all situations.
	But this can be dangerous. If you know what size it's 
	going to be, use that for safety's sake
3. From the MS documentation:
	"On 64-bit servers, the size of the string is limited 
	to 2 GB, the maximum size of nvarchar(max)."

*/






/* EXEC vs. sp_executesql */

DECLARE @SQL nvarchar(max)
SELECT @SQL = N'SELECT ''initial test'''

EXEC (@SQL)
EXEC sys.sp_executesql @SQL
GO



-- no actual execution plans???? 
-- It's a select statement with a constant. So it checks

-- now let's get some execution plans

DECLARE @SQL nvarchar(max)
SELECT @SQL = N'SELECT TOP 10 * FROM Inventory'

EXEC (@SQL)

EXEC sys.sp_executesql @SQL
GO



-- what if we want to have this vary for different tables?
DECLARE @SQL nvarchar(max),
	@Table sysname = 'Inventory'

-- This won't run. Don't bother....
--SELECT top 10 * FROM @Table

-- One option for writing this using EXEC 
--EXEC ('SELECT top 10 * FROM ' + @table)

SELECT @SQL = N'SELECT TOP 10 * FROM ' + @table
PRINT @SQL

EXEC (@SQL)

EXEC sp_executesql @SQL
GO



/*********************************
-- SECURITY PLEASE!!!!!
*********************************/

DECLARE @SQL nvarchar(max),
	@Table sysname = 'Inventory; SELECT ''Boston, We have a problem.'' as Injection'
	
SELECT @SQL = N'SELECT TOP 10 * FROM ' + @table
PRINT @SQL

EXEC (@SQL)

EXEC sp_executesql @SQL
GO


-- Let's solve this by using square brackets
/* Now let's try to break this */
DECLARE @SQL nvarchar(max),
	@Table sysname = 'Inventory] ; SELECT ''Boston, We have a problem.'' as [I can still do this:'


SELECT @SQL = N'SELECT TOP 10 * FROM [' + @table + ']'
PRINT @SQL

EXEC (@SQL)

EXEC sp_executesql @SQL
GO


-- use QUOTENAME for objects!!!
DECLARE @SQL nvarchar(max),
	@Table sysname = 'Inventory]; SELECT ''Boston, We have a problem.'' as [I can still do this:;'

SELECT @SQL = N'SELECT TOP 10 * FROM ' + QUOTENAME(@table)
PRINT @SQL

EXEC (@SQL)

EXEC sp_executesql @SQL
GO

-- Try other varieties to break this. It's harder to do, so have fun!


/************************* 
 Relationship of Dynamic SQL to the batch it's running in 
*************************/
SELECT @@SPID as SpidFromBatch

DECLARE @SQL nvarchar(max) = 'SELECT @@SPID as SpidFromDynamicSQL'
EXEC sys.sp_executesql @SQL

SELECT @SQL = N'SELECT @@SPID as SpidFromDynamicSQLEXEC'
EXEC (@SQL)

EXEC master..xp_cmdshell 'sqlcmd -S"localhost" -Q"SELECT @@SPID as SpidFromSQLCmd"'

GO

-- Why is this important?
-- show with temp tables

DROP TABLE IF EXISTS #Test

/* Use this temp table for the examples */
CREATE TABLE #Test
	(ID int IDENTITY(1,1),
	SampleValue varchar(50))


/* How I usually think of doing the statements */
DECLARE @Sql nvarchar(100)

SELECT @SQL = N'SELECT ''TestValue from standalone dynamic statement'' as TestValue'

INSERT INTO #Test (SampleValue)
EXEC sp_executesql @Sql

SELECT * FROM #Test
GO

/* How I can think of doing the statements */
DECLARE @Sql nvarchar(100)

SELECT @SQL = N'
INSERT INTO #Test (SampleValue)
SELECT ''TestValue from combined dynamic statement'' as TestValue'

EXEC sp_executesql @Sql

SELECT * FROM #Test
GO

/************************* 
 Parameters 
*************************/
-- Parameterize your queries. Start with EXEC 
DECLARE @SQL nvarchar(max),
	@BaseModelID int = 58

-- run just this part first
SELECT @SQL = N'SELECT TOP 10 * FROM Inventory WHERE BaseModelID = @BaseModelID'
EXEC (@SQL)

SELECT @BaseModelID
GO


DECLARE @SQL nvarchar(max),
	@BaseModelID int = 58

SELECT @SQL = N'SELECT TOP 10 * FROM Inventory WHERE BaseModelID = ' + convert(nvarchar(5), @BaseModelID)
EXEC (@SQL)

SELECT @SQL = N'SELECT TOP 10 * FROM Inventory WHERE BaseModelID = @BaseModelID'
EXEC sp_executesql @SQL, N'@BaseModelID int', @BaseModelID

GO

-- Multiple Parameters
DECLARE @SQL nvarchar(max),
	@BaseModelID int = 58,
	@PackageID int = 4


SELECT @SQL = N'SELECT TOP 10 * FROM Inventory WHERE BaseModelID = ' + convert(nvarchar(5), @BaseModelID)
	 + ' AND PackageID = ' + convert(nvarchar(5), @PackageID)
EXEC (@SQL)


SELECT @SQL = N'SELECT TOP 10 * FROM Inventory WHERE BaseModelID = @BaseModelID AND PackageID = @PackageID'
EXEC sp_executesql @SQL, N'@BaseModelID int, @PackageID int', @BaseModelID, @PackageID

GO

-- Parameters passed to the query don't have to match the inside parameter names
DECLARE @SQL nvarchar(max),
	@New_Base_Model_ID int = 58,
	@New_Package_ID int = 4

SELECT @SQL = N'SELECT TOP 10 * FROM Inventory WHERE BaseModelID = @BaseModelID AND PackageID = @PackageID'
EXEC sp_executesql @SQL, N'@BaseModelID int, @PackageID int', @New_Base_Model_ID, @New_Package_ID

GO

-- but the order still matters
DECLARE @SQL nvarchar(max),
	@New_Base_Model_ID int = 58,
	@New_Package_ID int = 4

SELECT @SQL = N'SELECT TOP 10 * FROM Inventory WHERE BaseModelID = @BaseModelID AND PackageID = @PackageID
SELECT @BaseModelID as BaseModelValue, @PackageID as PackageValue'
EXEC sp_executesql @SQL, N'@BaseModelID int, @PackageID int', @New_Package_ID, @New_Base_Model_ID

GO



-- Output parameters
DECLARE @SQL nvarchar(max),
	@BaseModelID int = 58,
	@TotalCount int


SELECT @SQL = N'SELECT @TotalCount = count(*) FROM Inventory WHERE BaseModelID = ' + convert(nvarchar(5), @BaseModelID)
--EXEC (@SQL)

-- has to be done as an INSERT
-- SELECT @TotalCount = EXEC (@SQL)

DECLARE @TotalCountTV TABLE (TotalCount INT)
SELECT @SQL = N'SELECT count(*) FROM Inventory WHERE BaseModelID = ' + convert(nvarchar(5), @BaseModelID)

INSERT INTO @TotalCountTV
EXEC (@SQL)

SELECT * FROM @TotalCountTV
GO


DECLARE @SQL nvarchar(max),
	@BaseModelID int = 58,
	@TotalCount int

SELECT @SQL = N'SELECT @TotalCount = count(*) FROM Inventory WHERE BaseModelID = @BaseModelID'
EXEC sp_executesql @SQL, N'@BaseModelID int, @TotalCount int OUTPUT', @BaseModelID, @TotalCount OUTPUT

SELECT @TotalCount


/************************* 
 What happens if you change the database inside the dynamic SQL statement?
*************************/

SELECT DB_NAME() AS Before_DB

EXEC sp_executesql N'
USE Superheroes;

SELECT DB_NAME() as DynamicSQLDB
'

SELECT DB_NAME() AS After_DB

/* as a side note, there are some things you can't do with Dynamic SQL*/
EXEC sp_executesql N'
USE Superheroes;
GO

SELECT DB_NAME() as DynamicSQLDB
'

/************************* 
 What does this mean for transactions ?
*************************/

-- create transaction outside dynamic sql
-- does it show inside the statement?
-- run individually

BEGIN TRAN TransactionOutside

SELECT TOP 10 * FROM dbo.Inventory

SELECT * FROM sys.dm_tran_active_transactions WHERE name = 'TransactionOutside'
EXEC sp_executesql N'SELECT * FROM sys.dm_tran_active_transactions  WHERE name = ''TransactionOutside'''

ROLLBACK TRAN TransactionOutside

/*
-- create transaction inside dynamic sql
	-- once for the current database
	-- once creating inside a different database
	-- does it show outside the statement
*/

EXEC sp_executesql N'
BEGIN TRAN TransactionInside

SELECT TOP 10 * FROM dbo.Inventory

--ROLLBACK TRAN TransactionInside
'

SELECT * FROM sys.dm_tran_active_transactions
WHERE name = 'TransactionInside'

ROLLBACK TRAN TransactionInside



/* 
https://www.sommarskog.se/error_handling/Part2.html#nestedtransactions 
*/

SELECT @@TRANCOUNT AS OutsideTransaction, @@NESTLEVEL AS OutsideNestLevel

EXEC sp_executesql N'
SELECT @@TRANCOUNT InsideTransaction_Before, @@NESTLEVEL InsideNestLevel_Before

BEGIN TRAN TransactionInside

SELECT @@TRANCOUNT InsideTransaction, @@NESTLEVEL InsideNestLevel 

ROLLBACK TRAN TransactionInside

SELECT @@TRANCOUNT InsideTransaction_After, @@NESTLEVEL InsideNestLevel_After
'
GO

--- does the same thing happen with EXEC(@SQL)?
DECLARE @SQL NVARCHAR(MAX) = '
SELECT @@TRANCOUNT InsideTransaction_Before, @@NESTLEVEL InsideNestLevel_Before

--BEGIN TRAN TransactionInside

--SELECT @@TRANCOUNT InsideTransaction, @@NESTLEVEL InsideNestLevel '

EXEC (@SQL)

ROLLBACK TRAN TransactionInside

GO


