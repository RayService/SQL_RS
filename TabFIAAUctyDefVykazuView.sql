USE [RayService]
GO

/****** Object:  View [dbo].[TabFIAAUctyDefVykazuView]    Script Date: 04.07.2025 10:20:33 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

CREATE VIEW [dbo].[TabFIAAUctyDefVykazuView] AS
SELECT
IdFIAAVykazDefinice, 
CASE Koeficient WHEN -1 THEN N'-' ELSE '' END + CisloUcetBrutto AS PrirazeneUcty
FROM TabFIAAVCisUctVykazDefinice WHERE CisloUcetBrutto IS NOT NULL
UNION ALL
SELECT
IdFIAAVykazDefinice, 
CASE Koeficient WHEN -1 THEN N'-' ELSE '' END + N'K ' + CisloUcetKorekce AS PrirazeneUcty
FROM TabFIAAVCisUctVykazDefinice WHERE CisloUcetKorekce IS NOT NULL
GO

