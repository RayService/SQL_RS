USE [RayService]
GO

/****** Object:  View [dbo].[TabEShopVariantsView]    Script Date: 04.07.2025 10:17:04 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

CREATE VIEW [dbo].[TabEShopVariantsView] AS
SELECT
S.ID AS id,
Z.CisloZbozi AS referenceId,
ISNULL(Z.Nazev1,'') AS name,
ISNULL(ISNULL(Z.MJVystup, Z.MJEvidence),'') AS measureUnit,
S.MnozstviDispo AS available,
W.ID AS warehouseId,
ISNULL(W.CisloStr,'') AS warehouseReferenceId,
W.Nazev AS warehouseName,
Z.ID AS productId,
Z.DatPorizeni AS createdOn,
Z.DatZmeny AS modifiedOn
FROM TabStavSkladu S
JOIN TabEShopKonfigSklady KS ON KS.IDSklad = S.IDSklad
JOIN TabEShopKonfigurace K ON K.ID = KS.IDKonfig
JOIN TabKmenZbozi Z ON Z.ID = S.IDKmenZbozi
JOIN TabStrom W ON W.Cislo = S.IDSklad
WHERE K.LoginName = SUSER_SNAME()
GO

