USE [RayService]
GO

/****** Object:  View [dbo].[hvw_KillLog]    Script Date: 03.07.2025 15:20:48 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

CREATE VIEW [dbo].[hvw_KillLog] AS SELECT ID
,Datum
,Autor
,loginame
,hostname
,login_time
,last_batch
,program_name
,db_name
,status
,cmd
,open_tran
FROM Tabx_KillLog
GO

