USE [RayService]
GO

/****** Object:  View [dbo].[hvw_APSLogis_IN_BOMCOMPONENT]    Script Date: 03.07.2025 12:52:46 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO




CREATE VIEW [dbo].[hvw_APSLogis_IN_BOMCOMPONENT] AS 
WITH BOM AS (SELECT 
  BOM_ID = KZV.SkupZbo+N'|'+KZV.RegCis, 
  ITEM_ID = KZN.SkupZbo+N'|'+KZN.RegCis, 
  QUANTITY= SUM(KV.mnozstviSeZtratou/KV.DavkaTPV), 
  ROUTING_NAME=CASE WHEN EXISTS(SELECT * FROM TabPostup P WHERE P.Dilec=MIN(KV.vyssi) AND P.ZmenaOd IS NOT NULL AND P.ZmenaDo IS NULL) THEN KZV.SkupZbo+N'|'+KZV.RegCis END, 
  SEQUENCE_NUMBER=CASE WHEN PD.RadaVyrPrikazu=N'803' THEN TRY_CONVERT(int,KV.Operace)
  ELSE (SELECT MIN(ISNULL(TRY_CONVERT(int,P.Operace),0)) FROM TabPostup P WHERE P.Dilec=MIN(KV.vyssi) AND P.ZmenaOd IS NOT NULL AND P.ZmenaDo IS NULL) END, 
  MAIN_MATERIAL=0, 
  SUBSTITUTED_ITEM_ID=NULL, 
  FIXED_QUANTITY=SUM(KV.FixniMnozstvi), 
  IDHeKey_TypeS=N'KV' 
FROM TabKVazby KV 
  INNER JOIN TabCzmeny ZOd ON (ZOd.ID=KV.ZmenaOd) 
  LEFT OUTER JOIN TabCzmeny ZDo ON (ZDo.ID=KV.ZmenaDo) 
  INNER JOIN TabKmenZbozi KZV ON (KZV.IdKusovnik=KV.vyssi AND (KV.IDVarianta IS NULL OR KZV.IdVarianta=KV.IDVarianta) AND KZV.Blokovano=0) 
  INNER JOIN TabSkupinyZbozi SZ ON (SZ.SkupZbo=KZV.SkupZbo) 
  LEFT OUTER JOIN TabSkupinyZbozi_Ext SZ_E ON (SZ_E.ID=SZ.ID) 
  INNER JOIN TabKmenZbozi KZN ON (KZN.ID=KV.nizsi AND (KZN.Dilec=1 OR (KZN.material=1 AND KZN.RezijniMat=0)) AND KV.RezijniMat=0) 
  INNER JOIN TabSkupinyZbozi SZN ON (SZN.SkupZbo=KZN.SkupZbo) 
  INNER JOIN TabSkupinyZbozi_Ext SZN_E ON (SZN_E.ID=SZN.ID AND SZN_E._EXT_RS_Logis=1) 
  INNER JOIN TabParKmZ PD ON PD.IDKmenZbozi=KZV.ID
WHERE ZOd.platnost=1 AND ZOd.datum<=convert(date,GETDATE()) AND (ZDo.platnost=0 OR KV.ZmenaDo IS NULL OR (ZDo.platnost=1 AND ZDo.datum>convert(date,GETDATE()) )) AND 
      SZ_E._EXT_RS_Logis=1 AND KZN.Naradi=0 
GROUP BY KZV.SkupZbo+N'|'+KZV.RegCis, KZN.SkupZbo+N'|'+KZN.RegCis, PD.RadaVyrPrikazu, KV.Operace
UNION ALL 
SELECT 
  BOM_ID = KZV.SkupZbo+N'|'+KZV.RegCis, 
  ITEM_ID = A_KZN.SkupZbo+N'|'+A_KZN.RegCis, 
  QUANTITY= SUM(A_KV.mnozstviSeZtratou/A_KV.DavkaTPV), 
  ROUTING_NAME=CASE WHEN EXISTS(SELECT * FROM TabPostup P WHERE P.Dilec=MIN(KV.vyssi) AND P.ZmenaOd IS NOT NULL AND P.ZmenaDo IS NULL) THEN KZV.SkupZbo+N'|'+KZV.RegCis END, 
  SEQUENCE_NUMBER=CASE WHEN PD.RadaVyrPrikazu=N'803' THEN TRY_CONVERT(int,KV.Operace)
  ELSE (SELECT MIN(ISNULL(TRY_CONVERT(int,P.Operace),0)) FROM TabPostup P WHERE P.Dilec=MIN(KV.vyssi) AND P.ZmenaOd IS NOT NULL AND P.ZmenaDo IS NULL) END, 
  MAIN_MATERIAL=0, 
  SUBSTITUTED_ITEM_ID=KZN.SkupZbo+N'|'+KZN.RegCis, 
  FIXED_QUANTITY=SUM(A_KV.FixniMnozstvi), 
  IDHeKey_TypeS=N'AKV' 
FROM TabKVazby KV 
  INNER JOIN TabCzmeny ZOd ON (ZOd.ID=KV.ZmenaOd) 
  LEFT OUTER JOIN TabCzmeny ZDo ON (ZDo.ID=KV.ZmenaDo) 
  INNER JOIN TabKmenZbozi KZV ON (KZV.IdKusovnik=KV.vyssi AND (KV.IDVarianta IS NULL OR KZV.IdVarianta=KV.IDVarianta) AND KZV.Blokovano=0) 
  INNER JOIN TabSkupinyZbozi SZ ON (SZ.SkupZbo=KZV.SkupZbo) 
  LEFT OUTER JOIN TabSkupinyZbozi_Ext SZ_E ON (SZ_E.ID=SZ.ID) 
  INNER JOIN TabKmenZbozi KZN ON (KZN.ID=KV.nizsi AND (KZN.Dilec=1 OR (KZN.material=1 AND KZN.RezijniMat=0)) AND KV.RezijniMat=0) 
  INNER JOIN TabSkupinyZbozi SZN ON (SZN.SkupZbo=KZN.SkupZbo) 
  INNER JOIN TabSkupinyZbozi_Ext SZN_E ON (SZN_E.ID=SZN.ID AND SZN_E._EXT_RS_Logis=1) 
  INNER JOIN TabAltKVazby A_KV ON (A_KV.KV_ID1=KV.ID1) 
  INNER JOIN TabCzmeny A_ZOd ON (A_ZOd.ID=A_KV.ZmenaOd) 
  LEFT OUTER JOIN TabCzmeny A_ZDo ON (A_ZDo.ID=A_KV.ZmenaDo) 
  INNER JOIN TabKmenZbozi A_KZN ON (A_KZN.ID=A_KV.nizsi AND (A_KZN.Dilec=1 OR (A_KZN.material=1 AND A_KZN.RezijniMat=0)) AND A_KV.RezijniMat=0) 
  INNER JOIN TabSkupinyZbozi A_SZN ON (A_SZN.SkupZbo=A_KZN.SkupZbo) 
  INNER JOIN TabSkupinyZbozi_Ext A_SZN_E ON (A_SZN_E.ID=A_SZN.ID AND A_SZN_E._EXT_RS_Logis=1) 
  INNER JOIN TabParKmZ PD ON PD.IDKmenZbozi=KZV.ID
WHERE ZOd.platnost=1 AND ZOd.datum<=convert(date,GETDATE()) AND (ZDo.platnost=0 OR KV.ZmenaDo IS NULL OR (ZDo.platnost=1 AND ZDo.datum>convert(date,GETDATE()) )) AND 
      A_ZOd.platnost=1 AND A_ZOd.datum<=convert(date,GETDATE()) AND (A_ZDo.platnost=0 OR A_KV.ZmenaDo IS NULL OR (A_ZDo.platnost=1 AND A_ZDo.datum>convert(date,GETDATE()) )) AND 
      SZ_E._EXT_RS_Logis=1 AND KZN.Naradi=0 AND A_KZN.Naradi=0 
GROUP BY KZV.SkupZbo+N'|'+KZV.RegCis, A_KZN.SkupZbo+N'|'+A_KZN.RegCis, KZN.SkupZbo+N'|'+KZN.RegCis, PD.RadaVyrPrikazu, KV.Operace
UNION ALL 
SELECT 
  BOM_ID = KZV.SkupZbo+N'|'+KZV.RegCis, 
  ITEM_ID = AKZ.SkupZbo+N'|'+AKZ.RegCis, 
  QUANTITY= SUM(KV.mnozstviSeZtratou*A.mnozstvi/KV.DavkaTPV), 
  ROUTING_NAME=CASE WHEN EXISTS(SELECT * FROM TabPostup P WHERE P.Dilec=MIN(KV.vyssi) AND P.ZmenaOd IS NOT NULL AND P.ZmenaDo IS NULL) THEN KZV.SkupZbo+N'|'+KZV.RegCis END, 
  SEQUENCE_NUMBER=CASE WHEN PD.RadaVyrPrikazu=N'803' THEN TRY_CONVERT(int,KV.Operace)
  ELSE (SELECT MIN(ISNULL(TRY_CONVERT(int,P.Operace),0)) FROM TabPostup P WHERE P.Dilec=MIN(KV.vyssi) AND P.ZmenaOd IS NOT NULL AND P.ZmenaDo IS NULL) END, 
  MAIN_MATERIAL=0, 
  SUBSTITUTED_ITEM_ID=KZN.SkupZbo+N'|'+KZN.RegCis, 
  FIXED_QUANTITY=SUM(KV.FixniMnozstvi), 
  IDHeKey_TypeS=N'Alter KZ of KV' 
FROM TabKVazby KV 
  INNER JOIN TabCzmeny ZOd ON (ZOd.ID=KV.ZmenaOd) 
  LEFT OUTER JOIN TabCzmeny ZDo ON (ZDo.ID=KV.ZmenaDo) 
  INNER JOIN TabKmenZbozi KZV ON (KZV.IdKusovnik=KV.vyssi AND (KV.IDVarianta IS NULL OR KZV.IdVarianta=KV.IDVarianta) AND KZV.Blokovano=0) 
  INNER JOIN TabSkupinyZbozi SZ ON (SZ.SkupZbo=KZV.SkupZbo) 
  LEFT OUTER JOIN TabSkupinyZbozi_Ext SZ_E ON (SZ_E.ID=SZ.ID) 
  INNER JOIN TabKmenZbozi KZN ON (KZN.ID=KV.nizsi AND (KZN.Dilec=1 OR (KZN.material=1 AND KZN.RezijniMat=0)) AND KV.RezijniMat=0) 
  INNER JOIN TabSkupinyZbozi SZN ON (SZN.SkupZbo=KZN.SkupZbo) 
  INNER JOIN TabSkupinyZbozi_Ext SZN_E ON (SZN_E.ID=SZN.ID AND SZN_E._EXT_RS_Logis=1) 
  INNER JOIN TabAlterKZ A ON (A.IDKmeneZbozi=KV.nizsi) 
  INNER JOIN TabKmenZbozi AKZ ON (AKZ.ID=A.IDKZNahrada AND AKZ.Blokovano=0 AND (AKZ.Dilec=1 OR (AKZ.material=1 AND AKZ.RezijniMat=0))) 
  INNER JOIN TabSkupinyZbozi A_SZN ON (A_SZN.SkupZbo=AKZ.SkupZbo) 
  INNER JOIN TabSkupinyZbozi_Ext A_SZN_E ON (A_SZN_E.ID=A_SZN.ID AND A_SZN_E._EXT_RS_Logis=1) 
  INNER JOIN TabParKmZ PD ON PD.IDKmenZbozi=KZV.ID
WHERE ZOd.platnost=1 AND ZOd.datum<=convert(date,GETDATE()) AND (ZDo.platnost=0 OR KV.ZmenaDo IS NULL OR (ZDo.platnost=1 AND ZDo.datum>convert(date,GETDATE()) )) AND 
      SZ_E._EXT_RS_Logis=1 AND KZN.Naradi=0 AND AKZ.Naradi=0 
GROUP BY KZV.SkupZbo+N'|'+KZV.RegCis, KZN.SkupZbo+N'|'+KZN.RegCis, AKZ.SkupZbo+N'|'+AKZ.RegCis, PD.RadaVyrPrikazu, KV.Operace
UNION ALL 
SELECT 
  BOM_ID = KZV.SkupZbo+N'|'+KZV.RegCis+N'|'+ZM.Kod, 
  ITEM_ID = KZN.SkupZbo+N'|'+KZN.RegCis, 
  QUANTITY= SUM(KV.mnozstviSeZtratou/KV.DavkaTPV), 
  ROUTING_NAME=CASE WHEN EXISTS(SELECT * FROM TabPostup P WHERE P.Dilec=MIN(KV.vyssi) AND P.IDZakazModif=MIN(KV.IDZakazModif) AND P.ZmenaDo IS NULL) THEN KZV.SkupZbo+N'|'+KZV.RegCis+N'|'+ZM.Kod END, 
  SEQUENCE_NUMBER=CASE WHEN PD.RadaVyrPrikazu=N'803' THEN TRY_CONVERT(int,KV.Operace)
  ELSE (SELECT MIN(ISNULL(TRY_CONVERT(int,P.Operace),0)) FROM TabPostup P WHERE P.Dilec=MIN(KV.vyssi) AND P.IDZakazModif=MIN(KV.IDZakazModif) AND P.ZmenaDo IS NULL) END, 
  MAIN_MATERIAL=0, 
  SUBSTITUTED_ITEM_ID=NULL, 
  FIXED_QUANTITY=SUM(KV.FixniMnozstvi), 
  IDHeKey_TypeS=N'KV ZakazModif' 
FROM TabZakazModifDilce ZMD 
  INNER JOIN TabZakazModif ZM ON (ZM.ID=ZMD.IDZakazModif AND ZM.Blokovano=0) 
  INNER JOIN TabKmenZbozi KZV ON (KZV.ID=ZMD.IDKmenZbozi AND KZV.Blokovano=0) 
  INNER JOIN TabSkupinyZbozi SZ ON (SZ.SkupZbo=KZV.SkupZbo) 
  LEFT OUTER JOIN TabSkupinyZbozi_Ext SZ_E ON (SZ_E.ID=SZ.ID) 
  INNER JOIN TabKVazby KV ON (KV.vyssi=ZMD.IDKmenZbozi AND KV.IDZakazModif=ZMD.IDZakazModif) 
  INNER JOIN TabKmenZbozi KZN ON (KZN.ID=KV.nizsi AND (KZN.Dilec=1 OR (KZN.material=1 AND KZN.RezijniMat=0)) AND KV.RezijniMat=0) 
  INNER JOIN TabSkupinyZbozi SZN ON (SZN.SkupZbo=KZN.SkupZbo) 
  INNER JOIN TabSkupinyZbozi_Ext SZN_E ON (SZN_E.ID=SZN.ID AND SZN_E._EXT_RS_Logis=1) 
  INNER JOIN TabParKmZ PD ON PD.IDKmenZbozi=KZV.ID
WHERE ZMD.TPVModif=1 AND 
      SZ_E._EXT_RS_Logis=1 AND KZN.Naradi=0 
GROUP BY KZV.SkupZbo+N'|'+KZV.RegCis+N'|'+ZM.Kod, KZN.SkupZbo+N'|'+KZN.RegCis, PD.RadaVyrPrikazu, KV.Operace
UNION ALL 
SELECT 
  BOM_ID = KZV.SkupZbo+N'|'+KZV.RegCis+N'|'+ZM.Kod, 
  ITEM_ID = A_KZN.SkupZbo+N'|'+A_KZN.RegCis, 
  QUANTITY= SUM(A_KV.mnozstviSeZtratou/A_KV.DavkaTPV), 
  ROUTING_NAME=CASE WHEN EXISTS(SELECT * FROM TabPostup P WHERE P.Dilec=MIN(KV.vyssi) AND P.IDZakazModif=MIN(KV.IDZakazModif) AND P.ZmenaDo IS NULL) THEN KZV.SkupZbo+N'|'+KZV.RegCis+N'|'+ZM.Kod END, 
  SEQUENCE_NUMBER=CASE WHEN PD.RadaVyrPrikazu=N'803' THEN TRY_CONVERT(int,KV.Operace)
  ELSE (SELECT MIN(ISNULL(TRY_CONVERT(int,P.Operace),0)) FROM TabPostup P WHERE P.Dilec=MIN(KV.vyssi) AND P.IDZakazModif=MIN(KV.IDZakazModif) AND P.ZmenaDo IS NULL) END, 
  MAIN_MATERIAL=0, 
  SUBSTITUTED_ITEM_ID=KZN.SkupZbo+N'|'+KZN.RegCis, 
  FIXED_QUANTITY=SUM(A_KV.FixniMnozstvi), 
  IDHeKey_TypeS=N'AKV ZakazModif' 
FROM TabZakazModifDilce ZMD 
  INNER JOIN TabZakazModif ZM ON (ZM.ID=ZMD.IDZakazModif AND ZM.Blokovano=0) 
  INNER JOIN TabKmenZbozi KZV ON (KZV.ID=ZMD.IDKmenZbozi AND KZV.Blokovano=0) 
  INNER JOIN TabSkupinyZbozi SZ ON (SZ.SkupZbo=KZV.SkupZbo) 
  LEFT OUTER JOIN TabSkupinyZbozi_Ext SZ_E ON (SZ_E.ID=SZ.ID) 
  INNER JOIN TabKVazby KV ON (KV.vyssi=ZMD.IDKmenZbozi AND KV.IDZakazModif=ZMD.IDZakazModif) 
  INNER JOIN TabKmenZbozi KZN ON (KZN.ID=KV.nizsi AND (KZN.Dilec=1 OR (KZN.material=1 AND KZN.RezijniMat=0)) AND KV.RezijniMat=0) 
  INNER JOIN TabSkupinyZbozi SZN ON (SZN.SkupZbo=KZN.SkupZbo) 
  INNER JOIN TabSkupinyZbozi_Ext SZN_E ON (SZN_E.ID=SZN.ID AND SZN_E._EXT_RS_Logis=1) 
  INNER JOIN TabAltKVazby A_KV ON (A_KV.KV_ID1=KV.ID1) 
  INNER JOIN TabKmenZbozi A_KZN ON (A_KZN.ID=A_KV.nizsi AND (A_KZN.Dilec=1 OR (A_KZN.material=1 AND A_KZN.RezijniMat=0)) AND A_KV.RezijniMat=0) 
  INNER JOIN TabSkupinyZbozi A_SZN ON (A_SZN.SkupZbo=A_KZN.SkupZbo) 
  INNER JOIN TabSkupinyZbozi_Ext A_SZN_E ON (A_SZN_E.ID=A_SZN.ID AND A_SZN_E._EXT_RS_Logis=1) 
  INNER JOIN TabParKmZ PD ON PD.IDKmenZbozi=KZV.ID
WHERE ZMD.TPVModif=1 AND 
      SZ_E._EXT_RS_Logis=1 AND KZN.Naradi=0 AND A_KZN.Naradi=0 
GROUP BY KZV.SkupZbo+N'|'+KZV.RegCis+N'|'+ZM.Kod, A_KZN.SkupZbo+N'|'+A_KZN.RegCis, KZN.SkupZbo+N'|'+KZN.RegCis, PD.RadaVyrPrikazu, KV.Operace
UNION ALL 
SELECT 
  BOM_ID = KZV.SkupZbo+N'|'+KZV.RegCis+N'|'+ZM.Kod, 
  ITEM_ID = AKZ.SkupZbo+N'|'+AKZ.RegCis, 
  QUANTITY= SUM(KV.mnozstviSeZtratou*A.mnozstvi/KV.DavkaTPV), 
  ROUTING_NAME=CASE WHEN EXISTS(SELECT * FROM TabPostup P WHERE P.Dilec=MIN(KV.vyssi) AND P.IDZakazModif=MIN(KV.IDZakazModif) AND P.ZmenaDo IS NULL) THEN KZV.SkupZbo+N'|'+KZV.RegCis+N'|'+ZM.Kod END, 
  SEQUENCE_NUMBER=CASE WHEN PD.RadaVyrPrikazu=N'803' THEN TRY_CONVERT(int,KV.Operace)
  ELSE (SELECT MIN(ISNULL(TRY_CONVERT(int,P.Operace),0)) FROM TabPostup P WHERE P.Dilec=MIN(KV.vyssi) AND P.IDZakazModif=MIN(KV.IDZakazModif) AND P.ZmenaDo IS NULL) END,
  MAIN_MATERIAL=0, 
  SUBSTITUTED_ITEM_ID=KZN.SkupZbo+N'|'+KZN.RegCis, 
  FIXED_QUANTITY=SUM(KV.FixniMnozstvi), 
  IDHeKey_TypeS=N'Alter KZ of KV ZakazModif' 
FROM TabZakazModifDilce ZMD 
  INNER JOIN TabZakazModif ZM ON (ZM.ID=ZMD.IDZakazModif AND ZM.Blokovano=0) 
  INNER JOIN TabKmenZbozi KZV ON (KZV.ID=ZMD.IDKmenZbozi AND KZV.Blokovano=0) 
  INNER JOIN TabSkupinyZbozi SZ ON (SZ.SkupZbo=KZV.SkupZbo) 
  LEFT OUTER JOIN TabSkupinyZbozi_Ext SZ_E ON (SZ_E.ID=SZ.ID) 
  INNER JOIN TabKVazby KV ON (KV.vyssi=ZMD.IDKmenZbozi AND KV.IDZakazModif=ZMD.IDZakazModif) 
  INNER JOIN TabKmenZbozi KZN ON (KZN.ID=KV.nizsi AND (KZN.Dilec=1 OR (KZN.material=1 AND KZN.RezijniMat=0)) AND KV.RezijniMat=0) 
  INNER JOIN TabSkupinyZbozi SZN ON (SZN.SkupZbo=KZN.SkupZbo) 
  INNER JOIN TabSkupinyZbozi_Ext SZN_E ON (SZN_E.ID=SZN.ID AND SZN_E._EXT_RS_Logis=1) 
  INNER JOIN TabAlterKZ A ON (A.IDKmeneZbozi=KV.nizsi) 
  INNER JOIN TabKmenZbozi AKZ ON (AKZ.ID=A.IDKZNahrada AND AKZ.Blokovano=0 AND (AKZ.Dilec=1 OR (AKZ.material=1 AND AKZ.RezijniMat=0))) 
  INNER JOIN TabSkupinyZbozi A_SZN ON (A_SZN.SkupZbo=AKZ.SkupZbo) 
  INNER JOIN TabSkupinyZbozi_Ext A_SZN_E ON (A_SZN_E.ID=A_SZN.ID AND A_SZN_E._EXT_RS_Logis=1) 
  INNER JOIN TabParKmZ PD ON PD.IDKmenZbozi=KZV.ID
WHERE ZMD.TPVModif=1 AND 
      SZ_E._EXT_RS_Logis=1 AND KZN.Naradi=0 AND AKZ.Naradi=0 
GROUP BY KZV.SkupZbo+N'|'+KZV.RegCis+N'|'+ZM.Kod, KZN.SkupZbo+N'|'+KZN.RegCis, AKZ.SkupZbo+N'|'+AKZ.RegCis, PD.RadaVyrPrikazu, KV.Operace
UNION ALL 
SELECT 
  BOM_ID=RTRIM(P.Rada)+N'|'+convert(nvarchar(10),P.Prikaz), 
  ITEM_ID = KZN.SkupZbo+N'|'+KZN.RegCis, 
  QUANTITY= SUM(PrKV.mnoz_zad/P.kusy_zad), 
  ROUTING_NAME=CASE WHEN EXISTS(SELECT * FROM TabPrPostup P LEFT OUTER JOIN TabPrPostup_Ext P_E ON (P_E.ID=P.ID) WHERE P.IDPrikaz=MIN(PrKV.IDPrikaz) AND P.Dilec=MIN(PrKV.vyssi) AND P.prednastaveno=1 AND P.IDOdchylkyDo IS NULL) THEN RTRIM(P.Rada)+N'|'+convert(nvarchar(10),P.Prikaz) END, 
  --upraveno:
  SEQUENCE_NUMBER=CASE WHEN PD.RadaVyrPrikazu=N'803' THEN (SELECT ISNULL(P_E._EXT_RS_PoradiLogis,ISNULL(TRY_CONVERT(int,P.Operace),0)) FROM TabPrPostup P LEFT OUTER JOIN TabPrPostup_Ext P_E ON (P_E.ID=P.ID) WHERE P.IDPrikaz=MIN(PrKV.IDPrikaz) AND P.Dilec=MIN(PrKV.vyssi) AND P.prednastaveno=1 AND P.IDOdchylkyDo IS NULL AND P.Operace=PrKV.Operace)
                      WHEN KZN.SkupZbo=N'932' AND P.SkupinaPlanu=N'P100' THEN (SELECT MAX(ISNULL(P_E._EXT_RS_PoradiLogis,ISNULL(TRY_CONVERT(int,P.Operace),0))) FROM TabPrPostup P LEFT OUTER JOIN TabPrPostup_Ext P_E ON (P_E.ID=P.ID) WHERE P.IDPrikaz=MIN(PrKV.IDPrikaz) AND P.Dilec=MIN(PrKV.vyssi) AND P.prednastaveno=1 AND P.IDOdchylkyDo IS NULL) 
                      ELSE (SELECT MIN(ISNULL(P_E._EXT_RS_PoradiLogis,ISNULL(TRY_CONVERT(int,P.Operace),0))) FROM TabPrPostup P LEFT OUTER JOIN TabPrPostup_Ext P_E ON (P_E.ID=P.ID) WHERE P.IDPrikaz=MIN(PrKV.IDPrikaz) AND P.Dilec=MIN(PrKV.vyssi) AND P.prednastaveno=1 AND P.IDOdchylkyDo IS NULL)
  END, 
  MAIN_MATERIAL=0, 
  SUBSTITUTED_ITEM_ID=NULL, 
  --upraveno:
  FIXED_QUANTITY=CASE WHEN KZN.SkupZbo=N'932' AND P.SkupinaPlanu=N'P100' THEN -100000 ELSE 0 END, 
  IDHeKey_TypeS=N'PrKV' 
FROM TabPrikaz P 
  INNER JOIN TabPrKVazby PrKV ON (PrKV.IDPrikaz=P.ID AND PrKV.prednastaveno=1 AND PrKV.IDOdchylkyDo IS NULL AND PrKV.Vyssi=P.IDTabKmen AND PrKV.Uzavreno=0) 
  INNER JOIN TabKmenZbozi KZV ON (KZV.ID=P.IDTabKmen) 
  INNER JOIN TabSkupinyZbozi SZ ON (SZ.SkupZbo=KZV.SkupZbo) 
  LEFT OUTER JOIN TabSkupinyZbozi_Ext SZ_E ON (SZ_E.ID=SZ.ID) 
  INNER JOIN TabRadyPrikazu RP ON (RP.Rada=P.Rada) 
  LEFT OUTER JOIN TabRadyPrikazu_Ext RP_E ON (RP_E.ID=RP.ID) 
  INNER JOIN TabKmenZbozi KZN ON (KZN.ID=PrKV.nizsi AND (KZN.Dilec=1 OR (KZN.material=1 AND KZN.RezijniMat=0)) AND PrKV.RezijniMat=0) 
  INNER JOIN TabSkupinyZbozi SZN ON (SZN.SkupZbo=KZN.SkupZbo) 
  INNER JOIN TabSkupinyZbozi_Ext SZN_E ON (SZN_E.ID=SZN.ID AND SZN_E._EXT_RS_Logis=1) 
  INNER JOIN TabParKmZ PD ON PD.IDKmenZbozi=KZV.ID
WHERE P.StavPrikazu IN (20,30,40) AND 
      SZ_E._EXT_RS_Logis=1 AND RP_E._EXT_RS_Logis=1 AND KZN.Naradi=0 
      AND KZV.SkupZbo<>'932'
GROUP BY P.SkupinaPlanu, RTRIM(P.Rada)+N'|'+convert(nvarchar(10),P.Prikaz), KZN.SkupZbo, KZN.SkupZbo+N'|'+KZN.RegCis, PD.RadaVyrPrikazu, PrKv.Operace
UNION ALL 
SELECT 
  BOM_ID=RTRIM(P.Rada)+N'|'+convert(nvarchar(10),P.Prikaz), 
  ITEM_ID = A_KZN.SkupZbo+N'|'+A_KZN.RegCis, 
  QUANTITY= SUM(A_PrKV.mnoz_zad/P.kusy_zad), 
  ROUTING_NAME=CASE WHEN EXISTS(SELECT * FROM TabPrPostup P LEFT OUTER JOIN TabPrPostup_Ext P_E ON (P_E.ID=P.ID) WHERE P.IDPrikaz=MIN(PrKV.IDPrikaz) AND P.Dilec=MIN(PrKV.vyssi) AND P.prednastaveno=1 AND P.IDOdchylkyDo IS NULL) THEN RTRIM(P.Rada)+N'|'+convert(nvarchar(10),P.Prikaz) END, 
  --upraveno:
  SEQUENCE_NUMBER=CASE WHEN PD.RadaVyrPrikazu=N'803' THEN (SELECT ISNULL(P_E._EXT_RS_PoradiLogis,ISNULL(TRY_CONVERT(int,P.Operace),0)) FROM TabPrPostup P LEFT OUTER JOIN TabPrPostup_Ext P_E ON (P_E.ID=P.ID) WHERE P.IDPrikaz=MIN(PrKV.IDPrikaz) AND P.Dilec=MIN(PrKV.vyssi) AND P.prednastaveno=1 AND P.IDOdchylkyDo IS NULL)
                      WHEN A_KZN.SkupZbo=N'932' AND P.SkupinaPlanu=N'P100' THEN (SELECT MAX(ISNULL(P_E._EXT_RS_PoradiLogis,ISNULL(TRY_CONVERT(int,P.Operace),0))) FROM TabPrPostup P LEFT OUTER JOIN TabPrPostup_Ext P_E ON (P_E.ID=P.ID) WHERE P.IDPrikaz=MIN(PrKV.IDPrikaz) AND P.Dilec=MIN(PrKV.vyssi) AND P.prednastaveno=1 AND P.IDOdchylkyDo IS NULL) 
                      ELSE (SELECT MIN(ISNULL(P_E._EXT_RS_PoradiLogis,ISNULL(TRY_CONVERT(int,P.Operace),0))) FROM TabPrPostup P LEFT OUTER JOIN TabPrPostup_Ext P_E ON (P_E.ID=P.ID) WHERE P.IDPrikaz=MIN(PrKV.IDPrikaz) AND P.Dilec=MIN(PrKV.vyssi) AND P.prednastaveno=1 AND P.IDOdchylkyDo IS NULL)
  END, 
  MAIN_MATERIAL=0, 
  SUBSTITUTED_ITEM_ID=KZN.SkupZbo+N'|'+KZN.RegCis, 
  --upraveno:
  FIXED_QUANTITY=CASE WHEN A_KZN.SkupZbo=N'932' AND P.SkupinaPlanu=N'P100' THEN -100000 ELSE 0 END, 
  IDHeKey_TypeS=N'Alt PrKV' 
FROM TabPrikaz P 
  INNER JOIN TabPrKVazby PrKV ON (PrKV.IDPrikaz=P.ID AND PrKV.prednastaveno=1 AND PrKV.IDOdchylkyDo IS NULL AND PrKV.Vyssi=P.IDTabKmen AND PrKV.Uzavreno=0) 
  INNER JOIN TabKmenZbozi KZV ON (KZV.ID=P.IDTabKmen) 
  INNER JOIN TabSkupinyZbozi SZ ON (SZ.SkupZbo=KZV.SkupZbo) 
  LEFT OUTER JOIN TabSkupinyZbozi_Ext SZ_E ON (SZ_E.ID=SZ.ID) 
  INNER JOIN TabRadyPrikazu RP ON (RP.Rada=P.Rada) 
  LEFT OUTER JOIN TabRadyPrikazu_Ext RP_E ON (RP_E.ID=RP.ID) 
  INNER JOIN TabKmenZbozi KZN ON (KZN.ID=PrKV.nizsi AND (KZN.Dilec=1 OR (KZN.material=1 AND KZN.RezijniMat=0)) AND PrKV.RezijniMat=0) 
  INNER JOIN TabSkupinyZbozi SZN ON (SZN.SkupZbo=KZN.SkupZbo) 
  INNER JOIN TabSkupinyZbozi_Ext SZN_E ON (SZN_E.ID=SZN.ID AND SZN_E._EXT_RS_Logis=1) 
  INNER JOIN TabPrKVazby A_PrKV ON (A_PrKV.IDPrikaz=P.ID AND A_PrKV.Doklad=PrKV.Doklad AND A_PrKV.prednastaveno=0 AND A_PrKV.IDOdchylkyDo IS NULL AND A_PrKV.Uzavreno=0) 
  INNER JOIN TabKmenZbozi A_KZN ON (A_KZN.ID=A_PrKV.nizsi AND (A_KZN.Dilec=1 OR (A_KZN.material=1 AND A_KZN.RezijniMat=0)) AND A_PrKV.RezijniMat=0) 
  INNER JOIN TabSkupinyZbozi A_SZN ON (A_SZN.SkupZbo=A_KZN.SkupZbo) 
  INNER JOIN TabSkupinyZbozi_Ext A_SZN_E ON (A_SZN_E.ID=A_SZN.ID AND A_SZN_E._EXT_RS_Logis=1) 
  INNER JOIN TabParKmZ PD ON PD.IDKmenZbozi=KZV.ID
WHERE P.StavPrikazu IN (20,30,40) AND 
      SZ_E._EXT_RS_Logis=1 AND RP_E._EXT_RS_Logis=1 AND KZN.Naradi=0 AND A_KZN.Naradi=0 
      AND KZV.SkupZbo<>'932'
GROUP BY P.SkupinaPlanu, RTRIM(P.Rada)+N'|'+convert(nvarchar(10),P.Prikaz), A_KZN.SkupZbo, A_KZN.SkupZbo+N'|'+A_KZN.RegCis, KZN.SkupZbo+N'|'+KZN.RegCis, PD.RadaVyrPrikazu
--duplikace kmenových dat, kde kusovník obsahuje 932 a zároveň inventory pro 932=0
UNION ALL 
SELECT
  BOM_ID = KZV.SkupZbo+N'|'+KZV.RegCis+'-PrvniKus', 
  ITEM_ID = KZN.SkupZbo+N'|'+KZN.RegCis, 
  QUANTITY= SUM(KV.mnozstviSeZtratou/KV.DavkaTPV), 
  ROUTING_NAME=CASE WHEN EXISTS(SELECT * FROM TabPostup P WHERE P.Dilec=MIN(KV.vyssi) AND P.ZmenaOd IS NOT NULL AND P.ZmenaDo IS NULL) THEN KZV.SkupZbo+N'|'+KZV.RegCis END, 
  SEQUENCE_NUMBER=CASE WHEN KZN.SkupZbo+N'|'+KZN.RegCis LIKE N'932%' THEN (SELECT MAX(ISNULL(TRY_CONVERT(int,P.Operace),0)) FROM TabPostup P WHERE P.Dilec=MIN(KV.vyssi) AND P.ZmenaOd IS NOT NULL AND P.ZmenaDo IS NULL) ELSE
  (SELECT MIN(ISNULL(TRY_CONVERT(int,P.Operace),0)) FROM TabPostup P WHERE P.Dilec=MIN(KV.vyssi) AND P.ZmenaOd IS NOT NULL AND P.ZmenaDo IS NULL) END, 
  MAIN_MATERIAL=0, 
  SUBSTITUTED_ITEM_ID=NULL, 
  FIXED_QUANTITY=CASE WHEN KZN.SkupZbo+N'|'+KZN.RegCis LIKE N'932%' THEN -100000 ELSE SUM(KV.FixniMnozstvi) END, 
  IDHeKey_TypeS=N'KV' 
FROM TabKVazby KV 
  INNER JOIN TabCzmeny ZOd ON (ZOd.ID=KV.ZmenaOd) 
  LEFT OUTER JOIN TabCzmeny ZDo ON (ZDo.ID=KV.ZmenaDo) 
  INNER JOIN TabKmenZbozi KZV ON (KZV.IdKusovnik=KV.vyssi AND (KV.IDVarianta IS NULL OR KZV.IdVarianta=KV.IDVarianta) AND KZV.Blokovano=0) 
  INNER JOIN TabSkupinyZbozi SZ ON (SZ.SkupZbo=KZV.SkupZbo) 
  LEFT OUTER JOIN TabSkupinyZbozi_Ext SZ_E ON (SZ_E.ID=SZ.ID) 
  INNER JOIN TabKmenZbozi KZN ON (KZN.ID=KV.nizsi AND (KZN.Dilec=1 OR (KZN.material=1 AND KZN.RezijniMat=0)) AND KV.RezijniMat=0) 
  INNER JOIN TabSkupinyZbozi SZN ON (SZN.SkupZbo=KZN.SkupZbo) 
  INNER JOIN TabSkupinyZbozi_Ext SZN_E ON (SZN_E.ID=SZN.ID AND SZN_E._EXT_RS_Logis=1) 
WHERE ZOd.platnost=1 AND ZOd.datum<=convert(date,GETDATE()) AND (ZDo.platnost=0 OR KV.ZmenaDo IS NULL OR (ZDo.platnost=1 AND ZDo.datum>convert(date,GETDATE()) )) AND 
      SZ_E._EXT_RS_Logis=1 AND KZN.Naradi=0 
AND KZV.ID IN (
SELECT DISTINCT tkzV.ID
FROM TabKvazby tkv
LEFT OUTER JOIN TabCzmeny tczOd ON tkv.ZmenaOd=tczOd.ID
LEFT OUTER JOIN TabCzmeny tczDo ON tkv.ZmenaDo=tczDo.ID
LEFT OUTER JOIN TabKmenZbozi tkzN ON tkv.nizsi=tkzN.ID
LEFT OUTER JOIN TabSkupinyZbozi tsV ON tsV.ID=(SELECT sz.ID  FROM TabKvazby kv WITH(NOLOCK)  LEFT OUTER JOIN TabKmenZbozi tkz WITH(NOLOCK) ON tkz.ID=kv.vyssi  LEFT OUTER JOIN TabSkupinyZbozi sz WITH(NOLOCK) ON sz.SkupZbo=tkz.SkupZbo  WHERE kv.ID=tkv.ID  )
LEFT OUTER JOIN TabSkupinyZbozi_EXT tsV_EXT ON tsV_EXT.ID=tsV.ID
LEFT OUTER JOIN TabKmenZbozi tkzV ON tkzV.ID=tkv.vyssi
LEFT OUTER JOIN TabStavSkladu tss ON tss.IDKmenZbozi=tkzN.ID AND tss.IDSklad='20000275900'
WHERE
(((tkv.IDZakazModif IS NOT NULL OR tczOd.platnostTPV=1 AND tczOd.datum<=GETDATE()
AND (tczDo.platnostTPV=0 OR tkv.ZmenaDo IS NULL OR (tczDo.platnostTPV=1 AND tczDo.datum>GETDATE())) ))
AND(tkzN.SkupZbo LIKE N'%932%')AND(ISNULL(tsV_EXT._EXT_RS_Logis,0)=1))
AND(tss.MnozSPrijBezVyd=0.0)
)
GROUP BY KZV.SkupZbo+N'|'+KZV.RegCis, KZN.SkupZbo+N'|'+KZN.RegCis )
SELECT BOM_ID, ITEM_ID, SUM(QUANTITY) AS QUANTITY, ROUTING_NAME, SEQUENCE_NUMBER, MAIN_MATERIAL, SUBSTITUTED_ITEM_ID, SUM(FIXED_QUANTITY) AS FIXED_QUANTITY, IDHeKey_TypeS
FROM BOM
GROUP BY IDHeKey_TypeS, BOM_ID, ITEM_ID, ROUTING_NAME, SEQUENCE_NUMBER, MAIN_MATERIAL, SUBSTITUTED_ITEM_ID



GO

