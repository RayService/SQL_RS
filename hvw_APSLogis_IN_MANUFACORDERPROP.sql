USE [RayService]
GO

/****** Object:  View [dbo].[hvw_APSLogis_IN_MANUFACORDERPROP]    Script Date: 03.07.2025 13:00:03 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO



CREATE VIEW [dbo].[hvw_APSLogis_IN_MANUFACORDERPROP] AS SELECT 
  MFG_ORDER_ID=RTRIM(P.Rada)+N'|'+convert(nvarchar(10),P.Prikaz), 
  ATTRIBUTE_NAME=N'ORIG_MFG_ORDER_ID', 
  STRING_VALUE=P_E._APSLogis_MFG_ORDER_ID, 
  NUMERIC_VALUE=NULL 
FROM TabPrikaz P 
  INNER JOIN TabPrikaz_Ext P_E ON (P_E.ID=P.ID AND P_E._APSLogis_MFG_ORDER_ID IS NOT NULL) 
  INNER JOIN TabKmenZbozi KZ ON (KZ.ID=P.IDTabKmen) 
  INNER JOIN TabSkupinyZbozi SZ ON (SZ.SkupZbo=KZ.SkupZbo) 
  LEFT OUTER JOIN TabSkupinyZbozi_Ext SZ_E ON (SZ_E.ID=SZ.ID) 
  INNER JOIN TabRadyPrikazu RP ON (RP.Rada=P.Rada) 
  LEFT OUTER JOIN TabRadyPrikazu_Ext RP_E ON (RP_E.ID=RP.ID) 
WHERE P.StavPrikazu IN (20,30,40) AND 
      SZ_E._EXT_RS_Logis=1 AND RP_E._EXT_RS_Logis=1 
      AND KZ.SkupZbo<>'932'
UNION ALL 
SELECT 
  MFG_ORDER_ID=RTRIM(P.Rada)+N'|'+convert(nvarchar(10),P.Prikaz), 
  ATTRIBUTE_NAME=N'RAY_Stav_Prikazu', 
  STRING_VALUE=CASE P.StavPrikazu WHEN 20 THEN N'Předzpracováno' WHEN 30 THEN N'Zadáno' WHEN 40 THEN N'Pozastaveno' END, 
  NUMERIC_VALUE=NULL 
FROM TabPrikaz P 
  INNER JOIN TabKmenZbozi KZ ON (KZ.ID=P.IDTabKmen) 
  INNER JOIN TabSkupinyZbozi SZ ON (SZ.SkupZbo=KZ.SkupZbo) 
  LEFT OUTER JOIN TabSkupinyZbozi_Ext SZ_E ON (SZ_E.ID=SZ.ID) 
  INNER JOIN TabRadyPrikazu RP ON (RP.Rada=P.Rada) 
  LEFT OUTER JOIN TabRadyPrikazu_Ext RP_E ON (RP_E.ID=RP.ID) 
WHERE P.StavPrikazu IN (20,30,40) AND 
      SZ_E._EXT_RS_Logis=1 AND RP_E._EXT_RS_Logis=1 
      AND KZ.SkupZbo<>'932'
UNION ALL 
SELECT 
  MFG_ORDER_ID=RTRIM(P.Rada)+N'|'+convert(nvarchar(10),P.Prikaz), 
  ATTRIBUTE_NAME=N'RAY_SkupinaPlanu', 
  STRING_VALUE=P.SkupinaPlanu, 
  NUMERIC_VALUE=NULL 
FROM TabPrikaz P 
  INNER JOIN TabKmenZbozi KZ ON (KZ.ID=P.IDTabKmen) 
  INNER JOIN TabSkupinyZbozi SZ ON (SZ.SkupZbo=KZ.SkupZbo) 
  LEFT OUTER JOIN TabSkupinyZbozi_Ext SZ_E ON (SZ_E.ID=SZ.ID) 
  INNER JOIN TabRadyPrikazu RP ON (RP.Rada=P.Rada) 
  LEFT OUTER JOIN TabRadyPrikazu_Ext RP_E ON (RP_E.ID=RP.ID) 
WHERE P.StavPrikazu IN (20,30,40) AND 
      SZ_E._EXT_RS_Logis=1 AND RP_E._EXT_RS_Logis=1 AND 
      P.SkupinaPlanu IS NOT NULL 
      AND KZ.SkupZbo<>'932'
GO

