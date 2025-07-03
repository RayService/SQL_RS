USE [RayService]
GO

/****** Object:  View [dbo].[hvw_APSLogis_IN_MFGORDEROPERWIP]    Script Date: 03.07.2025 13:01:07 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO



CREATE VIEW [dbo].[hvw_APSLogis_IN_MFGORDEROPERWIP] AS SELECT 
  MFG_ORDER_ID = RTRIM(P.Rada)+N'|'+convert(nvarchar(10),P.Prikaz), 
  SEQUENCE_NUMBER = ISNULL(PrP1.OperaceX,0), 
  MATERIAL_ID = NULL, 
  ITEM_ID = KZN.SkupZbo+N'|'+KZN.RegCis, 
  WIP_IN_QUEUE = SUM(ISNULL(GEN.Mnoz,0)) 
FROM TabPrKVazby PrKV 
  INNER JOIN TabPrikaz P ON (P.ID=PrKV.IDPrikaz AND P.StavPrikazu IN (20,30,40)) 
  INNER JOIN TabKmenZbozi KZ ON (KZ.ID=P.IDTabKmen) 
  INNER JOIN TabSkupinyZbozi SZ ON (SZ.SkupZbo=KZ.SkupZbo) 
  LEFT OUTER JOIN TabSkupinyZbozi_Ext SZ_E ON (SZ_E.ID=SZ.ID) 
  INNER JOIN TabRadyPrikazu RP ON (RP.Rada=P.Rada) 
  LEFT OUTER JOIN TabRadyPrikazu_Ext RP_E ON (RP_E.ID=RP.ID) 
  INNER JOIN TabKmenZbozi KZN ON (KZN.ID=PrKV.nizsi) 
  INNER JOIN TabSkupinyZbozi SZN ON (SZN.SkupZbo=KZN.SkupZbo) 
  LEFT OUTER JOIN TabSkupinyZbozi_Ext SZN_E ON (SZN_E.ID=SZN.ID) 
  OUTER APPLY (SELECT TOP 1 OperaceX=ISNULL(PrP_E._EXT_RS_PoradiLogis, ISNULL(TRY_CONVERT(int,PrP.Operace),0)) FROM TabPrPostup PrP LEFT OUTER JOIN TabPrPostup_Ext PrP_E ON (PrP_E.ID=PrP.ID) WHERE PrP.IDPrikaz=PrKV.IDPrikaz AND PrP.prednastaveno=1 AND PrP.IDOdchylkyDo IS NULL AND PrP.Dilec=P.IDTabKmen AND PrP.Uzavreno=0 ORDER BY ISNULL(PrP_E._EXT_RS_PoradiLogis, ISNULL(TRY_CONVERT(int,PrP.Operace),0)) ASC) PrP1 
  OUTER APPLY (SELECT Mnoz=ISNULL(SUM(CASE WHEN PZ.druhPohybuZbo=3 THEN -1.0 ELSE 1.0 END * PZ.prepmnozstvi*(PZ.Mnozstvi-PZ.MnOdebrane)), 0.0) 
                 FROM TabPohybyZbozi PZ WITH (NOLOCK) 
                   INNER JOIN TabStavSkladu SS WITH (NOLOCK) ON (SS.ID=PZ.IDZboSklad) 
                   INNER JOIN TabDokladyZbozi DZ WITH (NOLOCK) ON (DZ.ID=PZ.IDDoklad AND DZ.splneno=0) 
                 WHERE PZ.druhPohybuZbo IN (2,3,4,9,10) AND PZ.Splneno=0 AND PZ.TypVyrobnihoDokladu=1 AND PZ.IDPrikaz=PrKV.IDPrikaz AND PZ.DokladPrikazu=PrKV.Doklad AND SS.IDKmenZbozi=PrKV.nizsi) GEN 
WHERE PrKV.Prednastaveno=1 AND PrKV.IDOdchylkyDo IS NULL AND PrKV.Vyssi=P.IDTabKmen AND PrKV.Uzavreno=0 AND PrKV.Sklad IS NOT NULL AND 
      (KZN.Material=1 AND KZN.RezijniMat=0 AND PrKV.RezijniMat=0 OR KZN.Dilec=1) AND 
      ISNULL(GEN.Mnoz,0)>0.0 AND 
      SZ_E._EXT_RS_Logis=1 AND SZN_E._EXT_RS_Logis=1 AND RP_E._EXT_RS_Logis=1 
      AND KZ.SkupZbo<>'932'
GROUP BY RTRIM(P.Rada)+N'|'+convert(nvarchar(10),P.Prikaz), 
         ISNULL(PrP1.OperaceX,0), 
         KZN.SkupZbo+N'|'+KZN.RegCis 
GO

