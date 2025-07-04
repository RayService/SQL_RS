USE [RayService]
GO

/****** Object:  View [dbo].[TabEShopImagesView]    Script Date: 04.07.2025 10:08:30 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

CREATE VIEW [dbo].[TabEShopImagesView] AS
SELECT
D.ID AS id,
Z.ID AS productId,
CAST(D.ID AS NVARCHAR(10)) AS referenceId,
ISNULL(D.Popis,'') AS description,
D.Dokument AS content,
ISNULL(D.JmenoACesta,'') AS nameAndPath,
ISNULL(LTRIM(RTRIM(REVERSE(SUBSTRING(REVERSE(D.JmenoACesta), 0, CHARINDEX('\', REVERSE(D.JmenoACesta),0))))),'') AS fileName,
D.ID AS position,
D.DatPorizeni AS createdOn,
D.DatZmeny AS modifiedOn
FROM TabDokumenty D
JOIN TabDokumVazba V ON V.IdDok = D.ID AND IdentVazby = 8
JOIN TabKmenZbozi Z ON Z.ID = V.IdTab
WHERE D.PovolenoProEShop = 1
GO

