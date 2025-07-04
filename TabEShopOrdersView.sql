USE [RayService]
GO

/****** Object:  View [dbo].[TabEShopOrdersView]    Script Date: 04.07.2025 10:10:34 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

CREATE VIEW [dbo].[TabEShopOrdersView] AS
WITH Payments AS (
SELECT * FROM TabEShopPayments
WHERE ID IN (
SELECT MIN(ID)
FROM TabEShopPayments
GROUP BY IDObj)
)
SELECT
H.ID AS id,
ISNULL(H.Cislo,'') AS referenceId,
ISNULL(H.Rada + N'/' + H.Cislo,'') AS name,
ISNULL(H.VerejnaPoznamka,'') AS noteText,
H.VerejnaPoznamka AS noteText_All,
H.Mena AS transactionCurrencyCode,
H.Kurz AS exchangeRate,
H.SumaValPoZao AS totalPrice,
ISNULL(H.ZemeDPH,'') AS vatCountryCode,
H.ExterniCislo AS externalReferenceId,
H.IDFormaDopravy AS transportMethodId,
H.PopisDodavky AS deliveringDescription,
H.IDSklad AS warehouseId,
ISNULL(W.CisloStr,'') AS warehouseReferenceId,
ISNULL(CAST(N'' AS NVARCHAR(15)),'') AS discountCode,
ISNULL((SELECT SUM(SlevaCastkaSDPHVal) FROM TabDosleObjRekapDPH02 WHERE IDDosleObj = H.ID),0) AS discountAmount,
ISNULL(CAST((CASE WHEN H.StavKryti = 6 THEN N'shipped' WHEN H.StavKryti = 3 THEN N'partiallyShipped' WHEN P.ID IS NULL THEN N'waitingForPayment' WHEN (P.paymentMethodCode = 0 AND P.paymentStatusCode = 1) OR (P.paymentMethodCode = 1) OR (P.paymentMethodCode = 3) OR (P.paymentMethodCode = 2 AND P.paymentStatusCode = 1) THEN N'processing' WHEN (P.paymentMethodCode = 0 AND P.paymentStatusCode <> 1) OR (P.paymentMethodCode = 2 AND P.paymentStatusCode <> 1) THEN N'waitingForPayment' ELSE N'processing' END) AS NVARCHAR(20)),'') AS stateCode,
H.DatPorizeni AS createdOn,
H.DatZmeny AS modifiedOn,
OB.ID AS customerId,
OB.ID AS billingAddressId,
ISNULL(OS.ID, OB.ID) AS shippingAddressId
FROM TabDosleObjH02 H
JOIN TabStrom W ON W.ID = H.IDSklad
JOIN TabEShopKonfigurace K ON K.RadaDObj = H.Rada
LEFT JOIN TabCisOrg OB ON OB.CisloOrg = H.CisloOrg
LEFT JOIN TabCisOrg OS ON OS.CisloOrg = H.MistoUrceni
LEFT JOIN Payments P ON P.IDObj = H.ID
WHERE K.LoginName = SUSER_SNAME()
GO

