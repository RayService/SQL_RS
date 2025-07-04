USE [RayService]
GO

/****** Object:  View [dbo].[TabEShopOrderItemsView]    Script Date: 04.07.2025 10:10:01 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

CREATE VIEW [dbo].[TabEShopOrderItemsView] AS
SELECT
R.ID AS id,
R.CisloKarty  AS referenceId,
R.IDHlava AS orderId,
Z.ID AS productId,
Z.CisloZbozi  AS productReferenceId,
CAST((CASE Z.DruhKarty WHEN 1 THEN N'shipping' WHEN 2 THEN N'packing' WHEN 3 THEN N'assembly' WHEN 4 THEN N'insurance' ELSE N'product' END) AS NVARCHAR(15)) AS typeCode,
ISNULL(R.Nazev1,'') AS productName,
ISNULL(R.Poznamka,'') AS productDescription,
R.Poznamka AS productDescription_All,
W.ID AS warehouseId,
ISNULL(W.CisloStr,'') AS warehouseReferenceId,
W.Nazev AS warehouseName,
S.ID AS variantId,
Z.CisloZbozi AS variantReferenceId,
ISNULL(R.Nazev1,'') AS variantName,
R.Mnozstvi AS quantity,
ISNULL(R.MJ,'') AS measureUnit,
R.JCsDPHVal AS pricePerUnit,
R.JCsDPHKc AS pricePerUnitBase,
R.CCsDPHVal AS totalPrice,
ISNULL(R.SlevaPolozkyVal,0) AS discountUnitAmount,
(ISNULL((SELECT SUM(DPO.Mnozstvi) FROM TabDilciPrijmyDObj02 AS DPO JOIN TabZpusobZajKry02 ZZK ON ZZK.ID = DPO.IDZpusob JOIN TabZpusobZajDObj02 ZZO ON ZZK.IDZpusob = ZZO.ID WHERE ZZO.ID = R.ID),0)) AS blockedQuantity,
R.SazbaDPH AS vatRate,
R.DatPorizeni AS createdOn,
R.DatZmeny AS modifiedOn
FROM TabDosleObjR02 R
JOIN TabStavSkladu S ON S.ID = R.IDZboSklad
JOIN TabKmenZbozi Z ON Z.ID = S.IDKmenZbozi
JOIN TabStrom W ON W.Cislo = S.IDSklad
GO

