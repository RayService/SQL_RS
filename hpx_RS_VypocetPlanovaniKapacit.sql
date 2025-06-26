USE [RayService]
GO

/****** Object:  StoredProcedure [dbo].[hpx_RS_VypocetPlanovaniKapacit]    Script Date: 26.06.2025 14:03:52 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

CREATE PROCEDURE [dbo].[hpx_RS_VypocetPlanovaniKapacit]
AS
SET NOCOUNT ON;

IF OBJECT_ID('tempdb..#TabCapacity') IS NOT NULL DROP TABLE #TabCapacity
CREATE TABLE #TabCapacity (ID INT IDENTITY(1,1) NOT NULL, Kvaldil NVARCHAR(2) NOT NULL, CasPol NUMERIC(19,2) NULL, Mesic INT NOT NULL, TypVyroby INT NULL);
IF OBJECT_ID('tempdb..#TabCapacityVyp') IS NOT NULL DROP TABLE #TabCapacityVyp
CREATE TABLE #TabCapacityVyp (ID INT IDENTITY(1,1) NOT NULL, CasPol NUMERIC(19,2) NULL, Mesic INT NOT NULL, TypVyroby INT NULL);
/*naplnění tabulky
INSERT INTO Tabx_RS_PlanovaniKapacitVypocty (TypVyroby,ParametrVypoctu,Leden,Unor,Brezen,Duben,Kveten,Cerven,Cervenec,Srpen,Zari,Rijen,Listopad,Prosinec)
VALUES (1,1,0,0,0,0,0,0,0,0,0,0,0,0),(1,2,0,0,0,0,0,0,0,0,0,0,0,0),
(2,1,0,0,0,0,0,0,0,0,0,0,0,0),(2,2,0,0,0,0,0,0,0,0,0,0,0,0),
(3,1,0,0,0,0,0,0,0,0,0,0,0,0),(3,2,0,0,0,0,0,0,0,0,0,0,0,0),
(4,1,0,0,0,0,0,0,0,0,0,0,0,0),(4,2,0,0,0,0,0,0,0,0,0,0,0,0),
(5,1,0,0,0,0,0,0,0,0,0,0,0,0),(5,2,0,0,0,0,0,0,0,0,0,0,0,0)*/

