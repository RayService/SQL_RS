USE [RayService]
GO

/****** Object:  View [dbo].[TabOZVstupDSNView]    Script Date: 04.07.2025 11:33:28 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

CREATE VIEW [dbo].[TabOZVstupDSNView] AS
SELECT D.ID,
CAST(SUM(V.SumaKc)  AS NUMERIC(19,6)) AS SumaKc,
CAST(SUM(V.SumaVal) AS NUMERIC(19,6)) AS SumaVal
FROM TabDokladyZbozi AS D
LEFT OUTER JOIN TabVstupniDokladySN AS V ON V.IDDokZbo = D.ID
LEFT OUTER JOIN TabDokladySN        AS S ON S.ID = V.IDHla AND S.Realizovano = 1
GROUP BY D.ID
GO

