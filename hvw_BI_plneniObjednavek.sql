USE [RayService]
GO

/****** Object:  View [dbo].[hvw_BI_plneniObjednavek]    Script Date: 03.07.2025 14:16:43 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

CREATE VIEW [dbo].[hvw_BI_plneniObjednavek] AS (
SELECT PZ.ID, CO.CisloOrg, CO.Nazev, PZ.SkupZbo, PZ. RegCis, PZ.Nazev1, PZOld.PozadDatDod_X, PZ.DatPorizeni_X, DZ.DatRealizace_X,
DZOld.RadaDokladu AS RadaDokladuOld, DZOld.PoradoveCislo AS PoradoveCisloOld, datediff(day, PZOld.PozadDatDod_X, PZ.DatPorizeni_X) AS Rozdil,
DZ.RadaDokladu, DZ.PoradoveCislo,
ss.IdSklad
FROM TabPohybyZbozi PZ
LEFT OUTER JOIN TabDokladyZbozi DZ ON DZ.ID = PZ.IDDoklad
LEFT OUTER JOIN TabPohybyZbozi PZOld ON PZOld.ID = PZ.IDOldPolozka
LEFT OUTER JOIN TabDokladyZbozi DZOld ON PZOld.IDDoklad = DZOld.ID
LEFT OUTER JOIN TabStavSkladu SS ON SS.id=PZ.IDZboSklad
JOIN TabCisOrg CO ON CO.CisloOrg = DZ.CisloOrg
WHERE DZOld.DruhPohybuZbo = 6 AND DZ.DruhPohybuZbo IN (0,1)
)
GO

