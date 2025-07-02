USE [HCvicna]
GO

/****** Object:  Trigger [dbo].[et_TabKmenZbozi_kopieBAE]    Script Date: 02.07.2025 15:16:23 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

CREATE TRIGGER [dbo].[et_TabKmenZbozi_kopieBAE] ON [dbo].[TabKmenZbozi] FOR UPDATE AS
IF @@ROWCOUNT = 0 RETURN
SET NOCOUNT ON

/*
Maska pro generování výrobních čísel -- _RayService_GenVC_Maska
Generovat od posledního použitého čísla -- _RayService_GenVC_RespPosledni
Poslední použité číslo -- _RayService_GenVC_PosledniCislo
CofC, dle EN10204 “2.1“ -- _Cofc_en10204
*/

-- MŽ 11.8.2023 - kopie kmenové karty 855 do RS SK
DECLARE @SK NVARCHAR(3)=(SELECT TOP 1 SkupZbo FROM inserted)
IF @SK=N'855'
BEGIN
IF OBJECT_ID('tempdb..#KopieKmen') IS NOT NULL DROP TABLE #KopieKmen
CREATE TABLE #KopieKmen (
	[ID] [int] NULL,
	[SkupZbo] [nvarchar](3) NULL,
	[RegCis] [nvarchar](30) NULL,
	[Nazev1] [nvarchar](100) NULL,
	[Nazev2] [nvarchar](100) NULL,
	[Nazev3] [nvarchar](100) NULL,
	[Nazev4] [nvarchar](100) NULL,
	[SKP] [nvarchar](50) NULL,
	[BaleniTXT] [nvarchar](30) NULL,
	[MJEvidence] [nvarchar](10) NULL,
	[MJVstup] [nvarchar](10) NULL,
	[MJVystup] [nvarchar](10) NULL,
	[ZarukaVstup] [int] NULL,
	[TypZarukaVstup] [tinyint] NULL,
	[ZarukaVystup] [int] NULL,
	[TypZarukaVystup] [tinyint] NULL,
	[Poznamka] [NVARCHAR] (255) NULL,
	[UKod] [int] NULL,
	[DruhSkladu] [tinyint] NULL,
	[Sleva] [numeric](5, 2) NULL,
	[ZakladniMarze] [numeric](5, 2) NULL,
	[Minimum_Dodavatel] [numeric](19, 6) NULL,
	[Minimum_Odberatel] [numeric](19, 6) NULL,
	[Hmotnost] [numeric](19, 6) NULL,
	[Objem] [numeric](19, 6) NULL,
	[Vyska] [numeric](19, 6) NULL,
	[Sirka] [numeric](19, 6) NULL,
	[Hloubka] [numeric](19, 6) NULL,
	[Vykres] [nvarchar](35) NULL,
	[Davka] [numeric](19, 6) NULL,
	[PrepMnozstvi] [numeric](19, 6) NULL,
	[DatumOd] [datetime] NULL,
	[DatumDo] [datetime] NULL,
	[OdhadZvysNakupniCeny] [numeric](5, 2) NULL,
	[Dilec] [bit] NULL,
	[Montaz] [bit] NULL,
	[Material] [bit] NULL,
	[Naradi] [bit] NULL,
	[RezijniMat] [bit] NULL,
	[CelniNomenklatura] [nvarchar](8) NULL,
	[DodaciLhuta] [int] NULL,
	[TypDodaciLhuty] [tinyint] NULL,
	[DopKod] [nvarchar](2) NULL,
	[CNSPD] [nvarchar](4) NULL,
	[CNKod1] [nvarchar](4) NULL,
	[CNKod2] [nvarchar](4) NULL,
	[Slevy] [nchar](1) NULL,
	[EMJ] [nvarchar](10) NULL,
	[PrepMJ_EMJ] [numeric](19, 6) NULL,
	[PrepMJ_CMJ] [numeric](19, 6) NULL,
	[ProdCenaTabak] [numeric](19, 6) NULL,
	[ObvyklaZemePuvodu] [nvarchar](2) NULL,
	[ObvyklyKodPreference] [nvarchar](3) NULL,
	[ObvyklaCenavCM] [numeric](19, 6) NULL,
	[ZakladSDvSJ] [numeric](19, 6) NULL,
	[JCDFaTyp] [tinyint] NULL,
	[VychoziMnozstvi] [numeric](19, 6) NULL,
	[MjPocetEvidVstup] [numeric](19, 6) NULL,
	[MjPocetEvidVystup] [numeric](19, 6) NULL,
	[MjPocetVstup] [numeric](19, 6) NULL,
	[MjPocetVystup] [numeric](19, 6) NULL,
	[ADRtrida] [nvarchar](15) NULL,
	[ADRcislice] [nvarchar](15) NULL,
	[ADRpismeno] [nvarchar](15) NULL,
	[ADRidLatky] [nvarchar](15) NULL,
	[ADRidNebezpecnosti] [nvarchar](15) NULL,
	[IdKusovnik] [int] NULL,
	[IdVarianta] [int] NULL,
	[ADRPojmenovani] [nvarchar](255) NULL,
	[ADRTechnickyNazev] [nvarchar](255) NULL,
	[ADRObchodniNazev] [nvarchar](255) NULL,
	[VedProdukt] [bit] NULL,
	[UpravaCen] [nchar](1) NULL,
	[KodSD] [nvarchar](10) NULL,
	[PrepocetMJSD] [numeric](19, 6) NULL,
	[MJSD] [nvarchar](10) NULL,
	[KontrolaVyrC] [nchar](1) NULL,
	[KJDatOd] [datetime] NULL,
	[KJDatDo] [datetime] NULL,
	[PLUKod] [nvarchar](10) NULL,
	[IdSortiment] [int] NULL,
	[Upozorneni] [nvarchar](255) NULL,
	[BodovaHodnota] [int] NULL,
	[ZadavaniUmisteni] [smallint] NULL,
	[LhutaNaskladneni] [int] NULL,
	[SZ] [nvarchar](2) NULL,
	[DPHPrenesPov] [bit] NULL,
	[ADRObal] [nvarchar](15) NULL,
	[ADRJednotka] [nvarchar](15) NULL,
	[MJInventura] [nvarchar](10) NULL,
	[Minimum_Baleni_Dodavatel] [numeric](19, 6) NULL,
	[VykazLihuObjemVML] [numeric](19, 6) NULL,
	[VykazLihuProcentoLihu] [numeric](5, 2) NULL,
	[VykazLihuKoefKEvidMJ] [numeric](19, 6) NULL,
	[KodKV] [nvarchar](4) NULL,
	[IDKodPDP] [int] NULL,
	[DruhEET] [tinyint] NULL,
	[EET_dic_poverujiciho] [nvarchar](12) NULL,
	[PocetBaleniVeVrstve] [numeric](19, 6) NULL,
	[PocetVrstevNaPalete] [numeric](19, 6) NULL,
	[JeNovaVetaEditor] [bit] NULL,
	[NCSluzbyVHM] [numeric](19, 6) NULL,
	[HraniceMarze] [numeric](5, 2) NULL,
	[PouzitMarzeOdDo] [bit] NULL,
	[ZboziSluzba] [tinyint] NULL,
	[VCSarze] [tinyint] NULL
)

