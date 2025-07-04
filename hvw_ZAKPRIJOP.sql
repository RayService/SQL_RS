USE [RayService]
GO

/****** Object:  View [dbo].[hvw_ZAKPRIJOP]    Script Date: 04.07.2025 9:32:48 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

CREATE VIEW [dbo].[hvw_ZAKPRIJOP] AS SELECT tp.ID, tco.Nazev
FROM TabPrikaz tp, TabZakazka tz, TabCisOrg tco
WHERE tp.IDzakazka = tz.ID AND tz.Prijemce = tco.CisloOrg
GO

