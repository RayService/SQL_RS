USE [RayService]
GO

/****** Object:  View [dbo].[hvw_APSLogis_IN_ROUTINGOPERATION]    Script Date: 03.07.2025 13:08:28 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO



CREATE VIEW [dbo].[hvw_APSLogis_IN_ROUTINGOPERATION] AS SELECT 
  ROUTING_NAME = KZV.SkupZbo+N'|'+KZV.RegCis, 
  SEQUENCE_NUMBER =ISNULL(TRY_CONVERT(int,P.Operace),0), 
  OPERATION_NAME = MAX(P.nazev), 
  PREOP_TIME =MAX(CASE WHEN P.typ<2 THEN P.TBC_N ELSE ISNULL(P.Koop_DobaZpracDavky_N, IIF(ISNULL(CK.DobaZpracDavky_N,0)=0, 7*24*60, CK.DobaZpracDavky_N)) + CK.DobaPrepravy_N END), 
  UNIT_RUNTIME =MAX(CASE WHEN P.typ<2 THEN P.TAC_N END), 
  TIME_UOM = N'MINUTES', 
  YIELD=1, 
  POSTOP_TIME=MAX(P.MeziOperCas_N + SZ_E._EXT_RS_LhutaNaskladneni * 1440), 
  IDHeKey_TypeS=N'Postup' 
FROM TabPostup P 
  LEFT OUTER JOIN TabCKoop CK ON (CK.ID=P.IDkooperace) 
  INNER JOIN TabCzmeny ZOd ON (ZOd.ID=P.ZmenaOd) 
  LEFT OUTER JOIN TabCzmeny ZDo ON (ZDo.ID=P.ZmenaDo) 
  INNER JOIN TabKmenZbozi KZV ON (KZV.IdKusovnik=P.dilec AND (P.IDVarianta IS NULL OR KZV.IdVarianta=P.IDVarianta) AND KZV.Blokovano=0) 
  INNER JOIN TabSkupinyZbozi SZ ON (SZ.SkupZbo=KZV.SkupZbo) 
  LEFT OUTER JOIN TabSkupinyZbozi_Ext SZ_E ON (SZ_E.ID=SZ.ID) 
WHERE ZOd.platnost=1 AND ZOd.datum<=convert(date,GETDATE()) AND (ZDo.platnost=0 OR P.ZmenaDo IS NULL OR (ZDo.platnost=1 AND ZDo.datum>convert(date,GETDATE()) )) AND 
      ISNULL(P.Pracoviste,0) NOT IN (164, 51) AND 
      SZ_E._EXT_RS_Logis=1 
GROUP BY KZV.SkupZbo+N'|'+KZV.RegCis, ISNULL(TRY_CONVERT(int,P.Operace),0) 
UNION ALL 
SELECT 
  ROUTING_NAME = KZV.SkupZbo+N'|'+KZV.RegCis+N'|'+ZM.Kod, 
  SEQUENCE_NUMBER =ISNULL(TRY_CONVERT(int,P.Operace),0), 
  OPERATION_NAME = MAX(P.nazev), 
  PREOP_TIME =MAX(CASE WHEN P.typ<2 THEN P.TBC_N ELSE ISNULL(P.Koop_DobaZpracDavky_N, IIF(ISNULL(CK.DobaZpracDavky_N,0)=0, 7*24*60, CK.DobaZpracDavky_N)) + CK.DobaPrepravy_N END), 
  UNIT_RUNTIME =MAX(CASE WHEN P.typ<2 THEN P.TAC_N END), 
  TIME_UOM = N'MINUTES', 
  YIELD=1, 
  POSTOP_TIME=MAX(P.MeziOperCas_N + SZ_E._EXT_RS_LhutaNaskladneni * 1440), 
  IDHeKey_TypeS=N'Postup ZakazModif' 
FROM TabZakazModifDilce ZMD 
  INNER JOIN TabZakazModif ZM ON (ZM.ID=ZMD.IDZakazModif AND ZM.Blokovano=0) 
  INNER JOIN TabKmenZbozi KZV ON (KZV.ID=ZMD.IDKmenZbozi AND KZV.Blokovano=0) 
  INNER JOIN TabSkupinyZbozi SZ ON (SZ.SkupZbo=KZV.SkupZbo) 
  LEFT OUTER JOIN TabSkupinyZbozi_Ext SZ_E ON (SZ_E.ID=SZ.ID) 
  INNER JOIN TabPostup P ON (P.Dilec=ZMD.IDKmenZbozi AND P.IDZakazModif=ZMD.IDZakazModif) 
  LEFT OUTER JOIN TabCKoop CK ON (CK.ID=P.IDkooperace) 
WHERE ZMD.TPVModif=1 AND 
      ISNULL(P.Pracoviste,0) NOT IN (164, 51) AND 
      SZ_E._EXT_RS_Logis=1 
GROUP BY KZV.SkupZbo+N'|'+KZV.RegCis+N'|'+ZM.Kod, ISNULL(TRY_CONVERT(int,P.Operace),0) 
UNION ALL 
SELECT 
  ROUTING_NAME = RTRIM(P.Rada)+N'|'+convert(nvarchar(10),P.Prikaz), 
  SEQUENCE_NUMBER =ISNULL(PrP_E._EXT_RS_PoradiLogis, ISNULL(TRY_CONVERT(int,PrP.Operace),0)), 
  OPERATION_NAME = MAX(PrP.nazev), 
  PREOP_TIME =MAX(CASE WHEN PrP.typ<2 THEN PrP.TBC_N ELSE ISNULL(PrP.Koop_DobaZpracDavky_N, IIF(ISNULL(CK.DobaZpracDavky_N,0)=0, 7*24*60, CK.DobaZpracDavky_N)) + CK.DobaPrepravy_N END), 
  UNIT_RUNTIME =MAX(CASE WHEN PrP.typ<2 THEN PrP.TAC_N END), 
  TIME_UOM = N'MINUTES', 
  YIELD=1, 
  POSTOP_TIME=MAX(PrP.MeziOperCas_N + SZ_E._EXT_RS_LhutaNaskladneni * 1440), 
  IDHeKey_TypeS=N'PrP' 
FROM TabPrikaz P 
  INNER JOIN TabKmenZbozi KZV ON (KZV.ID=P.IDTabKmen) 
  INNER JOIN TabSkupinyZbozi SZ ON (SZ.SkupZbo=KZV.SkupZbo) 
  LEFT OUTER JOIN TabSkupinyZbozi_Ext SZ_E ON (SZ_E.ID=SZ.ID) 
  INNER JOIN TabRadyPrikazu RP ON (RP.Rada=P.Rada) 
  LEFT OUTER JOIN TabRadyPrikazu_Ext RP_E ON (RP_E.ID=RP.ID) 
  INNER JOIN TabPrPostup PrP ON (PrP.IDPrikaz=P.ID AND PrP.Prednastaveno=1 AND PrP.IDOdchylkyDo IS NULL AND PrP.Dilec=P.IDTabKmen AND PrP.Uzavreno=0) 
  LEFT OUTER JOIN TabPrPostup_Ext PrP_E ON (PrP_E.ID=PrP.ID) 
  LEFT OUTER JOIN TabCKoop CK ON (CK.ID=PrP.IDkooperace) 
WHERE P.StavPrikazu IN (20,30,40) AND 
      ISNULL(PrP.Pracoviste,0) NOT IN (164, 51) AND 
      SZ_E._EXT_RS_Logis=1 AND RP_E._EXT_RS_Logis=1 
      AND KZV.SkupZbo<>'932'
GROUP BY RTRIM(P.Rada)+N'|'+convert(nvarchar(10),P.Prikaz), ISNULL(PrP_E._EXT_RS_PoradiLogis, ISNULL(TRY_CONVERT(int,PrP.Operace),0)) 
GO

