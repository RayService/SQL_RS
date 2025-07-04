USE [RayService]
GO

/****** Object:  View [dbo].[TabMzdaNaUcetView]    Script Date: 04.07.2025 11:30:42 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

CREATE VIEW [dbo].[TabMzdaNaUcetView] AS
SELECT mp.ID AS ID
,cz.Cislo AS Cislo
,cz.ID AS ZamestnanecId
,mp.CisloMS AS CisloMS
,bs.CisloUctu AS CisloUctu
,pu.KodUstavu AS KodUstavu
,bs.IBANElektronicky AS IBANElektronicky
,bs.AVAReferenceID AS AVAReferenceID
,mp.IdObdobi AS IdObdobi
,mp.PorCislo AS PorCislo
FROM TabMzPaus mp
LEFT OUTER JOIN TabCisZam cz ON cz.ID = mp.ZamestnanecId
LEFT OUTER JOIN TabCisMzSl cms ON cms.CisloMzSl=mp.CisloMS AND cms.IdObdobi=mp.IdObdobi
LEFT OUTER JOIN TabBankSpojeni bs ON mp.BankSpojeni=bs.ID
LEFT OUTER JOIN TabPenezniUstavy pu ON pu.ID=(SELECT TabBankSpojeni.IDUstavu FROM TabBankSpojeni WHERE mp.BankSpojeni=TabBankSpojeni.ID)
WHERE mp.IdObdobi = (SELECT IdObdobi FROM TabMzdObd WHERE GETDATE() BETWEEN MzdObd_DatumOd AND DATEADD(d, 1,MzdObd_DatumDo)) AND 
cms.SkupinaMS = 11 AND cms.VstupniFormular = 0 AND cms.ZakladProVypocet_Prehled = 10
GO

