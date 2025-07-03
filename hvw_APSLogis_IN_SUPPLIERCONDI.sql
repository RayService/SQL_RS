USE [RayService]
GO

/****** Object:  View [dbo].[hvw_APSLogis_IN_SUPPLIERCONDI]    Script Date: 03.07.2025 13:23:44 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

CREATE VIEW [dbo].[hvw_APSLogis_IN_SUPPLIERCONDI] AS SELECT 
  SUPPLIER_ID=CO.CisloOrg, 
  ITEM_ID=KZ.SkupZbo+N'|'+KZ.RegCis, 
  LOCATION_ID = MAX(PKZ.VychoziSklad), 
  MIN_QTY_ORDERED=MAX(CASE WHEN KZ.Minimum_Dodavatel<=0 THEN 1.0 ELSE KZ.Minimum_Dodavatel END), 
  MAX_QTY_ORDERED=NULL, 
  DELIVERY_LEAD_TIME=MAX(CASE WHEN KZ.DodaciLhuta<=0 THEN 7 ELSE KZ.DodaciLhuta * (CASE KZ.TypDodaciLhuty WHEN 1 THEN 30 WHEN 2 THEN 365 ELSE 1 END) END + KZ.LhutaNaskladneni), 
  QTY_STEP=CASE WHEN MAX(KZ.Minimum_Baleni_Dodavatel)>0 THEN MAX(KZ.Minimum_Baleni_Dodavatel) END, 
  RANK=1, 
  PO_CUMULATION_WINDOW_DAYS=MAX(KZ_E._EXT_RS_AccumDays) 
FROM TabKmenZbozi KZ 
  INNER JOIN TabSkupinyZbozi SZ ON (SZ.SkupZbo=KZ.SkupZbo) 
  LEFT OUTER JOIN TabSkupinyZbozi_Ext SZ_E ON (SZ_E.ID=SZ.ID) 
  LEFT OUTER JOIN TabKmenZbozi_Ext KZ_E ON (KZ_E.ID=KZ.ID) 
  LEFT OUTER JOIN TabSortiment ts ON (ts.ID=KZ.IdSortiment) 
  LEFT OUTER JOIN TabParametryKmeneZbozi PKZ ON (PKZ.IDKmenZbozi=KZ.ID) 
  INNER JOIN TabCisOrg CO ON (CO.CisloOrg=KZ.Aktualni_Dodavatel AND CO.Stav=0) 
WHERE (KZ.Material=1 AND KZ.RezijniMat=0 OR KZ.Dilec=1 AND ts.ID=20/*VD*/) AND KZ.Blokovano=0 AND SZ_E._EXT_RS_Logis=1 
GROUP BY CO.CisloOrg, KZ.SkupZbo+N'|'+KZ.RegCis 
GO

