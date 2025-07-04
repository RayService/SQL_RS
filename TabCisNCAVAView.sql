USE [RayService]
GO

/****** Object:  View [dbo].[TabCisNCAVAView]    Script Date: 04.07.2025 9:47:54 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

CREATE VIEW [dbo].[TabCisNCAVAView] AS
SELECT
ROW_NUMBER() OVER (ORDER BY t.AVAReferenceID) AS ID,
t.*
FROM
(
SELECT
cnca.AVAReferenceID AS AVAReferenceID
,cnca.AVAExternalID AS AVAExternalID
,cnca.CenovaUroven AS CenovaUroven
,cnca.Nazev AS Nazev
,cnca.DruhCU AS DruhCU
,cnca.Poznamka AS Poznamka
,cnca.Mena AS Mena
,cnca.Sklad AS Sklad
,NULL AS CisloOrg
FROM
TabCisNCAVA cnca
WHERE
cnca.PusobnostCeniku = 0
UNION ALL
SELECT
cnca.AVAReferenceID AS AVAReferenceID
,cnca.AVAExternalID AS AVAExternalID
,cnca.CenovaUroven AS CenovaUroven
,cnca.Nazev AS Nazev
,cnca.DruhCU AS DruhCU
,cnca.Poznamka AS Poznamka
,cnca.Mena AS Mena
,cnca.Sklad AS Sklad
,co.CisloOrg AS CisloOrg
FROM
TabCisNCAVA cnca
JOIN TabCisOrg co ON co.CenovaUroven= cnca.CenovaUroven
OR co.CenovaUrovenNakup= cnca.CenovaUroven
WHERE
cnca.PusobnostCeniku = 1
) AS t
GO

