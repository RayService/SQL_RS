USE [RayService]
GO

/****** Object:  View [dbo].[hvw_8B36A3CEFE994866BC19631BEA2E8D6E]    Script Date: 03.07.2025 12:31:03 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

CREATE VIEW [dbo].[hvw_8B36A3CEFE994866BC19631BEA2E8D6E] AS (SELECT
PrKV.nizsi AS ID_nizsi
,PrKV.ID AS ID
,PrKV.IDPrikaz AS IDZdroj
,PrKV.IDPrikaz AS IDPrikaz
,PrKv.mnoz_Nevydane AS Mnozstvi_pozadavek
,0 AS Zdroj
,P.Plan_zadani AS Datum_plan
,P.Plan_zadani_X AS Datum_plan_X
,P.Plan_zadani_Y AS Datum_plan_Y
,P.Plan_zadani_Q AS Datum_plan_Q
,P.Plan_zadani_M AS Datum_plan_M
,P.Plan_zadani_W AS Datum_plan_T
,DATEPART(ISO_WEEK,P.Plan_zadani) AS Plan_zadani_TISO
,P.Plan_zadani_D AS Datum_plan_D
,PrKV.Sklad AS CisloSklad
,PrKV.mnoz_zad AS MnoZad
,PrKV.vyssi AS ID_vyssi
,PrKV.Poznamka AS Poznamka
	  ,(SUBSTRING(REPLACE(SUBSTRING(PrKV.Poznamka,1,255),(CHAR(13) + CHAR(10)),' '),1,255)) AS Poznamka_255
	  ,PrKV.Poznamka AS Poznamka_ALL
,KZN.SkupZbo AS SkupZbo
,KZN.RegCis AS RegCis
,KZN.Nazev1 AS Nazev1
,KZN.Nazev2 AS Nazev2
,KZN.SKP AS SKP
,tprkve._DatZajMat AS DatZajMat
,CASE WHEN DATEADD(dd, 0, DATEDIFF(dd, 0,tprkve._DatZajMat))=DATEADD(dd, 0, DATEDIFF(dd, 0, GETDATE())) THEN 0 ELSE NULL END AS StavPokryti
,PrKv.Cena_real AS Cena_real
,PrKv.DatPorizeni AS DatPorizeni
,PrKv.Autor AS Autor
      FROM TabPrKVazby PrKV WITH(NOLOCK) 
      INNER JOIN TabKmenZbozi KZN WITH(NOLOCK) ON KZN.ID=PrKV.nizsi
      INNER JOIN TabPrikaz P WITH(NOLOCK) ON P.ID=PrKV.IDPrikaz
      LEFT OUTER JOIN TabPrKVazby_EXT tprkve WITH(NOLOCK) ON tprkve.ID=PrKV.ID
      WHERE PrKv.mnoz_Nevydane>0 and 
            PrKV.Splneno=0 and
            PrKV.Prednastaveno=1 and
            PrKV.IDOdchylkyDo is null and
            P.StavPrikazu<=40)
UNION ALL
(SELECT
PPrKV.nizsi AS ID_nizsi
,PPrKV.ID AS ID
,PPrKV.IDPlan AS IDZdroj
,PPrKV.IDPlanPrikaz AS IDPrikaz
,PPrKV.mnoz_zad AS Mnozstvi_pozadavek
,1 AS Zdroj
,PP.Plan_zadani AS Datum_plan
,PP.Plan_zadani_X AS Datum_plan_X
,PP.Plan_zadani_Y AS Datum_plan_Y
,PP.Plan_zadani_Q AS Datum_plan_Q
,PP.Plan_zadani_M AS Datum_plan_M
,PP.Plan_zadani_W AS Datum_plan_T
,DATEPART(ISO_WEEK,PP.Plan_zadani) AS Plan_zadani_TISO
,PP.Plan_zadani_D AS Datum_plan_D
,PPrKV.Sklad AS CisloSklad
,PPrKV.mnoz_zad AS MnoZad
,PPrKV.vyssi AS ID_vyssi
,PPrKV.Poznamka AS Poznamka
	  ,(SUBSTRING(REPLACE(SUBSTRING(PPrKV.Poznamka,1,255),(CHAR(13) + CHAR(10)),' '),1,255)) AS Poznamka_255
	  ,PPrKV.Poznamka AS Poznamka_ALL
,KZN.SkupZbo AS SkupZbo
,KZN.RegCis AS RegCis
,KZN.Nazev1 AS Nazev1
,KZN.Nazev2 AS Nazev2
,KZN.SKP AS SKP
,tplprke._DatZajMat AS DatZajMat
,tplprke._KontrolaPokryti_Vysledek AS StavPokryti
,0 AS Cena_real
,PPrKv.DatPorizeni AS DatPorizeni
,PPrKv.Autor AS Autor
      FROM TabPlanPrKVazby PPrKV WITH(NOLOCK)
      INNER JOIN TabKmenZbozi KZN WITH(NOLOCK) ON KZN.ID=PPrKV.nizsi
      INNER JOIN TabPlanPrikaz PP WITH(NOLOCK) ON PP.ID=PPrKV.IDPlanPrikaz
      LEFT OUTER JOIN TabPlanPrKVazby_EXT tplprke WITH(NOLOCK) ON tplprke.ID=PPrKV.ID
--na chvíli přidávám
/*  LEFT OUTER JOIN TabPlan tp WITH(NOLOCK) ON tp.ID=PP.IDPlan
	  LEFT OUTER JOIN TabRadyPlanu trp ON trp.Rada=tp.Rada
	  WHERE (trp.ZahrnoutDoBilancovaniBudPoh=2) AND (KZN.SkupZbo NOT LIKE N'8%')*/
)
GO

