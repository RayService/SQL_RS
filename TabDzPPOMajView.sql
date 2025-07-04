USE [RayService]
GO

/****** Object:  View [dbo].[TabDzPPOMajView]    Script Date: 04.07.2025 10:02:53 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

CREATE VIEW [dbo].[TabDzPPOMajView] AS
SELECT DP.Skupina AS Skup, DP.TypPoh, Cast(Sum(DP.OpravkyZmena) as NUMERIC(19,6)) AS Odpis, O.Nazev, O.DatumOd_X AS DatObdOd, O.DatumDo_X AS DatObdDo,
O.ID AS IdObdobi, DP.DatumPlatnosti_X AS DatPoh, DP.RadekPriznani AS Radek
FROM TabMaPohD AS DP
JOIN TabObdobi AS O ON DP.DatumPlatnosti BETWEEN O.DatumOd_X AND O.DatumDo
WHERE DP.TypPoh = 1 OR DP.TypPoh = 18
GROUP BY DP.Skupina, DP.TypPoh, O.Nazev, O.DatumOd_X, O.DatumDo_X, O.ID, DP.DatumPlatnosti_X, DP.RadekPriznani
GO

