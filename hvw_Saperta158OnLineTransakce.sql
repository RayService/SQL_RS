USE [RayService]
GO

/****** Object:  View [dbo].[hvw_Saperta158OnLineTransakce]    Script Date: 04.07.2025 8:15:34 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

CREATE VIEW [dbo].[hvw_Saperta158OnLineTransakce] AS select es.session_id,es.host_name,es.program_name,es.login_name,(CASE es.[is_user_process] WHEN 1 THEN 'User' ELSE 'System' END) as vlastnik, db_name(database_id) as dbname,
tat.transaction_begin_time,(CASE tat.transaction_state WHEN 0 THEN 'The transaction has not been completely initialized yet.' WHEN 1 THEN 'The transaction has been initialized but has not started.'  
                    WHEN 2 THEN 'The transaction is active.' WHEN 3 THEN 'The transaction has ended. This is used for read-only transactions.' 
                    WHEN 4 THEN 'The commit process has been initiated on the distributed transaction. This is for distributed transactions only. The distributed transaction is still active but further processing cannot take place.' 
                    WHEN 5 THEN 'The transaction is in a prepared state and waiting resolution.' WHEN 6 THEN 'The transaction has been committed.' 
                    WHEN 7 THEN 'The transaction is being rolled back.' WHEN 8 THEN 'The transaction has been rolled back.' END) as operace, (CASE tat.transaction_type WHEN 1 THEN 'Read/Write' 
                    WHEN 2 THEN 'Read-only' WHEN 3 THEN 'System' END) as typ ,  est.text, substring(cast(est.text as nvarchar),1,255) as text255, tst.transaction_id,getdate() as datum 
FROM sys.dm_tran_active_transactions tat left outer join saperta_tab_paramglob glob on 1=1 INNER JOIN sys.dm_tran_session_transactions tst 
                    ON tst.transaction_id = tat.transaction_id INNER JOIN sys.dm_exec_sessions es ON es.session_id = tst.session_id INNER JOIN sys.dm_exec_connections ec 
                    ON ec.session_id = es.session_id OUTER APPLY sys.dm_exec_sql_text(ec.most_recent_sql_handle) est where left(es.program_name,4)<>'.Net' and db_name(database_id)=(case when glob.vsechnydatabaze=0 then db_name()
else db_name(database_id) end)
GO

