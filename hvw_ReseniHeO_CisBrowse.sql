USE [RayService]
GO

/****** Object:  View [dbo].[hvw_ReseniHeO_CisBrowse]    Script Date: 04.07.2025 8:02:37 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

CREATE VIEW [dbo].[hvw_ReseniHeO_CisBrowse] AS SELECT
ID
,BID
,BrowseName
,BrowseTxt
,TableName
,SysTableName
,Soudecek
FROM Tabx_ReseniHeO_CisBrowse
GO

