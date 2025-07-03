USE [RayService]
GO

/****** Object:  View [dbo].[hvw_6DA8931F5631466D9FAEA3936EB769A0]    Script Date: 03.07.2025 11:18:30 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

CREATE VIEW [dbo].[hvw_6DA8931F5631466D9FAEA3936EB769A0] AS (SELECT
PrKV.nizsi AS ID_nizsi
,PrKV.ID AS ID_vazba
,PrKV.IDPrikaz AS IDPrikaz
,PrKv.mnoz_Nevydane AS Mnozstvi_pozadavek
,0 AS Zdroj
,P.Plan_zadani AS Datum_plan
,tprkve._DatZajMat AS DatumZajisteni
,PrKV.Sklad AS CisloSklad
,PrKV.mnoz_zad AS MnoZad
,PrKV.vyssi AS ID_vyssi
      FROM TabPrKVazby PrKV WITH(NOLOCK) 
      INNER JOIN TabKmenZbozi KZ WITH(NOLOCK) ON KZ.ID=PrKV.nizsi
      INNER JOIN TabPrikaz P WITH(NOLOCK) ON P.ID=PrKV.IDPrikaz
	  LEFT OUTER JOIN TabPrKVazby_EXT tprkve WITH(NOLOCK) ON tprkve.ID=PrKV.ID
      WHERE PrKv.mnoz_Nevydane>0 and 
            PrKV.Splneno=0 and
            PrKV.Prednastaveno=1 and
            PrKV.IDOdchylkyDo is null and
            KZ.SkupZbo NOT IN (N'800',N'850',N'666',N'870') and 
            KZ.Material=1 and
            P.StavPrikazu<=40)
UNION ALL
(SELECT
PPrKV.nizsi AS ID_nizsi
,PPrKV.ID AS ID_vazba
,PPrKV.IDPlanPrikaz AS IDPrikaz
,PPrKV.mnoz_zad AS Mnozstvi_pozadavek
,1 AS Zdroj
,PP.Plan_zadani AS Datum_plan
,tplprke._DatZajMat AS DatumZajisteni
,PPrKV.Sklad AS CisloSklad
,PPrKV.mnoz_zad AS MnoZad
,PPrKV.vyssi AS ID_vyssi
      FROM TabPlanPrKVazby PPrKV WITH(NOLOCK)
      INNER JOIN TabKmenZbozi KZ WITH(NOLOCK) ON KZ.ID=PPrKV.nizsi
      INNER JOIN TabPlanPrikaz PP WITH(NOLOCK) ON PP.ID=PPrKV.IDPlanPrikaz
	  LEFT OUTER JOIN TabPlanPrKVazby_EXT tplprke WITH(NOLOCK) ON tplprke.ID=PPrKV.ID
      WHERE PPrKV.mnoz_zad>0 and             
            KZ.SkupZbo NOT IN (N'800',N'850',N'666',N'870') and 
            KZ.Material=1)
UNION ALL
(SELECT
PrKV.nizsi AS ID_nizsi
,PrKV.ID AS ID_vazba
,PrKV.IDPrikaz AS IDPrikaz
,PrKv.mnoz_Nevydane AS Mnozstvi_pozadavek
,0 AS Zdroj
,P.Plan_zadani AS Datum_plan
,tprkve._DatZajMat AS DatumZajisteni
,PrKV.Sklad AS CisloSklad
,PrKV.mnoz_zad AS MnoZad
,PrKV.vyssi AS ID_vyssi
      FROM TabPrKVazby PrKV WITH(NOLOCK)
      INNER JOIN TabKmenZbozi KZ WITH(NOLOCK) ON KZ.ID=PrKV.nizsi
      LEFT OUTER JOIN TabSortiment SOT WITH(NOLOCK) ON KZ.IdSortiment = SOT.ID
      INNER JOIN TabPrikaz P ON P.ID=PrKV.IDPrikaz
	  LEFT OUTER JOIN TabPrKVazby_EXT tprkve WITH(NOLOCK) ON tprkve.ID=PrKV.ID
      WHERE PrKv.mnoz_Nevydane>0 and 
            PrKV.Splneno=0 and
            PrKV.Prednastaveno=1 and
            PrKV.IDOdchylkyDo is NULL and
            KZ.Dilec=1 and
			SOT.K1= N'VD' AND
            P.StavPrikazu<=40)
UNION ALL
(SELECT
PPrKV.nizsi AS ID_nizsi
,PPrKV.ID AS ID_vazba
,PPrKV.IDPlanPrikaz AS IDPrikaz
,PPrKV.mnoz_zad AS Mnozstvi_pozadavek
,1 AS Zdroj
,PP.Plan_zadani AS Datum_plan
,tplprke._DatZajMat AS DatumZajisteni
,PPrKV.Sklad AS CisloSklad
,PPrKV.mnoz_zad AS MnoZad
,PPrKV.vyssi AS ID_vyssi
      FROM TabPlanPrKVazby PPrKV WITH(NOLOCK)
      INNER JOIN TabKmenZbozi KZ WITH(NOLOCK) ON KZ.ID=PPrKV.nizsi
      INNER JOIN TabPlanPrikaz PP WITH(NOLOCK) ON PP.ID=PPrKV.IDPlanPrikaz
      LEFT OUTER JOIN TabSortiment SOT WITH(NOLOCK) ON KZ.IdSortiment = SOT.ID
	  LEFT OUTER JOIN TabPlanPrKVazby_EXT tplprke WITH(NOLOCK) ON tplprke.ID=PPrKV.ID
      WHERE PPrKV.mnoz_zad>0 and             
            KZ.Dilec=1)
UNION ALL
(SELECT
tkz.ID AS ID_nizsi
, tpz.ID AS ID_vazba
,tdz.ID AS IDPrikaz
,(tpz.Mnozstvi-tpz.MnOdebrane-tpz.MnozstviStorno) AS Mnozstvi_pozadavek
,2 AS Zdroj
,ISNULL(tpze._dat_dod,tpz.PotvrzDatDod) AS Datum_plan
,0 AS Datum_zajisteni
,tss.IDSklad AS CisloSklad
,tpz.Mnozstvi AS MnoZad
,0 AS ID_vyssi
FROM TabPohybyZbozi tpz
LEFT OUTER JOIN TabPohybyZbozi_EXT tpze ON tpze.ID=tpz.ID
LEFT OUTER JOIN TabDokladyZbozi tdz ON tdz.ID=tpz.IDDoklad
LEFT OUTER JOIN TabStavSkladu tss ON tpz.IDZboSklad=tss.ID
LEFT OUTER JOIN TabKmenZbozi tkz ON tkz.ID=(SELECT TabStavSkladu.IDKmenZbozi FROM TabStavSkladu WHERE TabStavSkladu.ID=tpz.IDZboSklad)
WHERE ISNULL(tpze._dat_dod,tpz.PotvrzDatDod) IS NOT NULL 
AND tdz.DruhPohybuZbo=9 
AND tdz.Splneno<>1
AND tss.IDSklad='100'
AND (tpz.Mnozstvi-tpz.MnOdebrane-tpz.MnozstviStorno)>0
AND tpz.SkupZbo NOT LIKE '9%'
AND tkz.Material=1)
GO

