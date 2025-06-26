USE [RayService]
GO

/****** Object:  StoredProcedure [dbo].[hpx_RS_PlneniKapacityRSDisponibilita]    Script Date: 26.06.2025 16:04:59 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

CREATE PROCEDURE [dbo].[hpx_RS_PlneniKapacityRSDisponibilita]
AS
SET NOCOUNT ON;

--cvičný select
--SELECT RESOURCE_NAME AS NazevZdroje, END_TIME AS Den, DATEPART(YEAR,cal.END_TIME) AS Rok, DATEPART(MONTH,cal.END_TIME) AS Mesic, DATEPART(WEEK,cal.END_TIME) AS Tyden, NUMBER_OF_AVAIL_RESOURCES*8 AS KapacitaZdroje, SUBSTRING(RESOURCE_NAME,0,CHARINDEX('|',RESOURCE_NAME)) AS Stredisko
--FROM LADB.dbo.OUT_RESOURCECALENDAREXP cal
--WHERE (cal.RESOURCE_NAME LIKE '2002%')AND
----(cal.END_TIME BETWEEN '20241118' AND '20241118 23:59:59.997')AND
--(cal.NUMBER_OF_AVAIL_RESOURCES>0)
--AND CHARINDEX('|', RESOURCE_NAME, (CHARINDEX('|', RESOURCE_NAME, 1))+1)=0

--Datum brát vždy [END_TIME], suma řádků [NUMBER_OF_AVAIL_RESOURCES]*8 – v hodinách
--nejprve pomažeme data
DELETE FROM RayService.dbo.Tabx_RS_PrehledKapacitRS WHERE TypKapacity=1
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

--SELECT IDPracoviste, SUM(KapacitaZdroje) AS KapacitaZdroje, Rok, Mesic--, Tyden
--FROM #Kapacity
----WHERE NazevZdroje='20021000|KUSOVÁ V.'
--GROUP BY IDPracoviste, NazevZdroje, IDPracoviste, Rok, Mesic--, Tyden
--ORDER BY NazevZdroje ASC, Rok ASC, Mesic ASC--, Tyden ASC

--deklarace a sety pro zjištění aktuálního měsíce a roku pro úpravu kapacit pro aktuální rok a pro select dat
DECLARE @Month INT
DECLARE @Year INT
SET @Month=(SELECT DATEPART(MONTH, GETDATE()))
SET @Year=(SELECT DATEPART(YEAR, GETDATE()))
/*
--zjistíme počet pracovních dní v měsíci a počet zbývajících prac.dní
DECLARE @SumDays NUMERIC(5,2)
DECLARE @Day NUMERIC(5,2)
--SET @SumDays=(SELECT DAY(EOMONTH(GETDATE())))
--SET @Day=(SELECT DATEPART(DAY, GETDATE()))

;WITH Cal AS (
SELECT DISTINCT PKP.datum_D AS D
--COUNT(PKP.datum) OVER (PARTITION BY PKP.datum_M)
FROM TabPlanKalendare PK 
INNER JOIN TabPlanKalendPol PKP ON (PKP.IDPlanKalend=PK.ID AND PKP.MinDo-PKP.MinOd>0 ) 
WHERE PK.ID=2 AND datum_Y=DATEPART(YEAR,GETDATE()) AND datum_M=DATEPART(MONTH,GETDATE()))
SELECT @SumDays=COUNT(D)
FROM Cal
;

WITH CalW AS (
SELECT DISTINCT PKP.datum_D AS D
--COUNT(PKP.datum) OVER (PARTITION BY PKP.datum_M)
FROM TabPlanKalendare PK 
INNER JOIN TabPlanKalendPol PKP ON (PKP.IDPlanKalend=PK.ID AND PKP.MinDo-PKP.MinOd>0 ) 
WHERE PK.ID=2 AND datum_Y=DATEPART(YEAR,GETDATE()) AND datum_M=DATEPART(MONTH,GETDATE()) AND datum_D>=DATEPART(DAY,GETDATE()))
SELECT @Day=COUNT(D)
FROM CalW
;

--SELECT @SumDays, @Day

--UPDATE #Kapacity