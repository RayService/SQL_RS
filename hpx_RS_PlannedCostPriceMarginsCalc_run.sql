USE [RayService]
GO

/****** Object:  StoredProcedure [dbo].[hpx_RS_PlannedCostPriceMarginsCalc_run]    Script Date: 26.06.2025 12:57:30 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

CREATE PROCEDURE [dbo].[hpx_RS_PlannedCostPriceMarginsCalc_run]
AS

IF (OBJECT_ID('tempdb..#Temp') IS NOT NULL)
BEGIN
DROP TABLE #Temp
END;
CREATE TABLE #Temp 
( [ID] INT IDENTITY (1,1) PRIMARY KEY,
  [IDPlan] [INT]
)

INSERT INTO #Temp (IDPlan)
SELECT
TabPlan.ID
FROM TabPlan
  LEFT OUTER JOIN TabKmenZbozi VPlanKmenZbozi ON VPlanKmenZbozi.ID=TabPlan.IDTabKmen
  LEFT OUTER JOIN TabZakazka VPlanZakazka ON VPlanZakazka.ID=TabPlan.IDZakazka
WHERE
((TabPlan.InterniZaznam=0)AND((
(
SELECT
CASE
WHEN
(SELECT TP.mnozstvi * AVG(PZ.JCBezDaniKC)
FROM TabPlan TP WITH(NOLOCK)
INNER JOIN TabPlanZdrojOZ TPZ ON TPZ.IDPlan = TP.ID
JOIN TabPohybyZbozi PZ WITH(NOLOCK) ON TPZ.IDRezervace = PZ.ID
JOIN TabDokladyZbozi TD WITH(NOLOCK) ON TD.ID = PZ.IDDoklad
WHERE TP.ID = TabPlan.ID
GROUP BY TP.ID, TP.mnozstvi) IS NULL
THEN
CASE WHEN (SELECT tkz.SkupZbo
FROM TabPlan tpl
LEFT OUTER JOIN TabKmenZbozi tkz ON tkz.ID=tpl.IDTabKmen
WHERE tpl.ID = TabPlan.ID)='830'
THEN
(SELECT
SUM(tppp.Kusy_zad * tppp.TAC_S / 3600.0)*6900/*zde pro SK 830*/
FROM TabPlan tp WITH(NOLOCK)
  LEFT OUTER JOIN TabPlanPrikaz tpp WITH(NOLOCK) ON tpp.IDPlan = tp.ID
  LEFT OUTER JOIN TabPlanPrPostup tppp WITH(NOLOCK) ON tppp.IDPlanPrikaz = tpp.ID
  LEFT OUTER JOIN TabCPraco tcp WITH(NOLOCK) ON tppp.Pracoviste=tcp.ID
WHERE tcp.IDTabStrom = '200' AND tp.ID = TabPlan.ID)
ELSE
(SELECT
SUM(tppp.Kusy_zad * tppp.TAC_S / 3600.0)*1901/*zde pro SK ostatní*/
FROM TabPlan tp WITH(NOLOCK)
  LEFT OUTER JOIN TabPlanPrikaz tpp WITH(NOLOCK) ON tpp.IDPlan = tp.ID
  LEFT OUTER JOIN TabPlanPrPostup tppp WITH(NOLOCK) ON tppp.IDPlanPrikaz = tpp.ID
  LEFT OUTER JOIN TabCPraco tcp WITH(NOLOCK) ON tppp.Pracoviste=tcp.ID
WHERE tcp.IDTabStrom = '200' AND tp.ID = TabPlan.ID) END
ELSE
(SELECT TP.mnozstvi * AVG(PZ.JCBezDaniKC)
FROM TabPlan TP WITH(NOLOCK)
INNER JOIN TabPlanZdrojOZ TPZ ON TPZ.IDPlan = TP.ID
JOIN TabPohybyZbozi PZ WITH(NOLOCK) ON TPZ.IDRezervace = PZ.ID
JOIN TabDokladyZbozi TD WITH(NOLOCK) ON TD.ID = PZ.IDDoklad
WHERE TP.ID = TabPlan.ID
GROUP BY TP.ID, TP.mnozstvi)
END
))>0))
AND((TabPlan.Rada<>N'P_Gen')AND(TabPlan.Rada<>N'PT_Burza'))
AND(TabPlan.Datum>'20220101 23:59:59.997')


DECLARE @IDGen INT;
DECLARE CurCalcPrice CURSOR LOCAL FAST_FORWARD FOR
SELECT IDPlan FROM #Temp
OPEN CurCalcPrice;
FETCH NEXT FROM CurCalcPrice INTO @IDGen;
	WHILE (@@FETCH_STATUS = 0) AND (@@ERROR = 0)
	BEGIN

	EXEC dbo.hpx_RS_PlannedCostPriceMarginsCalc @ID=@IDGen

	FETCH NEXT FROM CurCalcPrice INTO @IDGen;
	END;
CLOSE CurCalcPrice;
DEALLOCATE CurCalcPrice;
GO

