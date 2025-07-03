USE [RayService]
GO

/****** Object:  View [dbo].[hvw_APSLogis_IN_MANUFACORDER]    Script Date: 03.07.2025 12:59:33 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO



CREATE VIEW [dbo].[hvw_APSLogis_IN_MANUFACORDER] AS SELECT 
  MFG_ORDER_ID=RTRIM(P.Rada)+N'|'+convert(nvarchar(10),P.Prikaz), 
  ITEM_ID= KZ.SkupZbo+N'|'+KZ.RegCis, 
  BOM_ID= RTRIM(P.Rada)+N'|'+convert(nvarchar(10),P.Prikaz), 
  ROUTING_NAME =RTRIM(P.Rada)+N'|'+convert(nvarchar(10),P.Prikaz), 
  QTY_ORDERED =P.kusy_zad, 
  QTY_COMPLETED = P.kusy_zad-((SELECT dbo.hf_Max_N19_6(0.0, P.kusy_zive - ISNULL(SUM(PZ.prepmnozstvi*PZ.mnozstvi), 0.0)) FROM TabPohybyZbozi PZ WITH (NOLOCK) WHERE PZ.druhPohybuZbo=0 AND PZ.SkutecneDatReal IS NULL AND PZ.TypVyrobnihoDokladu=0 AND PZ.IDPrikaz=P.ID)), 
  FIRMED=1, 
  IDHeKey=P.ID 
FROM TabPrikaz P 
  INNER JOIN TabKmenZbozi KZ ON (KZ.ID=P.IDTabKmen) 
  INNER JOIN TabSkupinyZbozi SZ ON (SZ.SkupZbo=KZ.SkupZbo) 
  LEFT OUTER JOIN TabSkupinyZbozi_Ext SZ_E ON (SZ_E.ID=SZ.ID) 
  INNER JOIN TabRadyPrikazu RP ON (RP.Rada=P.Rada) 
  LEFT OUTER JOIN TabRadyPrikazu_Ext RP_E ON (RP_E.ID=RP.ID) 
WHERE P.StavPrikazu IN (20,30,40) AND 
      SZ_E._EXT_RS_Logis=1 AND RP_E._EXT_RS_Logis=1 
      AND KZ.SkupZbo <> '932'
GO

