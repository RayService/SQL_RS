USE [RayService]
GO

/****** Object:  View [dbo].[TabOZSklAndTxtPolView]    Script Date: 04.07.2025 11:32:16 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

CREATE VIEW [dbo].[TabOZSklAndTxtPolView] AS
SELECT IDDoklad, ID AS IDPolozky, NULL AS IDTxtPol, ID AS IDUni, Poradi,
CAST(SkupZbo+' '+RegCis+' '+Nazev1 AS NVARCHAR(200)) AS Popis
FROM TabPohybyZbozi
UNION ALL
SELECT IDDoklad, NULL, ID, -ID, Poradi,
CAST(CAST(Poradi AS NVARCHAR (20))+', '+
CAST(Popis  AS NVARCHAR(200)) AS NVARCHAR(200))
FROM TabOZTxtPol
GO

