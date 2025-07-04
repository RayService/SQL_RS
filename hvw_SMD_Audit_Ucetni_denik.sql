USE [RayService]
GO

/****** Object:  View [dbo].[hvw_SMD_Audit_Ucetni_denik]    Script Date: 04.07.2025 8:35:50 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

CREATE VIEW [dbo].[hvw_SMD_Audit_Ucetni_denik] AS SELECT DatumPripad_X as DatumPripad,
           CAST(Sbornik as NVARCHAR)+'/'+CAST(CisloDokladu as NVARCHAR) as CisloDokladu,
           CisloUcet, 
           CastkaMD, 
           CastkaDAL,    
           '' as Protiucet,
           Popis,
           o.Nazev,
           Utvar,
           CisloZakazky,
           ParovaciZnak,
           d.Mena,
           CastkaMena,
           o.ICO,
           CAST(Sbornik as NVARCHAR) as Sbornik,
           DatumPripad_Y as Rok,
           DatumPripad_Q as Ctvrtleti,
           DatumPripad_M as Mesic

FROM TabDenik d
LEFT JOIN TabCisOrg o ON o.CisloOrg = d.CisloOrg 

WHERE Zaknihovano > 0 AND d.Stav = 0 
    AND DatumPripad  > =  (SELECT DatumOd FROM SMDTabVyberObdobi)
GO

