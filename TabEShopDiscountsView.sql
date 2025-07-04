USE [RayService]
GO

/****** Object:  View [dbo].[TabEShopDiscountsView]    Script Date: 04.07.2025 10:08:00 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

CREATE VIEW [dbo].[TabEShopDiscountsView] AS
SELECT
SL.ID AS id,
CAST(SL.ID AS NVARCHAR(10)) AS referenceId,
Soz.Nazev AS name,
ISNULL(CAST('percentage' AS NVARCHAR(15)),'') AS typeCode,
ISNULL(CAST(0 AS NUMERIC(19,6)),0) AS amount,
ISNULL((SELECT Kod FROM TabKodMen WHERE HlavniMena = 1),'') AS transactionCurrencyCode,
SL.Sleva AS percentage,
SL.OdHodnoty AS lowQuantity,
SL.PlatiOd AS validFrom,
SL.PlatiDo AS validTo,
SN.IDKmenZbo AS productId,
Soz.ID AS masterId,
SL.DatPorizeni AS createdOn,
SL.DatZmeny AS modifiedOn
FROM TabSoz Soz
JOIN TabSozNa SN ON SN.IDSoz = Soz.ID
JOIN TabSOZNaSlevy SL ON SL.IDSozNa = SN.ID
WHERE Soz.SortNS = 0 AND Soz.ElObchod = N'A'
AND SN.DruhSlevy = 0 AND SL.DruhCU IN(1,2)
AND EXISTS(SELECT * FROM TabStavSkladu S
JOIN TabEShopKonfigSklady KS ON KS.IDSklad = S.IDSklad
JOIN TabEShopKonfigurace K ON K.ID = KS.IDKonfig
WHERE S.IDKmenZbozi = SN.IDKmenZbo AND K.LoginName = SUSER_SNAME())
GO

