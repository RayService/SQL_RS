USE [RayService]
GO

/****** Object:  StoredProcedure [dbo].[hpx_RS_BOP_vykon_dochazka]    Script Date: 26.06.2025 13:03:11 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

CREATE PROCEDURE [dbo].[hpx_RS_BOP_vykon_dochazka]
AS
SET NOCOUNT ON

-----------------------------------------------------------------------------------------------------------------------------------
/*
Leden až květen zapoznámkován.
Po přechodu na rok 2025 nutno odpoznámkovat a zrušit podmínku pro select do #TempAttendance za měsíc > 5.
MŽ, 5.2.2025 Odpoznámkováno a zrušena podmínka na květen.
*/
-----------------------------------------------------------------------------------------------------------------------------------

IF (OBJECT_ID('tempdb..#TempAttendance') IS NOT NULL)
BEGIN
DROP TABLE #TempAttendance
END;
CREATE TABLE #TempAttendance 
( [ID] INT IDENTITY (1,1) PRIMARY KEY,
  [Year] [INT],
  [Month] [INT],
  [IDZam] [INT],
  [CountDoch] [Numeric](19,6)
)

INSERT INTO #TempAttendance (Year,Month,IDZam,CountDoch)
/*SELECT DATEPART(YEAR,dpich.picDatum),DATEPART(MONTH,dpich.picDatum),tcz.ID,SUM(CONVERT(NUMERIC(19,6),dpich.picOdpracDoba)/60) AS Odprac_H
FROM DOCHAZKASQL.IdentitaNET.dbo.DochPichacka dpich WITH(NOLOCK)
LEFT OUTER JOIN RayService..TabCisZam tcz WITH(NOLOCK) ON tcz.Cislo=dpich.picIDOsoby
WHERE DATEPART(YEAR,dpich.picDatum)=DATEPART(YEAR,GETDATE()) AND DATEPART(YEAR,dpich.picCasPrichodu)=DATEPART(YEAR,GETDATE()) AND dpich.picDatum<CONVERT(DATE,GETDATE())
AND(tcz.LoginID IN (N'buresova',N'sachova',N'sanakova',N'mankova',N'steigerova',N'pospisilovak',N'paurikova'))
GROUP BY DATEPART(YEAR,dpich.picDatum),DATEPART(MONTH,dpich.picDatum),tcz.ID
toto bylo původně a nahrazeno 22.2.2023 se započtením HO*/
/*
toto bylo za časů staré docházkySELECT DATEPART(YEAR,dpich.picDatum),DATEPART(MONTH,dpich.picDatum),tcz.ID,ISNULL(SUM(CONVERT(NUMERIC(19,6),dpich.picOdpracDoba)/60),0) + ISNULL(SUM(CONVERT(NUMERIC(19,6),dabsc.pabDobaAbsc)/60),0) AS DobaOdpracAbsc
FROM DOCHAZKASQL.IdentitaNET.dbo.DochPichacka dpich WITH(NOLOCK)
LEFT OUTER JOIN DOCHAZKASQL.IdentitaNET.dbo.DochPichAbsc dabsc WITH(NOLOCK) ON dabsc.pabIDPichacka=dpich.picIDPichacka AND dabsc.pabIDMzdPolozky IN (98,100)
LEFT OUTER JOIN RayService..TabCisZam tcz WITH(NOLOCK) ON tcz.Cislo=dpich.picIDOsoby
WHERE DATEPART(YEAR,dpich.picDatum)=DATEPART(YEAR,GETDATE()) AND dpich.picDatum<CONVERT(DATE,GETDATE())
AND(tcz.LoginID IN (N'buresova',N'sachova',N'sanakova',N'mankova',N'steigerova',N'pospisilovak',N'paurikova'))
GROUP BY DATEPART(YEAR,dpich.picDatum),DATEPART(MONTH,dpich.picDatum),tcz.ID*/
--nová docházka:
SELECT DATEPART(YEAR,dd.dd_Datum),DATEPART(MONTH,dd.dd_Datum),tcz.ID,ISNULL(SUM(CONVERT(NUMERIC(19,6),dd.dd_OdpracovanaDoba)/60),0) + ISNULL(SUM(CONVERT(NUMERIC(19,6),dd.dd_SaldoDen)/60),0) AS DobaOdpracAbsc
FROM DOCHAZKASQL.DC3.dbo.DochazkaDen dd
INNER JOIN DOCHAZKASQL.DC3.dbo.OsobaVztah dosv ON dosv.ov_IDZakaznik = dd.dd_IDZakaznik AND dosv.ov_IDOsobaVztah = dd.dd_IDOsobaVztah
INNER JOIN DOCHAZKASQL.DC3.dbo.Osoba dos ON dosv.ov_IDZakaznik = dos.osoIDZakaznik AND dosv.ov_IDOsoba = dos.osoIDOsoba
LEFT OUTER JOIN RayService..TabCisZam tcz ON tcz.Cislo = ISNULL(dosv.ov_CisloVztahu, dos.osoOsobniCislo)
WHERE DATEPART(YEAR,dd.dd_Datum)=DATEPART(YEAR,GETDATE()) AND dd.dd_Datum < CAST(GETDATE() AS DATE)
--AND DATEPART(MONTH,dd.dd_Datum)>5
AND(tcz.LoginID IN (N'buresova',N'sachova',N'sanakova',N'mankova',N'steigerova',N'pospisilovak',N'paurikova'))
--AND(dd.dd_DatumACasPrichodu IS NOT NULL AND dd.dd_DatumACasOdchodu IS NOT NULL)
--ORDER BY dd.dd_IDZakaznik, dd.dd_Datum, ISNULL(dosv.ov_CisloVztahu, dos.osoOsobniCislo)
GROUP BY DATEPART(YEAR,dd.dd_Datum),DATEPART(MONTH,dd.dd_Datum),tcz.ID


