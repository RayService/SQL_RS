USE [RayService]
GO

/****** Object:  View [dbo].[TabEShopCustomersView]    Script Date: 04.07.2025 10:06:44 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

CREATE VIEW [dbo].[TabEShopCustomersView] AS
SELECT
O.ID AS id,
CAST(O.CisloOrg AS NVARCHAR(10)) AS referenceId,
ISNULL(O.Nazev,N'') AS name,
ISNULL(O.ICO,N'') AS cin,
ISNULL(O.DIC,N'') AS tin,
CAST((CASE WHEN O.PravniForma IN (0,1) THEN N'legalEntity' ELSE N'privatePerson' END) AS NVARCHAR(15)) AS legalFormCode,
ISNULL(PL.Spojeni,N'') AS generalPhone,
ISNULL(EM.Spojeni,N'') AS generalEmail,
CU.ID AS priceListId,
O.IDSOZsleva AS discountMasterId,
O.DatPorizeni AS createdOn,
O.DatZmeny AS modifiedOn
FROM TabCisOrg O
LEFT OUTER JOIN TabKontakty PL ON O.ID=PL.IDOrg AND PL.Prednastaveno=1 AND PL.Druh = 1 AND PL.IDVztahKOsOrg IS NULL
LEFT OUTER JOIN TabKontakty EM ON O.ID=EM.IDOrg AND EM.Prednastaveno=1 AND EM.Druh = 6 AND EM.IDVztahKOsOrg IS NULL
LEFT OUTER JOIN TabCisNC CU ON CU.CenovaUroven = O.CenovaUroven
WHERE O.NadrizenaOrg IS NULL
GO

