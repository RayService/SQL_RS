USE [RayService]
GO

/****** Object:  View [dbo].[TabEShopAddressesView]    Script Date: 04.07.2025 10:03:35 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

CREATE VIEW [dbo].[TabEShopAddressesView] AS
SELECT
O.ID AS id,
CAST(O.CisloOrg AS NVARCHAR(10)) AS referenceId,
(CASE WHEN NadO.ID IS NULL THEN O.ID ELSE NadO.ID END) AS customerId,
ISNULL(O.Nazev,N'') AS name,
CAST((CASE WHEN NadO.ID IS NULL THEN N'billing' ELSE N'shipping' END) AS NVARCHAR(15)) AS typeCode,
ISNULL(O.Ulice,N'') AS street,
ISNULL(O.PopCislo,N'') AS houseNumber,
ISNULL(O.OrCislo,N'') AS streetNumber,
ISNULL(O.NazevCastiObce,N'') AS district,
ISNULL(O.Misto,N'') AS city,
ISNULL(O.NazevOkresu,N'') AS stateOrProvince,
ISNULL(O.PSC,N'') AS postalCode,
ISNULL(O.IdZeme,N'') AS countryCode,
ISNULL(MT.Spojeni,N'') AS shippingPhone,
O.DatPorizeni AS createdOn,
O.DatZmeny AS modifiedOn,
O.CisloOrg AS orgNumber
FROM TabCisOrg O
LEFT OUTER JOIN TabCisOrg NadO ON NadO.CisloOrg = O.NadrizenaOrg
LEFT OUTER JOIN TabKontakty MT ON O.ID=MT.IDOrg AND MT.Prednastaveno=1 AND MT.Druh = 2 AND MT.IDVztahKOsOrg IS NULL
GO

