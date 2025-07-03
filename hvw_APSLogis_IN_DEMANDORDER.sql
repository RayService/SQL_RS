USE [RayService]
GO

/****** Object:  View [dbo].[hvw_APSLogis_IN_DEMANDORDER]    Script Date: 03.07.2025 12:53:21 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

CREATE VIEW [dbo].[hvw_APSLogis_IN_DEMANDORDER] AS SELECT 
  DEMAND_ORDER_ID =PZ.CisloZakazky+N'|'+convert(nvarchar(10),PZ.ID), 
  CUSTOMER_ID =DZ.CisloOrg, 
  ITEM_ID =KZ.SkupZbo+N'|'+KZ.RegCis, 
  DUE_DATE=(SELECT PZ_E._EXT_RS_PromisedStockingDate FROM TabPohybyZbozi_Ext PZ_E WHERE PZ_E.ID=PZ.ID), 
  QTY_OPEN = (PZ.Mnozstvi-PZ.MnOdebrane)*PZ.PrepMnozstvi, 
  VIRTUAL_MATERIAL=0, 
  LOCATION_ID=SS.IDSklad, 
  PROMISE_DATE=ISNULL(PZ.PotvrzDatDod_X, ISNULL(PZ.PozadDatDod_X, DZ.TerminDodavkyDat_X)), 
  SALES_ORDER_ID=DZ.ParovaciZnak, 
  SALES_ORDER_LINE=convert(nvarchar(10),PZ.ID), 
  DEMAND_CLASS=Z.Stav+N'|'+Z_S.Popis, 
  IDHeKeyType=0, 
  IDHeKey_TypeS=N'EP', 
  IDHeKey=PZ.ID 
FROM TabDokladyZbozi DZ WITH (NOLOCK) 
  INNER JOIN TabDruhDokZbo DD ON (DD.RadaDokladu=DZ.RadaDokladu AND DD.DruhPohybuZbo=DZ.DruhPohybuZbo) 
  INNER JOIN TabPohybyZbozi PZ WITH (NOLOCK) ON (PZ.IDDoklad=DZ.ID) 
  INNER JOIN TabStavSkladu SS WITH (NOLOCK) ON (SS.ID=PZ.IDZboSklad) 
  INNER JOIN TabKmenZbozi KZ WITH (NOLOCK) ON (KZ.ID=SS.IDKmenZbozi AND (KZ.Dilec=1 OR (KZ.material=1 AND KZ.RezijniMat=0)) AND KZ.Sluzba=0) 
  INNER JOIN TabSkupinyZbozi SZ ON (SZ.SkupZbo=KZ.SkupZbo) 
  LEFT OUTER JOIN TabSkupinyZbozi_Ext SZ_E ON (SZ_E.ID=SZ.ID) 
  LEFT OUTER JOIN TabZakazka Z ON (Z.CisloZakazky=PZ.CisloZakazky) 
  LEFT OUTER JOIN TabZakStavy Z_S ON (Z_S.Cislo=Z.Stav) 
WHERE DZ.DruhPohybuZbo=9 AND DZ.Splneno=0 AND PZ.Splneno=0 AND (PZ.Mnozstvi-PZ.MnOdebrane)*PZ.PrepMnozstvi > 0.0 AND 
      SZ_E._EXT_RS_Logis=1 AND DZ.IDSklad IN (N'200', N'20000280282', N'10000115', N'100') AND KZ.blokovano=0 AND 
      EXISTS(SELECT * FROM TabPohybyZbozi_Ext PZ_E WHERE PZ_E.ID=PZ.ID AND PZ_E._EXT_RS_PromisedStockingDate IS NOT NULL) 
UNION ALL 
SELECT 
  DEMAND_ORDER_ID =PZ.CisloZakazky+N'|'+convert(nvarchar(10),PZ.ID), 
  CUSTOMER_ID =DZ.CisloOrg, 
  ITEM_ID =KZ.SkupZbo+N'|'+KZ.RegCis, 
  DUE_DATE =(SELECT PZ_E._EXT_RS_PromisedStockingDate FROM TabPohybyZbozi_Ext PZ_E WHERE PZ_E.ID=PZ.ID), 
  QTY_OPEN = (PZ.Mnozstvi-(SELECT ISNULL(SUM(P.Mnozstvi),0) FROM TabPohybyZbozi P WITH(NOLOCK) WHERE P.IDOldPolozka = PZ.ID)), 
  VIRTUAL_MATERIAL=0, 
  LOCATION_ID=SS.IDSklad, 
  PROMISE_DATE=ISNULL(PZ.PotvrzDatDod_X, ISNULL(PZ.PozadDatDod_X, DZ.TerminDodavkyDat_X)), 
  SALES_ORDER_ID=NULL, 
  SALES_ORDER_LINE=NULL, 
  DEMAND_CLASS=NULL, 
  IDHeKeyType=11, 
  IDHeKey_TypeS=N'Kontrakty přijaté', 
  IDHeKey=PZ.ID 
FROM TabDokladyZbozi DZ WITH (NOLOCK) 
  INNER JOIN TabDruhDokZbo DD ON (DD.RadaDokladu=DZ.RadaDokladu AND DD.DruhPohybuZbo=DZ.DruhPohybuZbo) 
  INNER JOIN TabParKontr PK WITH (NOLOCK) ON (PK.IDDoklad=DZ.ID AND PK.M=0) 
  INNER JOIN TabPohybyZbozi PZ WITH (NOLOCK) ON (PZ.IDDoklad=DZ.ID) 
  INNER JOIN TabStavSkladu SS WITH (NOLOCK) ON (SS.ID=PZ.IDZboSklad) 
  INNER JOIN TabKmenZbozi KZ WITH (NOLOCK) ON (KZ.ID=SS.IDKmenZbozi AND (KZ.Dilec=1 OR (KZ.material=1 AND KZ.RezijniMat=0)) AND KZ.Sluzba=0) 
  INNER JOIN TabSkupinyZbozi SZ ON (SZ.SkupZbo=KZ.SkupZbo) 
  LEFT OUTER JOIN TabSkupinyZbozi_Ext SZ_E ON (SZ_E.ID=SZ.ID) 
WHERE DZ.DruhPohybuZbo=11 AND DZ.PoradoveCislo>=0 AND DZ.Splneno=0 AND 
      (PZ.Mnozstvi-(SELECT ISNULL(SUM(P.Mnozstvi),0) FROM TabPohybyZbozi P WITH(NOLOCK) WHERE P.IDOldPolozka = PZ.ID))>0.0 AND 
      SZ_E._EXT_RS_Logis=1 AND 
      EXISTS(SELECT * FROM TabPohybyZbozi_Ext PZ_E WHERE PZ_E.ID=PZ.ID AND PZ_E._EXT_RS_PromisedStockingDate IS NOT NULL) 
UNION ALL 
SELECT 
  DEMAND_ORDER_ID =PZ.CisloZakazky+N'|'+convert(nvarchar(10),PZ.ID)+N'|'+convert(nvarchar(10), O.CisloOdv)+N'|'+convert(nvarchar(20),T.ID), 
  CUSTOMER_ID =DZ.CisloOrg, 
  ITEM_ID =KZ.SkupZbo+N'|'+KZ.RegCis, 
  DUE_DATE =T.DatumExpediceOd_X-KZ.LhutaNaskladneni, 
  QTY_OPEN = T.Mnozstvi_zive*PZ.PrepMnozstvi, 
  VIRTUAL_MATERIAL=0, 
  LOCATION_ID=SS.IDSklad, 
  PROMISE_DATE=T.DatumExpediceOd_X-KZ.LhutaNaskladneni, 
  SALES_ORDER_ID=NULL, 
  SALES_ORDER_LINE=NULL, 
  DEMAND_CLASS=NULL, 
  IDHeKeyType=1, 
  IDHeKey_TypeS=N'Odvolávky přijaté', 
  IDHeKey=T.ID 
FROM TabDokladyZbozi DZ WITH (NOLOCK) 
  INNER JOIN TabDruhDokZbo DD ON (DD.RadaDokladu=DZ.RadaDokladu AND DD.DruhPohybuZbo=DZ.DruhPohybuZbo) 
  INNER JOIN TabParKontr PK WITH (NOLOCK) ON (PK.IDDoklad=DZ.ID AND PK.M=0) 
  INNER JOIN TabPohybyZbozi PZ WITH (NOLOCK) ON (PZ.IDDoklad=DZ.ID) 
  INNER JOIN TabStavSkladu SS WITH (NOLOCK) ON (SS.ID=PZ.IDZboSklad) 
  INNER JOIN TabKmenZbozi KZ WITH (NOLOCK) ON (KZ.ID=SS.IDKmenZbozi AND (KZ.Dilec=1 OR (KZ.material=1 AND KZ.RezijniMat=0)) AND KZ.Sluzba=0) 
  INNER JOIN TabSkupinyZbozi SZ ON (SZ.SkupZbo=KZ.SkupZbo) 
  LEFT OUTER JOIN TabSkupinyZbozi_Ext SZ_E ON (SZ_E.ID=SZ.ID) 
  INNER JOIN TabOdvolavky O WITH (NOLOCK) ON (O.IDPolKontraktu=PZ.ID AND O.Aktivni=1 AND O.M=0 AND O.Jemna=0) 
  INNER JOIN TabTermOdvolavky T WITH (NOLOCK) ON (T.IDOdvolavky=O.ID AND T.Mnozstvi_zive>0.0 and T.Splneno=0) 
WHERE DZ.DruhPohybuZbo=11 AND DZ.PoradoveCislo>=0 AND DZ.Splneno=0 AND PZ.Splneno=0 AND T.Mnozstvi_zive>0.0 AND 
      SZ_E._EXT_RS_Logis=1 
UNION ALL 
SELECT 
  DEMAND_ORDER_ID =H.ParovaciZnak+N'|'+convert(nvarchar(10),R.ID), 
  CUSTOMER_ID =H.CisloOrg, 
  ITEM_ID =KZ.SkupZbo+N'|'+KZ.RegCis, 
  DUE_DATE =ISNULL(R.PotvrzDatDod_X, ISNULL(R.PozadDatDod_X, H.DatumDodavky_X))-KZ.LhutaNaskladneni, 
  QTY_OPEN = (R.Mnozstvi-R.MnozstviVydejky)*R.PrepMnozstvi, 
  VIRTUAL_MATERIAL=0, 
  LOCATION_ID=SS.IDSklad, 
  PROMISE_DATE=ISNULL(R.PotvrzDatDod_X, ISNULL(R.PozadDatDod_X, H.DatumDodavky_X))-KZ.LhutaNaskladneni, 
  SALES_ORDER_ID=NULL, 
  SALES_ORDER_LINE=NULL, 
  DEMAND_CLASS=NULL, 
  IDHeKeyType=2, 
  IDHeKey_TypeS=N'DO', 
  IDHeKey=R.ID 
FROM TabDosleObjH02 H WITH (NOLOCK) 
  INNER JOIN TabDosleObjRada DD ON (DD.Rada=H.Rada) 
  INNER JOIN TabDosleObjR02 R WITH (NOLOCK) ON (R.IDHlava=H.ID) 
  INNER JOIN TabStavSkladu SS WITH (NOLOCK) ON (SS.ID=R.IDZboSklad) 
  INNER JOIN TabKmenZbozi KZ WITH (NOLOCK) ON (KZ.ID=SS.IDKmenZbozi AND (KZ.Dilec=1 OR (KZ.material=1 AND KZ.RezijniMat=0)) AND KZ.Sluzba=0) 
  INNER JOIN TabSkupinyZbozi SZ ON (SZ.SkupZbo=KZ.SkupZbo) 
  LEFT OUTER JOIN TabSkupinyZbozi_Ext SZ_E ON (SZ_E.ID=SZ.ID) 
WHERE H.Splneno=0 AND R.Splneno=0 AND (R.Mnozstvi-R.MnozstviVydejky)*R.PrepMnozstvi > 0.0 AND 
      SZ_E._EXT_RS_Logis=1 
GO

