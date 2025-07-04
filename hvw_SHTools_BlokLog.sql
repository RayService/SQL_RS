USE [RayService]
GO

/****** Object:  View [dbo].[hvw_SHTools_BlokLog]    Script Date: 04.07.2025 8:25:25 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

CREATE VIEW [dbo].[hvw_SHTools_BlokLog] AS SELECT
B.ID
,B.IDSber
,event_time = CAST(CAST(B.event_time as datetime2(0)) as datetime)
,CONVERT(DATE,CAST(CAST(B.event_time as datetime2(0)) as datetime)) AS event_time_X
,DATEPART(DAY,CAST(CAST(B.event_time as datetime2(0)) as datetime)) AS event_time_D
,DATEPART(MONTH,CAST(CAST(B.event_time as datetime2(0)) as datetime)) AS event_time_M
,DATEPART(WEEK,CAST(CAST(B.event_time as datetime2(0)) as datetime)) AS event_time_W
,B.database_name
,B.currentdbname
,B.contentious_object
,B.activity
,B.blocking_tree
,B.spid
,B.ecid
,query_text = STUFF(CAST(SUBSTRING(REPLACE(REPLACE(REPLACE(REPLACE(CAST(B.query_text as nvarchar(MAX)),N'<?query ',N''),N' ?>',''),(NCHAR(13) + NCHAR(10)),N' '),NCHAR(10),N' '),1,255) as nvarchar(255)),1,1,N'')
,B.wait_time_ms
,B.status
,B.isolation_level
,B.lock_mode
,B.resource_owner_type
,B.transaction_count
,B.transaction_name
,last_transaction_started = CAST(B.last_transaction_started as datetime)
,last_transaction_completed = CAST(B.last_transaction_completed as datetime)
,B.client_option_1
,B.client_option_2
,B.wait_resource
,B.priority
,B.log_used
,B.client_app
,B.host_name
,B.login_name
,B.transaction_id
,_HeIQ_CB_activity = CAST(IIF(activity = 'blocking',15138815,13557503) as int)
,B.blocked_process_report
FROM dbo.Tabx_SHTools_BlokLog B
GO

