USE [RayService]
GO

/****** Object:  View [dbo].[TabEShopPriceListsView]    Script Date: 04.07.2025 10:16:01 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

CREATE VIEW [dbo].[TabEShopPriceListsView] AS
SELECT
ID AS id,
ISNULL(CAST(CenovaUroven AS NVARCHAR(10)),'') AS referenceId,
Nazev AS name,
ISNULL(CAST('priceList' AS NVARCHAR(15)),'') AS typeCode,
DatPorizeni AS createdOn,
DatZmeny AS modifiedOn
FROM TabCisNC
GO

