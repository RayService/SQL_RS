USE [RayService]
GO

/****** Object:  View [dbo].[TabBankSpView]    Script Date: 04.07.2025 9:45:25 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

CREATE VIEW [dbo].[TabBankSpView] AS
SELECT CASE WHEN A.ID IS NULL THEN B.NazevBankSpoj ELSE A.NazevBankSpoj END AS NazevBankSpoj,
CASE WHEN A.ID IS NULL THEN B.CisloUctu ELSE A.CisloUctu END AS CisloUctu,
CASE WHEN A.ID IS NULL THEN B.IBANElektronicky ELSE A.IBANElektronicky END AS IBANElektronicky,
CASE WHEN A.ID IS NULL THEN B.IBANPisemny ELSE A.IBANPisemny END AS IBANPisemny,
CASE WHEN A.ID IS NULL THEN (SELECT Z1.KodUstavu FROM TabPenezniUstavy Z1 WHERE Z1.ID=B.IdUstavu) ELSE (SELECT Z.KodUstavu FROM TabPenezniUstavy Z WHERE Z.ID=A.IdUstavu) END as KodUstavu,
CASE WHEN A.ID IS NULL THEN (SELECT Z1.SWIFTUstavu FROM TabPenezniUstavy Z1 WHERE Z1.ID=B.IdUstavu) ELSE (SELECT Z.SWIFTUstavu FROM TabPenezniUstavy Z WHERE Z.ID=A.IdUstavu) END as SWIFTUstavu,
CASE WHEN A.ID IS NULL THEN (SELECT Z1.NazevUstavu FROM TabPenezniUstavy Z1 WHERE Z1.ID=B.IdUstavu) ELSE A.NazevUstavu END as NazevUstavu,
A.DatZmeny, D.ID AS ID, N'DokZb' AS Tabulka
FROM TabDokladyZbozi D
LEFT OUTER JOIN TabBankSpojeni B ON B.ID=D.IDBankSpoj
LEFT OUTER JOIN TabBankSpojeniArch A ON A.IDBankSpoj=D.IDBankSpoj AND A.DatZmeny =
(SELECT MIN(V.DatZmeny) FROM TabBankSpojeniArch V
WHERE D.IDBankSpoj=V.IDBankSpoj AND ISNULL(D.DUZP,D.DatPorizeni) <= CONVERT(DATETIME,CONVERT(INT,CONVERT(FLOAT,V.DatZmeny))-0.0000000193) AND V.NeplatneUdaje=0 AND (V.Overeni IS NULL OR V.Overeni=0)) AND (SELECT PouzivatOrgBankSpojArch FROM TabHGlob)=1
GO

