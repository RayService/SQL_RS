USE [RayService]
GO

/****** Object:  View [dbo].[hvw_UniImportFormat]    Script Date: 04.07.2025 8:58:45 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

CREATE VIEW [dbo].[hvw_UniImportFormat] AS SELECT *FROM TabUniImportFormat
WHERE 
 ((ImportIdent=4)AND(SysName NOT IN('SazbaDPHVstup', 'SazbaDPHVystup')))
OR
 ImportIdent<>4
GO

