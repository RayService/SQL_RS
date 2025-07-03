USE [RayService]
GO

/****** Object:  View [dbo].[hvw_CFAABD47F9004C7D87000C76AA64B340]    Script Date: 03.07.2025 14:27:02 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

CREATE VIEW [dbo].[hvw_CFAABD47F9004C7D87000C76AA64B340] AS (
SELECT
PrKV.nizsi AS ID_nizsi
,SUM(PrKv.mnoz_Nevydane) AS Mnozstvi_pozadavek
,SUM(PrKV.mnoz_zad) AS MnoZad
,KZN.SkupZbo AS SkupZbo
,KZN.RegCis AS RegCis
,KZN.Nazev1 AS Nazev1
,KZN.Nazev2 AS Nazev2
,KZN.SKP AS SKP
FROM TabPrKVazby PrKV WITH(NOLOCK) 
INNER JOIN TabKmenZbozi KZN WITH(NOLOCK) ON KZN.ID=PrKV.nizsi
INNER JOIN TabPrikaz P WITH(NOLOCK) ON P.ID=PrKV.IDPrikaz
LEFT OUTER JOIN TabPrKVazby_EXT tprkve WITH(NOLOCK) ON tprkve.ID=PrKV.ID
WHERE PrKv.mnoz_Nevydane>0 AND 
    PrKV.Splneno=0 AND
    PrKV.Prednastaveno=1 AND
    PrKV.IDOdchylkyDo IS NULL AND
    P.StavPrikazu<=40 AND
	P.Plan_zadani<=GETDATE()+7
GROUP BY PrKV.nizsi,KZN.SkupZbo,KZN.RegCis,KZN.Nazev1,KZN.Nazev2,KZN.SKP
)
GO

