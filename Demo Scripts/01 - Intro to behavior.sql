/* Mastering Dynamic SQL Demos

Confirm database is SQL 2022 compat
and run sp_updatestats and turn on Query Store

*/

USE AutoDealershipDemo
GO

--- Turn on Execute Plans (Ctrl + M)

/* I tend to use nvarchar(max) a lot. 

WHY?
1. sp_executesql parameter is Unicode so I want to match
2. If I don't know the size of the query that's going to be built, I need to be able to handle all situations.
	But this can be dangerous. If you know what size it's going to be, use that for safety's sake
3. From the MS documentation:
	"On 64-bit servers, the size of the string is limited to 2 GB, the maximum size of nvarchar(max)."

*/

/* EXEC vs. sp_executesql */

DECLARE @SQL nvarchar(max)
SELECT @SQL = 'SELECT ''initial test'''

EXEC (@SQL)
EXEC sys.sp_executesql @SQL
GO



-- no actual execution plans???? It's a select statement with a constant. So it checks

-- now let's get some execution plans

DECLARE @SQL nvarchar(max)
SELECT @SQL = 'SELECT TOP 10 * FROM Inventory'

EXEC (@SQL)

EXEC sys.sp_executesql @SQL
GO



-- what if we want to have this vary for different tables?
DECLARE @SQL nvarchar(max),
	@Table sysname = 'Inventory'

-- This won't run. Don't bother....
-- SELECT top 10 * FROM @Table

-- One option for writing this using EXEC 
--EXEC ('SELECT top 10 * FROM ' + @table)

SELECT @SQL = 'SELECT TOP 10 * FROM ' + @table

EXEC (@SQL)

EXEC sp_executesql @SQL
GO



/*********************************
-- SECURITY PLEASE!!!!!
*********************************/

DECLARE @SQL nvarchar(max),
	@Table sysname = 'Inventory; SELECT ''NYC, We have a problem.'''

-- This won't run. Don't bother....
-- SELECT top 10 * FROM @Table

SELECT @SQL = 'SELECT TOP 10 * FROM ' + @table

EXEC (@SQL)

EXEC sp_executesql @SQL
GO


-- use quotename for objects!!!
DECLARE @SQL nvarchar(max),
	@Table sysname = 'Inventory; SELECT ''NYC, We have a problem.'''
	
SELECT @SQL = 'SELECT TOP 10 * FROM ' + quotename(@table)
PRINT @SQL

EXEC (@SQL)

EXEC sp_executesql @SQL
GO


/* Now let's try to break this */
-- Let's solve this by using square brackets
DECLARE @SQL nvarchar(max),
	@Table sysname = 'Inventory] ; SELECT ''NYC, We have a problem.'' as [I can still do this:'


SELECT @SQL = 'SELECT TOP 10 * FROM [' + @table + ']'
PRINT @SQL

EXEC (@SQL)

EXEC sp_executesql @SQL
GO


-- use quotename for objects!!!
DECLARE @SQL nvarchar(max),
	@Table sysname = 'Inventory] SELECT ''NYC, We have a problem.'' as [I can still do this:'

SELECT @SQL = 'SELECT TOP 10 * FROM ' + QUOTENAME(@table)
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

SELECT @SQL = 'SELECT @@SPID as SpidFromDynamicSQLEXEC'
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

SELECT @Sql = 'SELECT ''TestValue from standalone dynamic statement'' as TestValue'

INSERT INTO #Test (SampleValue)
EXEC sp_executesql @Sql

SELECT * FROM #Test
GO

/* How I can think of doing the statements */
DECLARE @Sql nvarchar(100)

SELECT @Sql = '
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
SELECT @SQL = 'SELECT TOP 10 * FROM Inventory WHERE BaseModelID = @BaseModelID'
EXEC (@SQL)
GO


DECLARE @SQL nvarchar(max),
	@BaseModelID int = 58

SELECT @SQL = 'SELECT TOP 10 * FROM Inventory WHERE BaseModelID = ' + convert(nvarchar(5), @BaseModelID)
EXEC (@SQL)

SELECT @SQL = 'SELECT TOP 10 * FROM Inventory WHERE BaseModelID = @BaseModelID'
EXEC sp_executesql @SQL, N'@BaseModelID int', @BaseModelID

GO

-- Multiple Parameters

DECLARE @SQL nvarchar(max),
	@BaseModelID int = 58,
	@PackageID int = 4


SELECT @SQL = 'SELECT TOP 10 * FROM Inventory WHERE BaseModelID = ' + convert(nvarchar(5), @BaseModelID)
	 + ' AND PackageID = ' + convert(nvarchar(5), @PackageID)
EXEC (@SQL)


SELECT @SQL = 'SELECT TOP 10 * FROM Inventory WHERE BaseModelID = @BaseModelID AND PackageID = @PackageID'
EXEC sp_executesql @SQL, N'@BaseModelID int, @PackageID int', @BaseModelID, @PackageID

GO


-- Output parameters
DECLARE @SQL nvarchar(max),
	@BaseModelID int = 58,
	@TotalCount int


SELECT @SQL = 'SELECT @TotalCount = count(*) FROM Inventory WHERE BaseModelID = ' + convert(nvarchar(5), @BaseModelID)
--EXEC (@SQL)

-- has to be done as an INSERT
-- SELECT @TotalCount = EXEC (@SQL)

DECLARE @TotalCountTV TABLE (TotalCount INT)
SELECT @SQL = 'SELECT count(*) FROM Inventory WHERE BaseModelID = ' + convert(nvarchar(5), @BaseModelID)

INSERT INTO @TotalCountTV
EXEC (@SQL)

SELECT * FROM @TotalCountTV
GO


DECLARE @SQL nvarchar(max),
	@BaseModelID int = 58,
	@TotalCount int

SELECT @SQL = 'SELECT @TotalCount = count(*) FROM Inventory WHERE BaseModelID = @BaseModelID'
EXEC sp_executesql @SQL, N'@BaseModelID int, @TotalCount int OUTPUT', @BaseModelID, @TotalCount OUTPUT

SELECT @TotalCount
GO