WITH PlanCap AS (
SELECT
tkz_EXT._KvalDil AS KvalDil,
(CASE WHEN EXISTS
(SELECT
tp.ID
FROM TabPlan tp WITH(NOLOCK)
WHERE (tp.InterniZaznam=0 AND tp.mnozstvi=1 AND (tp.SkupinaPlanu LIKE N'%p100%' OR tp.SkupinaPlanu LIKE N'%XXX%') AND tp.ID=TabPlan.ID))
THEN
(((
SELECT
ISNULL(SUM(tpp.TBC_S / 3600.0),0)+ISNULL(SUM(tpp.Kusy_zad * tpp.TAC_S / 3600.0),0)
FROM TabPrPostup AS tpp WITH(NOLOCK)
  LEFT OUTER JOIN TabPrikaz tp WITH(NOLOCK) ON tpp.IDPrikaz=tp.ID
  LEFT OUTER JOIN TabCPraco tcp WITH(NOLOCK) ON tpp.Pracoviste=tcp.ID
  LEFT OUTER JOIN TabPlan tpl WITH(NOLOCK) ON tpl.ID = tp.IDPlan
WHERE ((tpp.IDOdchylkyDo IS NULL) AND tpl.ID = TabPlan.ID AND tcp.IDTabStrom LIKE '200%')
)
+
(
SELECT
ISNULL(SUM(tppp.TBC_S / 3600.0),0)+ISNULL(SUM(tppp.Kusy_zad * tppp.TAC_S / 3600.0),0)
FROM TabPlan tp WITH(NOLOCK)
  LEFT OUTER JOIN TabPlanPrikaz tpp WITH(NOLOCK) ON tpp.IDPlan = tp.ID
  LEFT OUTER JOIN TabPlanPrPostup tppp WITH(NOLOCK) ON tppp.IDPlanPrikaz = tpp.ID
  LEFT OUTER JOIN TabCPraco tcp WITH(NOLOCK) ON tppp.Pracoviste=tcp.ID
WHERE tcp.IDTabStrom LIKE '200%' AND tp.ID = TabPlan.ID
))
*2)
ELSE
((
SELECT
ISNULL(SUM(tpp.TBC_S / 3600.0),0)+ISNULL(SUM(tpp.Kusy_zad * tpp.TAC_S / 3600.0),0)
FROM TabPrPostup AS tpp WITH(NOLOCK)
  LEFT OUTER JOIN TabPrikaz tp WITH(NOLOCK) ON tpp.IDPrikaz=tp.ID
  LEFT OUTER JOIN TabCPraco tcp WITH(NOLOCK) ON tpp.Pracoviste=tcp.ID
  LEFT OUTER JOIN TabPlan tpl WITH(NOLOCK) ON tpl.ID = tp.IDPlan
WHERE ((tpp.IDOdchylkyDo IS NULL) AND tpl.ID = TabPlan.ID AND tcp.IDTabStrom LIKE '200%')
)
+
(
SELECT
ISNULL(SUM(tppp.TBC_S / 3600.0),0)+ISNULL(SUM(tppp.Kusy_zad * tppp.TAC_S / 3600.0),0)
FROM TabPlan tp WITH(NOLOCK)
  LEFT OUTER JOIN TabPlanPrikaz tpp WITH(NOLOCK) ON tpp.IDPlan = tp.ID
  LEFT OUTER JOIN TabPlanPrPostup tppp WITH(NOLOCK) ON tppp.IDPlanPrikaz = tpp.ID
  LEFT OUTER JOIN TabCPraco tcp WITH(NOLOCK) ON tppp.Pracoviste=tcp.ID
WHERE tcp.IDTabStrom LIKE '200%' AND tp.ID = TabPlan.ID
))END) AS CasPol,
(
DATEPART(MONTH,(
SELECT TOP 1 Datum
FROM (
(SELECT tpl.datum AS Datum
FROM TabPlan tpl
WHERE tpl.ID=TabPlan.ID)
UNION
(SELECT Datum
FROM (SELECT
TOP 1 tp.Plan_ukonceni AS Datum
FROM TabPrikaz tp
WHERE
(tp.ID IN (SELECT PrZ.IDPrikaz FROM TabPrikazZdrojVyrPlan PrZ WHERE PrZ.IDPlan=TabPlan.ID))AND
(tp.StavPrikazu<=40)AND
(tp.kusy_zive>0)
ORDER BY tp.Plan_ukonceni DESC) AS T
)
UNION ALL
(SELECT Datum
FROM (SELECT
TOP 1 plpr.Plan_ukonceni AS Datum
FROM TabPlanPrikaz plpr
LEFT OUTER JOIN TabPlan tpl ON tpl.ID=plpr.IDPlan
WHERE
(plpr.IDPlan=TabPlan.ID)AND
(plpr.kusy_ciste>0)
ORDER BY plpr.Plan_ukonceni DESC) AS T
)
) AS R
ORDER BY Datum DESC
))
) AS Mesic

FROM TabPlan WITH(NOLOCK)
LEFT OUTER JOIN TabKmenZbozi tkz WITH(NOLOCK) ON tkz.ID=TabPlan.IDTabKmen
LEFT OUTER JOIN TabKmenZbozi_EXT tkz_EXT WITH(NOLOCK) ON tkz_EXT.ID=tkz.ID
LEFT OUTER JOIN TabRadyPlanu rp WITH(NOLOCK) ON rp.Rada=TabPlan.Rada

WHERE
((TabPlan.InterniZaznam=0)AND(tkz_EXT._KvalDil IS NOT NULL)AND(tkz_EXT._KvalDil <> ''))
AND((TabPlan.uzavreno=0)AND(rp.ZahrnoutDoBilancovaniBudPoh=2))
AND(SELECT TOP 1 Datum FROM ((SELECT tpl.datum AS Datum FROM TabPlan tpl WHERE tpl.ID=TabPlan.ID)
UNION
(SELECT Datum FROM (SELECT TOP 1 tp.Plan_ukonceni AS Datum FROM TabPrikaz tp
WHERE(tp.ID IN (SELECT PrZ.IDPrikaz FROM TabPrikazZdrojVyrPlan PrZ WHERE PrZ.IDPlan=TabPlan.ID))AND(tp.StavPrikazu<=40)AND(tp.kusy_zive>0)
ORDER BY tp.Plan_ukonceni DESC) AS T)
UNION ALL
(SELECT Datum FROM (SELECT TOP 1 plpr.Plan_ukonceni AS Datum FROM TabPlanPrikaz plpr
LEFT OUTER JOIN TabPlan tpl ON tpl.ID=plpr.IDPlan WHERE (plpr.IDPlan=TabPlan.ID)AND(plpr.kusy_ciste>0)
ORDER BY plpr.Plan_ukonceni DESC) AS T)) AS R
ORDER BY Datum DESC
) BETWEEN (CONVERT(DATETIME,CONVERT(INT,CONVERT(FLOAT,GETDATE())))) AND (CONVERT(DATETIME,CONVERT(INT,CONVERT(FLOAT,GETDATE()+365)))))
INSERT INTO #TabCapacity (Kvaldil, CasPol, Mesic)
SELECT KvalDil, SUM(CasPol), Mesic
FROM PlanCap
GROUP BY Mesic, KvalDil
ORDER BY Mesic ASC, KvalDil ASC

