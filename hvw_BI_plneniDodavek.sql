USE [RayService]
GO

/****** Object:  View [dbo].[hvw_BI_plneniDodavek]    Script Date: 03.07.2025 14:13:43 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

CREATE VIEW [dbo].[hvw_BI_plneniDodavek] AS SELECT 
PZ.ID, 
CO.CisloOrg, 
CO.Nazev, 
PZ.SkupZbo, 
PZ. RegCis, 
PZ.Nazev1, 
PZOld.DatPorizeni_X AS PorizeniEP,
PZOld.PotvrzDatDod_X, 
PZ.DatPorizeni_X, DZ.DatRealizace_X,
DZOld.RadaDokladu AS RadaDokladuOld, 
DZOld.PoradoveCislo AS PoradoveCisloOld,
DZ.RadaDokladu, 
DZ.PoradoveCislo, 
datediff(day, PZOld.PotvrzDatDod_X, PZ.DatPorizeni_X) AS Rozdil,
ss.IdSklad
FROM TabPohybyZbozi PZ
LEFT OUTER JOIN TabDokladyZbozi DZ ON DZ.ID = PZ.IDDoklad
LEFT OUTER JOIN TabPohybyZbozi PZOld ON PZOld.ID = PZ.IDOldPolozka
LEFT OUTER JOIN TabDokladyZbozi DZOld ON PZOld.IDDoklad = DZOld.ID
LEFT OUTER JOIN TabStavSkladu SS ON SS.id=PZ.IDZboSklad
JOIN TabCisOrg CO ON CO.CisloOrg = DZ.CisloOrg
WHERE DZOld.DruhPohybuZbo = 9 AND DZ.DruhPohybuZbo IN (2,3,4)
GO