INSERT INTO #KopieKmen (ID,SkupZbo,RegCis,Nazev1,Nazev2,Nazev3,Nazev4,SKP,BaleniTXT,MJEvidence,MJVstup,MJVystup,ZarukaVstup,TypZarukaVstup,ZarukaVystup,TypZarukaVystup,UKod,DruhSkladu
,Sleva,ZakladniMarze,Minimum_Dodavatel,Minimum_Odberatel,Hmotnost,Objem,Vyska,Sirka,Hloubka,Vykres,Davka,PrepMnozstvi,DatumOd,DatumDo,OdhadZvysNakupniCeny,
Dilec,Montaz,Material,Naradi,RezijniMat,CelniNomenklatura,DodaciLhuta,TypDodaciLhuty,DopKod,CNSPD,CNKod1,CNKod2,Slevy,EMJ,PrepMJ_EMJ,PrepMJ_CMJ,ProdCenaTabak,ObvyklaZemePuvodu,ObvyklyKodPreference,ObvyklaCenavCM,
ZakladSDvSJ,JCDFaTyp,VychoziMnozstvi,MjPocetEvidVstup,MjPocetEvidVystup,MjPocetVstup,MjPocetVystup,ADRtrida,ADRcislice,ADRpismeno,ADRidLatky,ADRidNebezpecnosti,IdKusovnik,IdVarianta,ADRPojmenovani,ADRTechnickyNazev,
ADRObchodniNazev,VedProdukt,UpravaCen,KodSD,PrepocetMJSD,MJSD,KontrolaVyrC,KJDatOd,KJDatDo,PLUKod,IdSortiment,Upozorneni,BodovaHodnota,ZadavaniUmisteni,LhutaNaskladneni,SZ,DPHPrenesPov,ADRObal,ADRJednotka,
MJInventura,Minimum_Baleni_Dodavatel,VykazLihuObjemVML,VykazLihuProcentoLihu,VykazLihuKoefKEvidMJ,KodKV,IDKodPDP,DruhEET,EET_dic_poverujiciho,PocetBaleniVeVrstve,PocetVrstevNaPalete,NCSluzbyVHM,HraniceMarze,PouzitMarzeOdDo
)
SELECT ID,SkupZbo,RegCis,Nazev1,Nazev2,Nazev3,Nazev4,SKP,BaleniTXT,MJEvidence,MJVstup,MJVystup,ZarukaVstup,TypZarukaVstup,ZarukaVystup,TypZarukaVystup,UKod,DruhSkladu
,Sleva,ZakladniMarze,Minimum_Dodavatel,Minimum_Odberatel,Hmotnost,Objem,Vyska,Sirka,Hloubka,Vykres,Davka,PrepMnozstvi,DatumOd,DatumDo,OdhadZvysNakupniCeny,
Dilec,Montaz,Material,Naradi,RezijniMat,CelniNomenklatura,DodaciLhuta,TypDodaciLhuty,DopKod,CNSPD,CNKod1,CNKod2,Slevy,EMJ,PrepMJ_EMJ,PrepMJ_CMJ,ProdCenaTabak,ObvyklaZemePuvodu,ObvyklyKodPreference,ObvyklaCenavCM,
ZakladSDvSJ,JCDFaTyp,VychoziMnozstvi,MjPocetEvidVstup,MjPocetEvidVystup,MjPocetVstup,MjPocetVystup,ADRtrida,ADRcislice,ADRpismeno,ADRidLatky,ADRidNebezpecnosti,ID/*IdKusovnik*/,IdVarianta,ADRPojmenovani,ADRTechnickyNazev,
ADRObchodniNazev,VedProdukt,UpravaCen,KodSD,PrepocetMJSD,MJSD,KontrolaVyrC,KJDatOd,KJDatDo,PLUKod,IdSortiment,Upozorneni,BodovaHodnota,ZadavaniUmisteni,LhutaNaskladneni,SZ,DPHPrenesPov,ADRObal,ADRJednotka,
MJInventura,Minimum_Baleni_Dodavatel,VykazLihuObjemVML,VykazLihuProcentoLihu,VykazLihuKoefKEvidMJ,KodKV,IDKodPDP,DruhEET,EET_dic_poverujiciho,PocetBaleniVeVrstve,PocetVrstevNaPalete,NCSluzbyVHM,HraniceMarze,PouzitMarzeOdDo
FROM inserted
/*
MERGE RayService5.dbo.TabKmenZbozi AS TARGET
USING #KopieKmen AS SOURCE
ON TARGET.SkupZbo=SOURCE.SkupZbo AND TARGET.RegCis=SOURCE.RegCis
WHEN MATCHED THEN
UPDATE SET TARGET.Nazev1=SOURCE.Nazev1,TARGET.Nazev2=SOURCE.Nazev2,TARGET.Nazev3=SOURCE.Nazev3,TARGET.Nazev4=SOURCE.Nazev4,TARGET.SKP=SOURCE.SKP,TARGET.MJEvidence=SOURCE.MJEvidence,TARGET.MJVstup=SOURCE.MJVstup,TARGET.MJVystup=SOURCE.MJVystup,
TARGET.ZarukaVstup=SOURCE.ZarukaVstup,TARGET.TypZarukaVstup=SOURCE.TypZarukaVstup,TARGET.ZarukaVystup=SOURCE.ZarukaVystup,TARGET.TypZarukaVystup=SOURCE.TypZarukaVystup,TARGET.DruhSkladu=SOURCE.DruhSkladu,TARGET.Hmotnost=SOURCE.Hmotnost,
TARGET.Dilec=SOURCE.Dilec,TARGET.Montaz=SOURCE.Montaz,TARGET.Material=SOURCE.Material ,TARGET.CelniNomenklatura=SOURCE.CelniNomenklatura,TARGET.ObvyklaZemePuvodu=SOURCE.ObvyklaZemePuvodu,TARGET.VedProdukt=SOURCE.VedProdukt,
TARGET.Upozorneni=SOURCE.Upozorneni
WHEN NOT MATCHED BY TARGET THEN
INSERT (SkupZbo,RegCis,Nazev1,Nazev2,Nazev3,Nazev4,SKP,BaleniTXT,MJEvidence,MJVstup,MJVystup,ZarukaVstup,TypZarukaVstup,ZarukaVystup,TypZarukaVystup,DruhSkladu
,Sleva,ZakladniMarze,Minimum_Dodavatel,Minimum_Odberatel,Hmotnost,Objem,Vyska,Sirka,Hloubka,Vykres,Davka,PrepMnozstvi,DatumOd,DatumDo,OdhadZvysNakupniCeny,
Dilec,Montaz,Material,Naradi,RezijniMat,CelniNomenklatura,DodaciLhuta,TypDodaciLhuty,DopKod,CNSPD,CNKod1,CNKod2,Slevy,EMJ,PrepMJ_EMJ,PrepMJ_CMJ,ProdCenaTabak,ObvyklaZemePuvodu,ObvyklyKodPreference,ObvyklaCenavCM,
ZakladSDvSJ,JCDFaTyp,VychoziMnozstvi,MjPocetEvidVstup,MjPocetEvidVystup,MjPocetVstup,MjPocetVystup,ADRtrida,ADRcislice,ADRpismeno,ADRidLatky,ADRidNebezpecnosti,/*IdKusovnik,*/IdVarianta,ADRPojmenovani,ADRTechnickyNazev,
ADRObchodniNazev,VedProdukt,UpravaCen,KodSD,PrepocetMJSD,MJSD,KontrolaVyrC,KJDatOd,KJDatDo,PLUKod,IdSortiment,Upozorneni,BodovaHodnota,ZadavaniUmisteni,LhutaNaskladneni,SZ,DPHPrenesPov,ADRObal,ADRJednotka,
MJInventura,Minimum_Baleni_Dodavatel,VykazLihuObjemVML,VykazLihuProcentoLihu,VykazLihuKoefKEvidMJ,KodKV,IDKodPDP,DruhEET,EET_dic_poverujiciho,PocetBaleniVeVrstve,PocetVrstevNaPalete,NCSluzbyVHM,HraniceMarze,CisloUcetPrijem,
CisloUcetVydej,CisloUcetVydejEC,CisloUcetFAPrij,CisloUcetFAVyd,PouzitMarzeOdDo,CisloUcetPrijem_DSN,CisloUcetVydej_DSN,CisloUcetVydejEC_DSN,CisloUcetFAPrij_DSN,ZboziSluzba,VCSarze,TypVoucheru,PlatnostVoucheru,ZmenaCenyVoucheru,
DruhKarty,ADRBezpZnacka,ADROmezMnozstvi,ADRNebezpZP,ADRzvlBezpOpatreni,ADRzvlOpatreni
)
VALUES (SOURCE.SkupZbo,SOURCE.RegCis,SOURCE.Nazev1,SOURCE.Nazev2,SOURCE.Nazev3,SOURCE.Nazev4,SOURCE.SKP,SOURCE.BaleniTXT,SOURCE.MJEvidence,SOURCE.MJVstup,SOURCE.MJVystup,SOURCE.ZarukaVstup,SOURCE.TypZarukaVstup,SOURCE.ZarukaVystup,SOURCE.TypZarukaVystup,SOURCE.DruhSkladu
,Sleva,ZakladniMarze,Minimum_Dodavatel,Minimum_Odberatel,Hmotnost,Objem,Vyska,Sirka,Hloubka,Vykres,Davka,PrepMnozstvi,DatumOd,DatumDo,OdhadZvysNakupniCeny,
Dilec,Montaz,Material,Naradi,RezijniMat,CelniNomenklatura,DodaciLhuta,TypDodaciLhuty,DopKod,CNSPD,CNKod1,CNKod2,Slevy,EMJ,PrepMJ_EMJ,PrepMJ_CMJ,ProdCenaTabak,ObvyklaZemePuvodu,ObvyklyKodPreference,ObvyklaCenavCM,
ZakladSDvSJ,JCDFaTyp,VychoziMnozstvi,MjPocetEvidVstup,MjPocetEvidVystup,MjPocetVstup,MjPocetVystup,ADRtrida,ADRcislice,ADRpismeno,ADRidLatky,ADRidNebezpecnosti,/*IdKusovnik,*/IdVarianta,ADRPojmenovani,ADRTechnickyNazev,
ADRObchodniNazev,VedProdukt,UpravaCen,KodSD,PrepocetMJSD,MJSD,KontrolaVyrC,KJDatOd,KJDatDo,PLUKod,IdSortiment,Upozorneni,BodovaHodnota,ZadavaniUmisteni,LhutaNaskladneni,SZ,DPHPrenesPov,ADRObal,ADRJednotka,
MJInventura,Minimum_Baleni_Dodavatel,VykazLihuObjemVML,VykazLihuProcentoLihu,VykazLihuKoefKEvidMJ,KodKV,IDKodPDP,DruhEET,EET_dic_poverujiciho,PocetBaleniVeVrstve,PocetVrstevNaPalete,NCSluzbyVHM,HraniceMarze,CisloUcetPrijem,
CisloUcetVydej,CisloUcetVydejEC,CisloUcetFAPrij,CisloUcetFAVyd,PouzitMarzeOdDo,CisloUcetPrijem_DSN,CisloUcetVydej_DSN,CisloUcetVydejEC_DSN,CisloUcetFAPrij_DSN,ZboziSluzba,VCSarze,TypVoucheru,PlatnostVoucheru,ZmenaCenyVoucheru,
DruhKarty,ADRBezpZnacka,ADROmezMnozstvi,ADRNebezpZP,ADRzvlBezpOpatreni,ADRzvlOpatreni
);
*/

