USE [RayService]
GO

/****** Object:  View [dbo].[hvw_SHTools_DeadlockDog]    Script Date: 04.07.2025 8:26:40 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

CREATE VIEW [dbo].[hvw_SHTools_DeadlockDog] AS SELECT
ID
,IDSber
,D.Skupina
,D.ServerName
,D.deadlock_type
,D.event_date
,CONVERT(DATE,D.event_date) AS event_date_X
,DATEPART(DAY,D.event_date) AS event_date_D
,DATEPART(MONTH,D.event_date) AS event_date_M
,DATEPART(WEEK,D.event_date) AS event_date_W
,D.database_name
,D.spid
,D.deadlock_group
,query = STUFF(CAST(SUBSTRING(REPLACE(REPLACE(REPLACE(REPLACE(CAST(D.query as nvarchar(MAX)),N'<?query ',N''),N' ?>',''),(NCHAR(13) + NCHAR(10)),N' '),NCHAR(10),N' '),1,255) as nvarchar(255)),1,1,N'')
,object_names = CAST(SUBSTRING(STUFF(REPLACE(REPLACE(CAST(D.object_names as nvarchar(MAX)),N'</object>',N''),N'<object>',N','),1,1,N''),1,255) as nvarchar(255))
,D.login_name
,D.host_name
,D.client_app
,_HeIQ_CB_Skupina = CAST(IIF(Skupina%2 = 0,13557503,14155735) as int)
,_HeIQ_CB_IDSber = CAST(IIF(Skupina%2 = 0,13557503,14155735) as int)
,_HeIQ_CB_event_date = CAST(IIF(Skupina%2 = 0,13557503,14155735) as int)
FROM dbo.Tabx_SHTools_DeadlockDog D
GO

