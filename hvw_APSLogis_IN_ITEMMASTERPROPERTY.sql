USE [RayService]
GO

/****** Object:  View [dbo].[hvw_APSLogis_IN_ITEMMASTERPROPERTY]    Script Date: 03.07.2025 12:58:47 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

CREATE VIEW [dbo].[hvw_APSLogis_IN_ITEMMASTERPROPERTY] AS SELECT 
  ITEM_ID=KZ.SkupZbo+N'|'+KZ.Regcis, 
  ATTRIBUTE_NAME=N'RAY_Typ', 
  ATTRIBUTE_DESCRIPTION=N'Typ položky', 
  STRING_VALUE=CASE WHEN kz.Material=1 THEN N'Materiál' 
                    WHEN kz.VedProdukt=1 THEN N'Vedlejší produkt' 
                    WHEN kz.Dilec=1 AND ts.ID=20 THEN N'VD' 
                    WHEN kz.Dilec=1 AND ISNULL(ts.ID,0)<>20 THEN N'Vyráběný dílec' 
                    WHEN kz.Naradi=1 THEN N'Nářadí' 
                    ELSE N'Neurčeno' 
               END, 
  NUMERIC_VALUE=NULL 
FROM TabKmenZbozi KZ 
  INNER JOIN TabSkupinyZbozi SZ ON (SZ.SkupZbo=KZ.SkupZbo) 
  INNER JOIN TabSkupinyZbozi_Ext SZ_E ON (SZ_E.ID=SZ.ID AND SZ_E._EXT_RS_Logis=1) 
  LEFT OUTER JOIN TabSortiment ts ON (ts.ID=kz.IdSortiment) 
WHERE KZ.Blokovano=0 AND (KZ.dilec=1 OR (KZ.material=1 AND KZ.RezijniMat=0) OR KZ.VedProdukt=1) AND KZ.Sluzba=0 
UNION ALL 
SELECT 
  ITEM_ID=KZ.SkupZbo+N'|'+KZ.Regcis, 
  ATTRIBUTE_NAME=N'RAY_Nazev2', 
  ATTRIBUTE_DESCRIPTION=N'Název2', 
  STRING_VALUE=KZ.Nazev2, 
  NUMERIC_VALUE=NULL 
FROM TabKmenZbozi KZ 
  INNER JOIN TabSkupinyZbozi SZ ON (SZ.SkupZbo=KZ.SkupZbo) 
  INNER JOIN TabSkupinyZbozi_Ext SZ_E ON (SZ_E.ID=SZ.ID AND SZ_E._EXT_RS_Logis=1) 
WHERE KZ.Blokovano=0 AND (KZ.dilec=1 OR (KZ.material=1 AND KZ.RezijniMat=0) OR KZ.VedProdukt=1) AND KZ.Sluzba=0 AND LEN(KZ.Nazev2)>0 
UNION ALL 
SELECT 
  ITEM_ID=KZ.SkupZbo+N'|'+KZ.Regcis, 
  ATTRIBUTE_NAME=N'RAY_Nazev3', 
  ATTRIBUTE_DESCRIPTION=N'Název3', 
  STRING_VALUE=KZ.Nazev3, 
  NUMERIC_VALUE=NULL 
FROM TabKmenZbozi KZ 
  INNER JOIN TabSkupinyZbozi SZ ON (SZ.SkupZbo=KZ.SkupZbo) 
  INNER JOIN TabSkupinyZbozi_Ext SZ_E ON (SZ_E.ID=SZ.ID AND SZ_E._EXT_RS_Logis=1) 
WHERE KZ.Blokovano=0 AND (KZ.dilec=1 OR (KZ.material=1 AND KZ.RezijniMat=0) OR KZ.VedProdukt=1) AND KZ.Sluzba=0 AND LEN(KZ.Nazev3)>0 
UNION ALL 
SELECT 
  ITEM_ID=KZ.SkupZbo+N'|'+KZ.Regcis, 
  ATTRIBUTE_NAME=N'RAY_KvalDil', 
  ATTRIBUTE_DESCRIPTION=N'Kvalifikace dílce', 
  STRING_VALUE=KZ_E._KvalDil, 
  NUMERIC_VALUE=NULL 
FROM TabKmenZbozi KZ 
  INNER JOIN TabSkupinyZbozi SZ ON (SZ.SkupZbo=KZ.SkupZbo) 
  INNER JOIN TabSkupinyZbozi_Ext SZ_E ON (SZ_E.ID=SZ.ID AND SZ_E._EXT_RS_Logis=1) 
  INNER JOIN TabKmenZbozi_Ext KZ_E ON (KZ_E.ID=KZ.ID AND KZ_E._KvalDil IS NOT NULL) 
WHERE KZ.Blokovano=0 AND (KZ.dilec=1 OR (KZ.material=1 AND KZ.RezijniMat=0) OR KZ.VedProdukt=1) AND KZ.Sluzba=0 
UNION ALL 
SELECT 
  ITEM_ID=KZ.SkupZbo+N'|'+KZ.Regcis, 
  ATTRIBUTE_NAME=N'RAY_RadaVP', 
  ATTRIBUTE_DESCRIPTION=N'Výchozí řada VP', 
  STRING_VALUE=PD.RadaVyrPrikazu, 
  NUMERIC_VALUE=NULL 
FROM TabKmenZbozi KZ 
  INNER JOIN TabSkupinyZbozi SZ ON (SZ.SkupZbo=KZ.SkupZbo) 
  INNER JOIN TabSkupinyZbozi_Ext SZ_E ON (SZ_E.ID=SZ.ID AND SZ_E._EXT_RS_Logis=1) 
  INNER JOIN TabParKmZ PD ON (PD.IDKmenZbozi=KZ.ID) 
WHERE KZ.Blokovano=0 AND KZ.dilec=1 AND KZ.Sluzba=0 AND PD.RadaVyrPrikazu IS NOT NULL 
UNION ALL 
SELECT 
  ITEM_ID=KZ.SkupZbo+N'|'+KZ.Regcis, 
  ATTRIBUTE_NAME=N'RAY_rozpracovana_zmena', 
  ATTRIBUTE_DESCRIPTION=N'Rozpracovaná změna', 
  STRING_VALUE=X.Zmena, 
  NUMERIC_VALUE=NULL 
FROM TabKmenZbozi KZ 
  INNER JOIN TabSkupinyZbozi SZ ON (SZ.SkupZbo=KZ.SkupZbo) 
  INNER JOIN TabSkupinyZbozi_Ext SZ_E ON (SZ_E.ID=SZ.ID AND SZ_E._EXT_RS_Logis=1) 
  OUTER APPLY (SELECT TOP 1 Zmena=RTRIM(CZ.rada)+N'-'+CZ.CisZmeny 
                 FROM TabDavka D WITH(NOLOCK) 
                   INNER JOIN TabCZmeny CZ WITH(NOLOCK) ON (CZ.ID=D.zmenaOd AND CZ.platnost=0) 
                 WHERE D.IDDilce=KZ.IDKusovnik AND D.IDZakazModif IS NULL AND D.ZmenaDo IS NULL) X 
WHERE KZ.Blokovano=0 AND KZ.dilec=1 AND KZ.Sluzba=0 AND X.Zmena IS NOT NULL 
UNION ALL 
SELECT 
  ITEM_ID=KZ.SkupZbo+N'|'+KZ.Regcis, 
  ATTRIBUTE_NAME=N'RAY_TechnikTPV100', 
  ATTRIBUTE_DESCRIPTION=N'Technik TPV 100', 
  STRING_VALUE=KZ_E._TechnikTPV100, 
  NUMERIC_VALUE=NULL 
FROM TabKmenZbozi KZ 
  INNER JOIN TabSkupinyZbozi SZ ON (SZ.SkupZbo=KZ.SkupZbo) 
  INNER JOIN TabSkupinyZbozi_Ext SZ_E ON (SZ_E.ID=SZ.ID AND SZ_E._EXT_RS_Logis=1) 
  INNER JOIN TabKmenZbozi_Ext KZ_E ON (KZ_E.ID=KZ.ID AND KZ_E._TechnikTPV100 IS NOT NULL) 
WHERE KZ.Blokovano=0 AND (KZ.dilec=1 OR (KZ.material=1 AND KZ.RezijniMat=0) OR KZ.VedProdukt=1) AND KZ.Sluzba=0 
GO

