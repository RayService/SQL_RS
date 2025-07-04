USE [RayService]
GO

/****** Object:  View [dbo].[TabIntrStavLimituProOMHView]    Script Date: 04.07.2025 11:26:14 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

CREATE VIEW [dbo].[TabIntrStavLimituProOMHView] AS
SELECT FIntrUnitsID, Rok, Mesic, DruhDeklarace,
CAST(CASE WHEN (MAX(ABS(ZmenaMnozstviProcenta))>5) OR
(MAX(ABS(ZmenaKcProcenta))>5) OR
(MAX(ABS(ZmenaHmotnostProcenta))>5) OR
(Rok>=2011)
THEN 1 ELSE 0 END AS BIT) AS OpravitMH,
MAX(ABS(ZmenaMnozstviProcenta)) AS ZmenaMnozstviProcentaMaxAbs,
CAST(5 AS NUMERIC(19,6)) LimitMnozstviProcento,
(SELECT TOP 1 Nomenklatura FROM dbo.TabIntrStavLimituProOMHMnCenaHmView pomV2
WHERE pomV1.FIntrUnitsID=pomV2.FIntrUnitsID
AND pomV1.Rok=pomV2.Rok
AND pomV1.Mesic=pomV2.Mesic
AND pomV1.DruhDeklarace=pomV2.DruhDeklarace
AND MAX(ABS(pomV1.ZmenaMnozstviProcenta))=ABS(pomV2.ZmenaMnozstviProcenta)
) AS NomenklaturaMnozstvi,
MAX(ABS(ZmenaKcProcenta)) AS ZmenaKcProcentaMaxAbs,
CAST(5 AS NUMERIC(19,6)) LimitKcProcenta,
(SELECT TOP 1 Nomenklatura FROM dbo.TabIntrStavLimituProOMHMnCenaHmView pomV2
WHERE pomV1.FIntrUnitsID=pomV2.FIntrUnitsID
AND pomV1.Rok=pomV2.Rok
AND pomV1.Mesic=pomV2.Mesic
AND pomV1.DruhDeklarace=pomV2.DruhDeklarace
AND MAX(ABS(pomV1.ZmenaKcProcenta))=ABS(pomV2.ZmenaKcProcenta)
) AS NomenklaturaKc,
MAX(ABS(ZmenaHmotnostProcenta)) AS ZmenaHmotnostProcentaMaxAbs,
CAST(5 AS NUMERIC(19,6)) LimitHmotnostProcenta,
(SELECT TOP 1 Nomenklatura FROM dbo.TabIntrStavLimituProOMHMnCenaHmView pomV2
WHERE pomV1.FIntrUnitsID=pomV2.FIntrUnitsID
AND pomV1.Rok=pomV2.Rok
AND pomV1.Mesic=pomV2.Mesic
AND pomV1.DruhDeklarace=pomV2.DruhDeklarace
AND MAX(ABS(pomV1.ZmenaHmotnostProcenta))=ABS(pomV2.ZmenaHmotnostProcenta)
) AS NomenklaturaHmotnost
FROM dbo.TabIntrStavLimituProOMHMnCenaHmView pomV1
GROUP BY FIntrUnitsID, Rok, Mesic, DruhDeklarace
GO

