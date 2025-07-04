USE [RayService]
GO

/****** Object:  View [dbo].[TabEShopInventoriesView]    Script Date: 04.07.2025 10:09:03 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

CREATE VIEW [dbo].[TabEShopInventoriesView] AS
WITH SKarty AS
(
SELECT S.IDKmenZbozi, SUM(S.MnozstviDispo) AS available
FROM TabStavSkladu S
JOIN TabEShopKonfigSklady KS ON KS.IDSklad = S.IDSklad
JOIN TabEShopKonfigurace K ON K.ID = KS.IDKonfig
WHERE K.LoginName = SUSER_SNAME()
GROUP BY S.IDKmenZbozi
)
SELECT
Z.ID AS id,
Z.CisloZbozi AS referenceId,
ISNULL(Z.Nazev1,'') AS name,
ISNULL(SKarty.available,0) AS available,
Z.DatPorizeni AS createdOn,
Z.DatZmeny AS modifiedOn
FROM TabKmenZbozi Z
JOIN SKarty ON SKarty.IDKmenZbozi = Z.ID
GO

