USE [RayService]
GO

/****** Object:  View [dbo].[TabBodoveKontoView]    Script Date: 04.07.2025 9:47:28 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

CREATE VIEW [dbo].[TabBodoveKontoView] AS
SELECT CisloOrg AS ID,CisloOrg,SUM(BodyPlus) AS BodyPlus,SUM(BodyMinus) AS BodyMinus,SUM(BodyCelkem) AS BodyCelkem,
MIN(DatumPrvni) AS DatumPrvni,
MAX(DatumPosledni) AS DatumPosledni
FROM TabBodoveKontoOrg
GROUP BY CisloOrg

 
GO

