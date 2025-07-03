USE [RayService]
GO

/****** Object:  View [dbo].[hvw_APSLogis_IN_DEMANDORDERPROPERTY]    Script Date: 03.07.2025 12:53:32 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

CREATE VIEW [dbo].[hvw_APSLogis_IN_DEMANDORDERPROPERTY] AS SELECT 
  DEMAND_ORDER_ID =PZ.CisloZakazky+N'|'+convert(nvarchar(10),PZ.ID), 
  ATTRIBUTE_NAME=N'RAY_SkupinaPlanu', 
  STRING_VALUE=PZ_E._EXT_RS_SkupinaPlanu, 
  NUMERIC_VALUE=NULL, 
  BOOL_VALUE=NULL 
FROM TabDokladyZbozi DZ WITH (NOLOCK) 
  INNER JOIN TabPohybyZbozi PZ WITH (NOLOCK) ON (PZ.IDDoklad=DZ.ID) 
  INNER JOIN TabPohybyZbozi_Ext PZ_E ON (PZ_E.ID=PZ.ID AND PZ_E._EXT_RS_SkupinaPlanu IS NOT NULL) 
  INNER JOIN TabStavSkladu SS WITH (NOLOCK) ON (SS.ID=PZ.IDZboSklad) 
  INNER JOIN TabKmenZbozi KZ WITH (NOLOCK) ON (KZ.ID=SS.IDKmenZbozi AND (KZ.Dilec=1 OR (KZ.material=1 AND KZ.RezijniMat=0)) AND KZ.Sluzba=0) 
  INNER JOIN TabSkupinyZbozi SZ ON (SZ.SkupZbo=KZ.SkupZbo) 
  LEFT OUTER JOIN TabSkupinyZbozi_Ext SZ_E ON (SZ_E.ID=SZ.ID) 
WHERE DZ.DruhPohybuZbo=9 AND DZ.Splneno=0 AND PZ.Splneno=0 AND (PZ.Mnozstvi-PZ.MnOdebrane)*PZ.PrepMnozstvi > 0.0 AND 
      SZ_E._EXT_RS_Logis=1 AND DZ.IDSklad IN (N'200', N'20000280282', N'10000115', N'100') AND KZ.blokovano=0 AND EXISTS(SELECT * FROM TabPohybyZbozi_Ext PZ_E WHERE PZ_E.ID=PZ.ID AND PZ_E._EXT_RS_PromisedStockingDate IS NOT NULL) 
UNION ALL 
SELECT 
  DEMAND_ORDER_ID =PZ.CisloZakazky+N'|'+convert(nvarchar(10),PZ.ID), 
  ATTRIBUTE_NAME=N'RAY_RadaPlanu', 
  STRING_VALUE=PZ_E._EXT_RS_RadaPlanu, 
  NUMERIC_VALUE=NULL, 
  BOOL_VALUE=NULL 
FROM TabDokladyZbozi DZ WITH (NOLOCK) 
  INNER JOIN TabPohybyZbozi PZ WITH (NOLOCK) ON (PZ.IDDoklad=DZ.ID) 
  INNER JOIN TabPohybyZbozi_Ext PZ_E ON (PZ_E.ID=PZ.ID AND PZ_E._EXT_RS_RadaPlanu IS NOT NULL) 
  INNER JOIN TabStavSkladu SS WITH (NOLOCK) ON (SS.ID=PZ.IDZboSklad) 
  INNER JOIN TabKmenZbozi KZ WITH (NOLOCK) ON (KZ.ID=SS.IDKmenZbozi AND (KZ.Dilec=1 OR (KZ.material=1 AND KZ.RezijniMat=0)) AND KZ.Sluzba=0) 
  INNER JOIN TabSkupinyZbozi SZ ON (SZ.SkupZbo=KZ.SkupZbo) 
  LEFT OUTER JOIN TabSkupinyZbozi_Ext SZ_E ON (SZ_E.ID=SZ.ID) 
WHERE DZ.DruhPohybuZbo=9 AND DZ.Splneno=0 AND PZ.Splneno=0 AND (PZ.Mnozstvi-PZ.MnOdebrane)*PZ.PrepMnozstvi > 0.0 AND 
      SZ_E._EXT_RS_Logis=1 AND DZ.IDSklad IN (N'200', N'20000280282', N'10000115', N'100') AND KZ.blokovano=0 AND EXISTS(SELECT * FROM TabPohybyZbozi_Ext PZ_E WHERE PZ_E.ID=PZ.ID AND PZ_E._EXT_RS_PromisedStockingDate IS NOT NULL) 
UNION ALL 
SELECT 
  DEMAND_ORDER_ID =PZ.CisloZakazky+N'|'+convert(nvarchar(10),PZ.ID), 
  ATTRIBUTE_NAME=N'RAY_FAIR', 
  STRING_VALUE=NULL, 
  NUMERIC_VALUE=NULL, 
  BOOL_VALUE=PZ_E._FAIR 
FROM TabDokladyZbozi DZ WITH (NOLOCK) 
  INNER JOIN TabPohybyZbozi PZ WITH (NOLOCK) ON (PZ.IDDoklad=DZ.ID) 
  INNER JOIN TabPohybyZbozi_Ext PZ_E ON (PZ_E.ID=PZ.ID AND PZ_E._FAIR IS NOT NULL) 
  INNER JOIN TabStavSkladu SS WITH (NOLOCK) ON (SS.ID=PZ.IDZboSklad) 
  INNER JOIN TabKmenZbozi KZ WITH (NOLOCK) ON (KZ.ID=SS.IDKmenZbozi AND (KZ.Dilec=1 OR (KZ.material=1 AND KZ.RezijniMat=0)) AND KZ.Sluzba=0) 
  INNER JOIN TabSkupinyZbozi SZ ON (SZ.SkupZbo=KZ.SkupZbo) 
  LEFT OUTER JOIN TabSkupinyZbozi_Ext SZ_E ON (SZ_E.ID=SZ.ID) 
WHERE DZ.DruhPohybuZbo=9 AND DZ.Splneno=0 AND PZ.Splneno=0 AND (PZ.Mnozstvi-PZ.MnOdebrane)*PZ.PrepMnozstvi > 0.0 AND 
      SZ_E._EXT_RS_Logis=1 AND DZ.IDSklad IN (N'200', N'20000280282', N'10000115', N'100') AND KZ.blokovano=0 AND EXISTS(SELECT * FROM TabPohybyZbozi_Ext PZ_E WHERE PZ_E.ID=PZ.ID AND PZ_E._EXT_RS_PromisedStockingDate IS NOT NULL) 
UNION ALL 
SELECT 
  DEMAND_ORDER_ID =PZ.CisloZakazky+N'|'+convert(nvarchar(10),PZ.ID), 
  ATTRIBUTE_NAME=N'RAY_DeltaFair', 
  STRING_VALUE=NULL, 
  NUMERIC_VALUE=NULL, 
  BOOL_VALUE=PZ_E._DeltaFair 
FROM TabDokladyZbozi DZ WITH (NOLOCK) 
  INNER JOIN TabPohybyZbozi PZ WITH (NOLOCK) ON (PZ.IDDoklad=DZ.ID) 
  INNER JOIN TabPohybyZbozi_Ext PZ_E ON (PZ_E.ID=PZ.ID AND PZ_E._DeltaFair IS NOT NULL) 
  INNER JOIN TabStavSkladu SS WITH (NOLOCK) ON (SS.ID=PZ.IDZboSklad) 
  INNER JOIN TabKmenZbozi KZ WITH (NOLOCK) ON (KZ.ID=SS.IDKmenZbozi AND (KZ.Dilec=1 OR (KZ.material=1 AND KZ.RezijniMat=0)) AND KZ.Sluzba=0) 
  INNER JOIN TabSkupinyZbozi SZ ON (SZ.SkupZbo=KZ.SkupZbo) 
  LEFT OUTER JOIN TabSkupinyZbozi_Ext SZ_E ON (SZ_E.ID=SZ.ID) 
WHERE DZ.DruhPohybuZbo=9 AND DZ.Splneno=0 AND PZ.Splneno=0 AND (PZ.Mnozstvi-PZ.MnOdebrane)*PZ.PrepMnozstvi > 0.0 AND 
      SZ_E._EXT_RS_Logis=1 AND DZ.IDSklad IN (N'200', N'20000280282', N'10000115', N'100') AND KZ.blokovano=0 AND EXISTS(SELECT * FROM TabPohybyZbozi_Ext PZ_E WHERE PZ_E.ID=PZ.ID AND PZ_E._EXT_RS_PromisedStockingDate IS NOT NULL) 
UNION ALL 
SELECT 
  DEMAND_ORDER_ID =PZ.CisloZakazky+N'|'+convert(nvarchar(10),PZ.ID), 
  ATTRIBUTE_NAME=N'RAY_FAIRint', 
  STRING_VALUE=NULL, 
  NUMERIC_VALUE=NULL, 
  BOOL_VALUE=PZ_E._FAIRint 
FROM TabDokladyZbozi DZ WITH (NOLOCK) 
  INNER JOIN TabPohybyZbozi PZ WITH (NOLOCK) ON (PZ.IDDoklad=DZ.ID) 
  INNER JOIN TabPohybyZbozi_Ext PZ_E ON (PZ_E.ID=PZ.ID AND PZ_E._FAIRint IS NOT NULL) 
  INNER JOIN TabStavSkladu SS WITH (NOLOCK) ON (SS.ID=PZ.IDZboSklad) 
  INNER JOIN TabKmenZbozi KZ WITH (NOLOCK) ON (KZ.ID=SS.IDKmenZbozi AND (KZ.Dilec=1 OR (KZ.material=1 AND KZ.RezijniMat=0)) AND KZ.Sluzba=0) 
  INNER JOIN TabSkupinyZbozi SZ ON (SZ.SkupZbo=KZ.SkupZbo) 
  LEFT OUTER JOIN TabSkupinyZbozi_Ext SZ_E ON (SZ_E.ID=SZ.ID) 
WHERE DZ.DruhPohybuZbo=9 AND DZ.Splneno=0 AND PZ.Splneno=0 AND (PZ.Mnozstvi-PZ.MnOdebrane)*PZ.PrepMnozstvi > 0.0 AND 
      SZ_E._EXT_RS_Logis=1 AND DZ.IDSklad IN (N'200', N'20000280282', N'10000115', N'100') AND KZ.blokovano=0 AND EXISTS(SELECT * FROM TabPohybyZbozi_Ext PZ_E WHERE PZ_E.ID=PZ.ID AND PZ_E._EXT_RS_PromisedStockingDate IS NOT NULL) 
UNION ALL 
SELECT 
  DEMAND_ORDER_ID =PZ.CisloZakazky+N'|'+convert(nvarchar(10),PZ.ID), 
  ATTRIBUTE_NAME=N'RAY_fair_not_required', 
  STRING_VALUE=NULL, 
  NUMERIC_VALUE=NULL, 
  BOOL_VALUE=PZ_E._EXT_RS_fair_not_required 
FROM TabDokladyZbozi DZ WITH (NOLOCK) 
  INNER JOIN TabPohybyZbozi PZ WITH (NOLOCK) ON (PZ.IDDoklad=DZ.ID) 
  INNER JOIN TabPohybyZbozi_Ext PZ_E ON (PZ_E.ID=PZ.ID AND PZ_E._EXT_RS_fair_not_required IS NOT NULL) 
  INNER JOIN TabStavSkladu SS WITH (NOLOCK) ON (SS.ID=PZ.IDZboSklad) 
  INNER JOIN TabKmenZbozi KZ WITH (NOLOCK) ON (KZ.ID=SS.IDKmenZbozi AND (KZ.Dilec=1 OR (KZ.material=1 AND KZ.RezijniMat=0)) AND KZ.Sluzba=0) 
  INNER JOIN TabSkupinyZbozi SZ ON (SZ.SkupZbo=KZ.SkupZbo) 
  LEFT OUTER JOIN TabSkupinyZbozi_Ext SZ_E ON (SZ_E.ID=SZ.ID) 
WHERE DZ.DruhPohybuZbo=9 AND DZ.Splneno=0 AND PZ.Splneno=0 AND (PZ.Mnozstvi-PZ.MnOdebrane)*PZ.PrepMnozstvi > 0.0 AND 
      SZ_E._EXT_RS_Logis=1 AND DZ.IDSklad IN (N'200', N'20000280282', N'10000115', N'100') AND KZ.blokovano=0 AND EXISTS(SELECT * FROM TabPohybyZbozi_Ext PZ_E WHERE PZ_E.ID=PZ.ID AND PZ_E._EXT_RS_PromisedStockingDate IS NOT NULL) 
UNION ALL 
SELECT 
  DEMAND_ORDER_ID =PZ.CisloZakazky+N'|'+convert(nvarchar(10),PZ.ID), 
  ATTRIBUTE_NAME=N'RAY_vg_protokol', 
  STRING_VALUE=NULL, 
  NUMERIC_VALUE=NULL, 
  BOOL_VALUE=PZ_E._EXT_RS_vg_protokol 
FROM TabDokladyZbozi DZ WITH (NOLOCK) 
  INNER JOIN TabPohybyZbozi PZ WITH (NOLOCK) ON (PZ.IDDoklad=DZ.ID) 
  INNER JOIN TabPohybyZbozi_Ext PZ_E ON (PZ_E.ID=PZ.ID AND PZ_E._EXT_RS_vg_protokol IS NOT NULL) 
  INNER JOIN TabStavSkladu SS WITH (NOLOCK) ON (SS.ID=PZ.IDZboSklad) 
  INNER JOIN TabKmenZbozi KZ WITH (NOLOCK) ON (KZ.ID=SS.IDKmenZbozi AND (KZ.Dilec=1 OR (KZ.material=1 AND KZ.RezijniMat=0)) AND KZ.Sluzba=0) 
  INNER JOIN TabSkupinyZbozi SZ ON (SZ.SkupZbo=KZ.SkupZbo) 
  LEFT OUTER JOIN TabSkupinyZbozi_Ext SZ_E ON (SZ_E.ID=SZ.ID) 
WHERE DZ.DruhPohybuZbo=9 AND DZ.Splneno=0 AND PZ.Splneno=0 AND (PZ.Mnozstvi-PZ.MnOdebrane)*PZ.PrepMnozstvi > 0.0 AND 
      SZ_E._EXT_RS_Logis=1 AND DZ.IDSklad IN (N'200', N'20000280282', N'10000115', N'100') AND KZ.blokovano=0 AND EXISTS(SELECT * FROM TabPohybyZbozi_Ext PZ_E WHERE PZ_E.ID=PZ.ID AND PZ_E._EXT_RS_PromisedStockingDate IS NOT NULL) 
UNION ALL
SELECT 
  DEMAND_ORDER_ID =PZ.CisloZakazky+N'|'+convert(nvarchar(10),PZ.ID), 
  ATTRIBUTE_NAME=N'RAY_UrovenFAIR', 
  STRING_VALUE=PZ_E._FairLevel, 
  NUMERIC_VALUE=NULL, 
  BOOL_VALUE=NULL 
FROM TabDokladyZbozi DZ WITH (NOLOCK) 
  INNER JOIN TabPohybyZbozi PZ WITH (NOLOCK) ON (PZ.IDDoklad=DZ.ID) 
  INNER JOIN TabPohybyZbozi_Ext PZ_E ON (PZ_E.ID=PZ.ID AND PZ_E._FairLevel IS NOT NULL) 
  INNER JOIN TabStavSkladu SS WITH (NOLOCK) ON (SS.ID=PZ.IDZboSklad) 
  INNER JOIN TabKmenZbozi KZ WITH (NOLOCK) ON (KZ.ID=SS.IDKmenZbozi AND (KZ.Dilec=1 OR (KZ.material=1 AND KZ.RezijniMat=0)) AND KZ.Sluzba=0) 
  INNER JOIN TabSkupinyZbozi SZ ON (SZ.SkupZbo=KZ.SkupZbo) 
  LEFT OUTER JOIN TabSkupinyZbozi_Ext SZ_E ON (SZ_E.ID=SZ.ID) 
WHERE DZ.DruhPohybuZbo=9 AND DZ.Splneno=0 AND PZ.Splneno=0 AND (PZ.Mnozstvi-PZ.MnOdebrane)*PZ.PrepMnozstvi > 0.0 AND 
      SZ_E._EXT_RS_Logis=1 AND DZ.IDSklad IN (N'200', N'20000280282', N'10000115', N'100') AND KZ.blokovano=0 AND EXISTS(SELECT * FROM TabPohybyZbozi_Ext PZ_E WHERE PZ_E.ID=PZ.ID AND PZ_E._EXT_RS_PromisedStockingDate IS NOT NULL) 
GO

