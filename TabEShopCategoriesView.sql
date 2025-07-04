USE [RayService]
GO

/****** Object:  View [dbo].[TabEShopCategoriesView]    Script Date: 04.07.2025 10:04:56 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

CREATE VIEW [dbo].[TabEShopCategoriesView] AS
SELECT
S.ID AS id,
ISNULL(S.KatAllTecky,'') AS referenceId,
ISNULL(S.Nazev,'') AS name,
P.ID AS superiorCategoryId,
CAST(1 AS INT) AS position,
S.DatPorizeni AS createdOn,
S.DatZmeny AS modifiedOn
FROM TabSortiment S
LEFT JOIN TabSortiment P ON P.ID = S.IDNadrazene
GO

