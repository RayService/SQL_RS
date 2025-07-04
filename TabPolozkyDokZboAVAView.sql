USE [RayService]
GO

/****** Object:  View [dbo].[TabPolozkyDokZboAVAView]    Script Date: 04.07.2025 11:39:42 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

CREATE VIEW [dbo].[TabPolozkyDokZboAVAView] AS
SELECT
t.ID AS ID
,t.IDDoklad AS IDDoklad
,NULL AS IDPolozky
,t.ID AS IDTxtPol
,t.AVAReferenceID AS AVAReferenceID
,'T' + CAST(t.ID AS NVARCHAR(10)) AS ItemId
,d.Mena AS Mena
,t.CCsDPHVal AS Amount
,t.CCsDPHValPoS AS AmountAfterDiscount
,t.CCbezDaniValPoS AS AmountAfterDiscountBase
,t.CCDPHValPoS AS AmountAfterDiscountTax
,t.CCbezDaniVal AS AmountBase
,CAST(t.CCsDPHVal-t.CCsDPHValPoS AS NUMERIC(19,6)) AS AmountDiscount
,t.CCDPHVal AS AmountTax
,t.JCsDPHVal AS AmountUnit
,t.JCbezDaniVal AS AmountUnitBase
,t.Poznamka AS Comments
,s.Cislo AS CostCenter
,z.CisloZakazky AS JobOrder
,CAST((CASE WHEN t.CCsDPHVal=0 THEN 0 ELSE ((t.CCsDPHVal-t.CCsDPHValPoS)/t.CCsDPHVal)*100 END) AS NUMERIC(5,2)) AS PercentageDiscount
,CAST(NULL AS NVARCHAR(15)) AS Project
,t.Mnozstvi AS Quantity
,NULL AS QuantityRecalculation
,t.MJ AS QuantityUnit
,NULL AS QuantityRegisterUnit
,NULL AS RequiredTotalStockPrice
,k.KodZbozi AS ReverseChargeCode
,NULL AS TotalStockPrice
,NULL AS UnitStockPrice
,t.SazbaDPH AS VATRate
,t.SazbaDPHproPDP AS VATReverseCharge
,CAST(NULL AS NVARCHAR(30)) AS Warehouse
,CAST(NULL AS NVARCHAR(3)) AS WarehouseMasterDataCard_Group
,CAST(ltrim(replace(substring(t.Popis,1,100),(nchar(13) + nchar(10)),nchar(32))) AS NVARCHAR(100)) AS WarehouseMasterDataCard_Name
,CAST(NULL AS NVARCHAR(30)) AS WarehouseMasterDataCard_Number
FROM TabOZTxtPol t
JOIN TabDokladyZbozi d ON d.ID=t.IDDoklad
LEFT JOIN TabCisKoduPDP k ON k.ID=t.IDKodPDP
LEFT JOIN TabZakazka z ON z.ID=t.IDZakazka
LEFT JOIN TabStrom s ON s.Id=t.IDStredNaklad

UNION ALL

SELECT
-p.ID
,p.IDDoklad
,p.ID
,NULL
,p.AVAReferenceID
,'P' + CAST(p.ID AS NVARCHAR(10))
,p.Mena
,p.CCsDPHVal
,p.CCsDPHValPoS
,p.CCsSDValPoS
,CAST(p.CCsDPHValPoS-p.CCsSDValPoS AS NUMERIC(19,6))
,p.CCsSDVal
,CAST(p.CCsDPHVal-p.CCsDPHValPoS AS NUMERIC(19,6))
,CAST(p.CCsDPHVal-p.CCsSDVal AS NUMERIC(19,6))
,p.JCsDPHVal
,p.JCsSDVal
,p.Poznamka
,p.StredNaklad
,p.CisloZakazky
,CAST((CASE WHEN p.CCsDPHVal=0 THEN 0 ELSE ((p.CCsDPHVal-p.CCsDPHValPoS)/p.CCsDPHVal)*100 END) AS NUMERIC(5,2))
,CAST(NULL AS NVARCHAR(15))
,p.Mnozstvi
,p.PrepMnozstvi
,p.MJ
,kz.MJEvidence
,p.CCevidPozadovana
,k.KodZbozi
,p.CCevid
,p.JCevid
,p.SazbaDPH
,p.SazbaDPHproPDP
,s.IDSklad
,p.SkupZbo
,p.Nazev1
,p.RegCis
FROM TabPohybyZbozi p
JOIN TabStavSkladu s ON s.ID=p.IDZboSklad
JOIN TabKmenZbozi kz ON kz.ID=s.IDKmenZbozi
LEFT JOIN TabCisKoduPDP k ON k.ID=p.IDKodPDP
GO

