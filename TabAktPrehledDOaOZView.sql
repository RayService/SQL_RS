USE [RayService]
GO

/****** Object:  View [dbo].[TabAktPrehledDOaOZView]    Script Date: 04.07.2025 9:43:19 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

CREATE VIEW [dbo].[TabAktPrehledDOaOZView] AS
SELECT H.ID AS ID, H.ID AS IDDoklad, H.ID AS IDDokZbo, NULL AS IDDobj, P.ID AS IDPolozka, H.DatPorizeni AS Datum,
H.DruhPohybuZbo AS DruhPohybuZbo, H.RadaDokladu AS RadaDokladu, (CONVERT([nvarchar](17),ISNULL(replicate(N'0',CASE WHEN H.[DelkaPorCis] IS NULL
THEN (6) ELSE H.[DelkaPorCis] END-LEN(H.[PoradoveCislo])),N'')+CONVERT([nvarchar](11),H.[PoradoveCislo]))) AS CisloDokladu,
P.IDZboSklad AS IDZboSklad, S.IDKmenZbozi AS IDKmenZbozi, CAST(0 AS BIT) AS JeObjednavka, H.CisloOrg AS CisloOrg,
(SELECT ID FROM TabZakazka WHERE CisloZakazky=H.CisloZakazky) AS IDZakazkaH,
(SELECT ID FROM TabZakazka WHERE CisloZakazky=P.CisloZakazky) AS IDZakazkaP,
(SELECT ID FROM TabStrom WHERE Cislo=H.IDSklad) AS IDSklad,
(SELECT ID FROM TabNakladovyOkruh WHERE Cislo=H.NOkruhCislo) AS IDNOkruh,
(SELECT ID FROM TabCisZam WHERE Cislo=P.CisloZam) AS IDZamH,
(SELECT ID FROM TabCisZam WHERE Cislo=H.CisloZam) AS IDZamP,
KontaktZam AS IDKontaktZam, KontaktOsoba AS IDKontaktOsoba,
P.Mnozstvi, P.MJ, P.MnozstviRPT, P.Hmotnost, P.JCbezDaniKC, P.JCsSDKc, P.JCsDPHKc, P.JCbezDaniKcPoS, P.JCsSDKcPoS,
P.JCsDPHKcPoS, P.JCbezDaniVal, P.JCsSDVal, P.JCsDPHVal, P.JCbezDaniValPoS, P.JCsSDValPoS, P.JCsDPHValPoS,
P.CCbezDaniKc, P.CCsSDKc, P.CCsDPHKc, P.CCbezDaniKcPoS, P.CCsSDKcPoS, P.CCsDPHKcPoS,
P.CCbezDaniVal, P.CCsSDVal, P.CCsDPHVal, P.CCbezDaniValPoS, P.CCsSDValPoS, P.CCsDPHValPoS,
P.Mena, P.Kurz, P.JednotkaMeny,
P.SazbaDPH, P.SazbaDPHproPDP, P.SlevaSkupZbo, P.SlevaZboKmen, P.SlevaZboSklad, P.SlevaOrg, P.SlevaSozNa,
P.TerminSlevaProc, P.TerminSlevaNazev, P.ZamknoutCenu, P.Nazev1, P.Nazev2, P.Nazev3, P.Nazev4,
P.SKP, P.NazevSozNa1, P.NazevSozNa2, P.NazevSozNa3, P.Autor, P.DatPorizeni, P.Zmenil, P.DatZmeny,
P.Poradi, P.PrepMnozstvi, P.SazbaSD, P.VstupniCena, P.SlevaPolozkyKc,
P.PotvrzDatDod, P.PozadDatDod, P.BarCode, NULL AS JeStin, P.SlevaCastka, P.IDZakazModif
FROM TabPohybyZbozi P
JOIN TabDokladyZbozi H ON H.ID=P.IDDoklad
JOIN TabStavSkladu S ON S.ID=P.IDZboSklad
WHERE H.PoradoveCislo>0
UNION ALL
SELECT H.ID AS ID, H.ID AS IDDoklad, NULL AS IDDokZbo, H.ID AS IDDobj, P.ID AS IDPolozka, H.DatPorizeni AS Datum,
CAST(53 AS TINYINT) AS DruhPohybuZbo, H.Rada AS RadaDokladu, CAST(H.Cislo AS NVARCHAR(17)) AS CisloDokladu,
P.IDZboSklad AS IDZboSklad, S.IDKmenZbozi AS IDKmenZbozi, CAST(1 AS BIT) AS JeObjednavka, H.CisloOrg AS CisloOrg,
H.IDZakazka AS IDZakazkaH, P.IDZakazka AS IDZakazkaP,
H.IDSklad AS IDSklad, H.IDNOkruh AS IDNOkruh,
H.IDZam AS IDZamH, P.IDZam AS IDZamP, H.IDKontaktZam AS IDKontaktZam, H.IDKontaktOsoba AS IDKontaktOsoba,
P.Mnozstvi, P.MJ, P.MnozstviRPT, P.Hmotnost, P.JCbezDaniKC, P.JCsSDKc, P.JCsDPHKc, P.JCbezDaniKcPoS, P.JCsSDKcPoS,
P.JCsDPHKcPoS, P.JCbezDaniVal, P.JCsSDVal, P.JCsDPHVal, P.JCbezDaniValPoS, P.JCsSDValPoS, P.JCsDPHValPoS,
P.CCbezDaniKc, P.CCsSDKc, P.CCsDPHKc, P.CCbezDaniKcPoS, P.CCsSDKcPoS, P.CCsDPHKcPoS,
P.CCbezDaniVal, P.CCsSDVal, P.CCsDPHVal, P.CCbezDaniValPoS, P.CCsSDValPoS, P.CCsDPHValPoS,
NULL AS Mena, NULL AS Kurz, NULL AS JednotkaMeny,
P.SazbaDPH, P.SazbaDPHproPDP, P.SlevaSkupZbo, P.SlevaZboKmen, P.SlevaZboSklad, P.SlevaOrg, P.SlevaSozNa,
P.TerminSlevaProc, P.TerminSlevaNazev, P.ZamknoutCenu, P.Nazev1, P.Nazev2, P.Nazev3, P.Nazev4,
P.SKP, P.NazevSozNa1, P.NazevSozNa2, P.NazevSozNa3, P.Autor, P.DatPorizeni, P.Zmenil, P.DatZmeny,
P.PoradiPolozky AS Poradi, P.PrepMnozstvi, P.SazbaSD, P.VstupniCena, P.SlevaPolozkyKc,
P.PotvrzDatDod, P.PozadDatDod, P.BarCode, P.JeStin, P.SlevaCastka, P.IDZakazModif
FROM TabDosleObjR02 P
JOIN TabDosleObjH02 H ON H.ID=P.IDHlava
JOIN TabStavSkladu S ON S.ID=P.IDZboSklad
GO

