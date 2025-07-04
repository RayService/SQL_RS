USE [RayService]
GO

/****** Object:  View [dbo].[hvw_SDLog_Obecny]    Script Date: 04.07.2025 8:16:57 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

CREATE VIEW [dbo].[hvw_SDLog_Obecny] AS SELECT Udalost, Autor, DatPorizeni,
(SELECT FullName FROM RayService..TabUserCfg WHERE LoginName=Tabx_SDLog.Autor) AS PlneJmeno
FROM Tabx_SDLog WHERE TypZaznamu = 0
GO

