USE [RayService]
GO

/****** Object:  View [dbo].[TabPolozkyDokZboView]    Script Date: 04.07.2025 11:40:33 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

CREATE VIEW [dbo].[TabPolozkyDokZboView] AS
SELECT
t.ID AS ID
,t.IDDoklad AS IDDoklad
,NULL AS IDPolozky
,t.ID AS IDTxtPol
,'T' + CAST(t.ID AS NVARCHAR(10)) AS itemId
,CAST(N'txtItem' AS NVARCHAR(7)) AS itemType
,NULL AS warehouseId
,NULL AS warehouseItemId
,NULL AS catalogueNo
,t.Popis AS description
,t.Mnozstvi AS quantity
,t.MJ AS measureUnit
,t.JCbezDaniValPoS AS unitCurrencyAmount
,t.CCbezDaniValPoS AS currencyAmount
,t.SazbaDPH AS vatRate
,t.CCsDPHValPoS AS currencyAmountTaxInclusive
,t.SazbaDPHproPDP AS reverseChargePercent
,k.KodZbozi AS reverseChargeCode
,t.Poznamka AS note
,t.DatPorizeni AS createdOn
,t.DatZmeny AS modifiedOn
FROM TabOZTxtPol t
LEFT JOIN TabCisKoduPDP k ON k.ID=t.IDKodPDP

UNION ALL

SELECT
-p.ID,p.IDDoklad,p.ID,NULL
,'P' + CAST(p.ID AS NVARCHAR(10))
,CAST(N'item' AS NVARCHAR(7)) AS itemType
,s.IDSklad AS warehouseId
,p.IDZboSklad AS warehouseItemId
,p.CisloKarty AS catalogueNo
,p.Nazev1 AS description
,p.Mnozstvi AS quantity
,p.MJ AS measureUnit
,p.JCsSDValPoS AS unitCurrencyAmount
,p.CCsSDValPoS AS currencyAmount
,p.SazbaDPH AS vatRate
,p.CCsDPHValPoS AS currencyAmountTaxInclusive
,p.SazbaDPHproPDP AS reverseChargePercent
,k.KodZbozi AS reverseChargeCode
,p.Poznamka AS note
,p.DatPorizeni AS createdOn
,p.DatZmeny AS modifiedOn
FROM TabPohybyZbozi p
JOIN TabStavSkladu s ON s.ID=p.IDZboSklad
LEFT JOIN TabCisKoduPDP k ON k.ID=p.IDKodPDP
GO

