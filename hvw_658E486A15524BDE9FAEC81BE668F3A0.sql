USE [RayService]
GO

/****** Object:  View [dbo].[hvw_658E486A15524BDE9FAEC81BE668F3A0]    Script Date: 03.07.2025 11:14:54 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

CREATE VIEW [dbo].[hvw_658E486A15524BDE9FAEC81BE668F3A0] AS SELECT
TabDokladyZbozi.ID,
TabDokladyZbozi.DruhpohybuZbo,
TabDokladyzbozi.radadokladu,
TabDokladyZbozi.PoradoveCislo,
TabDokladyZbozi.CisloOrg,
VDokZboCisOrg.Nazev,
TabDokladyZbozi.DatPorizeni_M,
TabDokladyZbozi.DatPorizeni_Q,
TabDokladyZbozi.DatPorizeni_Y,
(CASE WHEN DruhPohybuZbo IN (14,18) THEN -1 * TabDokladyZbozi.SumaKcBezDPH ELSE TabDokladyZbozi.SumaKcBezDPH END) AS Castka,
TabDokladyZbozi.SumaKcBezDPHDruh,
VDokZboCisOrg.IDzeme,
S.nazev AS NakladoveStrediskoNazev,
S.cislo AS NakladoveStrediskoCislo
FROM TabDokladyZbozi
LEFT OUTER  JOIN TabCisOrg VDokZboCisOrg ON TabDokladyZbozi.CisloOrg=VDokZboCisOrg.CisloOrg
LEFT OUTER JOIN TabStrom S ON TabDokladyZbozi.strednaklad = S.cislo
where druhpohybuzbo IN (13,14, 18, 19)
GO

