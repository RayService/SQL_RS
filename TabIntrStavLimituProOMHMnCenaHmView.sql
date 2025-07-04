USE [RayService]
GO

/****** Object:  View [dbo].[TabIntrStavLimituProOMHMnCenaHmView]    Script Date: 04.07.2025 11:25:41 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

CREATE VIEW [dbo].[TabIntrStavLimituProOMHMnCenaHmView] AS
SELECT jov.FIntrUnitsID, jov.Rok, jov.Mesic, jov.DruhDeklarace, jov.Nomenklatura,
mhv.MnozstviMH,
jov.ZmenaMnozstvi,
CAST(CASE WHEN jov.ZmenaMnozstvi=0 THEN 0 WHEN ISNULL(mhv.MnozstviMH,0)=0 THEN 100 ELSE (jov.ZmenaMnozstvi/mhv.MnozstviMH)*100 END AS NUMERIC(19,6)) ZmenaMnozstviProcenta,
mhv.CenaMH,
jov.ZmenaKc,
CAST(CASE WHEN jov.ZmenaKc=0 THEN 0 WHEN ISNULL(mhv.CenaMH,0)=0 THEN 100 ELSE (jov.ZmenaKc/mhv.CenaMH)*100 END AS NUMERIC(19,6)) ZmenaKcProcenta,
mhv.HmotnostMH,
jov.ZmenaHmotnost,
CAST(CASE WHEN jov.ZmenaHmotnost=0 THEN 0 WHEN ISNULL(mhv.HmotnostMH,0)=0 THEN 100 ELSE (jov.ZmenaHmotnost/mhv.HmotnostMH)*100 END AS NUMERIC(19,6)) ZmenaHmotnostProcenta
FROM TabIntrPpOMHMnCenaHmView jov
LEFT OUTER JOIN TabIntrMonthMsgMnCenaHmView mhv ON mhv.FIntrUnitsID=jov.FIntrUnitsID AND mhv.Rok=jov.Rok AND mhv.Mesic=jov.Mesic AND mhv.DruhDeklarace=jov.DruhDeklarace AND mhv.Nomenklatura=jov.Nomenklatura
GO

