USE [RayService]
GO

/****** Object:  View [dbo].[hvw_APSLogis_IN_INVENTORY]    Script Date: 03.07.2025 12:53:42 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

CREATE VIEW [dbo].[hvw_APSLogis_IN_INVENTORY] AS SELECT 
  MATERIAL_ID=KZ.SkupZbo+N'|'+KZ.RegCis+N'|'+SS.IDSklad, 
  ITEM_ID=KZ.SkupZbo+N'|'+KZ.RegCis, 
  LOCATION_ID=SS.IDSklad, 
  QUANTITY=SS.MnozSPrijBezVyd 
FROM TabStavSkladu SS WITH(NOLOCK) 
  INNER JOIN TabKmenZbozi KZ WITH(NOLOCK) ON (KZ.ID=SS.IDKmenZbozi AND (KZ.material=1 AND KZ.RezijniMat=0 OR KZ.Dilec=1) AND KZ.blokovano=0) 
  INNER JOIN TabSkupinyZbozi SZ ON (SZ.SkupZbo=KZ.SkupZbo) 
  LEFT OUTER JOIN TabSkupinyZbozi_Ext SZ_E ON (SZ_E.ID=SZ.ID) 
  INNER JOIN TabStrom S WITH(NOLOCK) ON (S.Cislo=SS.IDSklad AND S.Cislo IN (N'100', N'200', N'20000280', N'10000140144', N'10000140999', N'20000275900', N'20000280282', N'10000140998', N'20000280998', N'20000280999')) 
WHERE SS.MnozSPrijBezVyd>0.0 AND 
      SZ_E._EXT_RS_Logis=1 
GO

