
/* Delayed Parsing */

/*
-- Upgrade Scenario

same scripts run for all upgrades
Schemas may already exist. 
You have to select from a table then drop the column.

This script needs to run without errors regardless of what it's adding or skipping

*/
USE AutoDealershipDemo
GO

/* Version 1 Release */
-- Schema Create has to be the only statement. Can't use with IF EXISTS
CREATE SCHEMA DynamicSQL
GO

-- Creating Table. No Name specified for Primary Key and should be fixed later.
IF OBJECT_ID(N'DynamicSQL.UpgradeTestTable') IS NULL
CREATE TABLE DynamicSQL.UpgradeTestTable
	(
	UpgradeTestID int IDENTITY(1,1) NOT NULL PRIMARY KEY CLUSTERED,
	StaticColumn varchar(30) NULL,
	DropThisColumn varchar(30) NULL
	)
GO

SELECT UpgradeTestID, StaticColumn, DropThisColumn
FROM DynamicSQL.UpgradeTestTable
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


/* Version 3 Release: Rename unnamed primary key constraints */ 
SELECT * FROM sys.key_constraints
WHERE type = 'PK'
AND parent_object_id = OBJECT_ID(N'DynamicSQL.UpgradeTestTable')
GO