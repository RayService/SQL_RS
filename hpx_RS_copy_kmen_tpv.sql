USE [RayService]
GO

/****** Object:  StoredProcedure [dbo].[hpx_RS_copy_kmen_tpv]    Script Date: 26.06.2025 13:16:45 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

CREATE PROCEDURE [dbo].[hpx_RS_copy_kmen_tpv] @ID INT, @IDZmeny INT
AS
--USE HCvicna
--kopie dílce

--cvičně bereme ID původního dílce
--DECLARE @ID INT=103985

/*
1. hp_OZ_RegCislo_Autocislovanim
2. hp_OZCopyKmenASklad2
3. hp_KopieKonstrukceATech
*/
--nejprve najdeme volné reg.číslo
DECLARE @SkupZbo NVARCHAR(3);
DECLARE @RegCis  NVARCHAR(31);
DECLARE @Nazev1 NVARCHAR(255);
DECLARE @IDSklad NVARCHAR(30);
DECLARE @AutoCislovani BIT;
DECLARE @IDDilce_Cil INT;
--DECLARE @IDZmeny INT;
SET @SkupZbo=(SELECT SkupZbo FROM TabKmenZbozi WHERE ID=@ID)
--SET @IDZmeny=72073
SET @IDSklad=N'100'
EXEC dbo.hp_OZ_RegCislo_Autocislovanim @SkupZbo, @RegCis OUTPUT, @AutoCislovani OUTPUT

SELECT @Nazev1=Nazev1
FROM TabKmenZbozi
WHERE ID=@ID

SELECT @RegCis, @Nazev1, @SkupZbo

IF OBJECT_ID('tempdb..#KopieKmZboResult') IS NOT NULL
DROP TABLE #KopieKmZboResult
CREATE TABLE #KopieKmZboResult(ID INT, Chyba BIT, eMsg INT, Zdroj INT)

