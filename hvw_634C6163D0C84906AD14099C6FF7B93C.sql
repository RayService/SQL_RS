USE [RayService]
GO

/****** Object:  View [dbo].[hvw_634C6163D0C84906AD14099C6FF7B93C]    Script Date: 03.07.2025 11:13:27 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

CREATE VIEW [dbo].[hvw_634C6163D0C84906AD14099C6FF7B93C] AS SELECT
TabDokladyZbozi.ID,
TabDokladyZbozi.DruhpohybuZbo,
TabDokladyzbozi.radadokladu,
TabDokladyZbozi.PoradoveCislo,
TabDokladyZbozi.CisloOrg,
VDokZboCisOrg.Nazev,
TabDokladyZbozi.DatPorizeni_M,
TabDokladyZbozi.DatPorizeni_Q,
TabDokladyZbozi.DatPorizeni_Y,
TabDokladyZbozi.SumaKcBezDPHDruh,
VDokZboCisOrg.IDzeme,
S.nazev AS NakladoveStrediskoNazev,
S.cislo AS NakladoveStrediskoCislo
FROM TabDokladyZbozi
LEFT OUTER  JOIN TabCisOrg VDokZboCisOrg ON TabDokladyZbozi.CisloOrg=VDokZboCisOrg.CisloOrg
LEFT OUTER JOIN TabStrom S ON TabDokladyZbozi.strednaklad = S.cislo
where druhpohybuzbo IN (13,14)
GO

