USE [RayService]
GO

/****** Object:  View [dbo].[hvw_PinyaZakazka]    Script Date: 03.07.2025 15:32:27 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO




CREATE VIEW [dbo].[hvw_PinyaZakazka] AS 
SELECT
tz.ID AS ID
,tz.CisloZakazky AS CisloZakazky
,tco.Nazev AS Prijemce
,tz.NadrizenaZak AS NadrizenaZak
,tz.Nazev AS Nazev
,tz.Stav AS Stav
,tz.CisloObjednavky AS CisloObjednavky
,tz.DatPorizeni AS DatPorizeni
,tz.DatZmeny AS DatZmeny
FROM TabZakazka tz
LEFT OUTER JOIN TabCisOrg tco ON tz.Prijemce=tco.CisloOrg
WHERE tz.Ukonceno=0




GO