UPDATE t SET
t.Nazev1=kk.Nazev1,t.Nazev2=kk.Nazev2,t.Nazev3=kk.Nazev3,t.Nazev4=kk.Nazev4,t.SKP=kk.SKP,t.MJEvidence=kk.MJEvidence,t.MJVstup=kk.MJVstup,t.MJVystup=kk.MJVystup,t.ZarukaVstup=kk.ZarukaVstup,t.TypZarukaVstup=kk.TypZarukaVstup,
t.ZarukaVystup=kk.ZarukaVystup,t.TypZarukaVystup=kk.TypZarukaVystup,t.DruhSkladu=kk.DruhSkladu,t.Hmotnost=kk.Hmotnost,t.Dilec=kk.Dilec,t.Montaz=kk.Montaz,t.Material=kk.Material,t.CelniNomenklatura=kk.CelniNomenklatura,
t.ObvyklaZemePuvodu=kk.ObvyklaZemePuvodu,t.VedProdukt=kk.VedProdukt,t.Upozorneni=kk.Upozorneni
FROM RayService5.dbo.TabKmenZbozi t
LEFT OUTER JOIN #KopieKmen kk ON kk.SkupZbo=t.SkupZbo AND kk.RegCis=t.RegCis
WHERE t.SkupZbo=kk.SkupZbo AND t.RegCis=kk.RegCis;
IF @@ROWCOUNT = 0
BEGIN
	INSERT INTO RayService5.dbo.TabKmenZbozi (SkupZbo,RegCis,Nazev1,Nazev2,Nazev3,Nazev4,SKP,BaleniTXT,MJEvidence,MJVstup,MJVystup,ZarukaVstup,TypZarukaVstup,ZarukaVystup,TypZarukaVystup,DruhSkladu
	,Sleva,ZakladniMarze,Minimum_Dodavatel,Minimum_Odberatel,Hmotnost,Objem,Vyska,Sirka,Hloubka,Vykres,Davka,PrepMnozstvi,DatumOd,DatumDo,OdhadZvysNakupniCeny,
	Dilec,Montaz,Material,Naradi,RezijniMat,CelniNomenklatura,DodaciLhuta,TypDodaciLhuty,DopKod,CNSPD,CNKod1,CNKod2,Slevy,EMJ,PrepMJ_EMJ,PrepMJ_CMJ,ProdCenaTabak,ObvyklaZemePuvodu,ObvyklyKodPreference,ObvyklaCenavCM,
	ZakladSDvSJ,JCDFaTyp,VychoziMnozstvi,MjPocetEvidVstup,MjPocetEvidVystup,MjPocetVstup,MjPocetVystup,ADRtrida,ADRcislice,ADRpismeno,ADRidLatky,ADRidNebezpecnosti,/*IdKusovnik,*/IdVarianta,ADRPojmenovani,ADRTechnickyNazev,
	ADRObchodniNazev,VedProdukt,UpravaCen,KodSD,PrepocetMJSD,MJSD,KontrolaVyrC,KJDatOd,KJDatDo,PLUKod,IdSortiment,Upozorneni,BodovaHodnota,ZadavaniUmisteni,LhutaNaskladneni,SZ,DPHPrenesPov,ADRObal,ADRJednotka,
	MJInventura,Minimum_Baleni_Dodavatel,VykazLihuObjemVML,VykazLihuProcentoLihu,VykazLihuKoefKEvidMJ,KodKV,IDKodPDP,DruhEET,EET_dic_poverujiciho,PocetBaleniVeVrstve,PocetVrstevNaPalete,NCSluzbyVHM,HraniceMarze,PouzitMarzeOdDo)
	SELECT kk.SkupZbo,kk.RegCis,kk.Nazev1,kk.Nazev2,kk.Nazev3,kk.Nazev4,kk.SKP,kk.BaleniTXT,kk.MJEvidence,kk.MJVstup,kk.MJVystup,kk.ZarukaVstup,kk.TypZarukaVstup,kk.ZarukaVystup,kk.TypZarukaVystup,kk.DruhSkladu
	,Sleva,ZakladniMarze,Minimum_Dodavatel,Minimum_Odberatel,Hmotnost,Objem,Vyska,Sirka,Hloubka,Vykres,Davka,PrepMnozstvi,DatumOd,DatumDo,OdhadZvysNakupniCeny,
	Dilec,Montaz,Material,Naradi,RezijniMat,CelniNomenklatura,DodaciLhuta,TypDodaciLhuty,DopKod,CNSPD,CNKod1,CNKod2,Slevy,EMJ,PrepMJ_EMJ,PrepMJ_CMJ,ProdCenaTabak,ObvyklaZemePuvodu,ObvyklyKodPreference,ObvyklaCenavCM,
	ZakladSDvSJ,JCDFaTyp,VychoziMnozstvi,MjPocetEvidVstup,MjPocetEvidVystup,MjPocetVstup,MjPocetVystup,ADRtrida,ADRcislice,ADRpismeno,ADRidLatky,ADRidNebezpecnosti,/*IdKusovnik,*/IdVarianta,ADRPojmenovani,ADRTechnickyNazev,
	ADRObchodniNazev,VedProdukt,UpravaCen,KodSD,PrepocetMJSD,MJSD,KontrolaVyrC,KJDatOd,KJDatDo,PLUKod,IdSortiment,Upozorneni,BodovaHodnota,ZadavaniUmisteni,LhutaNaskladneni,SZ,DPHPrenesPov,ADRObal,ADRJednotka,
	MJInventura,Minimum_Baleni_Dodavatel,VykazLihuObjemVML,VykazLihuProcentoLihu,VykazLihuKoefKEvidMJ,KodKV,IDKodPDP,DruhEET,EET_dic_poverujiciho,PocetBaleniVeVrstve,PocetVrstevNaPalete,NCSluzbyVHM,HraniceMarze,PouzitMarzeOdDo
	FROM #KopieKmen kk
END;

END;



GO

ALTER TABLE [dbo].[TabKmenZbozi] ENABLE TRIGGER [et_TabKmenZbozi_kopieBAE]
GO

