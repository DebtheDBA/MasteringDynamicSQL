USE AutoDealershipDemo
GO



SELECT qsq.query_id, qsq.query_text_id, 
	qsq.object_id, 
	OBJECT_SCHEMA_NAME(qsq.object_id) + '.' + OBJECT_NAME(qsq.object_id) AS ObjectName,
	qst.query_sql_text,
	qsq.count_compiles AS QueryCountCompiles,
	qsp.count_compiles AS PlanCountCompiles,
	qsq.query_hash,
	qsq.query_parameterization_type_desc,
	qsq.last_execution_time,
	qsp.plan_id,
	CONVERT(XML, qsp.query_plan) AS query_plan_XML,
	qsp.is_parallel_plan
	, qsf.feature_desc, qsf.feedback_data, qsf.state_desc
FROM sys.query_store_query AS qsq
	JOIN sys.query_store_plan AS qsp ON qsp.query_id = qsq.query_id 
	JOIN sys.query_store_query_text AS qst ON qsq.query_text_id = qst.query_text_id
	LEFT JOIN sys.query_store_plan_feedback AS qsf ON qsp.plan_id = qsf.plan_id
WHERE qst.query_sql_text NOT LIKE '%query_store%'
AND qst.query_sql_text LIKE '%Inventory%'
AND qsq.last_execution_time > DATEADD(HOUR, -1, getdate())
ORDER BY qsq.last_execution_time DESC

