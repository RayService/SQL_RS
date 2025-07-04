USE [RayService]
GO

/****** Object:  View [dbo].[hvw_SDLog_Schvalovani]    Script Date: 04.07.2025 8:17:20 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

CREATE VIEW [dbo].[hvw_SDLog_Schvalovani] AS SELECT ID, IdDoklad, TypDokladu, SchvaleniStav, SchvaleniUroven, SchvaleniPoznamka, SchvaleniPoznamka_255, SchvaleniPoznamka_all, Autor, DatPorizeni,
(SELECT FullName FROM RayService..TabUserCfg WHERE LoginName=Tabx_SDLog.Autor) AS PlneJmeno
FROM Tabx_SDLog WHERE TypZaznamu = 1
GO

