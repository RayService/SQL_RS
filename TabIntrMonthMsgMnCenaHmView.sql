USE [RayService]
GO

/****** Object:  View [dbo].[TabIntrMonthMsgMnCenaHmView]    Script Date: 04.07.2025 11:24:28 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

CREATE VIEW [dbo].[TabIntrMonthMsgMnCenaHmView] AS
SELECT mhh.FIntrUnitsID, mhh.ObdobiRok Rok, mhh.ObdobiMesic Mesic, mhh.DruhDeklarace%2 DruhDeklarace, mhp.Nomenklatura,
CAST(SUM(mhp.Mnozstvi) AS NUMERIC(19,6)) MnozstviMH,
CAST(SUM(mhp.CCbezDPHKC) AS NUMERIC(19,6)) CenaMH,
CAST(SUM(mhp.Hmotnost) AS NUMERIC(19,6)) HmotnostMH
FROM TabIntrMonthMsg mhh
JOIN TabIntrMonthMsgPohyby mhp ON mhp.IDHlavicky=mhh.ID
WHERE mhh.DruhDeklarace BETWEEN 0 AND 3
AND NOT EXISTS(
SELECT * FROM TabIntrMonthMsg mhh_o
WHERE mhh_o.FIntrUnitsID=mhh.FIntrUnitsID
AND mhh_o.ObdobiRok=mhh.ObdobiRok
AND mhh_o.ObdobiMesic=mhh.ObdobiMesic
AND mhh_o.DruhDeklarace=mhh.DruhDeklarace+2
AND mhh_o.DruhDeklarace IN (2,3))
GROUP BY mhh.FIntrUnitsID, mhh.ObdobiRok, mhh.ObdobiMesic, mhh.DruhDeklarace, mhp.Nomenklatura
GO

