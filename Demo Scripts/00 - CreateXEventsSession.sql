CREATE EVENT SESSION [DynamicSQL]
ON SERVER
    ADD EVENT sqlserver.error_reported
    (ACTION
     (
         sqlserver.client_app_name,
         sqlserver.database_id,
         sqlserver.query_hash,
         sqlserver.request_id,
         sqlserver.session_id,
         sqlserver.sql_text,
         sqlserver.transaction_id,
         sqlserver.transaction_sequence
     )
     WHERE (
               (
                   ([package0].[greater_than_uint64]([sqlserver].[database_id], (4)))
                   AND ([package0].[equal_boolean]([sqlserver].[is_system], (0)))
               )
               AND
               (
                   ([sqlserver].[database_name] = N'Superheroes')
                   OR ([sqlserver].[database_name] = N'AutoDealershipDemo')
               )
           )
    ),
    ADD EVENT sqlserver.module_end
    (SET collect_statement = (1)
     ACTION
     (
         sqlserver.client_app_name,
         sqlserver.database_id,
         sqlserver.query_hash,
         sqlserver.request_id,
         sqlserver.session_id,
         sqlserver.sql_text,
         sqlserver.transaction_id,
         sqlserver.transaction_sequence
     )
     WHERE (
               (
                   ([package0].[greater_than_uint64]([sqlserver].[database_id], (4)))
                   AND ([package0].[equal_boolean]([sqlserver].[is_system], (0)))
               )
               AND
               (
                   ([sqlserver].[database_name] = N'Superheroes')
                   OR ([sqlserver].[database_name] = N'AutoDealershipDemo')
               )
           )
    ),
    ADD EVENT sqlserver.rpc_completed
    (ACTION
     (
         sqlserver.client_app_name,
         sqlserver.database_id,
         sqlserver.query_hash,
         sqlserver.request_id,
         sqlserver.session_id,
         sqlserver.sql_text,
         sqlserver.transaction_id,
         sqlserver.transaction_sequence
     )
     WHERE (
               (
                   ([package0].[greater_than_uint64]([sqlserver].[database_id], (4)))
                   AND ([package0].[equal_boolean]([sqlserver].[is_system], (0)))
               )
               AND
               (
                   ([sqlserver].[database_name] = N'Superheroes')
                   OR ([sqlserver].[database_name] = N'AutoDealershipDemo')
               )
           )
    ),
    ADD EVENT sqlserver.rpc_starting
    (ACTION
     (
         sqlserver.request_id,
         sqlserver.sql_text,
         sqlserver.transaction_id,
         sqlserver.transaction_sequence
     )
     WHERE (
               ([sqlserver].[database_name] = N'Superheroes')
               OR ([sqlserver].[database_name] = N'AutoDealershipDemo')
           )
    ),
    ADD EVENT sqlserver.sp_statement_completed
    (SET collect_object_name = (1)
     ACTION
     (
         sqlserver.client_app_name,
         sqlserver.database_id,
         sqlserver.query_hash,
         sqlserver.query_plan_hash,
         sqlserver.request_id,
         sqlserver.session_id,
         sqlserver.sql_text,
         sqlserver.transaction_id,
         sqlserver.transaction_sequence
     )
     WHERE (
               (
                   ([package0].[greater_than_uint64]([sqlserver].[database_id], (4)))
                   AND ([package0].[equal_boolean]([sqlserver].[is_system], (0)))
               )
               AND
               (
                   ([sqlserver].[database_name] = N'Superheroes')
                   OR ([sqlserver].[database_name] = N'AutoDealershipDemo')
               )
           )
    ),
    ADD EVENT sqlserver.sp_statement_starting
    (ACTION
     (
         sqlserver.request_id,
         sqlserver.sql_text,
         sqlserver.transaction_id,
         sqlserver.transaction_sequence
     )
     WHERE (
               ([sqlserver].[database_name] = N'Superheroes')
               OR ([sqlserver].[database_name] = N'AutoDealershipDemo')
           )
    ),
    ADD EVENT sqlserver.sql_batch_completed
    (ACTION
     (
         sqlserver.client_app_name,
         sqlserver.database_id,
         sqlserver.query_hash,
         sqlserver.request_id,
         sqlserver.session_id,
         sqlserver.sql_text,
         sqlserver.transaction_id,
         sqlserver.transaction_sequence
     )
     WHERE (
               (
                   ([package0].[greater_than_uint64]([sqlserver].[database_id], (4)))
                   AND ([package0].[equal_boolean]([sqlserver].[is_system], (0)))
               )
               AND
               (
                   ([sqlserver].[database_name] = N'Superheroes')
                   OR ([sqlserver].[database_name] = N'AutoDealershipDemo')
               )
           )
    ),
    ADD EVENT sqlserver.sql_batch_starting
    (ACTION
     (
         sqlserver.request_id,
         sqlserver.sql_text,
         sqlserver.transaction_id,
         sqlserver.transaction_sequence
     )
     WHERE (
               ([sqlserver].[database_name] = N'Superheroes')
               OR ([sqlserver].[database_name] = N'AutoDealershipDemo')
           )
    ),
    ADD EVENT sqlserver.sql_statement_completed
    (ACTION
     (
         sqlserver.client_app_name,
         sqlserver.database_id,
         sqlserver.query_hash,
         sqlserver.query_plan_hash,
         sqlserver.request_id,
         sqlserver.session_id,
         sqlserver.sql_text,
         sqlserver.transaction_id,
         sqlserver.transaction_sequence
     )
     WHERE (
               (
                   ([package0].[greater_than_uint64]([sqlserver].[database_id], (4)))
                   AND ([package0].[equal_boolean]([sqlserver].[is_system], (0)))
               )
               AND
               (
                   ([sqlserver].[database_name] = N'Superheroes')
                   OR ([sqlserver].[database_name] = N'AutoDealershipDemo')
               )
           )
    ),
    ADD EVENT sqlserver.sql_statement_starting
    (ACTION
     (
         sqlserver.request_id,
         sqlserver.sql_text,
         sqlserver.transaction_id,
         sqlserver.transaction_sequence
     )
     WHERE (
               ([sqlserver].[database_name] = N'Superheroes')
               OR ([sqlserver].[database_name] = N'AutoDealershipDemo')
           )
    )
    ADD TARGET package0.event_file
    (SET filename = N'C:\GitRepo\MasteringDynamicSQL\XEvents\TraceXEvents.xel')
    ;
GO


