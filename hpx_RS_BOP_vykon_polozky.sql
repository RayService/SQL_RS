USE [RayService]
GO

/****** Object:  StoredProcedure [dbo].[hpx_RS_BOP_vykon_polozky]    Script Date: 26.06.2025 13:02:44 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

CREATE PROCEDURE [dbo].[hpx_RS_BOP_vykon_polozky]
AS
SET NOCOUNT ON

IF (OBJECT_ID('tempdb..#Temp') IS NOT NULL)
BEGIN
DROP TABLE #Temp
END;
CREATE TABLE #Temp 
( [ID] INT IDENTITY (1,1) PRIMARY KEY,
  [Year] [INT],
  [Month] [INT],
  [IDZam] [INT],
  [Count] [INT]
)
--nakupované materiály
INSERT INTO #Temp (Year,Month,IDZam,Count)
SELECT tkz.DatPorizeni_Y,tkz.DatPorizeni_M,tcz.ID,COUNT(tkz.ID)
FROM TabKmenZbozi tkz
LEFT OUTER JOIN TabCisZam tcz ON tcz.LoginId=tkz.Autor
WHERE
(tkz.material=1)AND((tkz.DatPorizeni_Y=DATEPART(YEAR,GETDATE()))
AND(((tkz.Autor)=N'buresova')OR((tkz.Autor)=N'sachova')OR((tkz.Autor)=N'sanakova')OR((tkz.Autor)=N'mankova')OR((tkz.Autor)=N'steigerova')OR((tkz.Autor)=N'pospisilovak')OR((tkz.Autor)=N'paurikova')))
GROUP BY tkz.DatPorizeni_Y,tkz.DatPorizeni_M,tcz.ID
ORDER BY tkz.DatPorizeni_Y,tkz.DatPorizeni_M,tcz.ID
--oběhové doklady
INSERT INTO #Temp (Year,Month,IDZam,Count)
SELECT tdz.DatPovinnostiFa_Y,tdz.DatPovinnostiFa_M,tcz.ID,COUNT(tpz.ID)
FROM TabPohybyZbozi tpz
LEFT OUTER JOIN TabDokladyZbozi tdz ON tdz.ID=tpz.IDDoklad
LEFT OUTER JOIN TabCisZam tcz ON tcz.LoginId=tdz.Autor
WHERE
((((tdz.Autor)=N'steigerova')OR((tdz.Autor)=N'mankova')OR((tdz.Autor)=N'sachova')OR((tdz.Autor)=N'sanakova')OR((tdz.Autor)=N'buresova')OR((tdz.Autor)=N'pospisilovak')OR((tdz.Autor)=N'paurikova'))
AND(tdz.DatPovinnostiFa_Y=DATEPART(YEAR,GETDATE()))AND(tdz.RadaDokladu<>N'335'))
AND(((tpz.DruhPohybuZbo=2)OR(tpz.DruhPohybuZbo=9)OR(tpz.DruhPohybuZbo=11))AND(tdz.DatPovinnostiFa_Y=DATEPART(YEAR,GETDATE()))
AND(((tdz.Autor)=N'buresova')OR((tdz.Autor)=N'sachova')OR((tdz.Autor)=N'mankova')OR((tdz.Autor)=N'sanakova')OR((tdz.Autor)=N'steigerova')OR((tdz.Autor)=N'pospisilovak')OR((tdz.Autor)=N'paurikova')))
GROUP BY tdz.DatPovinnostiFa_Y,tdz.DatPovinnostiFa_M,tcz.ID
ORDER BY tdz.DatPovinnostiFa_Y,tdz.DatPovinnostiFa_M,tcz.ID
--procesní VP
INSERT INTO #Temp (Year,Month,IDZam,Count)
SELECT tp.DatPorizeni_Y,tp.DatPorizeni_M,tcz.ID,COUNT(tp.ID)
FROM TabPrikaz tp
LEFT OUTER JOIN TabCisZam tcz ON tcz.LoginId=tp.Autor
WHERE
((tp.DatPorizeni_Y=DATEPART(YEAR,GETDATE()))
AND(((tp.Autor)=N'buresova')OR((tp.Autor)=N'mankova')OR((tp.Autor)=N'steigerova')OR((tp.Autor)=N'sanakova')OR((tp.Autor)=N'sachova')OR((tp.Autor)=N'pospisilovak')OR((tp.Autor)=N'paurikova')))
GROUP BY tp.DatPorizeni_Y,tp.DatPorizeni_M,tcz.ID
ORDER BY tp.DatPorizeni_Y,tp.DatPorizeni_M,tcz.ID
--vyrabene dilce
INSERT INTO #Temp (Year,Month,IDZam,Count)
SELECT tkz.DatPorizeni_Y,tkz.DatPorizeni_M,tcz.ID,COUNT(tkz.ID)
FROM TabKmenZbozi tkz
LEFT OUTER JOIN TabCisZam tcz ON tcz.LoginId=tkz.Autor
WHERE
(tkz.dilec=1)AND((tkz.DatPorizeni_Y=DATEPART(YEAR,GETDATE()))AND(((tkz.Autor)=N'buresova')OR((tkz.Autor)=N'sachova')OR((tkz.Autor)=N'sanakova')OR((tkz.Autor)=N'mankova')OR((tkz.Autor)=N'steigerova')OR((tkz.Autor)=N'pospisilovak')OR((tkz.Autor)=N'paurikova')))
GROUP BY tkz.DatPorizeni_Y,tkz.DatPorizeni_M,tcz.ID
ORDER BY tkz.DatPorizeni_Y,tkz.DatPorizeni_M,tcz.ID
--SELECT * FROM #Temp;
/*
UPDATE BOP SET BOP.Item01=T.Count
FROM Tabx_RS_BONProcessPower BOP
LEFT OUTER JOIN #Temp T ON T.Year=BOP.Year AND T.IDZam=BOP.IDZam
WHERE T.Month=1 AND T.Year=DATEPART(YEAR,GETDATE())
*/
--leden
;WITH Tab AS (SELECT Year,Month,IDZam,SUM(Count) AS SumCount
FROM #Temp
GROUP BY Year,Month,IDZam)
UPDATE BOP SET BOP.Item01=T.SumCount
FROM Tabx_RS_BONProcessPower BOP
LEFT OUTER JOIN Tab T ON T.Year=BOP.Year AND T.IDZam=BOP.IDZam
WHERE T.Month=1 AND T.Year=DATEPART(YEAR,GETDATE())
--únor
;WITH Tab AS (SELECT Year,Month,IDZam,SUM(Count) AS SumCount
FROM #Temp
GROUP BY Year,Month,IDZam)
UPDATE BOP SET BOP.Item02=T.SumCount
FROM Tabx_RS_BONProcessPower BOP
LEFT OUTER JOIN Tab T ON T.Year=BOP.Year AND T.IDZam=BOP.IDZam
WHERE T.Month=2 AND T.Year=DATEPART(YEAR,GETDATE())
--březen
;WITH Tab AS (SELECT Year,Month,IDZam,SUM(Count) AS SumCount
FROM #Temp
GROUP BY Year,Month,IDZam)
UPDATE BOP SET BOP.Item03=T.SumCount
FROM Tabx_RS_BONProcessPower BOP
LEFT OUTER JOIN Tab T ON T.Year=BOP.Year AND T.IDZam=BOP.IDZam
WHERE T.Month=3 AND T.Year=DATEPART(YEAR,GETDATE())
--duben
;WITH Tab AS (SELECT Year,Month,IDZam,SUM(Count) AS SumCount
FROM #Temp
GROUP BY Year,Month,IDZam)
UPDATE BOP SET BOP.Item04=T.SumCount
FROM Tabx_RS_BONProcessPower BOP
LEFT OUTER JOIN Tab T ON T.Year=BOP.Year AND T.IDZam=BOP.IDZam
WHERE T.Month=4 AND T.Year=DATEPART(YEAR,GETDATE())
--květen
;WITH Tab AS (SELECT Year,Month,IDZam,SUM(Count) AS SumCount
FROM #Temp
GROUP BY Year,Month,IDZam)
UPDATE BOP SET BOP.Item05=T.SumCount
FROM Tabx_RS_BONProcessPower BOP
LEFT OUTER JOIN Tab T ON T.Year=BOP.Year AND T.IDZam=BOP.IDZam
WHERE T.Month=5 AND T.Year=DATEPART(YEAR,GETDATE())
--červen
;WITH Tab AS (SELECT Year,Month,IDZam,SUM(Count) AS SumCount
FROM #Temp
GROUP BY Year,Month,IDZam)
UPDATE BOP SET BOP.Item06=T.SumCount
FROM Tabx_RS_BONProcessPower BOP
LEFT OUTER JOIN Tab T ON T.Year=BOP.Year AND T.IDZam=BOP.IDZam
WHERE T.Month=6 AND T.Year=DATEPART(YEAR,GETDATE())
--červenec
;WITH Tab AS (SELECT Year,Month,IDZam,SUM(Count) AS SumCount
FROM #Temp
GROUP BY Year,Month,IDZam)
UPDATE BOP SET BOP.Item07=T.SumCount
FROM Tabx_RS_BONProcessPower BOP
LEFT OUTER JOIN Tab T ON T.Year=BOP.Year AND T.IDZam=BOP.IDZam
WHERE T.Month=7 AND T.Year=DATEPART(YEAR,GETDATE())
--srpen
;WITH Tab AS (SELECT Year,Month,IDZam,SUM(Count) AS SumCount
FROM #Temp
GROUP BY Year,Month,IDZam)
UPDATE BOP SET BOP.Item08=T.SumCount
FROM Tabx_RS_BONProcessPower BOP
LEFT OUTER JOIN Tab T ON T.Year=BOP.Year AND T.IDZam=BOP.IDZam
WHERE T.Month=8 AND T.Year=DATEPART(YEAR,GETDATE())
--září
;WITH Tab AS (SELECT Year,Month,IDZam,SUM(Count) AS SumCount
FROM #Temp
GROUP BY Year,Month,IDZam)
UPDATE BOP SET BOP.Item09=T.SumCount
FROM Tabx_RS_BONProcessPower BOP
LEFT OUTER JOIN Tab T ON T.Year=BOP.Year AND T.IDZam=BOP.IDZam
WHERE T.Month=9 AND T.Year=DATEPART(YEAR,GETDATE())
--říjen
;WITH Tab AS (SELECT Year,Month,IDZam,SUM(Count) AS SumCount
FROM #Temp
GROUP BY Year,Month,IDZam)
UPDATE BOP SET BOP.Item10=T.SumCount
FROM Tabx_RS_BONProcessPower BOP
LEFT OUTER JOIN Tab T ON T.Year=BOP.Year AND T.IDZam=BOP.IDZam
WHERE T.Month=10 AND T.Year=DATEPART(YEAR,GETDATE())
--listopad
;WITH Tab AS (SELECT Year,Month,IDZam,SUM(Count) AS SumCount
FROM #Temp
GROUP BY Year,Month,IDZam)
UPDATE BOP SET BOP.Item11=T.SumCount
FROM Tabx_RS_BONProcessPower BOP
LEFT OUTER JOIN Tab T ON T.Year=BOP.Year AND T.IDZam=BOP.IDZam
WHERE T.Month=11 AND T.Year=DATEPART(YEAR,GETDATE())
--prosinec
;WITH Tab AS (SELECT Year,Month,IDZam,SUM(Count) AS SumCount
FROM #Temp
GROUP BY Year,Month,IDZam)
UPDATE BOP SET BOP.Item12=T.SumCount
FROM Tabx_RS_BONProcessPower BOP
LEFT OUTER JOIN Tab T ON T.Year=BOP.Year AND T.IDZam=BOP.IDZam
WHERE T.Month=12 AND T.Year=DATEPART(YEAR,GETDATE())



GO

