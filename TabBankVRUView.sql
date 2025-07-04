USE [RayService]
GO

/****** Object:  View [dbo].[TabBankVRUView]    Script Date: 04.07.2025 9:47:00 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

CREATE VIEW [dbo].[TabBankVRUView] AS
SELECT IDHlava, ID AS IDRadek, NULL AS IDDetail, Castka, PocetMeny AS CastkaTrans,
VariabilniSymbol, NULL AS IDDokZbo, NULL AS IDUhrady
FROM TabBankVypisR
WHERE NOT EXISTS(SELECT*FROM TabBankVypisRUhrady WHERE IDRadek=TabBankVypisR.ID)
UNION ALL
SELECT r.IDHlava, r.ID AS IDRadek, d.ID AS IDDetail, d.Castka, d.CastkaTrans,
d.VariabilniSymbol, d.IDDokZbo, d.IDUhrady
FROM TabBankVypisRUhrady d
JOIN TabBankVypisR r ON r.ID=d.IDRadek

 
GO

