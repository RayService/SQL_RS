USE [RayService]
GO

/****** Object:  View [dbo].[hvw_5E246B5487A34D659FA31980D22EE3B7]    Script Date: 03.07.2025 11:12:13 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

CREATE VIEW [dbo].[hvw_5E246B5487A34D659FA31980D22EE3B7] AS SELECT
TabUziv.ID, TabUziv.LoginName,(SELECT U.FullName FROM RayService.dbo.TabUserCfg AS U WHERE U.LoginName=TabUziv.LoginName COLLATE DATABASE_DEFAULT) AS FullName
FROM TabUziv
WHERE
(EXISTS(SELECT*FROM RayService.dbo.TabUserCfg WHERE LoginName=TabUziv.LoginName COLLATE database_default))
GO

