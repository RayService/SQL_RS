USE [RayService]
GO

/****** Object:  View [dbo].[hvw_BalikobotVKonfiguraceUzivatele]    Script Date: 03.07.2025 14:08:47 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

CREATE VIEW [dbo].[hvw_BalikobotVKonfiguraceUzivatele] AS SELECT *
, (SELECT TabUserCfg.FullName FROM RayService..TabUserCfg TabUserCfg WHERE TabUserCfg.LoginName=Tabx_BalikobotVKonfiguraceUzivatele.LoginName) AS FullName
FROM Tabx_BalikobotVKonfiguraceUzivatele
GO

