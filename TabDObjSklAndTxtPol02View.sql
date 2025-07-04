USE [RayService]
GO

/****** Object:  View [dbo].[TabDObjSklAndTxtPol02View]    Script Date: 04.07.2025 9:51:40 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

CREATE VIEW [dbo].[TabDObjSklAndTxtPol02View] AS
SELECT IDHlava, ID AS IDPolozky, NULL AS IDTxtPol, ID AS IDUni, PoradiPolozky AS Poradi,
CAST(SkupZbo+' '+RegCis+' '+Nazev1 AS NVARCHAR(200)) AS Popis
FROM TabDosleObjR02
UNION ALL
SELECT IDHlava, NULL, ID, -ID, Poradi,
CAST(CAST(Poradi AS NVARCHAR (20))+', '+
CAST(Popis  AS NVARCHAR(200)) AS NVARCHAR(200))
FROM TabDosleObjTxtPol02
GO

