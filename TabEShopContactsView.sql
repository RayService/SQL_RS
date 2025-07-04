USE [RayService]
GO

/****** Object:  View [dbo].[TabEShopContactsView]    Script Date: 04.07.2025 10:05:53 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

CREATE VIEW [dbo].[TabEShopContactsView] AS
SELECT
KO.ID AS id,
O.ID AS customerId,
ISNULL(KO.Popis,'') AS contactName,
CAST(RIGHT('000000' + CAST(KO.Cislo AS NVARCHAR), 6) AS NVARCHAR(10)) AS referenceId,
ISNULL(KO.Jmeno,N'') AS firstName,
ISNULL(KO.Prijmeni,N'') AS lastName,
ISNULL(EM.Spojeni,N'') AS eMailAddress,
ISNULL(PL.Spojeni,N'') AS telephone,
ISNULL(MT.Spojeni,N'') AS mobilePhone,
KO.DatPorizeni AS createdOn,
(SELECT MAX(v)
FROM (VALUES (KO.DatZmeny), (EM.DatZmeny), (MT.DatZmeny), (PL.DatZmeny)) AS value(v)) AS modifiedOn
FROM TabCisKOs KO
LEFT OUTER JOIN TabKontakty PL ON KO.ID=PL.IDCisKOs AND PL.Prednastaveno=1 AND PL.Druh = 1 AND PL.IDVztahKOsOrg IS NULL
LEFT OUTER JOIN TabKontakty MT ON KO.ID=MT.IDCisKOs AND MT.Prednastaveno=1 AND MT.Druh = 2 AND MT.IDVztahKOsOrg IS NULL
LEFT OUTER JOIN TabKontakty EM ON KO.ID=EM.IDCisKOs AND EM.Prednastaveno=1 AND EM.Druh = 6 AND EM.IDVztahKOsOrg IS NULL
LEFT OUTER JOIN TabCisOrg O ON O.ID=(SELECT TOP 1 IDOrg FROM TabVztahOrgKOs WHERE IDCisKOs=KO.ID ORDER BY ID DESC)
WHERE O.ID IS NOT NULL
GO

