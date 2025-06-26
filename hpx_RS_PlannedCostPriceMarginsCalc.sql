USE [RayService]
GO

/****** Object:  StoredProcedure [dbo].[hpx_RS_PlannedCostPriceMarginsCalc]    Script Date: 26.06.2025 12:55:29 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

CREATE PROCEDURE [dbo].[hpx_RS_PlannedCostPriceMarginsCalc] @ID INT
AS
--cvičná deklarace
--DECLARE @ID INT=163234
--ostré deklarace
DECLARE @MnoPlan NUMERIC(19,6), @TotalCalcPrice NUMERIC(19,6), @BasicCalcPrice NUMERIC(19,6), @ObratPrice NUMERIC(19,6), @CisloZakazky NVARCHAR(15), @Dilec INT, @Price NUMERIC(19,6), @OVD NUMERIC(19,6), @Price2 NUMERIC(19,6), @RadaPl NVARCHAR(10);
--zjištění proměnných
SELECT @MnoPlan=mnozstvi, @CisloZakazky=tz.CisloZakazky, /*@TotalCalcPrice=ISNULL(RScal.Celkem,0),*/ @Dilec=tp.IDTabKmen, @RadaPl=tp.Rada
FROM TabPlan tp WITH(NOLOCK)
LEFT OUTER JOIN TabZakazka tz WITH(NOLOCK) ON tz.ID=tp.IDZakazka
--LEFT OUTER JOIN Tabx_RS_ZKalkulace RScal WITH(NOLOCK) ON RScal.Dilec=tp.IDTabKmen AND RScal.CisloZakazky=tz.CisloZakazky
WHERE tp.ID=@ID

SET @OVD=(SELECT ISNULL(td.davka,1)
FROM TabKmenZbozi tkz
LEFT OUTER JOIN TabDavka td ON td.IDDilce=tkz.IDKusovnik AND EXISTS(SELECT * FROM TabCZmeny Zod 
																	LEFT OUTER JOIN TabCZmeny Zdo ON (ZDo.ID=td.zmenaDo)
																	WHERE Zod.ID=td.zmenaOd AND Zod.platnostTPV=1 AND Zod.datum<=GETDATE() 
																	AND (td.ZmenaDo IS NULL OR Zdo.platnostTPV=0 OR (ZDo.platnostTPV=1 AND ZDo.datum>GETDATE())))
WHERE (tkz.ID = @Dilec))

SET @BasicCalcPrice=(SELECT ISNULL(tzk.Celkem,0)
FROM TabZKalkulace tzk
  LEFT OUTER JOIN TabCzmeny tczOd ON tzk.ZmenaOd=tczOd.ID
  LEFT OUTER JOIN TabCzmeny tczDo ON tzk.ZmenaDo=tczDo.ID
  LEFT OUTER JOIN TabKmenZbozi tkz ON tzk.Dilec=tkz.ID
WHERE
(((tczOd.platnostTPV=1 AND tczOd.datum<=GETDATE()))
AND(((tczDo.platnostTPV=0 OR tzk.ZmenaDo IS NULL OR (tczDo.platnostTPV=1 AND tczDo.datum>GETDATE())) ))
AND(tkz.ID=@Dilec)))

SET @ObratPrice=(SELECT ISNULL((SELECT CASE WHEN
(SELECT TP.mnozstvi * AVG(PZ.JCBezDaniKC)
FROM TabPlan TP WITH(NOLOCK)
INNER JOIN TabPlanZdrojOZ TPZ ON TPZ.IDPlan = TP.ID
JOIN TabPohybyZbozi PZ WITH(NOLOCK) ON TPZ.IDRezervace = PZ.ID
JOIN TabDokladyZbozi TD WITH(NOLOCK) ON TD.ID = PZ.IDDoklad
WHERE TP.ID = @ID
GROUP BY TP.ID, TP.mnozstvi) IS NULL
THEN
CASE WHEN (SELECT tkz.SkupZbo
FROM TabPlan tpl
LEFT OUTER JOIN TabKmenZbozi tkz ON tkz.ID=tpl.IDTabKmen
WHERE tpl.ID = @ID)='830'
THEN
(SELECT SUM(tppp.Kusy_zad * tppp.TAC_S / 3600.0)*6900/*zde pro SK 830*/
FROM TabPlan tp WITH(NOLOCK)
  LEFT OUTER JOIN TabPlanPrikaz tpp WITH(NOLOCK) ON tpp.IDPlan = tp.ID
  LEFT OUTER JOIN TabPlanPrPostup tppp WITH(NOLOCK) ON tppp.IDPlanPrikaz = tpp.ID
  LEFT OUTER JOIN TabCPraco tcp WITH(NOLOCK) ON tppp.Pracoviste=tcp.ID
WHERE tcp.IDTabStrom = '200' AND tp.ID = @ID)
ELSE
(SELECT SUM(tppp.Kusy_zad * tppp.TAC_S / 3600.0)*1901/*zde pro SK ostatní*/
FROM TabPlan tp WITH(NOLOCK)
  LEFT OUTER JOIN TabPlanPrikaz tpp WITH(NOLOCK) ON tpp.IDPlan = tp.ID
  LEFT OUTER JOIN TabPlanPrPostup tppp WITH(NOLOCK) ON tppp.IDPlanPrikaz = tpp.ID
  LEFT OUTER JOIN TabCPraco tcp WITH(NOLOCK) ON tppp.Pracoviste=tcp.ID
WHERE tcp.IDTabStrom = '200' AND tp.ID = @ID) END
ELSE
(SELECT TP.mnozstvi * AVG(PZ.JCBezDaniKC)
FROM TabPlan TP WITH(NOLOCK)
INNER JOIN TabPlanZdrojOZ TPZ ON TPZ.IDPlan = TP.ID
JOIN TabPohybyZbozi PZ WITH(NOLOCK) ON TPZ.IDRezervace = PZ.ID
JOIN TabDokladyZbozi TD WITH(NOLOCK) ON TD.ID = PZ.IDDoklad
WHERE TP.ID = @ID
GROUP BY TP.ID, TP.mnozstvi)
END),0))

