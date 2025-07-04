USE [RayService]
GO

/****** Object:  View [dbo].[TabFIAAVykazyPOView]    Script Date: 04.07.2025 10:28:15 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

CREATE VIEW [dbo].[TabFIAAVykazyPOView] --UPDATED 20151017
(Puvod,ID,SystCislo,Cislo,Nazev,DatumOd,DatumDo,DatumAktualizace,StavXML,GUIDScenare,DatumOdeslani,DatumPrijeti,DatumZpracovani,IdFIAAObdobiProVykazy)
AS 
SELECT
0,
P.ID,
P.ID,
V.CisloVykazu,
V.NazevVykazu1,
P.DatumOd1_X,
P.DatumDo1_X,
P.DatumAktualizace,
P.StavXML,
P.GUIDScenare,
P.DatumOdeslani,
P.DatumPrijeti,
P.DatumZpracovani,
P.IdFIAAObdobiProVykazy
FROM TabFIAAVykazParam AS P
LEFT OUTER JOIN TabFIAAVykaz AS V ON V.ID=P.IdFIAAVykaz
LEFT OUTER JOIN TabFIAAVykazSkupina AS S ON S.ID=P.IdFIAAVykazSkupina
WHERE V.RozvrhStandardu = 0
AND (S.Legislativni = 2) OR (S.Legislativni = 5)
UNION ALL
SELECT 
1 ,  
P.ID + 1000000000,
P.ID,
P.CisloDokument,
P.Nazev1,
OV.DatumOd1_X,
OV.DatumDo1_X,
P.DatumAktualizace,
P.StavXML,
P.GUIDScenare,
P.DatumOdeslani,
P.DatumPrijeti,
P.DatumZpracovani,
P.IdFIAAObdobiProVykazy
FROM TabFIABDokument AS P
LEFT OUTER JOIN TabFIAAObdobiProVykazy AS OV ON P.IdFIAAObdobiProVykazy=OV.ID
WHERE ((P.TypSestavy = 1) OR (P.TypSestavy = 5))
AND P.IdFIAAObdobiProVykazy IS NOT NULL
UNION ALL
SELECT 
2,  
-P.ID,
P.ID,
P.PlanCislo,
V.NazevVykazu1,
VP.DatumOd1_X,
VP.DatumDo1_X,
VP.DatumAktualizace,
P.StavXML,
P.GUIDScenare,
P.DatumOdeslani,
P.DatumPrijeti,
P.DatumZpracovani,
VP.IdFIAAObdobiProVykazy
FROM TabFIACPlan AS P
LEFT OUTER JOIN TabFIAAVykazParam AS VP ON VP.ID=P.IdFIAAVykazParam
LEFT OUTER JOIN TabFIAAVykaz AS V ON V.ID=VP.IdFIAAVykaz
LEFT OUTER JOIN TabFIAAVykazSkupina AS S ON S.ID=VP.IdFIAAVykazSkupina
WHERE V.Ucel = 1
AND S.Legislativni = 2
UNION ALL
SELECT 
3,  
-P.ID-1000000000,
P.ID,
P.Rok * 100 + Mesic,
N'Zam 1-04',
CONVERT(DATETIME,CONVERT(NVARCHAR,P.Rok*10000+101)),
DATEADD(DAY,-1,DATEADD(MONTH,1,CONVERT(DATETIME,CONVERT(NVARCHAR,P.Rok*10000+P.Mesic*100+1)))),
P.Datum,
P.StavXML,
P.GUIDScenare,
P.DatumOdeslani,
P.DatumPrijeti,
P.DatumZpracovani,
OV.ID
FROM TabMzZam104CzPocet AS P
LEFT OUTER JOIN TabFIAAObdobiProVykazy AS OV ON OV.ID=
(SELECT TOP 1 ID FROM TabFIAAObdobiProVykazy AS OPV WHERE 
((CONVERT(DATETIME,CONVERT(NVARCHAR,P.Rok*10000+P.Mesic*100+1)) BETWEEN OPV.DatumOd1_X AND OPV.DatumDo1)
AND(DATEADD(DAY,-1,DATEADD(MONTH,1,CONVERT(DATETIME,CONVERT(NVARCHAR,P.Rok*10000+P.Mesic*100+1)))) BETWEEN OPV.DatumOd1_X AND OPV.DatumDo1))
ORDER BY P.Mesic DESC)
GO

