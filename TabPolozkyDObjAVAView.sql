USE [RayService]
GO

/****** Object:  View [dbo].[TabPolozkyDObjAVAView]    Script Date: 04.07.2025 11:38:56 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

CREATE VIEW [dbo].[TabPolozkyDObjAVAView] AS
SELECT
T.ID AS ID
,T.IDHlava AS IDDoklad
,NULL AS IDPolozky
,T.ID AS IDTxtPol
,T.AVAReferenceID AS AVAReferenceID
,'T' + CAST(t.ID AS NVARCHAR(10)) AS ItemId
,T.Poradi AS ItemNo
,H.Mena AS Mena
,T.CCsDPHVal AS Amount
,T.CCsDPHValPoS AS AmountAfterDiscount
,T.CCbezDaniValPoS AS AmountAfterDiscountBase
,T.CCDPHValPoS AS AmountAfterDiscountTax
,T.CCbezDaniVal AS AmountBase
,CAST(T.CCsDPHVal-T.CCsDPHValPoS AS NUMERIC(19,6)) AS AmountDiscount
,T.CCDPHVal AS AmountTax
,T.JCsDPHVal AS AmountUnit
,T.JCbezDaniVal AS AmountUnitBase
,CASE WHEN T.Mnozstvi = 0 THEN CAST(0 AS NUMERIC(19,6)) ELSE CAST((T.CCsDPHVal - T.CCsDPHValPoS) / T.Mnozstvi AS NUMERIC(19,6)) END AS DiscountUnitAmount
,T.Poznamka AS Comments
,T.IDStredNaklad AS CostCenter
,T.IDZakazka AS JobOrder
,CAST((CASE WHEN T.CCsDPHVal=0 THEN 0 ELSE ((T.CCsDPHVal-T.CCsDPHValPoS)/T.CCsDPHVal)*100 END) AS NUMERIC(5,2)) AS PercentageDiscount
,NULL AS PlannedDeliveryDate
,CAST(ltrim(replace(substring(t.Popis,1,100),(nchar(13) + nchar(10)),nchar(32))) AS NVARCHAR(100)) AS Name
,NULL AS DoneQuantity
,T.Mnozstvi AS Quantity
,NULL AS QuantityRecalculation
,T.MJ AS QuantityUnit
,NULL AS QuantityRegisterUnit
,NULL AS StockMasterCard
,T.SazbaDPH AS VATRate
,CAST(NULL AS NVARCHAR(30)) AS Warehouse
FROM TabDosleObjTxtPol02 T
JOIN TabDosleObjH02 H ON H.ID=T.IDHlava

UNION ALL

SELECT
-P.ID
,P.IDHlava
,P.ID
,NULL
,P.AVAReferenceID
,'P' + CAST(p.ID AS NVARCHAR(10))
,P.PoradiPolozky
,H.Mena
,P.CCsDPHVal
,P.CCsDPHValPoS
,P.CCsSDValPoS
,CAST(P.CCsDPHValPoS-P.CCsSDValPoS AS NUMERIC(19,6))
,P.CCsSDVal
,CAST(P.CCsDPHVal-P.CCsDPHValPoS AS NUMERIC(19,6))
,CAST(P.CCsDPHVal-P.CCsSDVal AS NUMERIC(19,6))
,P.JCsDPHVal
,P.JCsSDVal
,CASE WHEN P.Mnozstvi = 0 THEN CAST(0 AS NUMERIC(19,6)) ELSE CAST((P.CCsDPHVal - P.CCsDPHValPoS) / P.Mnozstvi AS NUMERIC(19,6)) END
,P.Poznamka
,P.IDStredNaklad
,P.IDZakazka
,CAST((CASE WHEN P.CCsDPHVal=0 THEN 0 ELSE ((P.CCsDPHVal-P.CCsDPHValPoS)/P.CCsDPHVal)*100 END) AS NUMERIC(5,2))
,P.PotvrzDatDod
,P.Nazev1
,P.MnozstviRealVydej
,P.Mnozstvi
,P.PrepMnozstvi
,P.MJ
,KZ.MJEvidence
,KZ.ID
,P.SazbaDPH
,S.IDSklad
FROM TabDosleObjR02 P
JOIN TabDosleObjH02 H ON H.ID = P.IDHlava
JOIN TabStavSkladu S ON S.ID = P.IDZboSklad
JOIN TabKmenZbozi KZ ON KZ.ID = S.IDKmenZbozi
GO

