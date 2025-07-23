/* Delayed Parsing */

/*
-- Upgrade Scenario

same scripts run for all upgrades
Schemas may already exist. 
You have to select from a table then drop the column.

This script needs to run without errors regardless of what it's adding or skipping

*/

/* Version 1 Release */
USE AutoDealershipDemo
GO

-- Schema Create has to be the only statement. Can't use with IF EXISTS
IF NOT EXISTS (SELECT * FROM sys.schemas WHERE name = 'DynamicSQL')
EXEC sp_executesql 'CREATE SCHEMA DynamicSQL'
GO

-- Creating Table. No Name specified for Primary Key and should be fixed later.
IF OBJECT_ID(N'DynamicSQL.UpgradeTestTable') IS NULL
CREATE TABLE DynamicSQL.UpgradeTestTable
	(
	UpgradeTestID INT IDENTITY(1,1) NOT NULL PRIMARY KEY CLUSTERED,
	StaticColumn VARCHAR(30) NULL,
	DropThisColumn VARCHAR(30) NULL
	)
GO

IF EXISTS 
	(
	SELECT * FROM sys.columns 
	WHERE object_id = OBJECT_ID(N'DynamicSQL.UpgradeTestTable')
	AND name = 'DropThisColumn'
	)
EXEC sys.sp_executesql N'SELECT UpgradeTestID, StaticColumn, DropThisColumn FROM DynamicSQL.UpgradeTestTable'

GO

/* Version 2 Release */ 

IF EXISTS 
	(
	SELECT * FROM sys.columns 
	WHERE object_id = OBJECT_ID(N'DynamicSQL.UpgradeTestTable')
	AND name = 'DropThisColumn'
	)
ALTER TABLE DynamicSQL.UpgradeTestTable
DROP COLUMN DropThisColumn
GO

SELECT UpgradeTestID, StaticColumn
FROM DynamicSQL.UpgradeTestTable
GO


/* Version 3 Release */ 
DECLARE @sql nvarchar(2000)

SELECT @SQL = ISNULL(@SQL, '')
	+ 'EXEC sp_rename ''' + SCHEMA_NAME(schema_id) + '.' + object_name(parent_object_id) + '.' + name + ''', ''PK_' 
	+ REPLACE(OBJECT_NAME(parent_object_id), SCHEMA_NAME(schema_id), '') + '''; ' 
FROM sys.key_constraints
WHERE type = 'PK'
AND name NOT LIKE 'PK[_]' + REPLACE(OBJECT_NAME(parent_object_id), SCHEMA_NAME(schema_id), '') + '%'
AND schema_id = SCHEMA_ID('DynamicSQL')

SELECT @SQL
GO