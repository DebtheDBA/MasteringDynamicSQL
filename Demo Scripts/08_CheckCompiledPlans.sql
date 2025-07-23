/* Confirm the setting is off */
USE AutoDealershipDemo
GO

ALTER DATABASE SCOPED CONFIGURATION
SET OPTIMIZED_SP_EXECUTESQL = OFF;
GO

/* Run the proc for the three different colors individually */

/* Look at the cache plans */
/* Modified from aka.ms/sqlserver2025demos - engine/performance/optimized sp_executesql/getcacheplans.sql */

SELECT  
    qs.execution_count,
    qs.total_worker_time,
    qs.total_elapsed_time,
    cp.objtype,
    DB_NAME(qt.dbid) AS databasename,
    qt.text AS query_text
FROM sys.dm_exec_cached_plans AS cp
JOIN sys.dm_exec_query_stats AS qs
    ON cp.plan_handle = qs.plan_handle
CROSS APPLY sys.dm_exec_sql_text(cp.plan_handle) AS qt
WHERE 
    cp.cacheobjtype = 'Compiled Plan' 
AND    qt.text LIKE '%SearchAllSoldInventory_Dynamic%' --filter out the noise
ORDER BY qs.execution_count DESC;


/* clear the cache plans */

USE master
GO

ALTER DATABASE SCOPED CONFIGURATION CLEAR PROCEDURE_CACHE;
GO

USE AutoDealershipDemo
GO

ALTER DATABASE SCOPED CONFIGURATION CLEAR PROCEDURE_CACHE;
GO

/* Now run calling each simultaneously using ostress */

/* Look at the cache plans, with the same query as above */

SELECT  
    qs.execution_count,
    qs.total_worker_time,
    qs.total_elapsed_time,
    cp.objtype,
    DB_NAME(qt.dbid) AS databasename,
    qt.text AS query_text
FROM sys.dm_exec_cached_plans AS cp
JOIN sys.dm_exec_query_stats AS qs
    ON cp.plan_handle = qs.plan_handle
CROSS APPLY sys.dm_exec_sql_text(cp.plan_handle) AS qt
WHERE 
    cp.cacheobjtype = 'Compiled Plan' 
AND    qt.text LIKE '%SearchAllSoldInventory_Dynamic%'--filter out the noise
ORDER BY qs.execution_count DESC;


/*
Now alter the database to enable optimized sp_executesql
*/

USE AutoDealershipDemo
GO

ALTER DATABASE SCOPED CONFIGURATION
SET OPTIMIZED_SP_EXECUTESQL = ON;
GO

/* clear the cache plans */

USE master
GO

ALTER DATABASE SCOPED CONFIGURATION CLEAR PROCEDURE_CACHE;
GO

USE AutoDealershipDemo
GO

ALTER DATABASE SCOPED CONFIGURATION CLEAR PROCEDURE_CACHE;
GO

/* Rerun the ostress test */

/* Look at the cache plans, with the same query as above */

SELECT  
    qs.execution_count,
    qs.total_worker_time,
    qs.total_elapsed_time,
    cp.objtype,
    DB_NAME(qt.dbid) AS databasename,
    qt.text AS query_text
FROM sys.dm_exec_cached_plans AS cp
JOIN sys.dm_exec_query_stats AS qs
    ON cp.plan_handle = qs.plan_handle
CROSS APPLY sys.dm_exec_sql_text(cp.plan_handle) AS qt
WHERE 
    cp.cacheobjtype = 'Compiled Plan' 
AND    qt.text LIKE '%SearchAllSoldInventory_Dynamic%'--filter out the noise
ORDER BY qs.execution_count DESC;