/*
IF @TotalCalcPrice <> 0 SET @Price=@MnoPlan*@TotalCalcPrice
IF @TotalCalcPrice = 0 AND @BasicCalcPrice <> 0 SET @Price=@MnoPlan*@BasicCalcPrice
IF @TotalCalcPrice = 0 AND @BasicCalcPrice <> 0 AND @BasicCalcPrice=0 SET @Price=@ObratPrice/1.48
*/
--plánované položky 1
BEGIN
IF @BasicCalcPrice <> 0 SET @Price=@MnoPlan*@BasicCalcPrice*(1+((@OVD*0.1)/@MnoPlan))
IF @BasicCalcPrice=0 SET @Price=@ObratPrice/1.48

SELECT @ID AS IDPlan, @BasicCalcPrice AS 'Cena základní kalkulace', @ObratPrice AS 'Obrat položky', @Price AS 'Plánovaná nákl.cena položky', @ObratPrice-@Price AS 'Plánovaná marže položky', @OVD AS 'Opt.výr.dávka', @MnoPlan AS Mnoztsvi

BEGIN TRANSACTION;
UPDATE tpe WITH (UPDLOCK, SERIALIZABLE) SET _EXT_RS_PlanCostPriceItem = @Price, _EXT_RS_PlanMarginItem=@ObratPrice-@Price
FROM dbo.TabPlan tp
LEFT OUTER JOIN dbo.TabPlan_EXT tpe ON tpe.ID=tp.ID
WHERE tp.ID=@ID;
IF @@ROWCOUNT = 0
BEGIN
  INSERT dbo.TabPlan_EXT(ID,_EXT_RS_PlanCostPriceItem,_EXT_RS_PlanMarginItem) VALUES(@ID, @Price, @ObratPrice-@Price);
END
COMMIT TRANSACTION;
END;

--plánované položky 2
BEGIN
IF @BasicCalcPrice <> 0 SET @Price2=@MnoPlan*@BasicCalcPrice
IF @BasicCalcPrice=0 OR @RadaPl LIKE N'PT%' SET @Price2=@ObratPrice/1.48

SELECT @ID AS IDPlan, @BasicCalcPrice AS 'Cena základní kalkulace', @ObratPrice AS 'Obrat položky', @Price2 AS 'Plánovaná nákl.cena položky 2', @ObratPrice-@Price2 AS 'Plánovaná marže položky 2', @OVD AS 'Opt.výr.dávka', @MnoPlan AS Mnoztsvi

BEGIN TRANSACTION;
UPDATE tpe WITH (UPDLOCK, SERIALIZABLE) SET _EXT_RS_PlanCostPriceItem2 = @Price2, _EXT_RS_PlanMarginItem2=@ObratPrice-@Price2
FROM dbo.TabPlan tp
LEFT OUTER JOIN dbo.TabPlan_EXT tpe ON tpe.ID=tp.ID
WHERE tp.ID=@ID;
IF @@ROWCOUNT = 0
BEGIN
  INSERT dbo.TabPlan_EXT(ID,_EXT_RS_PlanCostPriceItem2,_EXT_RS_PlanMarginItem2) VALUES(@ID, @Price2, @ObratPrice-@Price2);
END
COMMIT TRANSACTION;
END;
GO

