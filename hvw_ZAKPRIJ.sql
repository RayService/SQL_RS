USE [RayService]
GO

/****** Object:  View [dbo].[hvw_ZAKPRIJ]    Script Date: 04.07.2025 9:32:20 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

CREATE VIEW [dbo].[hvw_ZAKPRIJ] AS SELECT TabZakazka.ID, TabCisOrg.Nazev FROM TabZakazka, TabCisOrg WHERE TabZakazka.Prijemce = TabCisOrg.CisloOrg
GO

