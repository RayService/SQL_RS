USE [RayService]
GO

/****** Object:  View [dbo].[hvw_APSLogis_IN_OPERRESOURCE]    Script Date: 03.07.2025 13:02:04 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO



CREATE VIEW [dbo].[hvw_APSLogis_IN_OPERRESOURCE] AS SELECT DISTINCT 
  ROUTING_NAME = KZV.SkupZbo+N'|'+KZV.RegCis, 
  SEQUENCE_NUMBER =ISNULL(TRY_CONVERT(int,P.Operace),0), 
  RESOURCE_NAME = ISNULL(CP.IDTabStrom + N'|' + CP.Pracoviste, N'K_'+CK.Rada + N'|' + CK.kod) + ISNULL(N'|' + CS.Kod,''), 
  RANKING=0, 
  resource_count=1, 
  IDHeKey_TypeS=N'Postupy - Pracoviště/Koop' 
FROM TabPostup P 
  INNER JOIN TabCzmeny ZOd ON (ZOd.ID=P.ZmenaOd) 
  LEFT OUTER JOIN TabCzmeny ZDo ON (ZDo.ID=P.ZmenaDo) 
  INNER JOIN TabKmenZbozi KZV ON (KZV.IdKusovnik=P.dilec AND (P.IDVarianta IS NULL OR KZV.IdVarianta=P.IDVarianta) AND KZV.Blokovano=0) 
  INNER JOIN TabSkupinyZbozi SZ ON (SZ.SkupZbo=KZV.SkupZbo) 
  LEFT OUTER JOIN TabSkupinyZbozi_Ext SZ_E ON (SZ_E.ID=SZ.ID) 
  LEFT OUTER JOIN TabCPraco CP ON (CP.ID=P.pracoviste) 
  LEFT OUTER JOIN TabCisStroju CS ON (CS.ID=P.IDStroje) 
  LEFT OUTER JOIN TabCKoop CK ON (CK.ID=P.IDkooperace) 
WHERE ZOd.platnost=1 AND ZOd.datum<=convert(date,GETDATE()) AND (ZDo.platnost=0 OR P.ZmenaDo IS NULL OR (ZDo.platnost=1 AND ZDo.datum>convert(date,GETDATE()) )) AND 
      ISNULL(P.Pracoviste,0) NOT IN (164, 51) AND 
      SZ_E._EXT_RS_Logis=1 
UNION ALL 
SELECT 
  ROUTING_NAME = KZV.SkupZbo+N'|'+KZV.RegCis, 
  SEQUENCE_NUMBER =ISNULL(TRY_CONVERT(int,P.Operace),0), 
  RESOURCE_NAME = ISNULL(CP.IDTabStrom + N'|' + CP.Pracoviste, N'K_'+CK.Rada + N'|' + CK.kod) + ISNULL(N'|' + CS.Kod,''), 
  RANKING=MIN(A_P.priorita), 
  resource_count=1, 
  IDHeKey_TypeS=N'Alt Postupy - Pracoviště/Koop' 
FROM TabPostup P 
  INNER JOIN TabCzmeny ZOd ON (ZOd.ID=P.ZmenaOd) 
  LEFT OUTER JOIN TabCzmeny ZDo ON (ZDo.ID=P.ZmenaDo) 
  INNER JOIN TabKmenZbozi KZV ON (KZV.IdKusovnik=P.dilec AND (P.IDVarianta IS NULL OR KZV.IdVarianta=P.IDVarianta) AND KZV.Blokovano=0) 
  INNER JOIN TabSkupinyZbozi SZ ON (SZ.SkupZbo=KZV.SkupZbo) 
  LEFT OUTER JOIN TabSkupinyZbozi_Ext SZ_E ON (SZ_E.ID=SZ.ID) 
  INNER JOIN TabAltPostup A_P ON (A_P.P_ID1=P.ID1 AND (ISNULL(A_P.pracoviste,0)<>ISNULL(P.pracoviste,0) OR ISNULL(A_P.IDStroje,0)<>ISNULL(P.IDStroje,0) OR ISNULL(A_P.IDkooperace,0)<>ISNULL(P.IDkooperace,0))) 
  INNER JOIN TabCzmeny A_ZOd ON (A_ZOd.ID=A_P.ZmenaOd) 
  LEFT OUTER JOIN TabCzmeny A_ZDo ON (A_ZDo.ID=A_P.ZmenaDo) 
  LEFT OUTER JOIN TabCPraco CP ON (CP.ID=A_P.pracoviste) 
  LEFT OUTER JOIN TabCisStroju CS ON (CS.ID=A_P.IDStroje) 
  LEFT OUTER JOIN TabCKoop CK ON (CK.ID=A_P.IDkooperace) 
WHERE ZOd.platnost=1 AND ZOd.datum<=convert(date,GETDATE()) AND (ZDo.platnost=0 OR P.ZmenaDo IS NULL OR (ZDo.platnost=1 AND ZDo.datum>convert(date,GETDATE()) )) AND 
      A_ZOd.platnost=1 AND A_ZOd.datum<=convert(date,GETDATE()) AND (A_ZDo.platnost=0 OR A_P.ZmenaDo IS NULL OR (A_ZDo.platnost=1 AND A_ZDo.datum>convert(date,GETDATE()) )) AND 
      ISNULL(P.Pracoviste,0) NOT IN (164, 51) AND ISNULL(A_P.Pracoviste,0) NOT IN (164, 51) AND 
      SZ_E._EXT_RS_Logis=1 
GROUP BY KZV.SkupZbo+N'|'+KZV.RegCis, ISNULL(TRY_CONVERT(int,P.Operace),0), ISNULL(CP.IDTabStrom + N'|' + CP.Pracoviste, N'K_'+CK.Rada + N'|' + CK.kod) + ISNULL(N'|' + CS.Kod,'') 
UNION ALL 
SELECT 
  ROUTING_NAME = KZV.SkupZbo+N'|'+KZV.RegCis+N'|'+ZM.Kod, 
  SEQUENCE_NUMBER =ISNULL(TRY_CONVERT(int,P.Operace),0), 
  RESOURCE_NAME = ISNULL(CP.IDTabStrom + N'|' + CP.Pracoviste, N'K_'+CK.Rada + N'|' + CK.kod) + ISNULL(N'|' + CS.Kod,''), 
  RANKING=0, 
  resource_count=1, 
  IDHeKey_TypeS=N'Postupy - Pracoviště/Koop ZakazModif' 
FROM TabZakazModifDilce ZMD 
  INNER JOIN TabZakazModif ZM ON (ZM.ID=ZMD.IDZakazModif AND ZM.Blokovano=0) 
  INNER JOIN TabKmenZbozi KZV ON (KZV.ID=ZMD.IDKmenZbozi AND KZV.Blokovano=0) 
  INNER JOIN TabSkupinyZbozi SZ ON (SZ.SkupZbo=KZV.SkupZbo) 
  LEFT OUTER JOIN TabSkupinyZbozi_Ext SZ_E ON (SZ_E.ID=SZ.ID) 
  INNER JOIN TabPostup P ON (P.Dilec=ZMD.IDKmenZbozi AND P.IDZakazModif=ZMD.IDZakazModif) 
  LEFT OUTER JOIN TabCPraco CP ON (CP.ID=P.pracoviste) 
  LEFT OUTER JOIN TabCisStroju CS ON (CS.ID=P.IDStroje) 
  LEFT OUTER JOIN TabCKoop CK ON (CK.ID=P.IDkooperace) 
WHERE ZMD.TPVModif=1 AND 
      ISNULL(P.Pracoviste,0) NOT IN (164, 51) AND 
      SZ_E._EXT_RS_Logis=1 
UNION ALL 
SELECT 
  ROUTING_NAME = KZV.SkupZbo+N'|'+KZV.RegCis+N'|'+ZM.Kod, 
  SEQUENCE_NUMBER =ISNULL(TRY_CONVERT(int,P.Operace),0), 
  RESOURCE_NAME = ISNULL(CP.IDTabStrom + N'|' + CP.Pracoviste, N'K_'+CK.Rada + N'|' + CK.kod) + ISNULL(N'|' + CS.Kod,''), 
  RANKING=MIN(A_P.priorita), 
  resource_count=1, 
  IDHeKey_TypeS=N'Alt Postupy - Pracoviště/Koop ZakazModif' 
FROM TabZakazModifDilce ZMD 
  INNER JOIN TabZakazModif ZM ON (ZM.ID=ZMD.IDZakazModif AND ZM.Blokovano=0) 
  INNER JOIN TabKmenZbozi KZV ON (KZV.ID=ZMD.IDKmenZbozi AND KZV.Blokovano=0) 
  INNER JOIN TabSkupinyZbozi SZ ON (SZ.SkupZbo=KZV.SkupZbo) 
  LEFT OUTER JOIN TabSkupinyZbozi_Ext SZ_E ON (SZ_E.ID=SZ.ID) 
  INNER JOIN TabPostup P ON (P.Dilec=ZMD.IDKmenZbozi AND P.IDZakazModif=ZMD.IDZakazModif) 
  INNER JOIN TabAltPostup A_P ON (A_P.P_ID1=P.ID1 AND (ISNULL(A_P.pracoviste,0)<>ISNULL(P.pracoviste,0) OR ISNULL(A_P.IDStroje,0)<>ISNULL(P.IDStroje,0) OR ISNULL(A_P.IDkooperace,0)<>ISNULL(P.IDkooperace,0))) 
  LEFT OUTER JOIN TabCPraco CP ON (CP.ID=A_P.pracoviste) 
  LEFT OUTER JOIN TabCisStroju CS ON (CS.ID=A_P.IDStroje) 
  LEFT OUTER JOIN TabCKoop CK ON (CK.ID=A_P.IDkooperace) 
WHERE ZMD.TPVModif=1 AND 
      ISNULL(P.Pracoviste,0) NOT IN (164, 51) AND ISNULL(A_P.Pracoviste,0) NOT IN (164, 51) AND 
      SZ_E._EXT_RS_Logis=1 
GROUP BY KZV.SkupZbo+N'|'+KZV.RegCis+N'|'+ZM.Kod, ISNULL(TRY_CONVERT(int,P.Operace),0), ISNULL(CP.IDTabStrom + N'|' + CP.Pracoviste, N'K_'+CK.Rada + N'|' + CK.kod) + ISNULL(N'|' + CS.Kod,'') 
UNION ALL 
SELECT DISTINCT 
  ROUTING_NAME = RTRIM(P.Rada)+N'|'+convert(nvarchar(10),P.Prikaz), 
  SEQUENCE_NUMBER =ISNULL(PrP_E._EXT_RS_PoradiLogis, ISNULL(TRY_CONVERT(int,PrP.Operace),0)), 
  RESOURCE_NAME = ISNULL(CP.IDTabStrom + N'|' + CP.Pracoviste, N'K_'+CK.Rada + N'|' + CK.kod) + ISNULL(N'|' + CS.Kod,''), 
  RANKING=0, 
  resource_count=1, 
  IDHeKey_TypeS=N'PrP - Pracoviště/Koop' 
FROM TabPrikaz P 
  INNER JOIN TabKmenZbozi KZV ON (KZV.ID=P.IDTabKmen) 
  INNER JOIN TabSkupinyZbozi SZ ON (SZ.SkupZbo=KZV.SkupZbo) 
  LEFT OUTER JOIN TabSkupinyZbozi_Ext SZ_E ON (SZ_E.ID=SZ.ID) 
  INNER JOIN TabRadyPrikazu RP ON (RP.Rada=P.Rada) 
  LEFT OUTER JOIN TabRadyPrikazu_Ext RP_E ON (RP_E.ID=RP.ID) 
  INNER JOIN TabPrPostup PrP ON (PrP.IDPrikaz=P.ID AND PrP.Prednastaveno=1 AND PrP.IDOdchylkyDo IS NULL AND PrP.Dilec=P.IDTabKmen AND PrP.Uzavreno=0) 
  LEFT OUTER JOIN TabPrPostup_Ext PrP_E ON (PrP_E.ID=PrP.ID) 
  LEFT OUTER JOIN TabCPraco CP ON (CP.ID=PrP.pracoviste) 
  LEFT OUTER JOIN TabCisStroju CS ON (CS.ID=PrP.IDStroje) 
  LEFT OUTER JOIN TabCKoop CK ON (CK.ID=PrP.IDkooperace) 
WHERE P.StavPrikazu IN (20,30,40) AND 
      ISNULL(PrP.Pracoviste,0) NOT IN (164, 51) AND 
      SZ_E._EXT_RS_Logis=1 AND RP_E._EXT_RS_Logis=1 AND (PrP.pracoviste IS NOT NULL OR PrP.IDkooperace IS NOT NULL) 
      AND KZV.SkupZbo<>'932'
UNION ALL 
SELECT 
  ROUTING_NAME = RTRIM(P.Rada)+N'|'+convert(nvarchar(10),P.Prikaz), 
  SEQUENCE_NUMBER =ISNULL(PrP_E._EXT_RS_PoradiLogis, ISNULL(TRY_CONVERT(int,PrP.Operace),0)), 
  RESOURCE_NAME = ISNULL(CP.IDTabStrom + N'|' + CP.Pracoviste, N'K_'+CK.Rada + N'|' + CK.kod) + ISNULL(N'|' + CS.Kod,''), 
  RANKING=MIN(A_PrP.priorita+1), 
  resource_count=1, 
  IDHeKey_TypeS=N'Alt PrP - Pracoviště/Koop' 
FROM TabPrikaz P 
  INNER JOIN TabKmenZbozi KZV ON (KZV.ID=P.IDTabKmen) 
  INNER JOIN TabSkupinyZbozi SZ ON (SZ.SkupZbo=KZV.SkupZbo) 
  LEFT OUTER JOIN TabSkupinyZbozi_Ext SZ_E ON (SZ_E.ID=SZ.ID) 
  INNER JOIN TabRadyPrikazu RP ON (RP.Rada=P.Rada) 
  LEFT JOIN TabRadyPrikazu_Ext RP_E ON (RP_E.ID=RP.ID) 
  INNER JOIN TabPrPostup PrP ON (PrP.IDPrikaz=P.ID AND PrP.Prednastaveno=1 AND PrP.IDOdchylkyDo IS NULL AND PrP.Dilec=P.IDTabKmen AND PrP.Uzavreno=0) 
  LEFT OUTER JOIN TabPrPostup_Ext PrP_E ON (PrP_E.ID=PrP.ID) 
  INNER JOIN TabPrPostup A_PrP ON (A_PrP.IDPrikaz=P.ID AND A_PrP.Doklad=PrP.Doklad AND A_PrP.Prednastaveno=0 AND A_PrP.IDOdchylkyDo IS NULL AND A_PrP.Dilec=P.IDTabKmen AND A_PrP.Uzavreno=0 AND 
                                   (ISNULL(A_PrP.pracoviste,0)<>ISNULL(PrP.pracoviste,0) OR ISNULL(A_PrP.IDStroje,0)<>ISNULL(PrP.IDStroje,0) OR ISNULL(A_PrP.IDkooperace,0)<>ISNULL(PrP.IDkooperace,0))) 
  LEFT OUTER JOIN TabCPraco CP ON (CP.ID=A_PrP.pracoviste) 
  LEFT OUTER JOIN TabCisStroju CS ON (CS.ID=A_PrP.IDStroje) 
  LEFT OUTER JOIN TabCKoop CK ON (CK.ID=A_PrP.IDkooperace) 
WHERE P.StavPrikazu IN (20,30,40) AND 
      ISNULL(PrP.Pracoviste,0) NOT IN (164, 51) AND ISNULL(A_PrP.Pracoviste,0) NOT IN (164, 51) AND 
      SZ_E._EXT_RS_Logis=1 AND RP_E._EXT_RS_Logis=1 AND (A_PrP.pracoviste IS NOT NULL OR A_PrP.IDkooperace IS NOT NULL) 
      AND KZV.SkupZbo<>'932'
GROUP BY RTRIM(P.Rada)+N'|'+convert(nvarchar(10),P.Prikaz), ISNULL(PrP_E._EXT_RS_PoradiLogis, ISNULL(TRY_CONVERT(int,PrP.Operace),0)), ISNULL(CP.IDTabStrom + N'|' + CP.Pracoviste, N'K_'+CK.Rada + N'|' + CK.kod) + ISNULL(N'|' + CS.Kod,'') 
GO

