USE [RayService]
GO

/****** Object:  View [dbo].[hvw_SynchroLog]    Script Date: 04.07.2025 8:38:16 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

CREATE VIEW [dbo].[hvw_SynchroLog] AS SELECT
ID
,Tab
,IdTab
,TypSynchro
,IdTabCil
,DatPorizeni
,Autor
,DatSynchro
,Synchronizoval
,Zprava
,Synchro
FROM Tabx_SynchroLog
GO

