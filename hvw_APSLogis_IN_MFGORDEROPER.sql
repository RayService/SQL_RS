USE [RayService]
GO

/****** Object:  View [dbo].[hvw_APSLogis_IN_MFGORDEROPER]    Script Date: 03.07.2025 13:00:37 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO








CREATE VIEW [dbo].[hvw_APSLogis_IN_MFGORDEROPER] AS

WITH OPER AS (
SELECT 
  MFG_ORDER_ID =RTRIM(P.Rada)+N'|'+convert(nvarchar(10),P.Prikaz), 
  SEQUENCE_NUMBER =ISNULL(PrP_E._EXT_RS_PoradiLogis, ISNULL(TRY_CONVERT(int,PrP.Operace),0)), 
  OPERATION_STATUS =CASE WHEN PrP.Splneno=1 THEN N'COMPLETE' END, 
  QTY_IN_QUEUE = CASE WHEN NOT EXISTS(SELECT * FROM TabPrKVazby PrKV WHERE PrKV.IDPrikaz=P.ID AND PrKV.IDOdchylkyDo IS NULL AND PrKV.Vyssi=P.IDTabKmen AND PrKV.Uzavreno=0) AND 
                           NOT EXISTS(SELECT * FROM TabPrPostup PrP2 WHERE PrP2.IDPrikaz=P.ID AND PrP2.Prednastaveno=1 AND PrP2.IDOdchylkyDo IS NULL AND PrP2.dilec=P.IDTabKmen AND PrP2.Uzavreno=0 AND PrP2.operace<PrP.operace) AND 
                           PrP.Splneno=0 
                        THEN PrP.KusyPredOperaci END, 
  QTY_IN_MOVE = PrP_E._APSLogis_QTY_IN_MOVE, 
  QTY_PRODUCED = PrP.Kusy_real+PrP.Kusy_zmet+PrP.Kusy_zmet_neopr, 
  CRT=/*CASE WHEN PrP.typ=2 THEN (SELECT MAX(ISNULL(PKO.PotvrzTerDod_X, ISNULL(PKO.PozadTerDod_X, ISNULL(KO.PotvrzTerDod_X, KO.PozadTerDod_X)))) 
                                                FROM TabPolKoopObj PKO 
                                                  INNER JOIN TabKoopObj KO ON (KO.ID=PKO.IDObjednavky AND KO.Splneno=0) 
                                                WHERE PKO.IDPrikaz=PrP.IDPrikaz AND PKO.DokladPrPostup=PrP.Doklad AND PKO.AltPrPostup=PrP.Alt AND PKO.Splneno=0) 
      END,*/
      CASE WHEN PrP.typ=2 THEN (CASE WHEN (SELECT MAX(PKO.PotvrzTerDod_X) FROM TabPolKoopObj PKO 
                                                  INNER JOIN TabKoopObj KO ON (KO.ID=PKO.IDObjednavky AND KO.Splneno=0) 
                                                WHERE PKO.IDPrikaz=PrP.IDPrikaz AND PKO.DokladPrPostup=PrP.Doklad AND PKO.AltPrPostup=PrP.Alt AND PKO.Splneno=0) IS NOT NULL
                                                THEN (SELECT MAX(PKO.PotvrzTerDod_X) FROM TabPolKoopObj PKO 
                                                  INNER JOIN TabKoopObj KO ON (KO.ID=PKO.IDObjednavky AND KO.Splneno=0)
                                                  WHERE PKO.IDPrikaz=PrP.IDPrikaz AND PKO.DokladPrPostup=PrP.Doklad AND PKO.AltPrPostup=PrP.Alt AND PKO.Splneno=0)
                                                  --ELSE GETDATE()+ISNULL(PrP.Koop_DobaZpracDavky,0) END)  --MŽ, 26.6.2025 na základě porady LPP vypnuto dotažení dnes plus doba zpracování dávky
                                                  ELSE NULL END)
      END,
  RESOURCE_NAME=CASE WHEN PrP.typ=2 THEN N'K_'+CK.Rada+N'|'+CK.kod END,
  PLANNED_BATCH_ID=(SELECT N'B'+convert(nvarchar(10),MAX(SOR.IDSdruzVyrOperace)) FROM TabSdruzVyrOperaceR SOR WHERE SOR.IDPrikaz=PrP.IDPrikaz AND SOR.Doklad=PrP.Doklad AND SOR.Alt=PrP.Alt AND PrP.Typ<2), 
  OP_HOLD_END_DATE=CASE WHEN P.StavPrikazu=40 THEN convert(date,GETDATE()+90) END, 
  IDHeKey=PrP.ID1 
