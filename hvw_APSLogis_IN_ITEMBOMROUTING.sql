USE [RayService]
GO

/****** Object:  View [dbo].[hvw_APSLogis_IN_ITEMBOMROUTING]    Script Date: 03.07.2025 12:54:04 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO





CREATE VIEW [dbo].[hvw_APSLogis_IN_ITEMBOMROUTING] AS SELECT 
  BOM_ID =KZ.SkupZbo+N'|'+KZ.Regcis, 
  ROUTING_NAME =KZ.SkupZbo+N'|'+KZ.Regcis, 
  ITEM_ID =KZ.SkupZbo+N'|'+KZ.Regcis, 
  USABLE_BY_NEW_MFG_ORD=1, 
  PRIORITY=100, 
  LOT_SIZE_STEP_QTY = CASE WHEN PKZ.MinDavka > 0 THEN PKZ.MinDavka END, 
  MIN_LOT_SIZE_QTY = CASE WHEN PKZ.MinDavka > 0 THEN PKZ.MinDavka END, 
  MAX_LOT_SIZE_QTY = D.Davka, 
  IDHeKey_TypeS=N'Dílce' 
FROM TabKmenZbozi KZ 
  INNER JOIN TabSkupinyZbozi SZ ON (SZ.SkupZbo=KZ.SkupZbo) 
  LEFT OUTER JOIN TabSkupinyZbozi_Ext SZ_E ON (SZ_E.ID=SZ.ID) 
  LEFT OUTER JOIN TabSortiment ts ON (ts.ID=kz.IdSortiment) 
  LEFT OUTER JOIN TabParKmZ PKZ on KZ.ID = PKZ.IDKmenZbozi 
  LEFT OUTER JOIN TabDavka D ON (D.IDDilce=KZ.IDKusovnik AND EXISTS(SELECT * FROM TabCZmeny ZodD 
                                                                          LEFT OUTER JOIN TabCZmeny ZdoD ON (ZDoD.ID=D.zmenaDo) 
                                                                        WHERE ZodD.ID=D.zmenaOd AND ZodD.platnost=1 AND ZodD.datum<=convert(date,GETDATE()) AND 
                                                                              (D.ZmenaDo IS NULL OR ZdoD.platnost=0 OR (ZDoD.platnost=1 AND ZDoD.datum>convert(date,GETDATE()))) )) 
WHERE KZ.Blokovano=0 AND KZ.dilec=1 AND 
      SZ_E._EXT_RS_Logis=1 AND ISNULL(ts.ID,0)<>20 AND KZ.Sluzba=0 
UNION ALL 
SELECT 
  BOM_ID =KZ.SkupZbo+N'|'+KZ.Regcis+N'|'+ZM.Kod, 
  ROUTING_NAME =KZ.SkupZbo+N'|'+KZ.Regcis+N'|'+ZM.Kod, 
  ITEM_ID =KZ.SkupZbo+N'|'+KZ.Regcis, 
  USABLE_BY_NEW_MFG_ORD=1, 
  PRIORITY=1, 
  LOT_SIZE_STEP_QTY = CASE WHEN PKZ.MinDavka > 0 THEN PKZ.MinDavka END, 
  MIN_LOT_SIZE_QTY = CASE WHEN PKZ.MinDavka > 0 THEN PKZ.MinDavka END, 
  MAX_LOT_SIZE_QTY = D.Davka, 
  IDHeKey_TypeS=N'ZakazModif' 
FROM TabZakazModifDilce ZMD 
  INNER JOIN TabZakazModif ZM ON (ZM.ID=ZMD.IDZakazModif AND ZM.Blokovano=0) 
  INNER JOIN TabKmenZbozi KZ ON (KZ.ID=ZMD.IDKmenZbozi AND KZ.Blokovano=0) 
  INNER JOIN TabSkupinyZbozi SZ ON (SZ.SkupZbo=KZ.SkupZbo) 
  LEFT OUTER JOIN TabSkupinyZbozi_Ext SZ_E ON (SZ_E.ID=SZ.ID) 
  LEFT OUTER JOIN TabParKmZ PKZ on KZ.ID = PKZ.IDKmenZbozi 
  LEFT OUTER JOIN TabDavka D ON (D.IDDilce=ZMD.IDKmenZbozi AND D.IDZakazModif=ZMD.IDZakazModif) 
WHERE ZMD.TPVModif=1 AND 
      SZ_E._EXT_RS_Logis=1 AND KZ.Sluzba=0 
UNION ALL 
SELECT 
  BOM_ID =RTRIM(P.Rada)+N'|'+convert(nvarchar(10),P.Prikaz), 
  ROUTING_NAME =RTRIM(P.Rada)+N'|'+convert(nvarchar(10),P.Prikaz), 
  ITEM_ID =KZ.SkupZbo+N'|'+KZ.Regcis, 
  USABLE_BY_NEW_MFG_ORD=0, 
  PRIORITY=1, 
  LOT_SIZE_STEP_QTY = NULL, 
  MIN_LOT_SIZE_QTY = NULL, 
  MAX_LOT_SIZE_QTY = NULL, 
  IDHeKey_TypeS=N'Výr. příkazy' 
FROM TabPrikaz P 
  INNER JOIN TabKmenZbozi KZ ON (KZ.ID=P.IDTabKmen) 
  INNER JOIN TabSkupinyZbozi SZ ON (SZ.SkupZbo=KZ.SkupZbo) 
  LEFT OUTER JOIN TabSkupinyZbozi_Ext SZ_E ON (SZ_E.ID=SZ.ID) 
  INNER JOIN TabRadyPrikazu RP ON (RP.Rada=P.Rada) 
  LEFT OUTER JOIN TabRadyPrikazu_Ext RP_E ON (RP_E.ID=RP.ID) 
WHERE P.StavPrikazu IN (20,30,40) AND 
      SZ_E._EXT_RS_Logis=1 AND RP_E._EXT_RS_Logis=1 AND KZ.Blokovano=0 
      AND KZ.SkupZbo<>'932'


--duplikace kmenových dat, kde kusovník obsahuje 932 a zároveň inventory pro 932=0
UNION ALL 
SELECT 
  BOM_ID =KZ.SkupZbo+N'|'+KZ.Regcis+'-PrvniKus', 
  ROUTING_NAME =KZ.SkupZbo+N'|'+KZ.Regcis, 
  ITEM_ID =KZ.SkupZbo+N'|'+KZ.Regcis, 
  USABLE_BY_NEW_MFG_ORD=1, 
  PRIORITY=NULL, 
  LOT_SIZE_STEP_QTY=NULL,-- CASE WHEN PKZ.MinDavka > 0 THEN PKZ.MinDavka END, 
  MIN_LOT_SIZE_QTY=NULL,-- CASE WHEN PKZ.MinDavka > 0 THEN PKZ.MinDavka END, 
  MAX_LOT_SIZE_QTY=NULL,-- D.Davka, 
  IDHeKey_TypeS=N'Dílce' 
FROM TabKmenZbozi KZ 
  INNER JOIN TabSkupinyZbozi SZ ON (SZ.SkupZbo=KZ.SkupZbo) 
  LEFT OUTER JOIN TabSkupinyZbozi_Ext SZ_E ON (SZ_E.ID=SZ.ID) 
  LEFT OUTER JOIN TabSortiment ts ON (ts.ID=kz.IdSortiment) 
  LEFT OUTER JOIN TabParKmZ PKZ on KZ.ID = PKZ.IDKmenZbozi 
  LEFT OUTER JOIN TabDavka D ON (D.IDDilce=KZ.IDKusovnik AND EXISTS(SELECT * FROM TabCZmeny ZodD 
                                                                          LEFT OUTER JOIN TabCZmeny ZdoD ON (ZDoD.ID=D.zmenaDo) 
                                                                        WHERE ZodD.ID=D.zmenaOd AND ZodD.platnost=1 AND ZodD.datum<=convert(date,GETDATE()) AND 
                                                                              (D.ZmenaDo IS NULL OR ZdoD.platnost=0 OR (ZDoD.platnost=1 AND ZDoD.datum>convert(date,GETDATE()))) )) 
WHERE KZ.Blokovano=0 AND KZ.dilec=1 AND 
      SZ_E._EXT_RS_Logis=1 AND ISNULL(ts.ID,0)<>20 AND KZ.Sluzba=0 
--duplikační podmínky
AND KZ.ID IN (
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
AND(tkzN.SkupZbo LIKE N'%932%')AND(ISNULL(tsV_EXT._EXT_RS_Logis,0)=1)
AND(tss.MnozSPrijBezVyd=0.0))
)





GO

