USE [RayService]
GO

/****** Object:  View [dbo].[hvw_1354C96A3FDE48CE9FD18663BBACD1F7]    Script Date: 03.07.2025 10:57:06 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

CREATE VIEW [dbo].[hvw_1354C96A3FDE48CE9FD18663BBACD1F7] AS SELECT ISNULL(ov.ov_CisloVztahu, os.osoOsobniCislo) AS OsobniCislo, os.*
FROM DOCHAZKASQL.DC3.dbo.Osoba os WITH(NOLOCK)
INNER JOIN DOCHAZKASQL.DC3.dbo.OsobaVztah ov WITH(NOLOCK) ON ov.ov_IDZakaznik = os.osoIDZakaznik AND ov.ov_IDOsoba = os.osoIDOsoba

/*SELECT *
FROM DOCHAZKASQL.IdentitaNET.dbo.Osoby WITH(NOLOCK)*/
GO

