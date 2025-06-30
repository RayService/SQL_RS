USE [RayService]
GO

/****** Object:  StoredProcedure [dbo].[hpx_RS_NadrizenaZakazkaJAGGING]    Script Date: 30.06.2025 8:50:26 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

CREATE PROCEDURE [dbo].[hpx_RS_NadrizenaZakazkaJAGGING]
AS

IF OBJECT_ID('tempdb..#Tab') IS NOT NULL DROP TABLE #Tab
CREATE TABLE #Tab (ID INT IDENTITY(1,1) NOT NULL, ID_JAG INT NOT NULL, Zakazky NVARCHAR(30))

IF OBJECT_ID('tempdb..#TabImp') IS NOT NULL DROP TABLE #TabImp
CREATE TABLE #TabImp (ID INT IDENTITY(1,1) NOT NULL, ID_JAG INT NOT NULL, NadrizeneZakazky NVARCHAR(4000))

INSERT INTO #Tab (ID_JAG, Zakazky)
SELECT ID, TRIM(VALUE) AS Separate
FROM Tabx_RS_OUT_MANUFACTURINGORDERJAGGING
CROSS APPLY STRING_SPLIT(ID_Zakazek,',',1)
--WHERE ID_Zakazek NOT LIKE 'ATO%' --AND ID_Zakazek LIKE '%|%'
;
WITH Tab AS (
SELECT t.ID AS ID
,t.ID_JAG AS ID_JAG
,t.Zakazky AS Zakazky
,LEFT(TRIM(t.Zakazky), CHARINDEX('|',TRIM(t.Zakazky))-1) AS Zakazka_bez_mezer
,tz.CisloZakazky AS CisloZakazky
,tz.NadrizenaZak AS Nadrizena
FROM #Tab t
LEFT OUTER JOIN RayService.dbo.TabZakazka tz ON tz.CisloZakazky=LEFT(TRIM(t.Zakazky), CHARINDEX('|',TRIM(t.Zakazky))-1)
WHERE t.Zakazky LIKE '%|%'
AND tz.NadrizenaZak IS NOT NULL)
INSERT INTO #TabImp (ID_JAG, NadrizeneZakazky)
SELECT tb.ID_JAG, STRING_AGG(tb.Nadrizena, ',')
FROM Tab tb
GROUP BY tb.ID_JAG
ORDER BY ID_JAG ASC

SELECT *
FROM #TabImp;

MERGE Tabx_RS_OUT_MANUFACTURINGORDERJAGGING AS TARGET
USING #TabImp AS SOURCE
ON TARGET.ID=SOURCE.ID_JAG
WHEN MATCHED THEN UPDATE
SET TARGET.ID_NadrizenychZakazek=SOURCE.NadrizeneZakazky
;
GO