FROM TabPrikaz P 
  INNER JOIN TabKmenZbozi KZV ON (KZV.ID=P.IDTabKmen) 
  INNER JOIN TabSkupinyZbozi SZ ON (SZ.SkupZbo=KZV.SkupZbo) 
  LEFT OUTER JOIN TabSkupinyZbozi_Ext SZ_E ON (SZ_E.ID=SZ.ID) 
  INNER JOIN TabRadyPrikazu RP ON (RP.Rada=P.Rada) 
  LEFT OUTER JOIN TabRadyPrikazu_Ext RP_E ON (RP_E.ID=RP.ID) 
  INNER JOIN TabPrPostup PrP ON (PrP.IDPrikaz=P.ID AND PrP.Prednastaveno=1 AND PrP.IDOdchylkyDo IS NULL AND PrP.dilec=P.IDTabKmen AND PrP.Uzavreno=0) 
  LEFT OUTER JOIN TabPrPostup_Ext PrP_E ON (PrP_E.ID=PrP.ID) 
  LEFT OUTER JOIN TabCKoop CK ON (PrP.typ=2 AND CK.ID=PrP.IDkooperace) 
WHERE P.StavPrikazu IN (20,30,40) AND 
      SZ_E._EXT_RS_Logis=1 AND RP_E._EXT_RS_Logis=1 AND (PrP.Pracoviste IS NULL OR (PrP.Pracoviste<>164 AND PrP.Pracoviste<>51))
      AND KZV.SkupZbo<>'932'
)
SELECT
OPER.MFG_ORDER_ID,
OPER.SEQUENCE_NUMBER,
OPER.OPERATION_STATUS, 
CASE WHEN (CASE WHEN (CRT IS NOT NULL AND RESOURCE_NAME LIKE '%koop%') THEN LAG(QTY_IN_MOVE) OVER (PARTITION BY MFG_ORDER_ID ORDER BY MFG_ORDER_ID ASC, SEQUENCE_NUMBER ASC) ELSE NULL END) IS NULL THEN QTY_IN_QUEUE ELSE (CASE WHEN (CRT IS NOT NULL AND RESOURCE_NAME LIKE '%koop%') THEN LAG(QTY_IN_MOVE) OVER (PARTITION BY MFG_ORDER_ID ORDER BY MFG_ORDER_ID ASC, SEQUENCE_NUMBER ASC) ELSE NULL END) END AS QTY_IN_QUEUE,
CASE WHEN (CASE WHEN LEAD(CRT) OVER (PARTITION BY MFG_ORDER_ID ORDER BY MFG_ORDER_ID ASC, SEQUENCE_NUMBER ASC) IS NOT NULL THEN CASE WHEN LEAD(RESOURCE_NAME) OVER (PARTITION BY MFG_ORDER_ID ORDER BY MFG_ORDER_ID ASC, SEQUENCE_NUMBER ASC) IS NOT NULL THEN 1 ELSE NULL END
ELSE NULL END)=1 THEN NULL ELSE QTY_IN_MOVE END AS QTY_IN_MOVE,
QTY_PRODUCED,
CRT,
RESOURCE_NAME,
PLANNED_BATCH_ID,
OP_HOLD_END_DATE,
IDHeKey
FROM OPER



