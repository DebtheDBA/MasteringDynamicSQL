USE AutoDealershipDemo
GO

SELECT qsq.query_id, qsq.query_text_id, 
	qsq.object_id, 
	OBJECT_SCHEMA_NAME(qsq.object_id) + '.' + OBJECT_NAME(qsq.object_id) as ObjectName,
	qst.query_sql_text,
	qsq.count_compiles as QueryCountCompiles,
	qsp.count_compiles as PlanCountCompiles,
	qsq.query_hash,
	qsq.query_parameterization_type_desc,
	qsq.last_execution_time,
	qsp.plan_id,
	qsp.query_plan,
	qsp.is_parallel_plan
	, qsf.feature_desc, qsf.feedback_data, qsf.state_desc
FROM sys.query_store_query as qsq
	JOIN sys.query_store_plan as qsp ON qsp.query_id = qsq.query_id 
	JOIN sys.query_store_query_text as qst ON qsq.query_text_id = qst.query_text_id
	LEFT JOIN sys.query_store_plan_feedback as qsf ON qsp.plan_id = qsf.plan_id
where qst.query_sql_text LIKE '%Inventory%'
and qst.query_sql_text NOT LIKE '%query_store%'
ORDER BY qsq.last_execution_time desc

