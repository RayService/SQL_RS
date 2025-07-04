USE [RayService]
GO

/****** Object:  View [dbo].[TabZdravotniPojistovnyView]    Script Date: 04.07.2025 13:08:53 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

CREATE VIEW [dbo].[TabZdravotniPojistovnyView] AS
SELECT
t.ID AS ID
,t.Kod AS Kod
,t.Nazev AS Nazev
,N'CZ' AS Legislativa
FROM TabZdrPoj t
WHERE t.IdObdobi= (SELECT IdObdobi FROM TabMzdObd WHERE Stav = 1)
UNION ALL
SELECT
-p.ID AS ID
,p.Symbol AS Kod
,p.Nazev AS Nazev
,'SK' AS Legislativa
FROM TabMzdPojFondy p
WHERE p.IdObdobi= (SELECT IdObdobi FROM TabMzdObd WHERE Stav = 1)
GO

