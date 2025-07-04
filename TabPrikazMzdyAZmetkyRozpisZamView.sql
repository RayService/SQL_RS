USE [RayService]
GO

/****** Object:  View [dbo].[TabPrikazMzdyAZmetkyRozpisZamView]    Script Date: 04.07.2025 12:37:50 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

CREATE VIEW [dbo].[TabPrikazMzdyAZmetkyRozpisZamView] AS 
SELECT R.ID, R.IDMzdy, IDRozpisuZam=R.ID, R.Zamestnanec, R.AgenturniPrac, R.Tarif, R.Nor_cas_Obsluhy_N, R.Sk_cas_Obsluhy_N, R.NormoMzda, R.KoefOhodnoceni, R.Doplatek, R.Mzda, R.Poznamka, R.PrevedenoDoMezd, R.IDPredzMzdy, R.Autor, R.DatPorizeni, R.Zmenil, R.DatZmeny 
  FROM TabPrikazMzdyAZmetkyRozpisZam R 
    INNER JOIN TabPrikazMzdyAZmetky MZ ON (MZ.ID=R.IDMzdy) 
UNION ALL 
SELECT ID=ISNULL(-MZ.ID,0), IDMzdy=MZ.ID, IDRozpisuZam=NULL, MZ.Zamestnanec, MZ.AgenturniPrac, MZ.Tarif, MZ.Nor_cas_Obsluhy_N, MZ.Sk_cas_Obsluhy_N, MZ.NormoMzda, MZ.KoefOhodnoceni, MZ.Doplatek, MZ.Mzda, MZ.Poznamka, MZ.PrevedenoDoMezd, MZ.IDPredzMzdy, MZ.Autor, MZ.DatPorizeni, MZ.Zmenil, MZ.DatZmeny 
  FROM TabPrikazMzdyAZmetky MZ 
  WHERE MZ.Zamestnanec IS NOT NULL
GO

