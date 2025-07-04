USE [RayService]
GO

/****** Object:  View [dbo].[TabEShopProductsView]    Script Date: 04.07.2025 10:16:36 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

CREATE VIEW [dbo].[TabEShopProductsView] AS 
SELECT
Z.ID AS id,
Z.CisloZbozi AS referenceId,
ISNULL(Z.Nazev1,'') AS name,
CAST((CASE Z.DruhKarty WHEN 1 THEN N'shipping' WHEN 2 THEN N'packing' WHEN 3 THEN N'assembly' WHEN 4 THEN N'insurance' ELSE N'product' END) AS NVARCHAR(15)) AS typeCode,
ISNULL(Z.Poznamka,'') AS description,
Z.Poznamka AS description_All,
ISNULL(BC.BarCode,'') AS barcode,
ISNULL(ISNULL(Z.MJVystup, Z.MJEvidence),'') AS measureUnit,
CAST((CASE Z.Blokovano WHEN 0 THEN N'active' WHEN 1 THEN N'archived' ELSE N'draft' END) AS NVARCHAR(10)) AS statusCode,
D.ID AS vendorId,
ISNULL(CAST(D.CisloOrg AS NVARCHAR(10)),'') AS vendorReferenceId,
ISNULL(D.Nazev,'') AS vendorName,
V.ID AS manufacturerId,
ISNULL(CAST(V.CisloOrg AS NVARCHAR(10)),'') AS manufacturerReferenceId,
ISNULL(V.Nazev,'') AS manufacturerName,
Z.DatPorizeni AS createdOn,
Z.DatZmeny AS modifiedOn
FROM TabKmenZbozi Z
LEFT JOIN TabBarCodeZbo BC ON BC.IDKmenZbo = Z.ID AND BC.Prednastaveno=1
LEFT JOIN TabCisOrg D ON D.CisloOrg = Z.Aktualni_Dodavatel
LEFT JOIN TabCisOrg V ON V.CisloOrg = Z.Vyrobce
WHERE EXISTS(SELECT * FROM TabStavSkladu S
JOIN TabEShopKonfigSklady KS ON KS.IDSklad = S.IDSklad
JOIN TabEShopKonfigurace K ON K.ID = KS.IDKonfig
WHERE S.IDKmenZbozi = Z.ID AND K.LoginName = SUSER_SNAME())
GO

