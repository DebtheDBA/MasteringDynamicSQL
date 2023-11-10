USE AutoDealershipDemo
GO

/******************************************* 
Same queries, different targets: 
--------------------------------

Find the select table objects for each database on the server that are not the master database. 
*******************************************/

/* Use regular Dynamic SQL. Can run twice - once using sp_executesql and once using EXEC(@SQL) */

DECLARE @SQL NVARCHAR(MAX),
	@dbname NVARCHAR(128)

DECLARE table_cursor SCROLL CURSOR FOR
SELECT name 
FROM master.sys.databases
WHERE database_id >=5
ORDER BY database_id

OPEN table_cursor

FETCH FIRST FROM table_cursor INTO @dbname

WHILE @@FETCH_STATUS = 0
BEGIN
	
	SELECT @SQL = N'USE ' + QUOTENAME(@dbname) + '/* table cursor */
	SELECT TOP 10 db_id() as DatabaseID, db_name() as DatabaseName, * 
	FROM INFORMATION_SCHEMA.TABLES'

	EXEC sys.sp_executesql @SQL
	--EXEC (@SQL)

	FETCH NEXT FROM table_cursor INTO @dbname

END

CLOSE table_cursor
DEALLOCATE table_cursor
GO


/* Use sp_MSforeachdb */
EXEC sp_MSforeachdb '
USE ?

IF db_id() >= 5
/* sp_MSforeachdb */
SELECT TOP 10 db_id() as DatabaseID, db_name() as DatabaseName, * FROM INFORMATION_SCHEMA.TABLES
'
GO