EXEC dbo.hp_OZCopyKmenASklad2
@Kmen=1,            -- 0 = StavSkladu / 1 = KmenZbozi
@SrcID=@ID,            -- ID zdrojoveho zaznamu ze kmene / skladu
@AktualniSklad=@IDSklad,   -- cislo aktualniho skladu
@OznacVic=0,            -- oznaceno vice zdrojovych zaznamu
@SkupZbo=@SkupZbo, -- zadana nova skupina zbozi
@RegCis=@RegCis, -- pozor, deklarace je zamerne o znak delsi
@Nazev1=@Nazev1, -- zadany novy nazev
@SezAtrKme=N'Nazev2,Nazev3,Nazev4,SKP,BodovaHodnota,Upozorneni,BaleniTXT,MJEvidence,MJVstup,MJVystup,MJInventura,ZarukaVstup,TypZarukaVstup,ZarukaVystup,TypZarukaVystup,SazbaDPHVstup,SazbaDPHVystup,DPHPrenesPov,SazbaSDVstup,SazbaSDVystup,KodSD,PrepocetMJSD,MJSD,Poznamka,UKod,DruhSkladu,DruhKarty,Sleva,ZakladniMarze,Aktualni_Dodavatel,Minimum_Dodavatel,Minimum_Baleni_Dodavatel,Minimum_Odberatel,Hmotnost,Objem,Vyska,Sirka,Hloubka,Vykres,KmenoveStredisko,Davka,PrepMnozstvi,DatumOd,DatumDo,OdhadZvysNakupniCeny,Dilec,Montaz,Material,Naradi,RezijniMat,KodKV,IDKodPDP,CelniNomenklatura,DodaciLhuta,TypDodaciLhuty,CLOPopisZbozi,DopKod,CNSPD,CNKod1,CNKod2,SZ,Slevy,UpravaCen,ZadavaniUmisteni,EMJ,PrepMJ_EMJ,PrepMJ_CMJ,ProdCenaTabak,ObvyklaZemePuvodu,ObvyklyKodPreference,ObvyklaCenavCM,ZakladSDvSJ,JCDFaTyp,VychoziMnozstvi,MjPocetEvidVstup,MjPocetEvidVystup,MjPocetVstup,MjPocetVystup,ADRtrida,ADRcislice,ADRpismeno,ADRidLatky,ADRidNebezpecnosti,ADRObal,ADRJednotka,ADRPojmenovani,ADRTechnickyNazev,ADRObchodniNazev,KontrolaVyrC,VCSarze,VedProdukt,KJDatOd,KJDatDo,IdSortiment,Vyrobce,LhutaNaskladneni,VykazLihuObjemVML,VykazLihuProcentoLihu,VykazLihuKoefKEvidMJ,EET_dic_poverujiciho,DruhEET,PocetBaleniVeVrstve,PocetVrstevNaPalete,NCSluzbyVHM,HraniceMarze,PouzitMarzeOdDo,CisloUcetPrijem,CisloUcetVydej,CisloUcetVydejEC,CisloUcetFAPrij,CisloUcetFAVyd,CisloUcetPrijem_DSN,CisloUcetVydej_DSN,CisloUcetVydejEC_DSN,CisloUcetFAPrij_DSN,ZboziSluzba,TypVoucheru,PlatnostVoucheru,ZmenaCenyVoucheru,JeNovaVetaEditor', -- seznam atributu TabKmenZbozi
@SezAtrNC=N'CenovaUroven,MJ,DatumOd,DatumDo,AltCena,CenaKC,BezDPH,CenaVal1,Mena1,CenaVal2,Mena2,CenaVal3,Mena3,CenaVal4,Mena4,CenaVal5,Mena5,AutAktualizace,BlokovaniEditoru,JeNovaVetaEditor', -- seznam atributu TabNC
@SezAtrVC=N'IDZakazModif,Nazev1,Nazev2,MnozFinReal,ZarukaVstup,TypZarukaVstup,ZarukaVystup,TypZarukaVystup,DatVstup,DatVystup,Poznamka,BlokovaniEditoru,DatExpirace,JeNovaVetaEditor', -- seznam atributu TabVyrCS
@SezAtrUmi=N'IDUmisteni,Poznamka,Prednastaveno', -- seznam atributu umisteni zbozi
@SezAtrSle=N'DruhCU,OdHodnoty,Sleva,DruhSlevy,Autor,DatPorizeni,Zmenil,DatZmeny,BlokovaniEditoru', -- seznam atributu slevy ke zbozi
@SezAtrMJ=N'KodMJ1,KodMJ2,PocetHlavni,PocetOdvozene,Autor,DatPorizeni,Zmenil,DatZmeny', -- seznam atributu MJ pro zbozi
@SezAtrDod=N'IDCisOrg,Minimum_Dodavatel,DodaciLhuta,TypDodaciLhuty,Poznamka,Autor,DatPorizeni,Zmenil,DatZmeny,BlokovaniEditoru,Minimum_Baleni_Dodavatel,JeNovaVetaEditor', -- seznam atributu dodavatele zbozi
@SezAtrNav=N'IDSoz,Nazev1,Nazev2,Nazev3,Nazev4,BarCode,Sleva,CenovaUroven,CenovaUrovenNakup,UplatnitSlevy,DruhSlevy,DruhSlevyNakup,OdHodnoty,ExpiraceTyp,ExpiraceProcento,ExpiraceHodnota,Autor,DatPorizeni,Zmenil,DatZmeny,BlokovaniEditoru,JeNovaVetaEditor', -- seznam atributu navazne skupiny zbozi
@SezAtrOba=N'IDObal,Mnozstvi,MnozstviObalu,Prednastaveno,PrijemNaSklad,StornoPrijmu,VydejZeSkladu,StornoVydeje,VydejVEvCene,VydanaObj,ExpPrikaz,Rezervace,Nabidka,FaktVydana,DobropisVydany,FakturaPrijata,DobropisPrijaty,DosleObj,PokladniProdej,Zaokrouhleni,ZalohaObalSK,Poznamka,Autor,DatPorizeni,Zmenil,DatZmeny,BlokovaniEditoru,JeNovaVetaEditor', -- seznam atributu obaly
@SezAtrDPH=N'DruhSazbyDPH,ISOKodZeme,PlatnostOd,PlatnostDo,Prednastaveno,VstupVystup,DPHPrenesPov,Autor,DatPorizeni,Zmenil,DatZmeny,BlokovaniEditoru', -- seznam atributu sazby DPH
@ZalozitNaSklady=0,        -- 0=vsechny sklady jako src / 1=jen aktualni sklad / 2=nic
@ZalozitNC=0,            -- kopiruj take navazne nabidkove ceny
@ZalozitVC=0,            -- kopiruj take navazne vyrobni cisla
@ZalozitUmi=0,            -- kopiruj take navazne umisteni
@ZalozitSle=1,            -- kopiruj take navazne slevy
@ZalozitMJ=1,            -- kopiruj take navazne merne jednotky
@ZalozitDod=1,            -- kopiruj take navazne dodavatele
@ZalozitExt=1,            -- kopiruj take vsechny externi sloupce
@ZalozitDok=0,            -- kopiruj take navazne dokumenty
@ZalozitNav=1,            -- kopiruj take navazne skupiny zbozi - SozNa
@ZalozitOba=1,            -- kopiruj take navazne obaly
@ZalozitDPH=1,            -- kopiruj take navazne sazby DPH
@SezAtrVK=N'IDZakazModif,Nazev2,ZarukaVstup,TypZarukaVstup,ZarukaVystup,TypZarukaVystup,DatVstup,DatVystup,DatExpirace,VyrCKProvereni,Poznamka,BlokovaniEditoru,JeNovaVetaEditor', -- seznam atributu TabVyrCK
@ZalozitVK=0,        -- kopiruj take navazne kmeny vyrobnich cisel
@ArchKK=1,        -- kopiruj i archivni kmeny
@ArchSK=1         -- kopiruj i archivni skladove karty

SELECT @IDDilce_Cil=ID
FROM #KopieKmZboResult

UPDATE tkz SET tkz.Nazev2=Nazev2+' !JP'
FROM TabKmenZbozi tkz
WHERE tkz.ID=@IDDilce_Cil

EXEC hp_KopieKonstrukceATech
@IDDilce_Zdroj=@ID,
@IDDilce_Cil=@IDDilce_Cil,
@IDZmeny_Cil=@IDZmeny, 
@OblastKVazby=1,
@OblastPostup=1,
@OblastNVazby=1,
@OblastTpvOPN=1,
@OblastVPVazby=1,
@OblastVyrDokum=1,
@OblastDavka=1



GO

