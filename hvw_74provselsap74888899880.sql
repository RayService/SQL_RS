USE [RayService]
GO

/****** Object:  View [dbo].[hvw_74provselsap74888899880]    Script Date: 03.07.2025 11:21:04 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

CREATE VIEW [dbo].[hvw_74provselsap74888899880] AS select *, round(cast(last_worker_time as numeric(19,6))/100000.00,2) as last_worker_second, round(cast(total_elapsed_time as numeric(19,6))/100000.00,2) as elapsed_time_second
 from Saperta_Tab_SelSQL
/*SELECT qs.last_execution_time,db_name(qp.dbid) as jmenodatab,
qs.last_logical_writes,qs.last_physical_reads,st.text, convert(nvarchar(255),substring(cast(st.text as varchar(max)),1,255)) as text255, qs.min_worker_time, qs.max_worker_time, qs.last_worker_time,qs.execution_count,qs.last_rows,qs.last_logical_reads
FROM sys.dm_exec_query_stats AS qs
CROSS APPLY
sys.dm_exec_sql_text(qs.sql_handle)AS st
CROSS APPLY
sys.dm_exec_text_query_plan(qs.plan_handle,DEFAULT,DEFAULT) AS qp 
where db_name(qp.dbid)=db_name()*/
GO