--SELECT * FROM #TabCapacity
--ORDER BY Mesic ASC, KvalDil ASC

--přepsání hodnot dle HEO tabulky
--Kvaldil E =5
--Kvaldil K =2
--Kvaldil L =4
--Kvaldil M =3
--Kvaldil P =1
--Kvaldil S =2
UPDATE tc SET TypVyroby=1
FROM #TabCapacity tc
WHERE tc.Kvaldil='P'
UPDATE tc SET TypVyroby=2
FROM #TabCapacity tc
WHERE (tc.Kvaldil='K' OR tc.Kvaldil='S')
UPDATE tc SET TypVyroby=3
FROM #TabCapacity tc
WHERE tc.Kvaldil='M'
UPDATE tc SET TypVyroby=4
FROM #TabCapacity tc
WHERE tc.Kvaldil='L'
UPDATE tc SET TypVyroby=5
FROM #TabCapacity tc
WHERE tc.Kvaldil='E'

--smažeme přebytečné řádky
DELETE FROM #TabCapacity WHERE TypVyroby IS NULL
/*
SELECT * FROM #TabCapacity
--WHERE Mesic=10
ORDER BY Mesic ASC, TypVyroby ASC*/

INSERT INTO #TabCapacityVyp (CasPol,Mesic,TypVyroby)
SELECT SUM(CasPol), Mesic, TypVyroby
FROM #TabCapacity tc
GROUP BY Mesic, TypVyroby

--SELECT * FROM #TabCapacityVyp
--SELECT ParametrVypoctu, TypVyroby, Leden, Brezen, Rijen
--FROM Tabx_RS_PlanovaniKapacitVypocty

