USE [RayService]
GO

/****** Object:  View [dbo].[hvw_APSLogis_IN_LOCATION]    Script Date: 03.07.2025 12:59:08 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

CREATE VIEW [dbo].[hvw_APSLogis_IN_LOCATION] AS SELECT DISTINCT 
  LOCATION_ID =SS.IDSklad, 
  LOCATION_DESCRIPTION=S.Nazev, 
  IDHeKey_TypeS=N'Sklady' 
FROM TabStavSkladu SS 
  INNER JOIN TabKmenZbozi KZ ON (KZ.ID=SS.IDKmenZbozi AND (KZ.Material=1 AND KZ.RezijniMat=0 OR KZ.dilec=1) AND KZ.Blokovano=0) 
  INNER JOIN TabSkupinyZbozi SZ ON (SZ.SkupZbo=KZ.SkupZbo) 
  LEFT OUTER JOIN TabSkupinyZbozi_Ext SZ_E ON (SZ_E.ID=SZ.ID) 
  INNER JOIN TabStrom S ON (S.Cislo=SS.IDSklad AND ISNULL(S.TypStrediska,0)<>1) 
WHERE SZ_E._EXT_RS_Logis=1 
UNION ALL 
SELECT 
  LOCATION_ID=S.Cislo, 
  LOCATION_DESCRIPTION=S.Nazev, 
  IDHeKey_TypeS=N'Lokality' 
FROM TabStrom S 
  INNER JOIN TabObdobi O ON (GETDATE() BETWEEN O.DatumOd AND O.DatumDo) 
  INNER JOIN TabStromDef D ON (D.IdStrom=S.Id AND D.IdObdobi=O.ID AND D.Blokovano=0 AND D.Zakazano=0) 
WHERE S.TypStrediska=1 
UNION ALL 
SELECT 
  LOCATION_ID =CK.Rada+N'|'+CK.kod, 
  LOCATION_DESCRIPTION =CK.Nazev, 
  IDHeKey_TypeS=N'Kooperace' 
FROM TabCKoop CK 
WHERE CK.Blokovano=0 
UNION ALL 
SELECT 
  LOCATION_ID=N'NÁŘADÍ', 
  LOCATION_DESCRIPTION =N'NÁŘADÍ', 
  IDHeKey_TypeS=N'Nářadí' 
GO

