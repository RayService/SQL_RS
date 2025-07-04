USE [RayService]
GO

/****** Object:  View [dbo].[TabEShopPriceListProductsView]    Script Date: 04.07.2025 10:14:16 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

CREATE VIEW [dbo].[TabEShopPriceListProductsView] AS
WITH XX_DPHVystup AS
(
SELECT TabKmenZbozi.ID,ISNULL(
(SELECT TOP 1 D.SazbaDPH
FROM (SELECT Z.DruhSazbyDPH, Z.ISOKodZeme, Z.PlatnostOd, Z.PlatnostDo,
Z.VstupVystup, Z.Prednastaveno, Z.IDKmenZbozi, NULL AS SkupZbo, 1 AS NaKmeni
FROM TabSazbyDPHZbo AS Z
WHERE Z.IDKmenZbozi = TabKmenZbozi.ID 
UNION
SELECT S.DruhSazbyDPH, S.ISOKodZeme, S.PlatnostOd, S.PlatnostDo,
S.VstupVystup, S.Prednastaveno, NULL, S.SkupZbo, 0
FROM TabSazbyDPHSku AS S
WHERE S.SkupZbo = TabKmenZbozi.SkupZbo) AS I
JOIN TabSazbyDPH    AS D
ON  D.DruhSazbyDPH = I.DruhSazbyDPH
AND D.ISOKodZeme   = I.ISOKodZeme
AND ISNULL(D.PlatnostOd,  '19000101 00:00:00.000') <= GETDATE()
AND ISNULL(D.PlatnostDo,  '99991231 23:59:59.997') >= GETDATE()
AND ISNULL(D.DatUkonceni, '99991231 23:59:59.997') >= GETDATE()
WHERE ISNULL(I.PlatnostOd,  '19000101 00:00:00.000') <= GETDATE()
AND   ISNULL(I.PlatnostDo,  '99991231 23:59:59.997') >= GETDATE()
AND   I.ISOKodZeme IN(SELECT ISOKod FROM TabZeme WHERE Vlastni = 1)
AND   I.VstupVystup IN(1,2)
ORDER BY I.NaKmeni DESC, I.Prednastaveno DESC), TabKmenZbozi.SazbaDPHVystup) AS SazbaDPHAktVystup
FROM TabKmenZbozi
WHERE EXISTS(SELECT * FROM TabStavSkladu S
JOIN TabEShopKonfigSklady KS ON KS.IDSklad = S.IDSklad
JOIN TabEShopKonfigurace K ON K.ID = KS.IDKonfig
WHERE S.IDKmenZbozi = TabKmenZbozi.ID AND K.LoginName = SUSER_SNAME())
)
SELECT C.ID AS priceId,
PL.ID AS priceListId,
Z.ID AS productId,
Z.CisloZbozi AS referenceId,
ISNULL(Z.Nazev1,'') AS name,
S.ID AS variantId,
ISNULL(ISNULL(ISNULL(C.MJ, Z.MJVystup), Z.MJEvidence),'') AS measureUnit,
ISNULL((SELECT TOP 1 Kod FROM TabKodMen WHERE HlavniMena = 1),'') AS transactionCurrencyCode,
C.CenaKC AS pricePerUnit,
DPH.SazbaDPHAktVystup AS tax,
CAST((CASE C.BezDPH WHEN 'A' THEN N'taxFree' WHEN 'S' THEN N'exciseTax' ELSE N'tax' END) AS NVARCHAR(15)) AS priceWithOrWithoutTax,
C.DatumOd AS validFrom,
C.DatumDo AS validTo
FROM TabStavSkladu S
JOIN TabKmenZbozi Z ON Z.ID = S.IDKmenZbozi
JOIN XX_DPHVystup DPH ON DPH.ID = Z.ID
JOIN TabNC C ON C.IDKmenZbozi = Z.ID
JOIN TabCisNC PL ON PL.CenovaUroven = C.CenovaUroven
WHERE EXISTS(SELECT*FROM TabHGlob WHERE PlatnostNabCen = 1)
UNION
SELECT C.ID AS priceId,
PL.ID AS priceListId,
Z.ID AS productId,
Z.CisloZbozi AS referenceId,
ISNULL(Z.Nazev1,'') AS name,
S.ID AS variantId,
ISNULL(ISNULL(ISNULL(C.MJ, Z.MJVystup), Z.MJEvidence),'') AS measureUnit,
ISNULL((SELECT TOP 1 Kod FROM TabKodMen WHERE HlavniMena = 1),'') AS transactionCurrencyCode,
C.CenaKC AS pricePerUnit,
DPH.SazbaDPHAktVystup AS tax,
CAST((CASE C.BezDPH WHEN 'A' THEN N'taxFree' WHEN 'S' THEN N'exciseTax' ELSE N'tax' END) AS NVARCHAR(15)) AS priceWithOrWithoutTax,
C.DatumOd AS validFrom,
C.DatumDo AS validTo
FROM TabStavSkladu S
JOIN TabKmenZbozi Z ON Z.ID = S.IDKmenZbozi
JOIN XX_DPHVystup DPH ON DPH.ID = Z.ID
JOIN TabNC C ON C.IDZboSklad = S.ID
JOIN TabCisNC PL ON PL.CenovaUroven = C.CenovaUroven
WHERE EXISTS(SELECT*FROM TabHGlob WHERE PlatnostNabCen = 0)
GO

