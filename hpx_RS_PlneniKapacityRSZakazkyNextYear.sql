USE [RayService]
GO

/****** Object:  StoredProcedure [dbo].[hpx_RS_PlneniKapacityRSZakazkyNextYear]    Script Date: 30.06.2025 8:41:36 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

CREATE PROCEDURE [dbo].[hpx_RS_PlneniKapacityRSZakazkyNextYear]
AS
SET NOCOUNT ON;

--datum BUCKET_END_TIME, Suma řádků LOAD_CAPACITY/60 – v hodinách
--naplníme dočasnou tabulku

IF OBJECT_ID('tempdb..#Zakazky') IS NOT NULL DROP TABLE #Zakazky
CREATE TABLE #Zakazky (ID INT IDENTITY(1,1) NOT NULL, SkupinaZdroje NVARCHAR(255) NULL, NazevZdroje NVARCHAR(255) NOT NULL, Rok INT, Mesic INT, Tyden INT, Zakazky NUMERIC(19,6), Stredisko NVARCHAR(30), IDPracoviste INT, EP BIT)
INSERT INTO #Zakazky (NazevZdroje, Rok, Mesic, Tyden, Zakazky, Stredisko, EP)
SELECT resload.RESOURCE_NAME AS NazevZdroje, resload.BUCKET_END_TIME_Y AS Rok, resload.BUCKET_END_TIME_M AS Mesic, resload.BUCKET_END_TIME_V AS Tyden, resload.LOAD_CAPACITY/60 AS Zakazky, SUBSTRING(resload.RESOURCE_NAME,0,CHARINDEX('|',resload.RESOURCE_NAME)) AS Stredisko, CASE WHEN ISNULL(mor.RAY_DO_SalesOrderID,'') <>'' THEN 1 ELSE 0 END AS EP
FROM GTabAPSLogis_OUT_RESOURCELOAD resload
LEFT OUTER JOIN hvw_APSLogis_OUT_MANUFACORDER mor ON mor.MFG_ORDER_ID=resload.MFG_ORDER_ID --.RAY_DO_SalesOrderID
WHERE (resload.RESOURCE_NAME LIKE '2002%')AND
--(resload.BUCKET_END_TIME BETWEEN '20241118' AND '20241118 23:59:59.997')AND
CHARINDEX('|', resload.RESOURCE_NAME, (CHARINDEX('|', resload.RESOURCE_NAME, 1))+1)=0

--doplníme ID pracoviště
MERGE #Zakazky AS TARGET
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

--SELECT IDPracoviste, SUM(Zakazky) AS Zakazky, Rok, Mesic--, Tyden
--FROM #Zakazky
----WHERE NazevZdroje='20021000|KUSOVÁ V.'
--GROUP BY IDPracoviste, NazevZdroje, IDPracoviste, Rok, Mesic--, Tyden
--ORDER BY IDPracoviste ASC, Rok ASC, Mesic ASC--, Tyden ASC

DECLARE @Month INT
DECLARE @Year INT
SET @Month=(SELECT DATEPART(MONTH, GETDATE()))
SET @Year=(SELECT DATEPART(YEAR, GETDATE()))

DELETE FROM RayService.dbo.Tabx_RS_PrehledKapacitRSNextYear WHERE TypKapacity=2

--naplníme naši tabulku
INSERT INTO RayService.dbo.Tabx_RS_PrehledKapacitRSNextYear (IDPracoviste, SkupinaPracoviste, TypKapacity, EP, Leden, Unor, Brezen, Duben, Kveten, Cerven, Cervenec, Srpen, Zari, Rijen, Listopad, Prosinec)
SELECT IDPracoviste, SkupinaZdroje, 2, EP,
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
SELECT IDPracoviste, SkupinaZdroje, EP, ISNULL(SUM(Zakazky),0) AS Zakazky, /*Rok,*/ Mesic--, Tyden
FROM #Zakazky
WHERE (Rok=DATEPART(YEAR,GETDATE())+1)
GROUP BY SkupinaZdroje, IDPracoviste, NazevZdroje, EP, /*Rok,*/ Mesic--, Tyden
--ORDER BY NazevZdroje ASC, Rok ASC, Mesic ASC, Tyden ASC
) P
PIVOT
(
SUM (Zakazky)
FOR Mesic IN ([1],[2],[3],[4],[5],[6],[7],[8],[9],[10],[11],[12])
) AS PVT
ORDER BY PVT.IDPracoviste

--MŽ 6.1.2025 na přání PaM
--u pracovišť BD a FC nastavit zakázky krát 100
UPDATE RayService.dbo.Tabx_RS_PrehledKapacitRSNextYear SET Leden=Leden*100, Unor=Unor*100, Brezen=Brezen*100, Duben=Duben*100, Kveten=Kveten*100,
Cerven=Cerven*100, Cervenec=Cervenec*100, Srpen=Srpen*100, Zari=Zari*100, Rijen=Rijen*100, Listopad=Listopad*100, Prosinec=Prosinec*100
WHERE IDPracoviste IN (343,344)




GO

