USE [RayService]
GO

/****** Object:  View [dbo].[TabDObjSklAndTxtPol01View]    Script Date: 04.07.2025 9:50:37 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

CREATE VIEW [dbo].[TabDObjSklAndTxtPol01View] AS
SELECT IDHlava, ID AS IDPolozky, NULL AS IDTxtPol, ID AS IDUni, PoradiPolozky AS Poradi,
CAST(SkupZbo+' '+RegCis+' '+Nazev1 AS NVARCHAR(200)) AS Popis
FROM TabDosleObjR01
UNION ALL
SELECT IDHlava, NULL, ID, -ID, Poradi,
CAST(CAST(Poradi AS NVARCHAR (20))+', '+
CAST(Popis  AS NVARCHAR(200)) AS NVARCHAR(200))
FROM TabDosleObjTxtPol01
GO

