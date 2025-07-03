USE [RayService]
GO

/****** Object:  View [dbo].[hvw_APSLogis_IN_PURCHASEORDER]    Script Date: 03.07.2025 13:05:22 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

CREATE VIEW [dbo].[hvw_APSLogis_IN_PURCHASEORDER] AS SELECT 
  PURCHASE_ORDER_ID = DZ.ParovaciZnak+N'|'+convert(nvarchar(10),PZ.ID), 
  SUPPLIER_ID =DZ.CisloOrg, 
  ITEM_ID =KZ.SkupZbo+N'|'+KZ.RegCis, 
  LOCATION_ID =SS.IDSklad, 
  QTY_OPEN =(PZ.Mnozstvi-PZ.MnOdebrane)*PZ.PrepMnozstvi, 
  SCHEDULED_DELIVERY_DATE = ISNULL(PZ.PotvrzDatDod+KZ.LhutaNaskladneni,DZ.DatPorizeni+KZ.DodaciLhuta+KZ.LhutaNaskladneni), 
  IDHeKey_TypeS=N'Obj. vydané', 
  IDHeKey_H=DZ.ID, 
  IDHeKey_P=PZ.ID 
FROM TabDokladyZbozi DZ WITH (NOLOCK) 
  INNER JOIN TabDruhDokZbo DD ON (DD.RadaDokladu=DZ.RadaDokladu AND DD.DruhPohybuZbo=DZ.DruhPohybuZbo) 
  INNER JOIN TabPohybyZbozi PZ WITH (NOLOCK) ON (PZ.IDDoklad=DZ.ID) 
  INNER JOIN TabStavSkladu SS WITH (NOLOCK) ON (SS.ID=PZ.IDZboSklad) 
  INNER JOIN TabKmenZbozi KZ WITH (NOLOCK) ON (KZ.ID=SS.IDKmenZbozi AND (KZ.material=1 AND KZ.RezijniMat=0 OR KZ.Dilec=1) AND KZ.Sluzba=0) 
  INNER JOIN TabSkupinyZbozi SZ ON (SZ.SkupZbo=KZ.SkupZbo) 
  LEFT OUTER JOIN TabSkupinyZbozi_Ext SZ_E ON (SZ_E.ID=SZ.ID) 
  INNER JOIN TabStrom S WITH (NOLOCK) ON (S.Cislo=SS.IDSklad AND S.Cislo IN (N'100', N'200', N'20000280', N'10000140144', N'10000140999', N'20000275900', N'20000280282', N'10000140998', N'20000280998')) 
WHERE DZ.CisloOrg IS NOT NULL AND DZ.druhpohybuzbo=6 AND DZ.poradovecislo>0 AND DZ.splneno=0 AND PZ.splneno=0 AND 
      (PZ.Mnozstvi-PZ.MnOdebrane)*PZ.PrepMnozstvi > 0.0 AND 
      SZ_E._EXT_RS_Logis=1 
GO