SELECT * FROM #TempAttendance

leden
;WITH Tab AS (SELECT Year,Month,IDZam,SUM(CountDoch) AS SumCountDoch
FROM #TempAttendance
GROUP BY Year,Month,IDZam)
UPDATE BOP SET BOP.Attendance01=T.SumCountDoch
FROM Tabx_RS_BONProcessPower BOP
LEFT OUTER JOIN Tab T ON T.Year=BOP.Year AND T.IDZam=BOP.IDZam
WHERE T.Month=1 AND T.Year=DATEPART(YEAR,GETDATE())
--únor
;WITH Tab AS (SELECT Year,Month,IDZam,SUM(CountDoch) AS SumCountDoch
FROM #TempAttendance
GROUP BY Year,Month,IDZam)
UPDATE BOP SET BOP.Attendance02=T.SumCountDoch
FROM Tabx_RS_BONProcessPower BOP
LEFT OUTER JOIN Tab T ON T.Year=BOP.Year AND T.IDZam=BOP.IDZam
WHERE T.Month=2 AND T.Year=DATEPART(YEAR,GETDATE())
--březen
;WITH Tab AS (SELECT Year,Month,IDZam,SUM(CountDoch) AS SumCountDoch
FROM #TempAttendance
GROUP BY Year,Month,IDZam)
UPDATE BOP SET BOP.Attendance03=T.SumCountDoch
FROM Tabx_RS_BONProcessPower BOP
LEFT OUTER JOIN Tab T ON T.Year=BOP.Year AND T.IDZam=BOP.IDZam
WHERE T.Month=3 AND T.Year=DATEPART(YEAR,GETDATE())
--duben
;WITH Tab AS (SELECT Year,Month,IDZam,SUM(CountDoch) AS SumCountDoch
FROM #TempAttendance
GROUP BY Year,Month,IDZam)
UPDATE BOP SET BOP.Attendance04=T.SumCountDoch
FROM Tabx_RS_BONProcessPower BOP
LEFT OUTER JOIN Tab T ON T.Year=BOP.Year AND T.IDZam=BOP.IDZam
WHERE T.Month=4 AND T.Year=DATEPART(YEAR,GETDATE())
--květen
;WITH Tab AS (SELECT Year,Month,IDZam,SUM(CountDoch) AS SumCountDoch
FROM #TempAttendance
GROUP BY Year,Month,IDZam)
UPDATE BOP SET BOP.Attendance05=T.SumCountDoch
FROM Tabx_RS_BONProcessPower BOP
LEFT OUTER JOIN Tab T ON T.Year=BOP.Year AND T.IDZam=BOP.IDZam
WHERE T.Month=5 AND T.Year=DATEPART(YEAR,GETDATE())
--červen
;WITH Tab AS (SELECT Year,Month,IDZam,SUM(CountDoch) AS SumCountDoch
FROM #TempAttendance
GROUP BY Year,Month,IDZam)
UPDATE BOP SET BOP.Attendance06=T.SumCountDoch
FROM Tabx_RS_BONProcessPower BOP
LEFT OUTER JOIN Tab T ON T.Year=BOP.Year AND T.IDZam=BOP.IDZam
WHERE T.Month=6 AND T.Year=DATEPART(YEAR,GETDATE())
--červenec
;WITH Tab AS (SELECT Year,Month,IDZam,SUM(CountDoch) AS SumCountDoch
FROM #TempAttendance
GROUP BY Year,Month,IDZam)
UPDATE BOP SET BOP.Attendance07=T.SumCountDoch
FROM Tabx_RS_BONProcessPower BOP
LEFT OUTER JOIN Tab T ON T.Year=BOP.Year AND T.IDZam=BOP.IDZam
WHERE T.Month=7 AND T.Year=DATEPART(YEAR,GETDATE())
--srpen
;WITH Tab AS (SELECT Year,Month,IDZam,SUM(CountDoch) AS SumCountDoch
FROM #TempAttendance
GROUP BY Year,Month,IDZam)
UPDATE BOP SET BOP.Attendance08=T.SumCountDoch
FROM Tabx_RS_BONProcessPower BOP
LEFT OUTER JOIN Tab T ON T.Year=BOP.Year AND T.IDZam=BOP.IDZam
WHERE T.Month=8 AND T.Year=DATEPART(YEAR,GETDATE())
--září
;WITH Tab AS (SELECT Year,Month,IDZam,SUM(CountDoch) AS SumCountDoch
FROM #TempAttendance
GROUP BY Year,Month,IDZam)
UPDATE BOP SET BOP.Attendance09=T.SumCountDoch
FROM Tabx_RS_BONProcessPower BOP
LEFT OUTER JOIN Tab T ON T.Year=BOP.Year AND T.IDZam=BOP.IDZam
WHERE T.Month=9 AND T.Year=DATEPART(YEAR,GETDATE())
--říjen
;WITH Tab AS (SELECT Year,Month,IDZam,SUM(CountDoch) AS SumCountDoch
FROM #TempAttendance
GROUP BY Year,Month,IDZam)
UPDATE BOP SET BOP.Attendance10=T.SumCountDoch
FROM Tabx_RS_BONProcessPower BOP
LEFT OUTER JOIN Tab T ON T.Year=BOP.Year AND T.IDZam=BOP.IDZam
WHERE T.Month=10 AND T.Year=DATEPART(YEAR,GETDATE())
--listopad
;WITH Tab AS (SELECT Year,Month,IDZam,SUM(CountDoch) AS SumCountDoch
FROM #TempAttendance
GROUP BY Year,Month,IDZam)
UPDATE BOP SET BOP.Attendance11=T.SumCountDoch
FROM Tabx_RS_BONProcessPower BOP
LEFT OUTER JOIN Tab T ON T.Year=BOP.Year AND T.IDZam=BOP.IDZam
WHERE T.Month=11 AND T.Year=DATEPART(YEAR,GETDATE())
--prosinec
;WITH Tab AS (SELECT Year,Month,IDZam,SUM(CountDoch) AS SumCountDoch
FROM #TempAttendance
GROUP BY Year,Month,IDZam)
UPDATE BOP SET BOP.Attendance12=T.SumCountDoch
FROM Tabx_RS_BONProcessPower BOP
LEFT OUTER JOIN Tab T ON T.Year=BOP.Year AND T.IDZam=BOP.IDZam
WHERE T.Month=12 AND T.Year=DATEPART(YEAR,GETDATE())



GO