--nasypeme hodnoty zakázek
UPDATE pkv SET pkv.Leden=tc.CasPol
FROM Tabx_RS_PlanovaniKapacitVypocty pkv
LEFT OUTER JOIN #TabCapacityVyp tc ON tc.TypVyroby=pkv.TypVyroby
WHERE pkv.ParametrVypoctu=1 AND tc.Mesic=1
UPDATE pkv SET pkv.Unor=tc.CasPol
FROM Tabx_RS_PlanovaniKapacitVypocty pkv
LEFT OUTER JOIN #TabCapacityVyp tc ON tc.TypVyroby=pkv.TypVyroby
WHERE pkv.ParametrVypoctu=1 AND tc.Mesic=2
UPDATE pkv SET pkv.Brezen=tc.CasPol
FROM Tabx_RS_PlanovaniKapacitVypocty pkv
LEFT OUTER JOIN #TabCapacityVyp tc ON tc.TypVyroby=pkv.TypVyroby
WHERE pkv.ParametrVypoctu=1 AND tc.Mesic=3
UPDATE pkv SET pkv.Duben=tc.CasPol
FROM Tabx_RS_PlanovaniKapacitVypocty pkv
LEFT OUTER JOIN #TabCapacityVyp tc ON tc.TypVyroby=pkv.TypVyroby
WHERE pkv.ParametrVypoctu=1 AND tc.Mesic=4
UPDATE pkv SET pkv.Kveten=tc.CasPol
FROM Tabx_RS_PlanovaniKapacitVypocty pkv
LEFT OUTER JOIN #TabCapacityVyp tc ON tc.TypVyroby=pkv.TypVyroby
WHERE pkv.ParametrVypoctu=1 AND tc.Mesic=5
UPDATE pkv SET pkv.Cerven=tc.CasPol
FROM Tabx_RS_PlanovaniKapacitVypocty pkv
LEFT OUTER JOIN #TabCapacityVyp tc ON tc.TypVyroby=pkv.TypVyroby
WHERE pkv.ParametrVypoctu=1 AND tc.Mesic=6
UPDATE pkv SET pkv.Cervenec=tc.CasPol
FROM Tabx_RS_PlanovaniKapacitVypocty pkv
LEFT OUTER JOIN #TabCapacityVyp tc ON tc.TypVyroby=pkv.TypVyroby
WHERE pkv.ParametrVypoctu=1 AND tc.Mesic=7
UPDATE pkv SET pkv.Srpen=tc.CasPol
FROM Tabx_RS_PlanovaniKapacitVypocty pkv
LEFT OUTER JOIN #TabCapacityVyp tc ON tc.TypVyroby=pkv.TypVyroby
WHERE pkv.ParametrVypoctu=1 AND tc.Mesic=8
UPDATE pkv SET pkv.Zari=tc.CasPol
FROM Tabx_RS_PlanovaniKapacitVypocty pkv
LEFT OUTER JOIN #TabCapacityVyp tc ON tc.TypVyroby=pkv.TypVyroby
WHERE pkv.ParametrVypoctu=1 AND tc.Mesic=9
UPDATE pkv SET pkv.Rijen=tc.CasPol
FROM Tabx_RS_PlanovaniKapacitVypocty pkv
LEFT OUTER JOIN #TabCapacityVyp tc ON tc.TypVyroby=pkv.TypVyroby
WHERE pkv.ParametrVypoctu=1 AND tc.Mesic=10
UPDATE pkv SET pkv.Listopad=tc.CasPol
FROM Tabx_RS_PlanovaniKapacitVypocty pkv
LEFT OUTER JOIN #TabCapacityVyp tc ON tc.TypVyroby=pkv.TypVyroby
WHERE pkv.ParametrVypoctu=1 AND tc.Mesic=11
UPDATE pkv SET pkv.Prosinec=tc.CasPol
FROM Tabx_RS_PlanovaniKapacitVypocty pkv
LEFT OUTER JOIN #TabCapacityVyp tc ON tc.TypVyroby=pkv.TypVyroby
WHERE pkv.ParametrVypoctu=1 AND tc.Mesic=12

--vložení dat transponovaných do další tabulky pro PBI

