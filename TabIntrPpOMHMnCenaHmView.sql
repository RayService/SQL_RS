USE [RayService]
GO

/****** Object:  View [dbo].[TabIntrPpOMHMnCenaHmView]    Script Date: 04.07.2025 11:25:12 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

CREATE VIEW [dbo].[TabIntrPpOMHMnCenaHmView] AS
SELECT joh.FIntrUnitsID, joh.Datum_Y Rok, joh.Datum_M Mesic, joh.DruhDeklarace, jop.Nomenklatura,
CAST(ISNULL(SUM(ABS(jop.Mnozstvi)),0) AS NUMERIC(19,6)) ZmenaMnozstvi,
CAST(ISNULL(SUM(ABS(jop.CCbezDPHKC)),0) AS NUMERIC(19,6)) ZmenaKc,
CAST(ISNULL(SUM(ABS(jop.Hmotnost)),0) AS NUMERIC(19,6)) ZmenaHmotnost
FROM TabIntrIndivOper joh
JOIN TabIntrIndivOperPohyby jop ON jop.IDHlavicky=joh.ID
WHERE joh.DruhHlaseni=1
GROUP BY joh.FIntrUnitsID, joh.Datum_Y, joh.Datum_M, joh.DruhDeklarace, jop.Nomenklatura
GO

