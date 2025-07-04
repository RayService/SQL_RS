USE [RayService]
GO

/****** Object:  View [dbo].[TabCisOrgView]    Script Date: 04.07.2025 9:48:26 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

CREATE VIEW [dbo].[TabCisOrgView] AS
SELECT ISNULL(T.CisloOrg, A.CisloOrg) AS CisloOrg,
ISNULL(T.Nazev, A.Nazev) as Nazev,
ISNULL(T.DruhyNazev, A.DruhyNazev) as DruhyNazev,
CASE WHEN T.ID IS NULL THEN A.PSC ELSE T.PSC END as PSC,
ISNULL(T.Misto, A.Misto) as Misto,
ISNULL(T.Ulice, A.Ulice) as Ulice,
ISNULL(T.OrCislo, A.OrCislo) as OrCislo,
ISNULL(T.PopCislo, A.PopCislo) as PopCislo,
ISNULL(T.UliceSCisly, A.UliceSCisly) as UliceSCisly,
CASE WHEN T.ID IS NULL THEN A.DIC ELSE T.DIC END as DIC,
CASE WHEN T.ID IS NULL THEN A.DICSk ELSE T.DICSk END as DICSk,
CASE WHEN T.ID IS NULL THEN A.ICO ELSE T.ICO END as ICO,
CASE WHEN T.ID IS NULL THEN A.IdZeme ELSE T.IdZeme END as IdZeme,
CASE WHEN T.ID IS NULL THEN (SELECT Z1.Nazev FROM TabZeme Z1 WHERE Z1.ISOKod=A.IdZeme) ELSE (SELECT Z.Nazev FROM TabZeme Z WHERE Z.ISOKod=T.IdZeme) END as NazevZeme,
ISNULL(T.UdajOZapisuDoObchRej, A.UdajOZapisuDoObchRej) as UdajOZapisuDoObchRej,
ISNULL(T.NazevCastiObce, A.NazevCastiObce) as NazevCastiObce,
ISNULL(T.NazevOkresu, A.NazevOkresu) as NazevOkresu,
ISNULL(T.MestskaCast, A.MestskaCast) as MestskaCast,
ISNULL(T.DatZmeny, T.DatPorizeni) AS DatZmeny, D.ID AS ID, N'CODZ0' AS Tabulka
FROM TabDokladyZbozi D
LEFT OUTER JOIN TabCisOrg A ON A.CisloOrg = 0
LEFT OUTER JOIN TabCisOrgArch T ON 0 = T.CisloOrg AND T.ID =
(SELECT TOP 1 V.ID FROM TabCisOrgArch V
WHERE 0=V.CisloOrg AND ISNULL(D.DUZP,D.DatPorizeni) <= CONVERT(DATETIME,CONVERT(INT,CONVERT(FLOAT,V.DatZmeny))-0.0000000193) AND V.NeplatneUdaje=0 AND (V.Overeni IS NULL OR V.Overeni=0) ORDER BY V.DatZmeny, V.ID) AND (SELECT PouzivatOrgBankSpojArch FROM TabHGlob)=1
UNION ALL
SELECT ISNULL(T.CisloOrg, A.CisloOrg) as CisloOrg,
ISNULL(T.Nazev, A.Nazev) as Nazev,
ISNULL(T.DruhyNazev, A.DruhyNazev) as DruhyNazev,
CASE WHEN T.ID IS NULL THEN A.PSC ELSE T.PSC END as PSC,
ISNULL(T.Misto, A.Misto) as Misto,
ISNULL(T.Ulice, A.Ulice) as Ulice,
ISNULL(T.OrCislo, A.OrCislo) as OrCislo,
ISNULL(T.PopCislo, A.PopCislo) as PopCislo,
ISNULL(T.UliceSCisly, A.UliceSCisly) as UliceSCisly,
CASE WHEN T.ID IS NULL THEN A.DIC ELSE T.DIC END as DIC,
CASE WHEN T.ID IS NULL THEN A.DICSk ELSE T.DICSk END as DICSk,
CASE WHEN T.ID IS NULL THEN A.ICO ELSE T.ICO END as ICO,
CASE WHEN T.ID IS NULL THEN A.IdZeme ELSE T.IdZeme END as IdZeme,
CASE WHEN T.ID IS NULL THEN (SELECT Z1.Nazev FROM TabZeme Z1 WHERE Z1.ISOKod=A.IdZeme) ELSE (SELECT Z.Nazev FROM TabZeme Z WHERE Z.ISOKod=T.IdZeme) END as NazevZeme,
NULL as UdajOZapisuDoObchRej,
ISNULL(T.NazevCastiObce, A.NazevCastiObce) as NazevCastiObce,
ISNULL(T.NazevOkresu, A.NazevOkresu) as NazevOkresu,
ISNULL(T.MestskaCast, A.MestskaCast) as MestskaCast,
ISNULL(T.DatZmeny, T.DatPorizeni) AS DatZmeny, D.ID AS ID, N'Denik' AS Tabulka
FROM TabDenik D
LEFT OUTER JOIN TabCisOrg A ON D.CisloOrg = A.CisloOrg
LEFT OUTER JOIN TabCisOrgArch T ON D.CisloOrg = T.CisloOrg AND T.ID =
(SELECT TOP 1 V.ID FROM TabCisOrgArch V
WHERE D.CisloOrg = V.CisloOrg AND D.DatPorizeni <= CONVERT(DATETIME,CONVERT(INT,CONVERT(FLOAT,V.DatZmeny))-0.0000000193) AND V.NeplatneUdaje=0 AND (V.Overeni IS NULL OR V.Overeni=0) ORDER BY V.DatZmeny, V.ID) AND (SELECT PouzivatOrgBankSpojArch FROM TabHGlob)=1
UNION ALL
SELECT ISNULL(T.CisloOrg, A.CisloOrg) as CisloOrg,
ISNULL(T.Nazev, A.Nazev) as Nazev,
ISNULL(T.DruhyNazev, A.DruhyNazev) as DruhyNazev,
CASE WHEN T.ID IS NULL THEN A.PSC ELSE T.PSC END as PSC,
ISNULL(T.Misto, A.Misto) as Misto,
ISNULL(T.Ulice, A.Ulice) as Ulice,
ISNULL(T.OrCislo, A.OrCislo) as OrCislo,
ISNULL(T.PopCislo, A.PopCislo) as PopCislo,
ISNULL(T.UliceSCisly, A.UliceSCisly) as UliceSCisly,
CASE WHEN T.ID IS NULL THEN A.DIC ELSE T.DIC END as DIC,
CASE WHEN T.ID IS NULL THEN A.DICSk ELSE T.DICSk END as DICSk,
CASE WHEN T.ID IS NULL THEN A.ICO ELSE T.ICO END as ICO,
CASE WHEN T.ID IS NULL THEN A.IdZeme ELSE T.IdZeme END as IdZeme,
CASE WHEN T.ID IS NULL THEN (SELECT Z1.Nazev FROM TabZeme Z1 WHERE Z1.ISOKod=A.IdZeme) ELSE (SELECT Z.Nazev FROM TabZeme Z WHERE Z.ISOKod=T.IdZeme) END as NazevZeme,
NULL as UdajOZapisuDoObchRej,
ISNULL(T.NazevCastiObce, A.NazevCastiObce) as NazevCastiObce,
ISNULL(T.NazevOkresu, A.NazevOkresu) as NazevOkresu,
ISNULL(T.MestskaCast, A.MestskaCast) as MestskaCast,
ISNULL(T.DatZmeny, T.DatPorizeni) AS DatZmeny, D.ID AS ID, N'Poklad' AS Tabulka
FROM TabPokladna D
LEFT OUTER JOIN TabCisOrg A ON D.CisloOrg = A.CisloOrg
LEFT OUTER JOIN TabCisOrgArch T ON D.CisloOrg = T.CisloOrg AND T.ID =
(SELECT TOP 1 V.ID FROM TabCisOrgArch V
WHERE D.CisloOrg = V.CisloOrg AND D.DatPorizeni <= CONVERT(DATETIME,CONVERT(INT,CONVERT(FLOAT,V.DatZmeny))-0.0000000193) AND V.NeplatneUdaje=0 AND (V.Overeni IS NULL OR V.Overeni=0) ORDER BY V.DatZmeny, V.ID) AND (SELECT PouzivatOrgBankSpojArch FROM TabHGlob)=1
UNION ALL
SELECT ISNULL(T.CisloOrg, A.CisloOrg) as CisloOrg,
ISNULL(T.Nazev, A.Nazev) as Nazev,
ISNULL(T.DruhyNazev, A.DruhyNazev) as DruhyNazev,
CASE WHEN T.ID IS NULL THEN A.PSC ELSE T.PSC END as PSC,
ISNULL(T.Misto, A.Misto) as Misto,
ISNULL(T.Ulice, A.Ulice) as Ulice,
ISNULL(T.OrCislo, A.OrCislo) as OrCislo,
ISNULL(T.PopCislo, A.PopCislo) as PopCislo,
ISNULL(T.UliceSCisly, A.UliceSCisly) as UliceSCisly,
CASE WHEN T.ID IS NULL THEN A.DIC ELSE T.DIC END as DIC,
CASE WHEN T.ID IS NULL THEN A.DICSk ELSE T.DICSk END as DICSk,
CASE WHEN T.ID IS NULL THEN A.ICO ELSE T.ICO END as ICO,
CASE WHEN T.ID IS NULL THEN A.IdZeme ELSE T.IdZeme END as IdZeme,
CASE WHEN T.ID IS NULL THEN (SELECT Z1.Nazev FROM TabZeme Z1 WHERE Z1.ISOKod=A.IdZeme) ELSE (SELECT Z.Nazev FROM TabZeme Z WHERE Z.ISOKod=T.IdZeme) END as NazevZeme,
NULL as UdajOZapisuDoObchRej,
ISNULL(T.NazevCastiObce, A.NazevCastiObce) as NazevCastiObce,
ISNULL(T.NazevOkresu, A.NazevOkresu) as NazevOkresu,
ISNULL(T.MestskaCast, A.MestskaCast) as MestskaCast,
ISNULL(T.DatZmeny, T.DatPorizeni) AS DatZmeny, D.ID AS ID, N'DokZb' AS Tabulka
FROM TabDokladyZbozi D
LEFT OUTER JOIN TabCisOrg A ON D.CisloOrg = A.CisloOrg
LEFT OUTER JOIN TabCisOrgArch T ON D.CisloOrg = T.CisloOrg AND T.ID =
(SELECT TOP 1 V.ID FROM TabCisOrgArch V
WHERE D.CisloOrg = V.CisloOrg AND ISNULL(D.DUZP,D.DatPorizeni) <= CONVERT(DATETIME,CONVERT(INT,CONVERT(FLOAT,V.DatZmeny))-0.0000000193) AND V.NeplatneUdaje=0 AND (V.Overeni IS NULL OR V.Overeni=0) ORDER BY V.DatZmeny, V.ID) AND (SELECT PouzivatOrgBankSpojArch FROM TabHGlob)=1
UNION ALL
SELECT ISNULL(T.CisloOrg, A.CisloOrg) as CisloOrg,
ISNULL(T.Nazev, A.Nazev) as Nazev,
ISNULL(T.DruhyNazev, A.DruhyNazev) as DruhyNazev,
CASE WHEN T.ID IS NULL THEN A.PSC ELSE T.PSC END as PSC,
ISNULL(T.Misto, A.Misto) as Misto,
ISNULL(T.Ulice, A.Ulice) as Ulice,
ISNULL(T.OrCislo, A.OrCislo) as OrCislo,
ISNULL(T.PopCislo, A.PopCislo) as PopCislo,
ISNULL(T.UliceSCisly, A.UliceSCisly) as UliceSCisly,
CASE WHEN T.ID IS NULL THEN A.DIC ELSE T.DIC END as DIC,
CASE WHEN T.ID IS NULL THEN A.DICSk ELSE T.DICSk END as DICSk,
CASE WHEN T.ID IS NULL THEN A.ICO ELSE T.ICO END as ICO,
CASE WHEN T.ID IS NULL THEN A.IdZeme ELSE T.IdZeme END as IdZeme,
CASE WHEN T.ID IS NULL THEN (SELECT Z1.Nazev FROM TabZeme Z1 WHERE Z1.ISOKod=A.IdZeme) ELSE (SELECT Z.Nazev FROM TabZeme Z WHERE Z.ISOKod=T.IdZeme) END as NazevZeme,
NULL as UdajOZapisuDoObchRej,
ISNULL(T.NazevCastiObce, A.NazevCastiObce) as NazevCastiObce,
ISNULL(T.NazevOkresu, A.NazevOkresu) as NazevOkresu,
ISNULL(T.MestskaCast, A.MestskaCast) as MestskaCast,
ISNULL(T.DatZmeny, T.DatPorizeni) AS DatZmeny, D.ID AS ID, N'DZbPr' AS Tabulka
FROM TabDokladyZbozi D
LEFT OUTER JOIN TabCisOrg A ON D.Prijemce = A.CisloOrg
LEFT OUTER JOIN TabCisOrgArch T ON D.Prijemce = T.CisloOrg AND T.ID =
(SELECT TOP 1 V.ID FROM TabCisOrgArch V
WHERE D.Prijemce = V.CisloOrg AND ISNULL(D.DUZP,D.DatPorizeni) <= CONVERT(DATETIME,CONVERT(INT,CONVERT(FLOAT,V.DatZmeny))-0.0000000193) AND V.NeplatneUdaje=0 AND (V.Overeni IS NULL OR V.Overeni=0) ORDER BY V.DatZmeny, V.ID) AND (SELECT PouzivatOrgBankSpojArch FROM TabHGlob)=1
UNION ALL
SELECT ISNULL(T.CisloOrg, A.CisloOrg) as CisloOrg,
ISNULL(T.Nazev, A.Nazev) as Nazev,
ISNULL(T.DruhyNazev, A.DruhyNazev) as DruhyNazev,
CASE WHEN T.ID IS NULL THEN A.PSC ELSE T.PSC END as PSC,
ISNULL(T.Misto, A.Misto) as Misto,
ISNULL(T.Ulice, A.Ulice) as Ulice,
ISNULL(T.OrCislo, A.OrCislo) as OrCislo,
ISNULL(T.PopCislo, A.PopCislo) as PopCislo,
ISNULL(T.UliceSCisly, A.UliceSCisly) as UliceSCisly,
CASE WHEN T.ID IS NULL THEN A.DIC ELSE T.DIC END as DIC,
CASE WHEN T.ID IS NULL THEN A.DICSk ELSE T.DICSk END as DICSk,
CASE WHEN T.ID IS NULL THEN A.ICO ELSE T.ICO END as ICO,
CASE WHEN T.ID IS NULL THEN A.IdZeme ELSE T.IdZeme END as IdZeme,
CASE WHEN T.ID IS NULL THEN (SELECT Z1.Nazev FROM TabZeme Z1 WHERE Z1.ISOKod=A.IdZeme) ELSE (SELECT Z.Nazev FROM TabZeme Z WHERE Z.ISOKod=T.IdZeme) END as NazevZeme,
NULL as UdajOZapisuDoObchRej,
ISNULL(T.NazevCastiObce, A.NazevCastiObce) as NazevCastiObce,
ISNULL(T.NazevOkresu, A.NazevOkresu) as NazevOkresu,
ISNULL(T.MestskaCast, A.MestskaCast) as MestskaCast,
ISNULL(T.DatZmeny, T.DatPorizeni) AS DatZmeny, D.ID AS ID, N'DZbMU' AS Tabulka
FROM TabDokladyZbozi D
LEFT OUTER JOIN TabCisOrg A ON D.MistoUrceni = A.CisloOrg
LEFT OUTER JOIN TabCisOrgArch T ON D.MistoUrceni = T.CisloOrg AND T.ID =
(SELECT TOP 1 V.ID FROM TabCisOrgArch V
WHERE D.MistoUrceni = V.CisloOrg AND ISNULL(D.DUZP,D.DatPorizeni) <= CONVERT(DATETIME,CONVERT(INT,CONVERT(FLOAT,V.DatZmeny))-0.0000000193) AND V.NeplatneUdaje=0 AND (V.Overeni IS NULL OR V.Overeni=0) ORDER BY V.DatZmeny, V.ID) AND (SELECT PouzivatOrgBankSpojArch FROM TabHGlob)=1
UNION ALL
SELECT ISNULL(T.CisloOrg, A.CisloOrg) as CisloOrg,
ISNULL(T.Nazev, A.Nazev) as Nazev,
ISNULL(T.DruhyNazev, A.DruhyNazev) as DruhyNazev,
CASE WHEN T.ID IS NULL THEN A.PSC ELSE T.PSC END as PSC,
ISNULL(T.Misto, A.Misto) as Misto,
ISNULL(T.Ulice, A.Ulice) as Ulice,
ISNULL(T.OrCislo, A.OrCislo) as OrCislo,
ISNULL(T.PopCislo, A.PopCislo) as PopCislo,
ISNULL(T.UliceSCisly, A.UliceSCisly) as UliceSCisly,
CASE WHEN T.ID IS NULL THEN A.DIC ELSE T.DIC END as DIC,
CASE WHEN T.ID IS NULL THEN A.DICSk ELSE T.DICSk END as DICSk,
CASE WHEN T.ID IS NULL THEN A.ICO ELSE T.ICO END as ICO,
CASE WHEN T.ID IS NULL THEN A.IdZeme ELSE T.IdZeme END as IdZeme,
CASE WHEN T.ID IS NULL THEN (SELECT Z1.Nazev FROM TabZeme Z1 WHERE Z1.ISOKod=A.IdZeme) ELSE (SELECT Z.Nazev FROM TabZeme Z WHERE Z.ISOKod=T.IdZeme) END as NazevZeme,
NULL as UdajOZapisuDoObchRej,
ISNULL(T.NazevCastiObce, A.NazevCastiObce) as NazevCastiObce,
ISNULL(T.NazevOkresu, A.NazevOkresu) as NazevOkresu,
ISNULL(T.MestskaCast, A.MestskaCast) as MestskaCast,
ISNULL(T.DatZmeny, T.DatPorizeni) AS DatZmeny, D.ID AS ID, N'Upom' AS Tabulka
FROM TabUpom D
LEFT OUTER JOIN TabCisOrg A ON D.Organizace = A.CisloOrg
LEFT OUTER JOIN TabCisOrgArch T ON D.Organizace = T.CisloOrg AND T.ID =
(SELECT TOP 1 V.ID FROM TabCisOrgArch V
WHERE D.Organizace = V.CisloOrg AND D.DatPorizeni <= CONVERT(DATETIME,CONVERT(INT,CONVERT(FLOAT,V.DatZmeny))-0.0000000193) AND V.NeplatneUdaje=0 AND (V.Overeni IS NULL OR V.Overeni=0) ORDER BY V.DatZmeny, V.ID) AND (SELECT PouzivatOrgBankSpojArch FROM TabHGlob)=1
UNION ALL
SELECT ISNULL(T.CisloOrg, A.CisloOrg) as CisloOrg,
ISNULL(T.Nazev, A.Nazev) as Nazev,
ISNULL(T.DruhyNazev, A.DruhyNazev) as DruhyNazev,
CASE WHEN T.ID IS NULL THEN A.PSC ELSE T.PSC END as PSC,
ISNULL(T.Misto, A.Misto) as Misto,
ISNULL(T.Ulice, A.Ulice) as Ulice,
ISNULL(T.OrCislo, A.OrCislo) as OrCislo,
ISNULL(T.PopCislo, A.PopCislo) as PopCislo,
ISNULL(T.UliceSCisly, A.UliceSCisly) as UliceSCisly,
CASE WHEN T.ID IS NULL THEN A.DIC ELSE T.DIC END as DIC,
CASE WHEN T.ID IS NULL THEN A.DICSk ELSE T.DICSk END as DICSk,
CASE WHEN T.ID IS NULL THEN A.ICO ELSE T.ICO END as ICO,
CASE WHEN T.ID IS NULL THEN A.IdZeme ELSE T.IdZeme END as IdZeme,
CASE WHEN T.ID IS NULL THEN (SELECT Z1.Nazev FROM TabZeme Z1 WHERE Z1.ISOKod=A.IdZeme) ELSE (SELECT Z.Nazev FROM TabZeme Z WHERE Z.ISOKod=T.IdZeme) END as NazevZeme,
NULL as UdajOZapisuDoObchRej,
ISNULL(T.NazevCastiObce, A.NazevCastiObce) as NazevCastiObce,
ISNULL(T.NazevOkresu, A.NazevOkresu) as NazevOkresu,
ISNULL(T.MestskaCast, A.MestskaCast) as MestskaCast,
ISNULL(T.DatZmeny, T.DatPorizeni) AS DatZmeny, D.ID AS ID, N'UpomH' AS Tabulka
FROM TabUpomHlavicka D
LEFT OUTER JOIN TabCisOrg A ON D.Organizace = A.CisloOrg
LEFT OUTER JOIN TabCisOrgArch T ON D.Organizace = T.CisloOrg AND T.ID =
(SELECT TOP 1 V.ID FROM TabCisOrgArch V
WHERE D.Organizace = V.CisloOrg AND D.DatPorizeni <= CONVERT(DATETIME,CONVERT(INT,CONVERT(FLOAT,V.DatZmeny))-0.0000000193) AND V.NeplatneUdaje=0 AND (V.Overeni IS NULL OR V.Overeni=0) ORDER BY V.DatZmeny, V.ID) AND (SELECT PouzivatOrgBankSpojArch FROM TabHGlob)=1
UNION ALL
SELECT ISNULL(T.CisloOrg, A.CisloOrg) as CisloOrg,
ISNULL(T.Nazev, A.Nazev) as Nazev,
ISNULL(T.DruhyNazev, A.DruhyNazev) as DruhyNazev,
CASE WHEN T.ID IS NULL THEN A.PSC ELSE T.PSC END as PSC,
ISNULL(T.Misto, A.Misto) as Misto,
ISNULL(T.Ulice, A.Ulice) as Ulice,
ISNULL(T.OrCislo, A.OrCislo) as OrCislo,
ISNULL(T.PopCislo, A.PopCislo) as PopCislo,
ISNULL(T.UliceSCisly, A.UliceSCisly) as UliceSCisly,
CASE WHEN T.ID IS NULL THEN A.DIC ELSE T.DIC END as DIC,
CASE WHEN T.ID IS NULL THEN A.DICSk ELSE T.DICSk END as DICSk,
CASE WHEN T.ID IS NULL THEN A.ICO ELSE T.ICO END as ICO,
CASE WHEN T.ID IS NULL THEN A.IdZeme ELSE T.IdZeme END as IdZeme,
CASE WHEN T.ID IS NULL THEN (SELECT Z1.Nazev FROM TabZeme Z1 WHERE Z1.ISOKod=A.IdZeme) ELSE (SELECT Z.Nazev FROM TabZeme Z WHERE Z.ISOKod=T.IdZeme) END as NazevZeme,
NULL as UdajOZapisuDoObchRej,
ISNULL(T.NazevCastiObce, A.NazevCastiObce) as NazevCastiObce,
ISNULL(T.NazevOkresu, A.NazevOkresu) as NazevOkresu,
ISNULL(T.MestskaCast, A.MestskaCast) as MestskaCast,
ISNULL(T.DatZmeny, T.DatPorizeni) AS DatZmeny, D.ID AS ID, N'PenFak' AS Tabulka
FROM TabPenFak D
LEFT OUTER JOIN TabCisOrg A ON D.Organizace = A.CisloOrg
LEFT OUTER JOIN TabCisOrgArch T ON D.Organizace = T.CisloOrg AND T.ID =
(SELECT TOP 1 V.ID FROM TabCisOrgArch V
WHERE D.Organizace = V.CisloOrg AND D.DatPorizeni <= CONVERT(DATETIME,CONVERT(INT,CONVERT(FLOAT,V.DatZmeny))-0.0000000193) AND V.NeplatneUdaje=0 AND (V.Overeni IS NULL OR V.Overeni=0) ORDER BY V.DatZmeny, V.ID) AND (SELECT PouzivatOrgBankSpojArch FROM TabHGlob)=1
UNION ALL
SELECT ISNULL(T.CisloOrg, A.CisloOrg) as CisloOrg,
ISNULL(T.Nazev, A.Nazev) as Nazev,
ISNULL(T.DruhyNazev, A.DruhyNazev) as DruhyNazev,
CASE WHEN T.ID IS NULL THEN A.PSC ELSE T.PSC END as PSC,
ISNULL(T.Misto, A.Misto) as Misto,
ISNULL(T.Ulice, A.Ulice) as Ulice,
ISNULL(T.OrCislo, A.OrCislo) as OrCislo,
ISNULL(T.PopCislo, A.PopCislo) as PopCislo,
ISNULL(T.UliceSCisly, A.UliceSCisly) as UliceSCisly,
CASE WHEN T.ID IS NULL THEN A.DIC ELSE T.DIC END as DIC,
CASE WHEN T.ID IS NULL THEN A.DICSk ELSE T.DICSk END as DICSk,
CASE WHEN T.ID IS NULL THEN A.ICO ELSE T.ICO END as ICO,
CASE WHEN T.ID IS NULL THEN A.IdZeme ELSE T.IdZeme END as IdZeme,
CASE WHEN T.ID IS NULL THEN (SELECT Z1.Nazev FROM TabZeme Z1 WHERE Z1.ISOKod=A.IdZeme) ELSE (SELECT Z.Nazev FROM TabZeme Z WHERE Z.ISOKod=T.IdZeme) END as NazevZeme,
NULL as UdajOZapisuDoObchRej,
ISNULL(T.NazevCastiObce, A.NazevCastiObce) as NazevCastiObce,
ISNULL(T.NazevOkresu, A.NazevOkresu) as NazevOkresu,
ISNULL(T.MestskaCast, A.MestskaCast) as MestskaCast,
ISNULL(T.DatZmeny, T.DatPorizeni) AS DatZmeny, D.ID AS ID, N'BVR' AS Tabulka
FROM TabBankVypisR D
LEFT OUTER JOIN TabCisOrg A ON D.CisloOrg = A.CisloOrg
LEFT OUTER JOIN TabCisOrgArch T ON D.CisloOrg = T.CisloOrg AND T.ID =
(SELECT TOP 1 V.ID FROM TabCisOrgArch V
WHERE D.CisloOrg = V.CisloOrg AND D.DatumSplatnosti <= CONVERT(DATETIME,CONVERT(INT,CONVERT(FLOAT,V.DatZmeny))-0.0000000193) AND V.NeplatneUdaje=0 AND (V.Overeni IS NULL OR V.Overeni=0) ORDER BY V.DatZmeny, V.ID) AND (SELECT PouzivatOrgBankSpojArch FROM TabHGlob)=1
UNION ALL
SELECT ISNULL(T.CisloOrg, A.CisloOrg) as CisloOrg,
ISNULL(T.Nazev, A.Nazev) as Nazev,
ISNULL(T.DruhyNazev, A.DruhyNazev) as DruhyNazev,
CASE WHEN T.ID IS NULL THEN A.PSC ELSE T.PSC END as PSC,
ISNULL(T.Misto, A.Misto) as Misto,
ISNULL(T.Ulice, A.Ulice) as Ulice,
ISNULL(T.OrCislo, A.OrCislo) as OrCislo,
ISNULL(T.PopCislo, A.PopCislo) as PopCislo,
ISNULL(T.UliceSCisly, A.UliceSCisly) as UliceSCisly,
CASE WHEN T.ID IS NULL THEN A.DIC ELSE T.DIC END as DIC,
CASE WHEN T.ID IS NULL THEN A.DICSk ELSE T.DICSk END as DICSk,
CASE WHEN T.ID IS NULL THEN A.ICO ELSE T.ICO END as ICO,
CASE WHEN T.ID IS NULL THEN A.IdZeme ELSE T.IdZeme END as IdZeme,
CASE WHEN T.ID IS NULL THEN (SELECT Z1.Nazev FROM TabZeme Z1 WHERE Z1.ISOKod=A.IdZeme) ELSE (SELECT Z.Nazev FROM TabZeme Z WHERE Z.ISOKod=T.IdZeme) END as NazevZeme,
NULL as UdajOZapisuDoObchRej,
ISNULL(T.NazevCastiObce, A.NazevCastiObce) as NazevCastiObce,
ISNULL(T.NazevOkresu, A.NazevOkresu) as NazevOkresu,
ISNULL(T.MestskaCast, A.MestskaCast) as MestskaCast,
ISNULL(T.DatZmeny, T.DatPorizeni) AS DatZmeny, D.ID AS ID, N'CRM' AS Tabulka
FROM TabKontaktJednani D
LEFT OUTER JOIN TabCisOrg A ON D.CisloOrg = A.CisloOrg
LEFT OUTER JOIN TabCisOrgArch T ON D.CisloOrg = T.CisloOrg AND T.ID =
(SELECT TOP 1 V.ID FROM TabCisOrgArch V
WHERE D.CisloOrg = V.CisloOrg AND D.DatPorizeni <= CONVERT(DATETIME,CONVERT(INT,CONVERT(FLOAT,V.DatZmeny))-0.0000000193) AND V.NeplatneUdaje=0 AND (V.Overeni IS NULL OR V.Overeni=0) ORDER BY V.DatZmeny, V.ID) AND (SELECT PouzivatOrgBankSpojArch FROM TabHGlob)=1
UNION ALL
SELECT ISNULL(T.CisloOrg, A.CisloOrg) AS CisloOrg,
ISNULL(T.Nazev, A.Nazev) as Nazev,
ISNULL(T.DruhyNazev, A.DruhyNazev) as DruhyNazev,
CASE WHEN T.ID IS NULL THEN A.PSC ELSE T.PSC END as PSC,
ISNULL(T.Misto, A.Misto) as Misto,
ISNULL(T.Ulice, A.Ulice) as Ulice,
ISNULL(T.OrCislo, A.OrCislo) as OrCislo,
ISNULL(T.PopCislo, A.PopCislo) as PopCislo,
ISNULL(T.UliceSCisly, A.UliceSCisly) as UliceSCisly,
CASE WHEN T.ID IS NULL THEN A.DIC ELSE T.DIC END as DIC,
CASE WHEN T.ID IS NULL THEN A.DICSk ELSE T.DICSk END as DICSk,
CASE WHEN T.ID IS NULL THEN A.ICO ELSE T.ICO END as ICO,
CASE WHEN T.ID IS NULL THEN A.IdZeme ELSE T.IdZeme END as IdZeme,
CASE WHEN T.ID IS NULL THEN (SELECT Z1.Nazev FROM TabZeme Z1 WHERE Z1.ISOKod=A.IdZeme) ELSE (SELECT Z.Nazev FROM TabZeme Z WHERE Z.ISOKod=T.IdZeme) END as NazevZeme,
ISNULL(T.UdajOZapisuDoObchRej, A.UdajOZapisuDoObchRej) as UdajOZapisuDoObchRej,
ISNULL(T.NazevCastiObce, A.NazevCastiObce) as NazevCastiObce,
ISNULL(T.NazevOkresu, A.NazevOkresu) as NazevOkresu,
ISNULL(T.MestskaCast, A.MestskaCast) as MestskaCast,
ISNULL(T.DatZmeny, T.DatPorizeni) AS DatZmeny, D.ID AS ID, N'CRM0' AS Tabulka
FROM TabKontaktJednani D
LEFT OUTER JOIN TabCisOrg A ON A.CisloOrg = 0
LEFT OUTER JOIN TabCisOrgArch T ON 0 = T.CisloOrg AND T.ID =
(SELECT TOP 1 V.ID FROM TabCisOrgArch V
WHERE 0=V.CisloOrg AND D.DatPorizeni <= CONVERT(DATETIME,CONVERT(INT,CONVERT(FLOAT,V.DatZmeny))-0.0000000193) AND V.NeplatneUdaje=0 AND (V.Overeni IS NULL OR V.Overeni=0) ORDER BY V.DatZmeny, V.ID) AND (SELECT PouzivatOrgBankSpojArch FROM TabHGlob)=1
UNION ALL
SELECT ISNULL(T.CisloOrg, A.CisloOrg) as CisloOrg,
ISNULL(T.Nazev, A.Nazev) as Nazev,
ISNULL(T.DruhyNazev, A.DruhyNazev) as DruhyNazev,
CASE WHEN T.ID IS NULL THEN A.PSC ELSE T.PSC END as PSC,
ISNULL(T.Misto, A.Misto) as Misto,
ISNULL(T.Ulice, A.Ulice) as Ulice,
ISNULL(T.OrCislo, A.OrCislo) as OrCislo,
ISNULL(T.PopCislo, A.PopCislo) as PopCislo,
ISNULL(T.UliceSCisly, A.UliceSCisly) as UliceSCisly,
CASE WHEN T.ID IS NULL THEN A.DIC ELSE T.DIC END as DIC,
CASE WHEN T.ID IS NULL THEN A.DICSk ELSE T.DICSk END as DICSk,
CASE WHEN T.ID IS NULL THEN A.ICO ELSE T.ICO END as ICO,
CASE WHEN T.ID IS NULL THEN A.IdZeme ELSE T.IdZeme END as IdZeme,
CASE WHEN T.ID IS NULL THEN (SELECT Z1.Nazev FROM TabZeme Z1 WHERE Z1.ISOKod=A.IdZeme) ELSE (SELECT Z.Nazev FROM TabZeme Z WHERE Z.ISOKod=T.IdZeme) END as NazevZeme,
NULL as UdajOZapisuDoObchRej,
ISNULL(T.NazevCastiObce, A.NazevCastiObce) as NazevCastiObce,
ISNULL(T.NazevOkresu, A.NazevOkresu) as NazevOkresu,
ISNULL(T.MestskaCast, A.MestskaCast) as MestskaCast,
ISNULL(T.DatZmeny, T.DatPorizeni) AS DatZmeny, D.ID AS ID, N'CRMMU' AS Tabulka
FROM TabKontaktJednani D
LEFT OUTER JOIN TabCisOrg A ON D.MistoUrceni = A.CisloOrg
LEFT OUTER JOIN TabCisOrgArch T ON D.MistoUrceni = T.CisloOrg AND T.ID =
(SELECT TOP 1 V.ID FROM TabCisOrgArch V
WHERE D.MistoUrceni = V.CisloOrg AND D.DatPorizeni <= CONVERT(DATETIME,CONVERT(INT,CONVERT(FLOAT,V.DatZmeny))-0.0000000193) AND V.NeplatneUdaje=0 AND (V.Overeni IS NULL OR V.Overeni=0) ORDER BY V.DatZmeny, V.ID) AND (SELECT PouzivatOrgBankSpojArch FROM TabHGlob)=1
UNION ALL
SELECT ISNULL(T.CisloOrg, A.CisloOrg) as CisloOrg,
ISNULL(T.Nazev, A.Nazev) as Nazev,
ISNULL(T.DruhyNazev, A.DruhyNazev) as DruhyNazev,
CASE WHEN T.ID IS NULL THEN A.PSC ELSE T.PSC END as PSC,
ISNULL(T.Misto, A.Misto) as Misto,
ISNULL(T.Ulice, A.Ulice) as Ulice,
ISNULL(T.OrCislo, A.OrCislo) as OrCislo,
ISNULL(T.PopCislo, A.PopCislo) as PopCislo,
ISNULL(T.UliceSCisly, A.UliceSCisly) as UliceSCisly,
CASE WHEN T.ID IS NULL THEN A.DIC ELSE T.DIC END as DIC,
CASE WHEN T.ID IS NULL THEN A.DICSk ELSE T.DICSk END as DICSk,
CASE WHEN T.ID IS NULL THEN A.ICO ELSE T.ICO END as ICO,
CASE WHEN T.ID IS NULL THEN A.IdZeme ELSE T.IdZeme END as IdZeme,
CASE WHEN T.ID IS NULL THEN (SELECT Z1.Nazev FROM TabZeme Z1 WHERE Z1.ISOKod=A.IdZeme) ELSE (SELECT Z.Nazev FROM TabZeme Z WHERE Z.ISOKod=T.IdZeme) END as NazevZeme,
NULL as UdajOZapisuDoObchRej,
ISNULL(T.NazevCastiObce, A.NazevCastiObce) as NazevCastiObce,
ISNULL(T.NazevOkresu, A.NazevOkresu) as NazevOkresu,
ISNULL(T.MestskaCast, A.MestskaCast) as MestskaCast,
ISNULL(T.DatZmeny, T.DatPorizeni) AS DatZmeny, D.ID AS ID, N'CRMPr' AS Tabulka
FROM TabKontaktJednani D
LEFT OUTER JOIN TabCisOrg A ON D.Prijemce = A.CisloOrg
LEFT OUTER JOIN TabCisOrgArch T ON D.Prijemce = T.CisloOrg AND T.ID =
(SELECT TOP 1 V.ID FROM TabCisOrgArch V
WHERE D.Prijemce = V.CisloOrg AND D.DatPorizeni <= CONVERT(DATETIME,CONVERT(INT,CONVERT(FLOAT,V.DatZmeny))-0.0000000193) AND V.NeplatneUdaje=0 AND (V.Overeni IS NULL OR V.Overeni=0) ORDER BY V.DatZmeny, V.ID) AND (SELECT PouzivatOrgBankSpojArch FROM TabHGlob)=1
UNION ALL
SELECT ISNULL(T.CisloOrg, A.CisloOrg) as CisloOrg,
ISNULL(T.Nazev, A.Nazev) as Nazev,
ISNULL(T.DruhyNazev, A.DruhyNazev) as DruhyNazev,
CASE WHEN T.ID IS NULL THEN A.PSC ELSE T.PSC END as PSC,
ISNULL(T.Misto, A.Misto) as Misto,
ISNULL(T.Ulice, A.Ulice) as Ulice,
ISNULL(T.OrCislo, A.OrCislo) as OrCislo,
ISNULL(T.PopCislo, A.PopCislo) as PopCislo,
ISNULL(T.UliceSCisly, A.UliceSCisly) as UliceSCisly,
CASE WHEN T.ID IS NULL THEN A.DIC ELSE T.DIC END as DIC,
CASE WHEN T.ID IS NULL THEN A.DICSk ELSE T.DICSk END as DICSk,
CASE WHEN T.ID IS NULL THEN A.ICO ELSE T.ICO END as ICO,
CASE WHEN T.ID IS NULL THEN A.IdZeme ELSE T.IdZeme END as IdZeme,
CASE WHEN T.ID IS NULL THEN (SELECT Z1.Nazev FROM TabZeme Z1 WHERE Z1.ISOKod=A.IdZeme) ELSE (SELECT Z.Nazev FROM TabZeme Z WHERE Z.ISOKod=T.IdZeme) END as NazevZeme,
NULL as UdajOZapisuDoObchRej,
ISNULL(T.NazevCastiObce, A.NazevCastiObce) as NazevCastiObce,
ISNULL(T.NazevOkresu, A.NazevOkresu) as NazevOkresu,
ISNULL(T.MestskaCast, A.MestskaCast) as MestskaCast,
ISNULL(T.DatZmeny, T.DatPorizeni) AS DatZmeny, D.ID AS ID, N'PFakH' AS Tabulka
FROM TabPenFakHlavicka D
LEFT OUTER JOIN TabCisOrg A ON D.Organizace = A.CisloOrg
LEFT OUTER JOIN TabCisOrgArch T ON D.Organizace = T.CisloOrg AND T.ID =
(SELECT TOP 1 V.ID FROM TabCisOrgArch V
WHERE D.Organizace = V.CisloOrg AND D.DatPorizeni <= CONVERT(DATETIME,CONVERT(INT,CONVERT(FLOAT,V.DatZmeny))-0.0000000193) AND V.NeplatneUdaje=0 AND (V.Overeni IS NULL OR V.Overeni=0) ORDER BY V.DatZmeny, V.ID) AND (SELECT PouzivatOrgBankSpojArch FROM TabHGlob)=1
UNION ALL
SELECT ISNULL(T.CisloOrg, A.CisloOrg) as CisloOrg,
ISNULL(T.Nazev, A.Nazev) as Nazev,
ISNULL(T.DruhyNazev, A.DruhyNazev) as DruhyNazev,
CASE WHEN T.ID IS NULL THEN A.PSC ELSE T.PSC END as PSC,
ISNULL(T.Misto, A.Misto) as Misto,
ISNULL(T.Ulice, A.Ulice) as Ulice,
ISNULL(T.OrCislo, A.OrCislo) as OrCislo,
ISNULL(T.PopCislo, A.PopCislo) as PopCislo,
ISNULL(T.UliceSCisly, A.UliceSCisly) as UliceSCisly,
CASE WHEN T.ID IS NULL THEN A.DIC ELSE T.DIC END as DIC,
CASE WHEN T.ID IS NULL THEN A.DICSk ELSE T.DICSk END as DICSk,
CASE WHEN T.ID IS NULL THEN A.ICO ELSE T.ICO END as ICO,
CASE WHEN T.ID IS NULL THEN A.IdZeme ELSE T.IdZeme END as IdZeme,
CASE WHEN T.ID IS NULL THEN (SELECT Z1.Nazev FROM TabZeme Z1 WHERE Z1.ISOKod=A.IdZeme) ELSE (SELECT Z.Nazev FROM TabZeme Z WHERE Z.ISOKod=T.IdZeme) END as NazevZeme,
NULL as UdajOZapisuDoObchRej,
ISNULL(T.NazevCastiObce, A.NazevCastiObce) as NazevCastiObce,
ISNULL(T.NazevOkresu, A.NazevOkresu) as NazevOkresu,
ISNULL(T.MestskaCast, A.MestskaCast) as MestskaCast,
ISNULL(T.DatZmeny, T.DatPorizeni) AS DatZmeny, D.ID AS ID, N'Obj02' AS Tabulka
FROM TabDosleObjH02 D
LEFT OUTER JOIN TabCisOrg A ON D.CisloOrg = A.CisloOrg
LEFT OUTER JOIN TabCisOrgArch T ON D.CisloOrg = T.CisloOrg AND T.ID =
(SELECT TOP 1 V.ID FROM TabCisOrgArch V
WHERE D.CisloOrg = V.CisloOrg AND ISNULL(D.DatumPripadu, D.DatPorizeni) <= CONVERT(DATETIME,CONVERT(INT,CONVERT(FLOAT,V.DatZmeny))-0.0000000193) AND V.NeplatneUdaje=0 AND (V.Overeni IS NULL OR V.Overeni=0) ORDER BY V.DatZmeny, V.ID) AND (SELECT PouzivatOrgBankSpojArch FROM TabHGlob)=1
UNION ALL
SELECT ISNULL(T.CisloOrg, A.CisloOrg) as CisloOrg,
ISNULL(T.Nazev, A.Nazev) as Nazev,
ISNULL(T.DruhyNazev, A.DruhyNazev) as DruhyNazev,
CASE WHEN T.ID IS NULL THEN A.PSC ELSE T.PSC END as PSC,
ISNULL(T.Misto, A.Misto) as Misto,
ISNULL(T.Ulice, A.Ulice) as Ulice,
ISNULL(T.OrCislo, A.OrCislo) as OrCislo,
ISNULL(T.PopCislo, A.PopCislo) as PopCislo,
ISNULL(T.UliceSCisly, A.UliceSCisly) as UliceSCisly,
CASE WHEN T.ID IS NULL THEN A.DIC ELSE T.DIC END as DIC,
CASE WHEN T.ID IS NULL THEN A.DICSk ELSE T.DICSk END as DICSk,
CASE WHEN T.ID IS NULL THEN A.ICO ELSE T.ICO END as ICO,
CASE WHEN T.ID IS NULL THEN A.IdZeme ELSE T.IdZeme END as IdZeme,
CASE WHEN T.ID IS NULL THEN (SELECT Z1.Nazev FROM TabZeme Z1 WHERE Z1.ISOKod=A.IdZeme) ELSE (SELECT Z.Nazev FROM TabZeme Z WHERE Z.ISOKod=T.IdZeme) END as NazevZeme,
NULL as UdajOZapisuDoObchRej,
ISNULL(T.NazevCastiObce, A.NazevCastiObce) as NazevCastiObce,
ISNULL(T.NazevOkresu, A.NazevOkresu) as NazevOkresu,
ISNULL(T.MestskaCast, A.MestskaCast) as MestskaCast,
ISNULL(T.DatZmeny, T.DatPorizeni) AS DatZmeny, D.ID AS ID, N'Obj03' AS Tabulka
FROM TabDosleObjH03 D
LEFT OUTER JOIN TabCisOrg A ON D.CisloOrg = A.CisloOrg
LEFT OUTER JOIN TabCisOrgArch T ON D.CisloOrg = T.CisloOrg AND T.ID =
(SELECT TOP 1 V.ID FROM TabCisOrgArch V
WHERE D.CisloOrg = V.CisloOrg AND ISNULL(D.DatumPripadu, D.DatPorizeni) <= CONVERT(DATETIME,CONVERT(INT,CONVERT(FLOAT,V.DatZmeny))-0.0000000193) AND V.NeplatneUdaje=0 AND (V.Overeni IS NULL OR V.Overeni=0) ORDER BY V.DatZmeny, V.ID) AND (SELECT PouzivatOrgBankSpojArch FROM TabHGlob)=1
UNION ALL
SELECT ISNULL(T.CisloOrg, A.CisloOrg) as CisloOrg,
ISNULL(T.Nazev, A.Nazev) as Nazev,
ISNULL(T.DruhyNazev, A.DruhyNazev) as DruhyNazev,
CASE WHEN T.ID IS NULL THEN A.PSC ELSE T.PSC END as PSC,
ISNULL(T.Misto, A.Misto) as Misto,
ISNULL(T.Ulice, A.Ulice) as Ulice,
ISNULL(T.OrCislo, A.OrCislo) as OrCislo,
ISNULL(T.PopCislo, A.PopCislo) as PopCislo,
ISNULL(T.UliceSCisly, A.UliceSCisly) as UliceSCisly,
CASE WHEN T.ID IS NULL THEN A.DIC ELSE T.DIC END as DIC,
CASE WHEN T.ID IS NULL THEN A.DICSk ELSE T.DICSk END as DICSk,
CASE WHEN T.ID IS NULL THEN A.ICO ELSE T.ICO END as ICO,
CASE WHEN T.ID IS NULL THEN A.IdZeme ELSE T.IdZeme END as IdZeme,
CASE WHEN T.ID IS NULL THEN (SELECT Z1.Nazev FROM TabZeme Z1 WHERE Z1.ISOKod=A.IdZeme) ELSE (SELECT Z.Nazev FROM TabZeme Z WHERE Z.ISOKod=T.IdZeme) END as NazevZeme,
NULL as UdajOZapisuDoObchRej,
ISNULL(T.NazevCastiObce, A.NazevCastiObce) as NazevCastiObce,
ISNULL(T.NazevOkresu, A.NazevOkresu) as NazevOkresu,
ISNULL(T.MestskaCast, A.MestskaCast) as MestskaCast,
ISNULL(T.DatZmeny, T.DatPorizeni) AS DatZmeny, D.ID AS ID, N'Obj02P' AS Tabulka
FROM TabDosleObjH02 D
LEFT OUTER JOIN TabCisOrg A ON D.Prijemce = A.CisloOrg
LEFT OUTER JOIN TabCisOrgArch T ON D.Prijemce = T.CisloOrg AND T.ID =
(SELECT TOP 1 V.ID FROM TabCisOrgArch V
WHERE D.Prijemce = V.CisloOrg AND ISNULL(D.DatumPripadu, D.DatPorizeni) <= CONVERT(DATETIME,CONVERT(INT,CONVERT(FLOAT,V.DatZmeny))-0.0000000193) AND V.NeplatneUdaje=0 AND (V.Overeni IS NULL OR V.Overeni=0) ORDER BY V.DatZmeny, V.ID) AND (SELECT PouzivatOrgBankSpojArch FROM TabHGlob)=1
UNION ALL
SELECT ISNULL(T.CisloOrg, A.CisloOrg) as CisloOrg,
ISNULL(T.Nazev, A.Nazev) as Nazev,
ISNULL(T.DruhyNazev, A.DruhyNazev) as DruhyNazev,
CASE WHEN T.ID IS NULL THEN A.PSC ELSE T.PSC END as PSC,
ISNULL(T.Misto, A.Misto) as Misto,
ISNULL(T.Ulice, A.Ulice) as Ulice,
ISNULL(T.OrCislo, A.OrCislo) as OrCislo,
ISNULL(T.PopCislo, A.PopCislo) as PopCislo,
ISNULL(T.UliceSCisly, A.UliceSCisly) as UliceSCisly,
CASE WHEN T.ID IS NULL THEN A.DIC ELSE T.DIC END as DIC,
CASE WHEN T.ID IS NULL THEN A.DICSk ELSE T.DICSk END as DICSk,
CASE WHEN T.ID IS NULL THEN A.ICO ELSE T.ICO END as ICO,
CASE WHEN T.ID IS NULL THEN A.IdZeme ELSE T.IdZeme END as IdZeme,
CASE WHEN T.ID IS NULL THEN (SELECT Z1.Nazev FROM TabZeme Z1 WHERE Z1.ISOKod=A.IdZeme) ELSE (SELECT Z.Nazev FROM TabZeme Z WHERE Z.ISOKod=T.IdZeme) END as NazevZeme,
NULL as UdajOZapisuDoObchRej,
ISNULL(T.NazevCastiObce, A.NazevCastiObce) as NazevCastiObce,
ISNULL(T.NazevOkresu, A.NazevOkresu) as NazevOkresu,
ISNULL(T.MestskaCast, A.MestskaCast) as MestskaCast,
ISNULL(T.DatZmeny, T.DatPorizeni) AS DatZmeny, D.ID AS ID, N'Obj03P' AS Tabulka
FROM TabDosleObjH03 D
LEFT OUTER JOIN TabCisOrg A ON D.Prijemce = A.CisloOrg
LEFT OUTER JOIN TabCisOrgArch T ON D.Prijemce = T.CisloOrg AND T.ID =
(SELECT TOP 1 V.ID FROM TabCisOrgArch V
WHERE D.Prijemce = V.CisloOrg AND ISNULL(D.DatumPripadu, D.DatPorizeni) <= CONVERT(DATETIME,CONVERT(INT,CONVERT(FLOAT,V.DatZmeny))-0.0000000193) AND V.NeplatneUdaje=0 AND (V.Overeni IS NULL OR V.Overeni=0) ORDER BY V.DatZmeny, V.ID) AND (SELECT PouzivatOrgBankSpojArch FROM TabHGlob)=1
UNION ALL
SELECT ISNULL(T.CisloOrg, A.CisloOrg) as CisloOrg,
ISNULL(T.Nazev, A.Nazev) as Nazev,
ISNULL(T.DruhyNazev, A.DruhyNazev) as DruhyNazev,
CASE WHEN T.ID IS NULL THEN A.PSC ELSE T.PSC END as PSC,
ISNULL(T.Misto, A.Misto) as Misto,
ISNULL(T.Ulice, A.Ulice) as Ulice,
ISNULL(T.OrCislo, A.OrCislo) as OrCislo,
ISNULL(T.PopCislo, A.PopCislo) as PopCislo,
ISNULL(T.UliceSCisly, A.UliceSCisly) as UliceSCisly,
CASE WHEN T.ID IS NULL THEN A.DIC ELSE T.DIC END as DIC,
CASE WHEN T.ID IS NULL THEN A.DICSk ELSE T.DICSk END as DICSk,
CASE WHEN T.ID IS NULL THEN A.ICO ELSE T.ICO END as ICO,
CASE WHEN T.ID IS NULL THEN A.IdZeme ELSE T.IdZeme END as IdZeme,
CASE WHEN T.ID IS NULL THEN (SELECT Z1.Nazev FROM TabZeme Z1 WHERE Z1.ISOKod=A.IdZeme) ELSE (SELECT Z.Nazev FROM TabZeme Z WHERE Z.ISOKod=T.IdZeme) END as NazevZeme,
NULL as UdajOZapisuDoObchRej,
ISNULL(T.NazevCastiObce, A.NazevCastiObce) as NazevCastiObce,
ISNULL(T.NazevOkresu, A.NazevOkresu) as NazevOkresu,
ISNULL(T.MestskaCast, A.MestskaCast) as MestskaCast,
ISNULL(T.DatZmeny, T.DatPorizeni) AS DatZmeny, D.ID AS ID, N'Obj02M' AS Tabulka
FROM TabDosleObjH02 D
LEFT OUTER JOIN TabCisOrg A ON D.MistoUrceni = A.CisloOrg
LEFT OUTER JOIN TabCisOrgArch T ON D.MistoUrceni = T.CisloOrg AND T.ID =
(SELECT TOP 1 V.ID FROM TabCisOrgArch V
WHERE D.MistoUrceni = V.CisloOrg AND ISNULL(D.DatumPripadu, D.DatPorizeni) <= CONVERT(DATETIME,CONVERT(INT,CONVERT(FLOAT,V.DatZmeny))-0.0000000193) AND V.NeplatneUdaje=0 AND (V.Overeni IS NULL OR V.Overeni=0) ORDER BY V.DatZmeny, V.ID) AND (SELECT PouzivatOrgBankSpojArch FROM TabHGlob)=1
UNION ALL
SELECT ISNULL(T.CisloOrg, A.CisloOrg) as CisloOrg,
ISNULL(T.Nazev, A.Nazev) as Nazev,
ISNULL(T.DruhyNazev, A.DruhyNazev) as DruhyNazev,
CASE WHEN T.ID IS NULL THEN A.PSC ELSE T.PSC END as PSC,
ISNULL(T.Misto, A.Misto) as Misto,
ISNULL(T.Ulice, A.Ulice) as Ulice,
ISNULL(T.OrCislo, A.OrCislo) as OrCislo,
ISNULL(T.PopCislo, A.PopCislo) as PopCislo,
ISNULL(T.UliceSCisly, A.UliceSCisly) as UliceSCisly,
CASE WHEN T.ID IS NULL THEN A.DIC ELSE T.DIC END as DIC,
CASE WHEN T.ID IS NULL THEN A.DICSk ELSE T.DICSk END as DICSk,
CASE WHEN T.ID IS NULL THEN A.ICO ELSE T.ICO END as ICO,
CASE WHEN T.ID IS NULL THEN A.IdZeme ELSE T.IdZeme END as IdZeme,
CASE WHEN T.ID IS NULL THEN (SELECT Z1.Nazev FROM TabZeme Z1 WHERE Z1.ISOKod=A.IdZeme) ELSE (SELECT Z.Nazev FROM TabZeme Z WHERE Z.ISOKod=T.IdZeme) END as NazevZeme,
NULL as UdajOZapisuDoObchRej,
ISNULL(T.NazevCastiObce, A.NazevCastiObce) as NazevCastiObce,
ISNULL(T.NazevOkresu, A.NazevOkresu) as NazevOkresu,
ISNULL(T.MestskaCast, A.MestskaCast) as MestskaCast,
ISNULL(T.DatZmeny, T.DatPorizeni) AS DatZmeny, D.ID AS ID, N'Obj03M' AS Tabulka
FROM TabDosleObjH03 D
LEFT OUTER JOIN TabCisOrg A ON D.MistoUrceni = A.CisloOrg
LEFT OUTER JOIN TabCisOrgArch T ON D.MistoUrceni = T.CisloOrg AND T.ID =
(SELECT TOP 1 V.ID FROM TabCisOrgArch V
WHERE D.MistoUrceni = V.CisloOrg AND ISNULL(D.DatumPripadu, D.DatPorizeni) <= CONVERT(DATETIME,CONVERT(INT,CONVERT(FLOAT,V.DatZmeny))-0.0000000193) AND V.NeplatneUdaje=0 AND (V.Overeni IS NULL OR V.Overeni=0) ORDER BY V.DatZmeny, V.ID) AND (SELECT PouzivatOrgBankSpojArch FROM TabHGlob)=1
UNION ALL
SELECT ISNULL(T.CisloOrg, A.CisloOrg) AS CisloOrg,
ISNULL(T.Nazev, A.Nazev) as Nazev,
ISNULL(T.DruhyNazev, A.DruhyNazev) as DruhyNazev,
CASE WHEN T.ID IS NULL THEN A.PSC ELSE T.PSC END as PSC,
ISNULL(T.Misto, A.Misto) as Misto,
ISNULL(T.Ulice, A.Ulice) as Ulice,
ISNULL(T.OrCislo, A.OrCislo) as OrCislo,
ISNULL(T.PopCislo, A.PopCislo) as PopCislo,
ISNULL(T.UliceSCisly, A.UliceSCisly) as UliceSCisly,
CASE WHEN T.ID IS NULL THEN A.DIC ELSE T.DIC END as DIC,
CASE WHEN T.ID IS NULL THEN A.DICSk ELSE T.DICSk END as DICSk,
CASE WHEN T.ID IS NULL THEN A.ICO ELSE T.ICO END as ICO,
CASE WHEN T.ID IS NULL THEN A.IdZeme ELSE T.IdZeme END as IdZeme,
CASE WHEN T.ID IS NULL THEN (SELECT Z1.Nazev FROM TabZeme Z1 WHERE Z1.ISOKod=A.IdZeme) ELSE (SELECT Z.Nazev FROM TabZeme Z WHERE Z.ISOKod=T.IdZeme) END as NazevZeme,
ISNULL(T.UdajOZapisuDoObchRej, A.UdajOZapisuDoObchRej) as UdajOZapisuDoObchRej,
ISNULL(T.NazevCastiObce, A.NazevCastiObce) as NazevCastiObce,
ISNULL(T.NazevOkresu, A.NazevOkresu) as NazevOkresu,
ISNULL(T.MestskaCast, A.MestskaCast) as MestskaCast,
ISNULL(T.DatZmeny, T.DatPorizeni) AS DatZmeny, D.ID AS ID, N'CO0DO2' AS Tabulka
FROM TabDosleObjH02 D
LEFT OUTER JOIN TabCisOrg A ON A.CisloOrg = 0
LEFT OUTER JOIN TabCisOrgArch T ON 0 = T.CisloOrg AND T.ID =
(SELECT TOP 1 V.ID FROM TabCisOrgArch V
WHERE 0 = V.CisloOrg AND ISNULL(D.DatumPripadu, D.DatPorizeni) <= CONVERT(DATETIME,CONVERT(INT,CONVERT(FLOAT,V.DatZmeny))-0.0000000193) AND V.NeplatneUdaje=0 AND (V.Overeni IS NULL OR V.Overeni=0) ORDER BY V.DatZmeny, V.ID) AND (SELECT PouzivatOrgBankSpojArch FROM TabHGlob)=1
UNION ALL
SELECT ISNULL(T.CisloOrg, A.CisloOrg) AS CisloOrg,
ISNULL(T.Nazev, A.Nazev) as Nazev,
ISNULL(T.DruhyNazev, A.DruhyNazev) as DruhyNazev,
CASE WHEN T.ID IS NULL THEN A.PSC ELSE T.PSC END as PSC,
ISNULL(T.Misto, A.Misto) as Misto,
ISNULL(T.Ulice, A.Ulice) as Ulice,
ISNULL(T.OrCislo, A.OrCislo) as OrCislo,
ISNULL(T.PopCislo, A.PopCislo) as PopCislo,
ISNULL(T.UliceSCisly, A.UliceSCisly) as UliceSCisly,
CASE WHEN T.ID IS NULL THEN A.DIC ELSE T.DIC END as DIC,
CASE WHEN T.ID IS NULL THEN A.DICSk ELSE T.DICSk END as DICSk,
CASE WHEN T.ID IS NULL THEN A.ICO ELSE T.ICO END as ICO,
CASE WHEN T.ID IS NULL THEN A.IdZeme ELSE T.IdZeme END as IdZeme,
CASE WHEN T.ID IS NULL THEN (SELECT Z1.Nazev FROM TabZeme Z1 WHERE Z1.ISOKod=A.IdZeme) ELSE (SELECT Z.Nazev FROM TabZeme Z WHERE Z.ISOKod=T.IdZeme) END as NazevZeme,
ISNULL(T.UdajOZapisuDoObchRej, A.UdajOZapisuDoObchRej) as UdajOZapisuDoObchRej,
ISNULL(T.NazevCastiObce, A.NazevCastiObce) as NazevCastiObce,
ISNULL(T.NazevOkresu, A.NazevOkresu) as NazevOkresu,
ISNULL(T.MestskaCast, A.MestskaCast) as MestskaCast,
ISNULL(T.DatZmeny, T.DatPorizeni) AS DatZmeny, D.ID AS ID, N'CO0DO3' AS Tabulka
FROM TabDosleObjH03 D
LEFT OUTER JOIN TabCisOrg A ON A.CisloOrg = 0
LEFT OUTER JOIN TabCisOrgArch T ON 0 = T.CisloOrg AND T.ID =
(SELECT TOP 1 V.ID FROM TabCisOrgArch V
WHERE 0 = V.CisloOrg AND ISNULL(D.DatumPripadu, D.DatPorizeni) <= CONVERT(DATETIME,CONVERT(INT,CONVERT(FLOAT,V.DatZmeny))-0.0000000193) AND V.NeplatneUdaje=0 AND (V.Overeni IS NULL OR V.Overeni=0) ORDER BY V.DatZmeny, V.ID) AND (SELECT PouzivatOrgBankSpojArch FROM TabHGlob)=1
UNION ALL
SELECT ISNULL(T.CisloOrg, A.CisloOrg) as CisloOrg,
ISNULL(T.Nazev, A.Nazev) as Nazev,
ISNULL(T.DruhyNazev, A.DruhyNazev) as DruhyNazev,
CASE WHEN T.ID IS NULL THEN A.PSC ELSE T.PSC END as PSC,
ISNULL(T.Misto, A.Misto) as Misto,
ISNULL(T.Ulice, A.Ulice) as Ulice,
ISNULL(T.OrCislo, A.OrCislo) as OrCislo,
ISNULL(T.PopCislo, A.PopCislo) as PopCislo,
ISNULL(T.UliceSCisly, A.UliceSCisly) as UliceSCisly,
CASE WHEN T.ID IS NULL THEN A.DIC ELSE T.DIC END as DIC,
CASE WHEN T.ID IS NULL THEN A.DICSk ELSE T.DICSk END as DICSk,
CASE WHEN T.ID IS NULL THEN A.ICO ELSE T.ICO END as ICO,
CASE WHEN T.ID IS NULL THEN A.IdZeme ELSE T.IdZeme END as IdZeme,
CASE WHEN T.ID IS NULL THEN (SELECT Z1.Nazev FROM TabZeme Z1 WHERE Z1.ISOKod=A.IdZeme) ELSE (SELECT Z.Nazev FROM TabZeme Z WHERE Z.ISOKod=T.IdZeme) END as NazevZeme,
NULL as UdajOZapisuDoObchRej,
ISNULL(T.NazevCastiObce, A.NazevCastiObce) as NazevCastiObce,
ISNULL(T.NazevOkresu, A.NazevOkresu) as NazevOkresu,
ISNULL(T.MestskaCast, A.MestskaCast) as MestskaCast,
ISNULL(T.DatZmeny, T.DatPorizeni) AS DatZmeny, D.ID AS ID, N'UctH' AS Tabulka
FROM TabUctenkaH D
LEFT OUTER JOIN TabCisOrg A ON D.CisloOrg = A.CisloOrg
LEFT OUTER JOIN TabCisOrgArch T ON D.CisloOrg = T.CisloOrg AND T.ID =
(SELECT TOP 1 V.ID FROM TabCisOrgArch V
WHERE D.CisloOrg = V.CisloOrg AND ISNULL(D.DUZP,D.DatPorizeni) <= CONVERT(DATETIME,CONVERT(INT,CONVERT(FLOAT,V.DatZmeny))-0.0000000193) AND V.NeplatneUdaje=0 AND (V.Overeni IS NULL OR V.Overeni=0) ORDER BY V.DatZmeny, V.ID) AND (SELECT PouzivatOrgBankSpojArch FROM TabHGlob)=1
UNION ALL
SELECT ISNULL(T.CisloOrg, A.CisloOrg) AS CisloOrg,
ISNULL(T.Nazev, A.Nazev) as Nazev,
ISNULL(T.DruhyNazev, A.DruhyNazev) as DruhyNazev,
CASE WHEN T.ID IS NULL THEN A.PSC ELSE T.PSC END as PSC,
ISNULL(T.Misto, A.Misto) as Misto,
ISNULL(T.Ulice, A.Ulice) as Ulice,
ISNULL(T.OrCislo, A.OrCislo) as OrCislo,
ISNULL(T.PopCislo, A.PopCislo) as PopCislo,
ISNULL(T.UliceSCisly, A.UliceSCisly) as UliceSCisly,
CASE WHEN T.ID IS NULL THEN A.DIC ELSE T.DIC END as DIC,
CASE WHEN T.ID IS NULL THEN A.DICSk ELSE T.DICSk END as DICSk,
CASE WHEN T.ID IS NULL THEN A.ICO ELSE T.ICO END as ICO,
CASE WHEN T.ID IS NULL THEN A.IdZeme ELSE T.IdZeme END as IdZeme,
CASE WHEN T.ID IS NULL THEN (SELECT Z1.Nazev FROM TabZeme Z1 WHERE Z1.ISOKod=A.IdZeme) ELSE (SELECT Z.Nazev FROM TabZeme Z WHERE Z.ISOKod=T.IdZeme) END as NazevZeme,
ISNULL(T.UdajOZapisuDoObchRej, A.UdajOZapisuDoObchRej) as UdajOZapisuDoObchRej,
ISNULL(T.NazevCastiObce, A.NazevCastiObce) as NazevCastiObce,
ISNULL(T.NazevOkresu, A.NazevOkresu) as NazevOkresu,
ISNULL(T.MestskaCast, A.MestskaCast) as MestskaCast,
ISNULL(T.DatZmeny, T.DatPorizeni) AS DatZmeny, D.ID AS ID, N'CO0Uct' AS Tabulka
FROM TabUctenkaH D
LEFT OUTER JOIN TabCisOrg A ON A.CisloOrg = 0
LEFT OUTER JOIN TabCisOrgArch T ON 0 = T.CisloOrg AND T.ID =
(SELECT TOP 1 V.ID FROM TabCisOrgArch V
WHERE 0 = V.CisloOrg AND ISNULL(D.DUZP,D.DatPorizeni) <= CONVERT(DATETIME,CONVERT(INT,CONVERT(FLOAT,V.DatZmeny))-0.0000000193) AND V.NeplatneUdaje=0 AND (V.Overeni IS NULL OR V.Overeni=0) ORDER BY V.DatZmeny, V.ID) AND (SELECT PouzivatOrgBankSpojArch FROM TabHGlob)=1
UNION ALL
SELECT ISNULL(T.CisloOrg, A.CisloOrg) AS CisloOrg,
ISNULL(T.Nazev, A.Nazev) AS Nazev,
ISNULL(T.DruhyNazev, A.DruhyNazev) as DruhyNazev,
CASE WHEN T.ID IS NULL THEN A.PSC ELSE T.PSC END as PSC,
ISNULL(T.Misto, A.Misto) as Misto,
ISNULL(T.Ulice, A.Ulice) as Ulice,
ISNULL(T.OrCislo, A.OrCislo) as OrCislo,
ISNULL(T.PopCislo, A.PopCislo) as PopCislo,
ISNULL(T.UliceSCisly, A.UliceSCisly) as UliceSCisly,
CASE WHEN T.ID IS NULL THEN A.DIC ELSE T.DIC END as DIC,
CASE WHEN T.ID IS NULL THEN A.DICSk ELSE T.DICSk END as DICSk,
CASE WHEN T.ID IS NULL THEN A.ICO ELSE T.ICO END as ICO,
CASE WHEN T.ID IS NULL THEN A.IdZeme ELSE T.IdZeme END as IdZeme,
CASE WHEN T.ID IS NULL THEN (SELECT Z1.Nazev FROM TabZeme Z1 WHERE Z1.ISOKod=A.IdZeme) ELSE (SELECT Z.Nazev FROM TabZeme Z WHERE Z.ISOKod=T.IdZeme) END as NazevZeme,
ISNULL(T.UdajOZapisuDoObchRej, A.UdajOZapisuDoObchRej) as UdajOZapisuDoObchRej,
ISNULL(T.NazevCastiObce, A.NazevCastiObce) as NazevCastiObce,
ISNULL(T.NazevOkresu, A.NazevOkresu) as NazevOkresu,
ISNULL(T.MestskaCast, A.MestskaCast) as MestskaCast,
ISNULL(T.DatZmeny, T.DatPorizeni) AS DatZmeny, D.ID AS ID, N'CO0Pok' AS Tabulka
FROM TabPokladna D
LEFT OUTER JOIN TabCisOrg A ON A.CisloOrg = 0
LEFT OUTER JOIN TabCisOrgArch T ON 0 = T.CisloOrg AND T.ID =
(SELECT TOP 1 V.ID FROM TabCisOrgArch V
WHERE 0 = V.CisloOrg AND D.DatPorizeni <= CONVERT(DATETIME,CONVERT(INT,CONVERT(FLOAT,V.DatZmeny))-0.0000000193) AND V.NeplatneUdaje=0 AND (V.Overeni IS NULL OR V.Overeni=0) ORDER BY V.DatZmeny, V.ID) AND (SELECT PouzivatOrgBankSpojArch FROM TabHGlob)=1
GO