/*
CREATE VIEW [dbo].[hvw_APSLogis_IN_MFGORDEROPER] AS SELECT 
  MFG_ORDER_ID =RTRIM(P.Rada)+N'|'+convert(nvarchar(10),P.Prikaz), 
  SEQUENCE_NUMBER =ISNULL(PrP_E._EXT_RS_PoradiLogis, ISNULL(TRY_CONVERT(int,PrP.Operace),0)), 
  OPERATION_STATUS =CASE WHEN PrP.Splneno=1 THEN N'COMPLETE' END, 
  QTY_IN_QUEUE = CASE WHEN NOT EXISTS(SELECT * FROM TabPrKVazby PrKV WHERE PrKV.IDPrikaz=P.ID AND PrKV.IDOdchylkyDo IS NULL AND PrKV.Vyssi=P.IDTabKmen AND PrKV.Uzavreno=0) AND 
                           NOT EXISTS(SELECT * FROM TabPrPostup PrP2 WHERE PrP2.IDPrikaz=P.ID AND PrP2.Prednastaveno=1 AND PrP2.IDOdchylkyDo IS NULL AND PrP2.dilec=P.IDTabKmen AND PrP2.Uzavreno=0 AND PrP2.operace<PrP.operace) AND 
                           PrP.Splneno=0 
                        THEN PrP.KusyPredOperaci END, 
  QTY_IN_MOVE = PrP_E._APSLogis_QTY_IN_MOVE, 
  QTY_PRODUCED = PrP.Kusy_real+PrP.Kusy_zmet+PrP.Kusy_zmet_neopr, 
  CRT=CASE WHEN PrP.typ=2 THEN (SELECT MAX(ISNULL(PKO.PotvrzTerDod_X, ISNULL(PKO.PozadTerDod_X, ISNULL(KO.PotvrzTerDod_X, KO.PozadTerDod_X)))) 
                                                FROM TabPolKoopObj PKO 
                                                  INNER JOIN TabKoopObj KO ON (KO.ID=PKO.IDObjednavky AND KO.Splneno=0) 
                                                WHERE PKO.IDPrikaz=PrP.IDPrikaz AND PKO.DokladPrPostup=PrP.Doklad AND PKO.AltPrPostup=PrP.Alt AND PKO.Splneno=0) 
      END, 
  RESOURCE_NAME=CASE WHEN PrP.typ=2 THEN N'K_'+CK.Rada+N'|'+CK.kod END, 
  PLANNED_BATCH_ID=(SELECT N'B'+convert(nvarchar(10),MAX(SOR.IDSdruzVyrOperace)) FROM TabSdruzVyrOperaceR SOR WHERE SOR.IDPrikaz=PrP.IDPrikaz AND SOR.Doklad=PrP.Doklad AND SOR.Alt=PrP.Alt AND PrP.Typ<2), 
  OP_HOLD_END_DATE=CASE WHEN P.StavPrikazu=40 THEN convert(date,GETDATE()+90) END, 
  IDHeKey=PrP.ID1 
FROM TabPrikaz P 
  INNER JOIN TabKmenZbozi KZV ON (KZV.ID=P.IDTabKmen) 
  INNER JOIN TabSkupinyZbozi SZ ON (SZ.SkupZbo=KZV.SkupZbo) 
  LEFT OUTER JOIN TabSkupinyZbozi_Ext SZ_E ON (SZ_E.ID=SZ.ID) 
  INNER JOIN TabRadyPrikazu RP ON (RP.Rada=P.Rada) 
  LEFT OUTER JOIN TabRadyPrikazu_Ext RP_E ON (RP_E.ID=RP.ID) 
  INNER JOIN TabPrPostup PrP ON (PrP.IDPrikaz=P.ID AND PrP.Prednastaveno=1 AND PrP.IDOdchylkyDo IS NULL AND PrP.dilec=P.IDTabKmen AND PrP.Uzavreno=0) 
  LEFT OUTER JOIN TabPrPostup_Ext PrP_E ON (PrP_E.ID=PrP.ID) 
  LEFT OUTER JOIN TabCKoop CK ON (PrP.typ=2 AND CK.ID=PrP.IDkooperace) 
WHERE P.StavPrikazu IN (20,30,40) AND 
      SZ_E._EXT_RS_Logis=1 AND RP_E._EXT_RS_Logis=1 AND (PrP.Pracoviste IS NULL OR (PrP.Pracoviste<>164 AND PrP.Pracoviste<>51)) 
GO

*/
GO

