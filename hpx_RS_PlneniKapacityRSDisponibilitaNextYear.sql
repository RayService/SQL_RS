USE [RayService]
GO

/****** Object:  StoredProcedure [dbo].[hpx_RS_PlneniKapacityRSDisponibilitaNextYear]    Script Date: 30.06.2025 8:41:10 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

CREATE PROCEDURE [dbo].[hpx_RS_PlneniKapacityRSDisponibilitaNextYear]
AS
SET NOCOUNT ON;

--Datum brát vždy [END_TIME], suma řádků [NUMBER_OF_AVAIL_RESOURCES]*8 – v hodinách
--nejprve pomažeme data
DELETE FROM RayService.dbo.Tabx_RS_PrehledKapacitRSNextYear WHERE TypKapacity=1
--naplníme dočasnou tabulku
IF OBJECT_ID('tempdb..#Kapacity') IS NOT NULL DROP TABLE #Kapacity
CREATE TABLE #Kapacity (ID INT IDENTITY(1,1) NOT NULL, SkupinaZdroje NVARCHAR(255) NULL, NazevZdroje NVARCHAR(255) NOT NULL, Rok INT, Mesic INT, Tyden INT, KapacitaZdroje NUMERIC(19,6), Stredisko NVARCHAR(30), IDPracoviste INT)
INSERT INTO #Kapacity (NazevZdroje, Rok, Mesic, Tyden, KapacitaZdroje, Stredisko)
SELECT RESOURCE_NAME AS NazevZdroje, DATEPART(YEAR,cal.END_TIME) AS Rok, DATEPART(MONTH,cal.END_TIME) AS Mesic, DATEPART(WEEK,cal.END_TIME) AS Tyden, ISNULL(NUMBER_OF_AVAIL_RESOURCES,0)*8 AS KapacitaZdroje, SUBSTRING(RESOURCE_NAME,0,CHARINDEX('|',RESOURCE_NAME)) AS Stredisko
FROM LADB.dbo.OUT_RESOURCECALENDAREXP cal
WHERE (cal.RESOURCE_NAME LIKE '2002%')AND
--(cal.END_TIME BETWEEN '20241118' AND '20241118 23:59:59.997')AND
(cal.NUMBER_OF_AVAIL_RESOURCES>0)
AND CHARINDEX('|', RESOURCE_NAME, (CHARINDEX('|', RESOURCE_NAME, 1))+1)=0

MERGE #Kapacity AS TARGET
USING (SELECT
tcpo.ID AS IDPracoviste, tcpo.IDTabStrom AS IDStrom, tcpo.Pracoviste AS Pracoviste, CONCAT(tcpo.IDTabStrom,'|',tcpo.Pracoviste) AS Zdroj, tcpoe._EXT_RS_SkupinaPracoviste AS SkupinaPracoviste
FROM TabCPraco tcpo
LEFT OUTER JOIN TabCPraco_EXT tcpoe ON tcpoe.ID=tcpo.ID
WHERE (tcpo.IDTabStrom like N'2002%')
) AS SOURCE
ON TARGET.NazevZdroje=SOURCE.Zdroj
WHEN MATCHED THEN UPDATE
SET TARGET.IDPracoviste=SOURCE.IDPracoviste, TARGET.SkupinaZdroje=SOURCE.SkupinaPracoviste
;

SELECT SkupinaZdroje, IDPracoviste, SUM(KapacitaZdroje) AS KapacitaZdroje, Rok, Mesic--, Tyden
FROM #Kapacity
--WHERE NazevZdroje='20021000|KUSOVÁ V.'
GROUP BY SkupinaZdroje, IDPracoviste, NazevZdroje, IDPracoviste, Rok, Mesic--, Tyden
ORDER BY NazevZdroje ASC, Rok ASC, Mesic ASC--, Tyden ASC

DELETE FROM RayService.dbo.Tabx_RS_PrehledKapacitRSNextYear WHERE TypKapacity=1

--naplníme naši tabulku
INSERT INTO RayService.dbo.Tabx_RS_PrehledKapacitRSNextYear (IDPracoviste, SkupinaPracoviste, TypKapacity, Leden, Unor, Brezen, Duben, Kveten, Cerven, Cervenec, Srpen, Zari, Rijen, Listopad, Prosinec)
SELECT IDPracoviste, SkupinaZdroje, 1,
[1] AS Leden,
[2] AS Unor,
[3] AS Brezen,
[4] AS Duben,
[5] AS Kveten,
[6] AS Cerver,
[7] AS Cervenec,
[8] AS Srpen,
[9] AS Zari,
[10] AS Rijen,
[11] AS Listopad,
[12] AS Prosinec
FROM
(
SELECT IDPracoviste, SkupinaZdroje, ISNULL(SUM(KapacitaZdroje),0) AS KapacitaZdroje, /*Rok,*/ Mesic--, Tyden
FROM #Kapacity
WHERE (Rok=DATEPART(YEAR,GETDATE())+1)
GROUP BY SkupinaZdroje, IDPracoviste, NazevZdroje, IDPracoviste, /*Rok,*/ Mesic--, Tyden
--ORDER BY NazevZdroje ASC, Rok ASC, Mesic ASC, Tyden ASC
) P
PIVOT
(
SUM (KapacitaZdroje)
FOR Mesic IN ([1],[2],[3],[4],[5],[6],[7],[8],[9],[10],[11],[12])
) AS PVT
ORDER BY PVT.IDPracoviste

--u pracovišť BD a FC nastavit disponibilitu = 0
UPDATE RayService.dbo.Tabx_RS_PrehledKapacitRSNextYear SET Leden=0, Unor=0, Brezen=0, Duben=0, Kveten=0, Cerven=0, Cervenec=0, Srpen=0, Zari=0, Rijen=0, Listopad=0, Prosinec=0
WHERE IDPracoviste IN (343,344)

GO

