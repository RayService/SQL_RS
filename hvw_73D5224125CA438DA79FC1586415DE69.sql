USE [RayService]
GO

/****** Object:  View [dbo].[hvw_73D5224125CA438DA79FC1586415DE69]    Script Date: 03.07.2025 11:20:32 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

CREATE VIEW [dbo].[hvw_73D5224125CA438DA79FC1586415DE69] AS SELECT 
dpr.dprIDDochazkaPritomnost
,dpr.dprIDOsoba, dpr.dprDatumACas
,dpr.dprIDTypPruchodu
,dprIDZdrojCasovychUdalosti
,dpr.dprZmeneno
,tcz.ID AS IDZam
--,ISNULL(dosv.ov_CisloVztahu, dos.osoOsobniCislo) AS OsobniCislo
--,ISNULL(dosv.ov_ZarazeniZkratka1, dosv.ov_Zarazeni1) AS Zarazeni1
FROM DOCHAZKASQL.DC3.dbo.DochazkaPritomnost dpr
INNER JOIN DOCHAZKASQL.DC3.dbo.Osoba dos ON dos.osoIDZakaznik = dpr.dprIDZakaznik AND dos.osoIDOsoba = dpr.dprIDOsoba
INNER JOIN DOCHAZKASQL.DC3.dbo.OsobaVztah dosv ON dosv.ov_IDZakaznik = dos.osoIDZakaznik AND dosv.ov_IDOsoba = dos.osoIDOsoba
LEFT OUTER JOIN DOCHAZKASQL.DC3.dbo.ZdrojCasovychUdalosti zcu ON zcu.zcuIDZdrojCasovychUdalosti=dpr.dprIDZdrojCasovychUdalosti
LEFT OUTER JOIN RAYSERVERISH.RayService.dbo.TabCisZam tcz WITH(NOLOCK) ON tcz.Cislo=ISNULL(dosv.ov_CisloVztahu, dos.osoOsobniCislo)
WHERE dosv.ov_PlatnostDo IS NULL

/*
SELECT dpr.*,
dst.strIDStrediska
FROM DOCHAZKASQL.IdentitaNET.dbo.DochPritomnost dpr WITH(NOLOCK)
LEFT OUTER JOIN  DOCHAZKASQL.IdentitaNET.dbo.Osoby dos WITH(NOLOCK) ON dos.os_IDOsoby=dpr.priIDOsoby
LEFT OUTER JOIN DOCHAZKASQL.IdentitaNET.dbo.Strediska dst WITH(NOLOCK) ON dst.strIDStrediska=dos.os_IDStrediska
LEFT OUTER JOIN  DOCHAZKASQL.IdentitaNET.dbo.OsobyPersonalniData opd WITH(NOLOCK) ON opd.opdIDOsoby=dpr.priIDOsoby
WHERE ISNULL(opd.opdDenUkonceni,opd.opdDatumVyrazeniDo) IS NULL
*/
GO