DELETE FROM Tabx_RS_PlanovaniKapacitVypoctyTranspo
INSERT INTO Tabx_RS_PlanovaniKapacitVypoctyTranspo (MesicCislo,MesicNazev,KLLinkaZak,KLLinkaKap,KLKusovkaZak,KLKusovkaKap,KLMaketyZak,KLMaketyKap,EMLinkaZak,EMLinkaKap,EMKusovkaZak,EMKusovkaKap)
SELECT MesicCislo,Mesic,
  sum(case when TypVyroby = 1 AND ParametrVypoctu =1 then value else 0 end) KLLinkaZak,
  sum(case when TypVyroby = 1 AND ParametrVypoctu =2 then value else 0 end) KLLinkaKap,
  sum(case when TypVyroby = 2 AND ParametrVypoctu =1 then value else 0 end) KLKusovkaZak,
  sum(case when TypVyroby = 2 AND ParametrVypoctu =2 then value else 0 end) KLKusovkaKap,
  sum(case when TypVyroby = 3 AND ParametrVypoctu =1 then value else 0 end) KLMaketyZak,
  sum(case when TypVyroby = 3 AND ParametrVypoctu =2 then value else 0 end) KLMaketyKap,
  sum(case when TypVyroby = 4 AND ParametrVypoctu =1 then value else 0 end) EMLinkaZak,
  sum(case when TypVyroby = 4 AND ParametrVypoctu =2 then value else 0 end) EMLinkaKap,
  sum(case when TypVyroby = 5 AND ParametrVypoctu =1 then value else 0 end) EMKusovkaZak,
  sum(case when TypVyroby = 5 AND ParametrVypoctu =2 then value else 0 end) EMKusovkaKap
from
(
  select TypVyroby,ParametrVypoctu, Leden value, 'Leden' Mesic, 1 MesicCislo
  from Tabx_RS_PlanovaniKapacitVypocty
  union all
  select TypVyroby,ParametrVypoctu, Unor value, 'Unor' Mesic, 2 MesicCislo
  from Tabx_RS_PlanovaniKapacitVypocty
  union all
  select TypVyroby,ParametrVypoctu, Brezen value, 'Brezen' Mesic, 3 MesicCislo
  from Tabx_RS_PlanovaniKapacitVypocty
  union all
  select TypVyroby,ParametrVypoctu, Duben value, 'Duben' Mesic, 4 MesicCislo
  from Tabx_RS_PlanovaniKapacitVypocty
  union all
  select TypVyroby,ParametrVypoctu, Kveten value, 'Kveten' Mesic, 5 MesicCislo
  from Tabx_RS_PlanovaniKapacitVypocty
  union all
  select TypVyroby,ParametrVypoctu, Cerven value, 'Cerven' Mesic, 6 MesicCislo
  from Tabx_RS_PlanovaniKapacitVypocty
  union all
  select TypVyroby,ParametrVypoctu, Cervenec value, 'Cervenec' Mesic, 7 MesicCislo
  from Tabx_RS_PlanovaniKapacitVypocty
  union all
  select TypVyroby,ParametrVypoctu, Srpen value, 'Srpen' Mesic, 8 MesicCislo
  from Tabx_RS_PlanovaniKapacitVypocty
  union all
  select TypVyroby,ParametrVypoctu, Zari value, 'Zari' Mesic, 9 MesicCislo
  from Tabx_RS_PlanovaniKapacitVypocty
  union all
  select TypVyroby,ParametrVypoctu, Rijen value, 'Rijen' Mesic, 10 MesicCislo
  from Tabx_RS_PlanovaniKapacitVypocty
  union all
  select TypVyroby,ParametrVypoctu, Listopad value, 'Listopad' Mesic, 11 MesicCislo
  from Tabx_RS_PlanovaniKapacitVypocty
  union all
  select TypVyroby,ParametrVypoctu, Prosinec value, 'Prosinec' Mesic, 12 MesicCislo
  from Tabx_RS_PlanovaniKapacitVypocty
) src
group by Mesic,MesicCislo

SELECT TypVyroby,ParametrVypoctu,Leden,Unor,Brezen,Duben,Kveten,Cerven,Cervenec,Srpen,Zari,Rijen,Listopad,Prosinec
FROM Tabx_RS_PlanovaniKapacitVypocty

SELECT * FROM Tabx_RS_PlanovaniKapacitVypoctyTranspo
GO

