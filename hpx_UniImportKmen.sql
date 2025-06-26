USE [RayService]
GO

/****** Object:  StoredProcedure [dbo].[hpx_UniImportKmen]    Script Date: 26.06.2025 10:18:18 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

/*rpObecneImporty.Import*/CREATE PROC [dbo].[hpx_UniImportKmen]
AS
SET NOCOUNT ON
SET ANSI_NULLS ON
SET ANSI_NULL_DFLT_ON ON
SET ANSI_PADDING ON
SET ANSI_WARNINGS ON
SET QUOTED_IDENTIFIER ON
SET CURSOR_CLOSE_ON_COMMIT OFF
SET CONCAT_NULL_YIELDS_NULL ON
SET IMPLICIT_TRANSACTIONS OFF
SET DATEFORMAT dmy
SET DATEFIRST 1
SET XACT_ABORT ON
SET ARITHABORT ON
SET NUMERIC_ROUNDABORT OFF
SET DEADLOCK_PRIORITY LOW
SET LOCK_TIMEOUT -1

DECLARE @JazykVerze INT
SET @JazykVerze=(SELECT Jazyk FROM TabUziv WHERE LoginName=SUSER_SNAME())
IF @JazykVerze IS NULL SET @JazykVerze=1
IF @JazykVerze NOT IN(1, 4, 6) SET @JazykVerze = 1

DECLARE @PouzeZaznamyDleLogin BIT
SET @PouzeZaznamyDleLogin=(SELECT TOP 1 PouzeZaznamyDleLogin FROM TabUniImportKonfig ORDER BY ID ASC)

DECLARE @PocetRadkuImpTabulky INT, @InfoText NVARCHAR(255)
SET @PocetRadkuImpTabulky=(SELECT COUNT(*) FROM TabUniImportKmen WHERE Chyba IS NULL AND ((@PouzeZaznamyDleLogin=1 AND Autor=SUSER_SNAME())OR(@PouzeZaznamyDleLogin=0)) )
SET @InfoText = dbo.hpf_UniImportHlasky('959B5166-6EEF-44A5-B4AC-DA13F5642C08', @JazykVerze, 'TabUniImportKmen', CAST(@PocetRadkuImpTabulky AS NVARCHAR), DEFAULT, DEFAULT)
IF @InfoText IS NOT NULL
  EXEC dbo.hp_ZapisDoZurnalu 1, 77, @InfoText
IF OBJECT_ID('dbo.epx_UniImportKmen02', 'P') IS NOT NULL EXEC dbo.epx_UniImportKmen02
DECLARE @ChybaPriImportu BIT, @IDKmen INT, @SQLString NVARCHAR(4000), @TextChybyImportu NVARCHAR(4000), @ChybaExtAtr NVARCHAR(4000),
        @IdSortPom INT, @Nuly NVARCHAR(30), @DelkaReg TINYINT, @Zarovnani TINYINT, @I TINYINT, @AutoCislovani BIT, @IDKodPDP INT,
/*PRI PRIDANI NOVE VERZE IMPORTU PRIDAT DEKLARACE NOVYCH PROMENNYCH I SEM*/
@ID INT, @InterniVerze INT, @SkupZbo NVARCHAR(3), @RegCis NVARCHAR(30), @DruhSkladu TINYINT, @Nazev1 NVARCHAR(100), @Nazev2 NVARCHAR(100),
@Nazev3 NVARCHAR(100), @Nazev4 NVARCHAR(100), @SKP NVARCHAR(50), @MJEvidence NVARCHAR(10), @MJvstup NVARCHAR(10),
@MJvystup NVARCHAR(10), @KJDatOd DATETIME, @KJDatDo DATETIME, @Vykres NVARCHAR(35), @ZarukaVstup INT,
@TypZarukaVstup TINYINT, @ZarukaVystup INT, @TypZarukaVystup TINYINT, @DodaciLhuta INT, @TypDodaciLhuty TINYINT,
@BaleniTXT NVARCHAR(30), @Aktualni_Dodavatel INT, @Minimum_Dodavatel NUMERIC(19,6), @Minimum_Odberatel NUMERIC(19,6),
@Sirka NUMERIC(19,6), @Vyska NUMERIC(19,6), @Hloubka NUMERIC(19,6), @Objem NUMERIC(19,6), @Hmotnost NUMERIC(19,6),
@IdSortiment NVARCHAR(54), @Vyrobce INT, @VychoziMnozstvi NUMERIC(19,6), @PrepMnozstvi NUMERIC(19,6),
@SazbaDPHVstup NUMERIC(5,2), @SazbaDPHVystup NUMERIC(5,2), @CelniNomenklatura NVARCHAR(8), @DopKod NVARCHAR(2), @CLOPopisZbozi NVARCHAR(MAX), @BarCode NVARCHAR(50), @DoplnkovyKod NVARCHAR(50), @ObvyklaZemePuvodu NVARCHAR(2),
@ExtAtr1 NVARCHAR(30), @ExtAtr1Nazev NVARCHAR(127), @ExtAtr2 NVARCHAR(255), @ExtAtr2Nazev NVARCHAR(127),
@ExtAtr3 DATETIME, @ExtAtr3Nazev NVARCHAR(127), @ExtAtr4 NUMERIC(19,6), @ExtAtr4Nazev NVARCHAR(127),
@ExtAtr5 NVARCHAR(255), @ExtAtr5Nazev NVARCHAR(127),
@ExtAtr6 NVARCHAR(255), @ExtAtr6Nazev NVARCHAR(127),
@ExtAtr7 NVARCHAR(255), @ExtAtr7Nazev NVARCHAR(127),
@ExtAtr8 NVARCHAR(255), @ExtAtr8Nazev NVARCHAR(127),
@ExtAtr9 BIT,           @ExtAtr9Nazev NVARCHAR(127),
@KontrolaVyrC NCHAR(1),
@Blokovano TINYINT,
@Minimum_Baleni_Dodavatel NUMERIC(19,6),
@VykazLihuObjemVML NUMERIC(19,6),
@VykazLihuProcentoLihu NUMERIC(5,2),
@VykazLihuKoefKEvidMJ NUMERIC(19,6),
@Upozorneni NVARCHAR(255),
@KodZbozi NVARCHAR(20),
@LhutaNaskladneni INT,
@Poznamka NVARCHAR(MAX),
@UKod INT,
@CisloUcetPrijem NVARCHAR(30),
@CisloUcetVydej NVARCHAR(30),
@CisloUcetVydejEC NVARCHAR(30),
@CisloUcetFAPrij NVARCHAR(30),
@CisloUcetFAVyd NVARCHAR(30),
@Sleva NUMERIC(5,2),
@KodRecyk NVARCHAR(20), @CastkaHistRecyk NUMERIC(19,6), @CastkaGarRecyk NUMERIC(19,6), @MJRecyk NVARCHAR(10), @PrepMJRecyk NUMERIC(19,6),
@ZboziSluzba TINYINT, @MJInventura NVARCHAR(10),
@PocetBaleniVeVrstve NUMERIC(19,6), @PocetVrstevNaPalete NUMERIC(19,6),
@PLUKod NVARCHAR(10), @BodovaHodnota INT,
@Nazev1_U NVARCHAR(100),
@Nazev2_U NVARCHAR(100),
@Nazev3_U NVARCHAR(100),
@Nazev4_U NVARCHAR(100),
@SKP_U NVARCHAR(50),
@MJEvidence_U NVARCHAR(10),
@MJVstup_U NVARCHAR(10),
@MJVystup_U NVARCHAR(10),
@MJInventura_U NVARCHAR(10),
@KJDatOd_U DATETIME,
@KJDatDo_U DATETIME,
@Vykres_U NVARCHAR(35),
@ZarukaVstup_U INT,
@TypZarukaVstup_U TINYINT,
@ZarukaVystup_U INT,
@TypZarukaVystup_U TINYINT,
@DodaciLhuta_U INT,
@TypDodaciLhuty_U TINYINT,
@BaleniTXT_U NVARCHAR(30),
@Aktualni_Dodavatel_U INT,
@Minimum_Dodavatel_U NUMERIC(19,6),
@Minimum_Odberatel_U NUMERIC(19,6),
@Sirka_U NUMERIC(19,6),
@Vyska_U NUMERIC(19,6),
@Hloubka_U NUMERIC(19,6),
@Objem_U NUMERIC(19,6),
@Hmotnost_U NUMERIC(19,6),
@IdSortiment_U NVARCHAR(54),
@Vyrobce_U INT,
@VychoziMnozstvi_U NUMERIC(19,6),
@PrepMnozstvi_U NUMERIC(19,6),
@SazbaDPHVstup_U NUMERIC(5,2),
@SazbaDPHVystup_U NUMERIC(5,2),
@CelniNomenklatura_U NVARCHAR(8),
@DopKod_U NVARCHAR(2),
@ObvyklaZemePuvodu_U NVARCHAR(2),
@KontrolaVyrC_U NCHAR(1),
@Blokovano_U TINYINT,
@Minimum_Baleni_Dodavatel_U NUMERIC(19,6),
@VykazLihuObjemVML_U NUMERIC(19,6),
@VykazLihuProcentoLihu_U NUMERIC(5,2),
@VykazLihuKoefKEvidMJ_U NUMERIC(19,6),
@Upozorneni_U NVARCHAR(255),
@KodZbozi_U NVARCHAR(20),
@LhutaNaskladneni_U INT,
@Poznamka_U NVARCHAR(MAX),
@UKod_U INT,
@CisloUcetPrijem_U NVARCHAR(30),
@CisloUcetVydej_U NVARCHAR(30),
@CisloUcetVydejEC_U NVARCHAR(30),
@CisloUcetFAPrij_U NVARCHAR(30),
@CisloUcetFAVyd_U NVARCHAR(30),
@Sleva_U NUMERIC(5,2),
@KodRecyk_U NVARCHAR(20), @CastkaHistRecyk_U NUMERIC(19,6), @CastkaGarRecyk_U NUMERIC(19,6), @MJRecyk_U NVARCHAR(10), @PrepMJRecyk_U NUMERIC(19,6),
@ZboziSluzba_U TINYINT,
@PocetBaleniVeVrstve_U NUMERIC(19,6),
@PocetVrstevNaPalete_U NUMERIC(19,6),
@PLUKod_U NVARCHAR(10),
@BodovaHodnota_U INT,
@Nazev1_B BIT,
@Nazev2_B BIT,
@Nazev3_B BIT,
@Nazev4_B BIT,
@Poznamka_B BIT,
@SKP_B BIT,
@MJEvidence_B BIT,
@MJVstup_B BIT,
@MJVystup_B BIT,
@MJInventura_B BIT,
@KJDatOd_B BIT,
@KJDatDo_B BIT,
@Vykres_B BIT,
@ZarukaVstup_B BIT,
@TypZarukaVstup_B BIT,
@ZarukaVystup_B BIT,
@TypZarukaVystup_B BIT,
@DodaciLhuta_B BIT,
@TypDodaciLhuty_B BIT,
@BaleniTXT_B BIT,
@Aktualni_Dodavatel_B BIT,
@Minimum_Dodavatel_B BIT,
@Minimum_Odberatel_B BIT,
@Sirka_B BIT,
@Vyska_B BIT,
@Hloubka_B BIT,
@Objem_B BIT,
@Hmotnost_B BIT,
@IdSortiment_B BIT,
@Vyrobce_B BIT,
@KontrolaVyrC_B BIT,
@VychoziMnozstvi_B BIT,
@PrepMnozstvi_B BIT,
@SazbaDPHVstup_B BIT,
@SazbaDPHVystup_B BIT,
@CelniNomenklatura_B BIT,
@DopKod_B BIT,
@ObvyklaZemePuvodu_B BIT,
@Blokovano_B BIT,
@Minimum_Baleni_Dodavatel_B BIT,
@VykazLihuObjemVML_B BIT,
@VykazLihuProcentoLihu_B BIT,
@VykazLihuKoefKEvidMJ_B BIT,
@Upozorneni_B BIT,
@KodZbozi_B BIT,
@LhutaNaskladneni_B BIT,
@UKod_B BIT,
@CisloUcetPrijem_B BIT,
@CisloUcetVydej_B BIT,
@CisloUcetVydejEC_B BIT,
@CisloUcetFAPrij_B BIT,
@CisloUcetFAVyd_B BIT,
@Sleva_B BIT,
@KodRecyk_B BIT, @CastkaHistRecyk_B BIT, @CastkaGarRecyk_B BIT, @MJRecyk_B BIT, @PrepMJRecyk_B BIT,
@ZboziSluzba_B BIT,
@PocetBaleniVeVrstve_B BIT,
@PocetVrstevNaPalete_B BIT,
@PLUKod_B BIT,
@BodovaHodnota_B BIT,
@DoplnkovyKod_B BIT,
@ExtAtr1_B BIT,
@ExtAtr2_B BIT,
@ExtAtr3_B BIT,
@ExtAtr4_B BIT,
@ExtAtr5_B BIT,
@ExtAtr6_B BIT,
@ExtAtr7_B BIT,
@ExtAtr8_B BIT,
@ExtAtr9_B BIT
DECLARE c CURSOR LOCAL FAST_FORWARD FOR
/*PRI PRIDANI NOVE VERZE IMPORTU PRIDAT NOVE PROMENNE I SEM*/
SELECT ID, InterniVerze, SkupZbo, RegCis, DruhSkladu, Nazev1, Nazev2, Nazev3, Nazev4, SKP, MJEvidence, MJvstup,
MJvystup, MJInventura, KJDatOd, KJDatDo, Vykres, ZarukaVstup, TypZarukaVstup, ZarukaVystup, TypZarukaVystup,
DodaciLhuta, TypDodaciLhuty, BaleniTXT, Aktualni_Dodavatel, Minimum_Dodavatel, Minimum_Odberatel,
Sirka, Vyska, Hloubka, Objem, Hmotnost, IdSortiment, Vyrobce, VychoziMnozstvi, PrepMnozstvi,
SazbaDPHVstup, SazbaDPHVystup, CelniNomenklatura, DopKod, ObvyklaZemePuvodu, BarCode, ExtAtr1, ExtAtr1Nazev, ExtAtr2,
ExtAtr2Nazev, ExtAtr3, ExtAtr3Nazev, ExtAtr4, ExtAtr4Nazev,
ExtAtr5, ExtAtr5Nazev, ExtAtr6, ExtAtr6Nazev, ExtAtr7, ExtAtr7Nazev, ExtAtr8, ExtAtr8Nazev, ExtAtr9, ExtAtr9Nazev,
CASE KontrolaVyrC WHEN '0' THEN 'N' WHEN '1' THEN 'A' ELSE KontrolaVyrC END,
Blokovano, Minimum_Baleni_Dodavatel, VykazLihuObjemVML, VykazLihuProcentoLihu, VykazLihuKoefKEvidMJ, Upozorneni, KodZbozi, LhutaNaskladneni, Poznamka,
UKod, CisloUcetPrijem, CisloUcetVydej, CisloUcetVydejEC, CisloUcetFAPrij, CisloUcetFAVyd, Sleva, KodRecyk, CastkaHistRecyk, CastkaGarRecyk, MJRecyk, PrepMJRecyk,
ZboziSluzba, PocetBaleniVeVrstve, PocetVrstevNaPalete, PLUKod, BodovaHodnota, DoplnkovyKod
FROM dbo.TabUniImportKmen
WHERE Chyba IS NULL
 AND ((@PouzeZaznamyDleLogin=1 AND Autor=SUSER_SNAME())OR(@PouzeZaznamyDleLogin=0)) 
OPEN c
/*PRI PRIDANI NOVE VERZE IMPORTU PRIDAT NOVE PROMENNE I SEM*/
FETCH NEXT FROM c INTO @ID, @InterniVerze, @SkupZbo, @RegCis, @DruhSkladu, @Nazev1, @Nazev2, @Nazev3, @Nazev4, @SKP, @MJEvidence,
@MJvstup, @MJvystup, @MJInventura, @KJDatOd, @KJDatDo, @Vykres, @ZarukaVstup, @TypZarukaVstup, @ZarukaVystup,
@TypZarukaVystup, @DodaciLhuta, @TypDodaciLhuty, @BaleniTXT, @Aktualni_Dodavatel,
@Minimum_Dodavatel, @Minimum_Odberatel, @Sirka, @Vyska, @Hloubka, @Objem, @Hmotnost,
@IdSortiment, @Vyrobce, @VychoziMnozstvi, @PrepMnozstvi, @SazbaDPHVstup, @SazbaDPHVystup,
@CelniNomenklatura, @DopKod, @ObvyklaZemePuvodu, @BarCode, @ExtAtr1, @ExtAtr1Nazev, @ExtAtr2, @ExtAtr2Nazev, @ExtAtr3,
@ExtAtr3Nazev, @ExtAtr4, @ExtAtr4Nazev,
@ExtAtr5, @ExtAtr5Nazev, @ExtAtr6, @ExtAtr6Nazev, @ExtAtr7, @ExtAtr7Nazev, @ExtAtr8, @ExtAtr8Nazev, @ExtAtr9, @ExtAtr9Nazev,
@KontrolaVyrC, @Blokovano, @Minimum_Baleni_Dodavatel, @VykazLihuObjemVML, @VykazLihuProcentoLihu, @VykazLihuKoefKEvidMJ, @Upozorneni, @KodZbozi, @LhutaNaskladneni,
@Poznamka, @UKod,
@CisloUcetPrijem, @CisloUcetVydej, @CisloUcetVydejEC, @CisloUcetFAPrij, @CisloUcetFAVyd, @Sleva,
@KodRecyk, @CastkaHistRecyk, @CastkaGarRecyk, @MJRecyk, @PrepMJRecyk, @ZboziSluzba, @PocetBaleniVeVrstve, @PocetVrstevNaPalete,
@PLUKod, @BodovaHodnota, @DoplnkovyKod
WHILE 1=1
BEGIN
BEGIN TRY
SET @ChybaPriImportu=0
SET @TextChybyImportu=''
SET @IDKmen=NULL
/*VERZE IMPORTU C.1----------------------------------------------------------------------------------------------------------*/
IF @InterniVerze=1
BEGIN
/*--existuje uz karta? pokud ano, chyba a konec*/
IF LEN(@SkupZbo)=1 SET @SkupZbo=N'00' + @SkupZbo
IF LEN(@SkupZbo)=2 SET @SkupZbo=N'0'  + @SkupZbo
IF @RegCis IS NULL
BEGIN
IF EXISTS(SELECT * FROM TabSkupinyZbozi WHERE SkupZbo = @SkupZbo AND Cislovat = 1)
  EXEC dbo.hp_OZ_RegCislo_Autocislovanim @SkupZbo, @RegCis OUTPUT, @AutoCislovani OUTPUT, 1
IF @RegCis IS NULL
BEGIN
  SET @ChybaPriImportu=1
  UPDATE dbo.TabUniImportKmen SET Chyba=dbo.hpf_UniImportHlasky('5AA30F8F-978D-4BD5-AA8B-D07057203168', @JazykVerze, @SkupZbo, DEFAULT, DEFAULT, DEFAULT), DatumImportu=GETDATE() WHERE ID=@ID
END
END
ELSE
BEGIN
SET @Nuly=''
SELECT @DelkaReg=DelkaRegCislaZbozi, @Zarovnani=ZarovnaniRegCislaZbozi FROM TabHGlob
IF LEN(@RegCis)>@DelkaReg
BEGIN
  SET @ChybaPriImportu=1
  UPDATE dbo.TabUniImportKmen SET Chyba=dbo.hpf_UniImportHlasky('0B22315C-C48D-48F3-9E30-153AA961CECD', @JazykVerze, @SkupZbo, @RegCis, DEFAULT, DEFAULT), DatumImportu=GETDATE() WHERE ID=@ID
END
ELSE
BEGIN
SET @I = @DelkaReg - LEN(@RegCis)
WHILE @I >= 1
BEGIN
  SET @Nuly = @Nuly + '0'
  SET @I = @I - 1
END
IF @Zarovnani=2 SET @RegCis = @Nuly + @RegCis
  ELSE IF @Zarovnani=3 SET @RegCis = @RegCis + @Nuly
END
END
IF @ChybaPriImportu=0
BEGIN
IF EXISTS(SELECT ID FROM TabKmenZbozi WHERE SkupZbo=@SkupZbo AND RegCis=@RegCis)
BEGIN
  UPDATE dbo.TabUniImportKmen SET Chyba=dbo.hpf_UniImportHlasky('60FD0E28-01E7-4FB6-B271-0392C433D3EE', @JazykVerze, @SkupZbo, @RegCis, DEFAULT, DEFAULT), DatumImportu=GETDATE() WHERE ID=@ID
END
ELSE
BEGIN
BEGIN TRAN T1
/*insertujeme zakladni udaje karty bez navaznych udaju*/
/*existuje skupina zbozi?*/
IF NOT EXISTS(SELECT ID FROM TabSkupinyZbozi WHERE SkupZbo=@SkupZbo)
BEGIN
INSERT TabSkupinyZbozi(SkupZbo) VALUES(@SkupZbo)
END
IF @DruhSkladu IS NULL SET @DruhSkladu=1
IF @ChybaPriImportu=0
INSERT TabKmenZbozi(DruhSkladu, SkupZbo, RegCis, Nazev1, Nazev2, Nazev3, Nazev4, SKP, KJDatOd, KJDatDo, Vykres, BaleniTXT, DopKod, ObvyklaZemePuvodu, KontrolaVyrC, Blokovano, Minimum_Baleni_Dodavatel,
VykazLihuObjemVML, VykazLihuProcentoLihu, VykazLihuKoefKEvidMJ, Upozorneni, LhutaNaskladneni, Poznamka, Sleva, ZboziSluzba, PocetBaleniVeVrstve, PocetVrstevNaPalete, PLUKod, BodovaHodnota)
VALUES(@DruhSkladu, @SkupZbo, @RegCis, ISNULL(@Nazev1, ''), ISNULL(@Nazev2, ''), ISNULL(@Nazev3, ''), ISNULL(@Nazev4, ''),
ISNULL(@SKP, ''), @KJDatOd, @KJDatDo, @Vykres, ISNULL(@BaleniTXT, ''), ISNULL(@DopKod, ''), @ObvyklaZemePuvodu, @KontrolaVyrC,
@Blokovano, @Minimum_Baleni_Dodavatel, @VykazLihuObjemVML, @VykazLihuProcentoLihu, @VykazLihuKoefKEvidMJ, ISNULL(@Upozorneni, ''), @LhutaNaskladneni, @Poznamka, ISNULL(@Sleva, 0),
ISNULL(@ZboziSluzba, 0), ISNULL(@PocetBaleniVeVrstve, 0), ISNULL(@PocetVrstevNaPalete, 0), ISNULL(@PLUKod, ''), ISNULL(@BodovaHodnota, 0))
IF @@ERROR<>0 SET @ChybaPriImportu=1
/*dohledani ID kmene, hodi se v dalsi casti importu*/
SET @IDKmen=SCOPE_IDENTITY()
IF ISNULL(@MJRecyk, '')<>'' 
BEGIN
  IF NOT EXISTS(SELECT ID FROM TabMJ WHERE Kod=@MJRecyk)
    INSERT TabMJ(Kod) VALUES(@MJRecyk)
END
IF NOT EXISTS(SELECT * FROM TabKmenZboziDodatek WHERE ID=@IDKmen)
  INSERT TabKmenZboziDodatek(ID) VALUES(@IDKmen)
UPDATE TabKmenZboziDodatek SET
   KodRecyk=@KodRecyk
 , CastkaHistRecyk=@CastkaHistRecyk
 , CastkaGarRecyk=@CastkaGarRecyk
 , MJRecyk=@MJRecyk
 , PrepMJRecyk=@PrepMJRecyk
WHERE ID=@IDKmen
/*MJevidence*/
IF @MJevidence IS NOT NULL
BEGIN
  IF NOT EXISTS(SELECT ID FROM TabMJ WHERE Kod=@MJevidence)
    INSERT TabMJ(Kod) VALUES(@MJevidence)
  UPDATE TabKmenZbozi SET MJEvidence=@MJEvidence WHERE ID=@IDKmen
  IF @@ERROR<>0 SET @ChybaPriImportu=1
END
/*MJvstup*/
IF (@MJvstup IS NOT NULL)AND(@MJevidence IS NOT NULL)
BEGIN
IF @MJVstup=@MJEvidence UPDATE TabKmenZbozi SET MJvstup=@MJvstup WHERE ID=@IDKmen
ELSE
BEGIN
IF dbo.hfx_UniImportKontrolaVztahuMJ(@MJEvidence, @MJVstup, NULL, NULL, @IDKmen) = 1
  UPDATE TabKmenZbozi SET MJvstup=@MJvstup WHERE ID=@IDKmen
ELSE
BEGIN
SET @ChybaPriImportu=1
IF @TextChybyImportu<>'' SET @TextChybyImportu=@TextChybyImportu + ' | '
SET @TextChybyImportu = @TextChybyImportu + dbo.hpf_UniImportHlasky('1E3241C1-0B92-482B-9C6F-1CF47F45AA23', @JazykVerze, @MJvstup, DEFAULT, DEFAULT, DEFAULT)
END
END
END
/*MJvystup*/
IF (@MJvystup IS NOT NULL)AND(@MJevidence IS NOT NULL)
BEGIN
IF @MJVystup=@MJEvidence UPDATE TabKmenZbozi SET MJvystup=@MJvystup WHERE ID=@IDKmen
ELSE
BEGIN
IF dbo.hfx_UniImportKontrolaVztahuMJ(@MJEvidence, NULL, @MJVystup, NULL, @IDKmen) = 1
  UPDATE TabKmenZbozi SET MJvystup=@MJvystup WHERE ID=@IDKmen
ELSE
BEGIN
SET @ChybaPriImportu=1
IF @TextChybyImportu<>'' SET @TextChybyImportu=@TextChybyImportu + ' | '
SET @TextChybyImportu = @TextChybyImportu + dbo.hpf_UniImportHlasky('ACD18CCD-048D-494F-8914-66C4DBD38B40', @JazykVerze, @MJvystup, DEFAULT, DEFAULT, DEFAULT)
END
END
END
IF (@MJInventura IS NOT NULL)AND(@MJevidence IS NOT NULL)
BEGIN
IF @MJInventura=@MJEvidence UPDATE TabKmenZbozi SET MJInventura=@MJInventura WHERE ID=@IDKmen
ELSE
BEGIN
IF dbo.hfx_UniImportKontrolaVztahuMJ(@MJEvidence, NULL, NULL, @MJInventura, @IDKmen) = 1
  UPDATE TabKmenZbozi SET MJInventura=@MJInventura WHERE ID=@IDKmen
ELSE
BEGIN
SET @ChybaPriImportu=1
IF @TextChybyImportu<>'' SET @TextChybyImportu=@TextChybyImportu + ' | '
SET @TextChybyImportu = @TextChybyImportu + dbo.hpf_UniImportHlasky('D756F518-D5C8-4845-B378-93412F2FC605', @JazykVerze, @MJInventura, DEFAULT, DEFAULT, DEFAULT)
END
END
END
IF	   @ZarukaVstup		IS NOT NULL
OR @TypZarukaVstup	IS NOT NULL
OR @ZarukaVystup	IS NOT NULL
OR @TypZarukaVystup	IS NOT NULL
OR @DodaciLhuta		IS NOT NULL
OR @TypDodaciLhuty	IS NOT NULL
UPDATE TabKmenZbozi
SET
ZarukaVstup	=ISNULL(@ZarukaVstup	,ZarukaVstup)
,TypZarukaVstup	=ISNULL(@TypZarukaVstup	,TypZarukaVstup)
,ZarukaVystup	=ISNULL(@ZarukaVystup	,ZarukaVystup)
,TypZarukaVystup=ISNULL(@TypZarukaVystup,TypZarukaVystup)
,DodaciLhuta	=ISNULL(@DodaciLhuta	,DodaciLhuta)
,TypDodaciLhuty	=ISNULL(@TypDodaciLhuty	,TypDodaciLhuty)
WHERE ID=@IDKmen
IF @@ERROR<>0 SET @ChybaPriImportu=1
/*Aktualni dodavatel*/
IF @Aktualni_Dodavatel IS NOT NULL
IF EXISTS(SELECT ID FROM TabCisOrg WHERE CisloOrg=@Aktualni_Dodavatel)
BEGIN
UPDATE TabKmenZbozi SET Aktualni_Dodavatel=@Aktualni_Dodavatel WHERE ID=@IDKmen
IF @@ERROR<>0 SET @ChybaPriImportu=1
END
ELSE
BEGIN
SET @ChybaPriImportu=1
IF @TextChybyImportu<>'' SET @TextChybyImportu=@TextChybyImportu + ' | '
SET @TextChybyImportu = @TextChybyImportu + dbo.hpf_UniImportHlasky('8B0B3077-6061-4544-BFD3-E6DADCC06599', @JazykVerze, CAST(@Aktualni_Dodavatel AS NVARCHAR(10)), DEFAULT, DEFAULT, DEFAULT)
END
/*Vyrobce*/
IF @Vyrobce IS NOT NULL
IF EXISTS(SELECT ID FROM TabCisOrg WHERE CisloOrg=@Vyrobce)
BEGIN
UPDATE TabKmenZbozi SET Vyrobce=@Vyrobce WHERE ID=@IDKmen
IF @@ERROR<>0 SET @ChybaPriImportu=1
END
ELSE
BEGIN
SET @ChybaPriImportu=1
IF @TextChybyImportu<>'' SET @TextChybyImportu=@TextChybyImportu + ' | '
SET @TextChybyImportu = @TextChybyImportu + dbo.hpf_UniImportHlasky('B497DA2F-6958-4357-871C-B95842DE3BE3', @JazykVerze, @Vyrobce, DEFAULT, DEFAULT, DEFAULT)
END
IF	   @Minimum_Dodavatel	IS NOT NULL
OR @Minimum_Odberatel	IS NOT NULL
OR @Sirka				IS NOT NULL
OR @Vyska				IS NOT NULL
OR @Hloubka				IS NOT NULL
OR @Objem				IS NOT NULL
OR @Hmotnost			IS NOT NULL
OR @VychoziMnozstvi		IS NOT NULL
OR @PrepMnozstvi		IS NOT NULL
UPDATE TabKmenZbozi
SET  Minimum_Dodavatel	=ISNULL(@Minimum_Dodavatel	, Minimum_Dodavatel)
,Minimum_Odberatel	=ISNULL(@Minimum_Odberatel	, Minimum_Odberatel)
,Sirka				=ISNULL(@Sirka				, Sirka)
,Vyska				=ISNULL(@Vyska				, Vyska)
,Hloubka			=ISNULL(@Hloubka			, Hloubka)
,Objem				=ISNULL(@Objem				, Objem)
,Hmotnost			=ISNULL(@Hmotnost			, Hmotnost)
,VychoziMnozstvi	=ISNULL(@VychoziMnozstvi	, VychoziMnozstvi)
,PrepMnozstvi		=ISNULL(@PrepMnozstvi		, PrepMnozstvi)
WHERE ID=@IDKmen
IF @@ERROR<>0 SET @ChybaPriImportu=1
/*SazbaDPHVstup*/
IF @SazbaDPHVstup IS NOT NULL
IF dbo.hpf_UniImportExistujeSazbaDPH(@SazbaDPHVstup, NULL) = 1
BEGIN
UPDATE TabKmenZbozi SET SazbaDPHVstup=@SazbaDPHVstup WHERE ID=@IDKmen
IF @@ERROR<>0 SET @ChybaPriImportu=1
END
ELSE
BEGIN
SET @ChybaPriImportu=1
IF @TextChybyImportu<>'' SET @TextChybyImportu=@TextChybyImportu + ' | '
SET @TextChybyImportu = @TextChybyImportu + dbo.hpf_UniImportHlasky('593FB54F-C1E7-48E4-996E-C499F540EF4F', @JazykVerze, CAST(@SazbaDPHVstup AS NVARCHAR(20)), DEFAULT, DEFAULT, DEFAULT)
END
/*SazbaDPHVystup*/
IF @SazbaDPHVystup IS NOT NULL
IF dbo.hpf_UniImportExistujeSazbaDPH(@SazbaDPHVystup, NULL) = 1
BEGIN
UPDATE TabKmenZbozi SET SazbaDPHVystup=@SazbaDPHVystup WHERE ID=@IDKmen
IF @@ERROR<>0 SET @ChybaPriImportu=1
END
ELSE
BEGIN
SET @ChybaPriImportu=1
IF @TextChybyImportu<>'' SET @TextChybyImportu=@TextChybyImportu + ' | '
SET @TextChybyImportu = @TextChybyImportu + dbo.hpf_UniImportHlasky('593FB54F-C1E7-48E4-996E-C499F540EF4F', @JazykVerze, CAST(@SazbaDPHVystup AS NVARCHAR(20)), DEFAULT, DEFAULT, DEFAULT)
END
/*CelniNomenklatura*/
IF @CelniNomenklatura IS NOT NULL UPDATE TabKmenZbozi SET CelniNomenklatura=@CelniNomenklatura WHERE ID=@IDKmen
IF @@ERROR<>0 SET @ChybaPriImportu=1
IF @ChybaPriImportu=0
BEGIN
SET @CLOPopisZbozi=(SELECT TOP 1 ZboziText FROM dbo.TabClaEcit WHERE Nomenklatura=@CelniNomenklatura AND DopKod=ISNULL(@DopKod, '00'))
UPDATE TabKmenZbozi SET CLOPopisZbozi=@CLOPopisZbozi WHERE ID=@IDKmen
END
/*IdSortiment*/
IF @IdSortiment IS NOT NULL
BEGIN
SET @IdSortPom=(SELECT ID FROM TabSortiment WHERE KatAllTecky=@IdSortiment)
IF @IdSortPom IS NOT NULL
BEGIN
UPDATE TabKmenZbozi SET IdSortiment=@IdSortPom WHERE ID=@IDKmen
IF @@ERROR<>0 SET @ChybaPriImportu=1
END
ELSE
BEGIN
SET @ChybaPriImportu=1
IF @TextChybyImportu<>'' SET @TextChybyImportu=@TextChybyImportu + ' | '
SET @TextChybyImportu = @TextChybyImportu + dbo.hpf_UniImportHlasky('FFFFEEC2-6C60-40D1-84D8-854C408A6F4D', @JazykVerze, @IdSortiment, DEFAULT, DEFAULT, DEFAULT)
END
END
/*BarCode*/
IF @BarCode IS NOT NULL
IF @BarCode<>''
BEGIN
IF NOT EXISTS(SELECT * FROM TabBarCodeZbo WHERE BarCode=@BarCode)
  INSERT TabBarCodeZbo(IDKmenZbo, BarCode, DoplnkovyKod) VALUES(@IDKmen, @BarCode, @DoplnkovyKod)
ELSE
BEGIN
SET @ChybaPriImportu=1
IF @TextChybyImportu<>'' SET @TextChybyImportu=@TextChybyImportu + ' | '
SET @TextChybyImportu = @TextChybyImportu + dbo.hpf_UniImportHlasky('BE79245C-ABF2-4A3A-90E6-585C7B00440E', @JazykVerze, @BarCode, DEFAULT, DEFAULT, DEFAULT)
END
END
IF (ISNULL(@KodZbozi, '')<>'')AND(@ChybaPriImportu=0)
BEGIN
SET @IDKodPDP=(SELECT ID FROM TabCisKoduPDP WHERE KodZbozi=@KodZbozi)
IF @IDKodPDP IS NULL
BEGIN
SET @ChybaPriImportu=1
IF @TextChybyImportu<>'' SET @TextChybyImportu=@TextChybyImportu + ' | '
SET @TextChybyImportu = @TextChybyImportu + dbo.hpf_UniImportHlasky('4E6E8339-BE7B-4A8B-8C5A-D82DFFC78849', @JazykVerze, ISNULL(@KodZbozi, ''), DEFAULT, DEFAULT, DEFAULT)
END
ELSE
UPDATE TabKmenZbozi SET IDKodPDP=@IDKodPDP WHERE ID=@IDKmen
END
IF @UKod IS NOT NULL
BEGIN
IF NOT EXISTS(SELECT * FROM TabSkupUKod WHERE ID=@UKod)
BEGIN
SET @ChybaPriImportu=1
IF @TextChybyImportu<>'' SET @TextChybyImportu=@TextChybyImportu + ' | '
SET @TextChybyImportu = @TextChybyImportu + dbo.hpf_UniImportHlasky('A9340307-9957-4D2C-BE6C-4E35F106D06D', @JazykVerze, DEFAULT, DEFAULT, DEFAULT, DEFAULT)
END
ELSE
UPDATE TabKmenZbozi SET UKod=@UKod WHERE ID=@IDKmen
END
IF ISNULL(@CisloUcetPrijem, '')<>'' 
BEGIN
IF NOT EXISTS(SELECT * FROM TabCisUct WHERE CisloUcet=@CisloUcetPrijem)
BEGIN
SET @ChybaPriImportu=1
IF @TextChybyImportu<>'' SET @TextChybyImportu=@TextChybyImportu + ' | '
SET @TextChybyImportu = @TextChybyImportu + dbo.hpf_UniImportHlasky('DDD57F75-B6F7-4647-8D32-6AFB8447E1D7', @JazykVerze, @CisloUcetPrijem, DEFAULT, DEFAULT, DEFAULT)
END
ELSE
UPDATE TabKmenZbozi SET CisloUcetPrijem=@CisloUcetPrijem WHERE ID=@IDKmen
END
IF ISNULL(@CisloUcetVydej, '')<>'' 
BEGIN
IF NOT EXISTS(SELECT * FROM TabCisUct WHERE CisloUcet=@CisloUcetVydej)
BEGIN
SET @ChybaPriImportu=1
IF @TextChybyImportu<>'' SET @TextChybyImportu=@TextChybyImportu + ' | '
SET @TextChybyImportu = @TextChybyImportu + dbo.hpf_UniImportHlasky('DDD57F75-B6F7-4647-8D32-6AFB8447E1D7', @JazykVerze, @CisloUcetVydej, DEFAULT, DEFAULT, DEFAULT)
END
ELSE
UPDATE TabKmenZbozi SET CisloUcetVydej=@CisloUcetVydej WHERE ID=@IDKmen
END
IF ISNULL(@CisloUcetVydejEC, '')<>'' 
BEGIN
IF NOT EXISTS(SELECT * FROM TabCisUct WHERE CisloUcet=@CisloUcetVydejEC)
BEGIN
SET @ChybaPriImportu=1
IF @TextChybyImportu<>'' SET @TextChybyImportu=@TextChybyImportu + ' | '
SET @TextChybyImportu = @TextChybyImportu + dbo.hpf_UniImportHlasky('DDD57F75-B6F7-4647-8D32-6AFB8447E1D7', @JazykVerze, @CisloUcetVydejEC, DEFAULT, DEFAULT, DEFAULT)
END
ELSE
UPDATE TabKmenZbozi SET CisloUcetVydejEC=@CisloUcetVydejEC WHERE ID=@IDKmen
END
IF ISNULL(@CisloUcetFAPrij, '')<>'' 
BEGIN
IF NOT EXISTS(SELECT * FROM TabCisUct WHERE CisloUcet=@CisloUcetFAPrij)
BEGIN
SET @ChybaPriImportu=1
IF @TextChybyImportu<>'' SET @TextChybyImportu=@TextChybyImportu + ' | '
SET @TextChybyImportu = @TextChybyImportu + dbo.hpf_UniImportHlasky('DDD57F75-B6F7-4647-8D32-6AFB8447E1D7', @JazykVerze, @CisloUcetFAPrij, DEFAULT, DEFAULT, DEFAULT)
END
ELSE
UPDATE TabKmenZbozi SET CisloUcetFAPrij=@CisloUcetFAPrij WHERE ID=@IDKmen
END
IF ISNULL(@CisloUcetFAVyd, '')<>'' 
BEGIN
IF NOT EXISTS(SELECT * FROM TabCisUct WHERE CisloUcet=@CisloUcetFAVyd)
BEGIN
SET @ChybaPriImportu=1
IF @TextChybyImportu<>'' SET @TextChybyImportu=@TextChybyImportu + ' | '
SET @TextChybyImportu = @TextChybyImportu + dbo.hpf_UniImportHlasky('DDD57F75-B6F7-4647-8D32-6AFB8447E1D7', @JazykVerze, @CisloUcetFAVyd, DEFAULT, DEFAULT, DEFAULT)
END
ELSE
UPDATE TabKmenZbozi SET CisloUcetFAVyd=@CisloUcetFAVyd WHERE ID=@IDKmen
END
/*externi atributy*/
/*--ex. atrb. 1 - typ NVARCHAR(30)*/
IF (@ExtAtr1 IS NOT NULL)AND(@ExtAtr1Nazev IS NOT NULL)
BEGIN
IF (OBJECT_ID('TabKmenZbozi_EXT','U')IS NOT NULL)AND(COLUMNPROPERTY(OBJECT_ID('TabKmenZbozi_EXT','U'),'_'+@ExtAtr1Nazev,'AllowsNull')IS NOT NULL)
BEGIN
SET @ExtAtr1Nazev='_' + @ExtAtr1Nazev
IF EXISTS(SELECT ID FROM TabKmenZbozi_EXT WHERE ID=@IDKmen)
SET @SQLString='UPDATE TabKmenZbozi_EXT SET ' + @ExtAtr1Nazev + '=N' + '''' + @ExtAtr1 + '''' + ' WHERE ID=' + CAST(@IDKmen AS NVARCHAR(10))
ELSE
SET @SQLString='INSERT TabKmenZbozi_EXT(ID, ' + @ExtAtr1Nazev + ') VALUES(' + CAST(@IDKmen AS NVARCHAR(10)) + ', N' + '''' + @ExtAtr1 + '''' + ')'
EXEC sp_executesql @SQLString
END
ELSE
BEGIN
SET @ChybaPriImportu=1
IF @TextChybyImportu<>'' SET @TextChybyImportu=@TextChybyImportu + ' | '
SET @TextChybyImportu = @TextChybyImportu + dbo.hpf_UniImportHlasky('15364319-B20F-4D65-8900-391DE8D4C52F', @JazykVerze, '_'+@ExtAtr1Nazev, DEFAULT, DEFAULT, DEFAULT)
END
END
/*--ex. atrb. 2 - typ NVARCHAR(255)*/
IF (@ExtAtr2 IS NOT NULL)AND(@ExtAtr2Nazev IS NOT NULL)
IF (OBJECT_ID('TabKmenZbozi_EXT','U')IS NOT NULL)AND(COLUMNPROPERTY(OBJECT_ID('TabKmenZbozi_EXT','U'),'_'+@ExtAtr2Nazev,'AllowsNull')IS NOT NULL)
BEGIN
SET @ExtAtr2Nazev='_' + @ExtAtr2Nazev
IF EXISTS(SELECT ID FROM TabKmenZbozi_EXT WHERE ID=@IDKmen)
SET @SQLString='UPDATE TabKmenZbozi_EXT SET ' + @ExtAtr2Nazev + '=N' + '''' + @ExtAtr2 + '''' + ' WHERE ID=' + CAST(@IDKmen AS NVARCHAR(10))
ELSE
SET @SQLString='INSERT TabKmenZbozi_EXT(ID, ' + @ExtAtr2Nazev + ') VALUES(' + CAST(@IDKmen AS NVARCHAR(10)) + ', N' + '''' + @ExtAtr2 + '''' + ')'
EXECUTE sp_executesql @SQLString
END
ELSE
BEGIN
SET @ChybaPriImportu=1
IF @TextChybyImportu<>'' SET @TextChybyImportu=@TextChybyImportu + ' | '
SET @TextChybyImportu = @TextChybyImportu + dbo.hpf_UniImportHlasky('15364319-B20F-4D65-8900-391DE8D4C52F', @JazykVerze, '_'+@ExtAtr2Nazev, DEFAULT, DEFAULT, DEFAULT)
END
/*--ex. atrb. 3 - typ DATETIME*/
IF (@ExtAtr3 IS NOT NULL)AND(@ExtAtr3Nazev IS NOT NULL)
IF (OBJECT_ID('TabKmenZbozi_EXT','U')IS NOT NULL)AND(COLUMNPROPERTY(OBJECT_ID('TabKmenZbozi_EXT','U'),'_'+@ExtAtr3Nazev,'AllowsNull')IS NOT NULL)
BEGIN
SET @ExtAtr3Nazev='_' + @ExtAtr3Nazev
IF EXISTS(SELECT ID FROM TabKmenZbozi_EXT WHERE ID=@IDKmen)
SET @SQLString='UPDATE TabKmenZbozi_EXT SET ' + @ExtAtr3Nazev + '=' + '''' + CONVERT(NVARCHAR(10),@ExtAtr3, 112) + '''' + ' WHERE ID=' + CAST(@IDKmen AS NVARCHAR(10))
ELSE
SET @SQLString='INSERT TabKmenZbozi_EXT(ID, ' + @ExtAtr3Nazev + ') VALUES(' + CAST(@IDKmen AS NVARCHAR(10)) + ', ' + '''' + CONVERT(NVARCHAR(10),@ExtAtr3, 112) + '''' + ')'
EXECUTE sp_executesql @SQLString
END
ELSE
BEGIN
SET @ChybaPriImportu=1
IF @TextChybyImportu<>'' SET @TextChybyImportu=@TextChybyImportu + ' | '
SET @TextChybyImportu = @TextChybyImportu + dbo.hpf_UniImportHlasky('15364319-B20F-4D65-8900-391DE8D4C52F', @JazykVerze, '_'+@ExtAtr3Nazev, DEFAULT, DEFAULT, DEFAULT)
END
/*--ex. atrb. 4 - typ NUMERIC*/
IF (@ExtAtr4 IS NOT NULL)AND(@ExtAtr4Nazev IS NOT NULL)
IF (OBJECT_ID('TabKmenZbozi_EXT','U')IS NOT NULL)AND(COLUMNPROPERTY(OBJECT_ID('TabKmenZbozi_EXT','U'),'_'+@ExtAtr4Nazev,'AllowsNull')IS NOT NULL)
BEGIN
SET @ExtAtr4Nazev='_' + @ExtAtr4Nazev
IF EXISTS(SELECT ID FROM TabKmenZbozi_EXT WHERE ID=@IDKmen)
SET @SQLString='UPDATE TabKmenZbozi_EXT SET ' + @ExtAtr4Nazev + '=' + CAST(@ExtAtr4 AS NVARCHAR(26)) +  ' WHERE ID=' + CAST(@IDKmen AS NVARCHAR(10))
ELSE
SET @SQLString='INSERT TabKmenZbozi_EXT(ID, ' + @ExtAtr4Nazev + ') VALUES(' + CAST(@IDKmen AS NVARCHAR(10)) + ', ' + CAST(@ExtAtr4 AS NVARCHAR(26)) + ')'
EXECUTE sp_executesql @SQLString
END
ELSE
BEGIN
SET @ChybaPriImportu=1
IF @TextChybyImportu<>'' SET @TextChybyImportu=@TextChybyImportu + ' | '
SET @TextChybyImportu = @TextChybyImportu + dbo.hpf_UniImportHlasky('15364319-B20F-4D65-8900-391DE8D4C52F', @JazykVerze, '_'+@ExtAtr4Nazev, DEFAULT, DEFAULT, DEFAULT)
END
/*--ex. atrb. 5 - typ NVARCHAR(255)*/
IF (@ExtAtr5 IS NOT NULL)AND(@ExtAtr5Nazev IS NOT NULL)
IF (OBJECT_ID('TabKmenZbozi_EXT','U')IS NOT NULL)AND(COLUMNPROPERTY(OBJECT_ID('TabKmenZbozi_EXT','U'),'_'+@ExtAtr5Nazev,'AllowsNull')IS NOT NULL)
BEGIN
SET @ExtAtr5Nazev='_' + @ExtAtr5Nazev
IF EXISTS(SELECT ID FROM TabKmenZbozi_EXT WHERE ID=@IDKmen)
SET @SQLString='UPDATE TabKmenZbozi_EXT SET ' + @ExtAtr5Nazev + '=N' + '''' + @ExtAtr5 + '''' + ' WHERE ID=' + CAST(@IDKmen AS NVARCHAR(10))
ELSE
SET @SQLString='INSERT TabKmenZbozi_EXT(ID, ' + @ExtAtr5Nazev + ') VALUES(' + CAST(@IDKmen AS NVARCHAR(10)) + ', N' + '''' + @ExtAtr5 + '''' + ')'
EXECUTE sp_executesql @SQLString
END
ELSE
BEGIN
SET @ChybaPriImportu=1
IF @TextChybyImportu<>'' SET @TextChybyImportu=@TextChybyImportu + ' | '
SET @TextChybyImportu = @TextChybyImportu + dbo.hpf_UniImportHlasky('15364319-B20F-4D65-8900-391DE8D4C52F', @JazykVerze, '_'+@ExtAtr5Nazev, DEFAULT, DEFAULT, DEFAULT)
END
/*--ex. atrb. 6 - typ NVARCHAR(255)*/
IF (@ExtAtr6 IS NOT NULL)AND(@ExtAtr6Nazev IS NOT NULL)
IF (OBJECT_ID('TabKmenZbozi_EXT','U')IS NOT NULL)AND(COLUMNPROPERTY(OBJECT_ID('TabKmenZbozi_EXT','U'),'_'+@ExtAtr6Nazev,'AllowsNull')IS NOT NULL)
BEGIN
SET @ExtAtr6Nazev='_' + @ExtAtr6Nazev
IF EXISTS(SELECT ID FROM TabKmenZbozi_EXT WHERE ID=@IDKmen)
SET @SQLString='UPDATE TabKmenZbozi_EXT SET ' + @ExtAtr6Nazev + '=N' + '''' + @ExtAtr6 + '''' + ' WHERE ID=' + CAST(@IDKmen AS NVARCHAR(10))
ELSE
SET @SQLString='INSERT TabKmenZbozi_EXT(ID, ' + @ExtAtr6Nazev + ') VALUES(' + CAST(@IDKmen AS NVARCHAR(10)) + ', N' + '''' + @ExtAtr6 + '''' + ')'
EXECUTE sp_executesql @SQLString
END
ELSE
BEGIN
SET @ChybaPriImportu=1
IF @TextChybyImportu<>'' SET @TextChybyImportu=@TextChybyImportu + ' | '
SET @TextChybyImportu = @TextChybyImportu + dbo.hpf_UniImportHlasky('15364319-B20F-4D65-8900-391DE8D4C52F', @JazykVerze, '_'+@ExtAtr6Nazev, DEFAULT, DEFAULT, DEFAULT)
END
/*--ex. atrb. 7 - typ NVARCHAR(255)*/
IF (@ExtAtr7 IS NOT NULL)AND(@ExtAtr7Nazev IS NOT NULL)
IF (OBJECT_ID('TabKmenZbozi_EXT','U')IS NOT NULL)AND(COLUMNPROPERTY(OBJECT_ID('TabKmenZbozi_EXT','U'),'_'+@ExtAtr7Nazev,'AllowsNull')IS NOT NULL)
BEGIN
SET @ExtAtr7Nazev='_' + @ExtAtr7Nazev
IF EXISTS(SELECT ID FROM TabKmenZbozi_EXT WHERE ID=@IDKmen)
SET @SQLString='UPDATE TabKmenZbozi_EXT SET ' + @ExtAtr7Nazev + '=N' + '''' + @ExtAtr7 + '''' + ' WHERE ID=' + CAST(@IDKmen AS NVARCHAR(10))
ELSE
SET @SQLString='INSERT TabKmenZbozi_EXT(ID, ' + @ExtAtr7Nazev + ') VALUES(' + CAST(@IDKmen AS NVARCHAR(10)) + ', N' + '''' + @ExtAtr7 + '''' + ')'
EXECUTE sp_executesql @SQLString
END
ELSE
BEGIN
SET @ChybaPriImportu=1
IF @TextChybyImportu<>'' SET @TextChybyImportu=@TextChybyImportu + ' | '
SET @TextChybyImportu = @TextChybyImportu + dbo.hpf_UniImportHlasky('15364319-B20F-4D65-8900-391DE8D4C52F', @JazykVerze, '_'+@ExtAtr7Nazev, DEFAULT, DEFAULT, DEFAULT)
END
/*--ex. atrb. 8 - typ NVARCHAR(255)*/
IF (@ExtAtr8 IS NOT NULL)AND(@ExtAtr8Nazev IS NOT NULL)
IF (OBJECT_ID('TabKmenZbozi_EXT','U')IS NOT NULL)AND(COLUMNPROPERTY(OBJECT_ID('TabKmenZbozi_EXT','U'),'_'+@ExtAtr8Nazev,'AllowsNull')IS NOT NULL)
BEGIN
SET @ExtAtr8Nazev='_' + @ExtAtr8Nazev
IF EXISTS(SELECT ID FROM TabKmenZbozi_EXT WHERE ID=@IDKmen)
SET @SQLString='UPDATE TabKmenZbozi_EXT SET ' + @ExtAtr8Nazev + '=N' + '''' + @ExtAtr8 + '''' + ' WHERE ID=' + CAST(@IDKmen AS NVARCHAR(10))
ELSE
SET @SQLString='INSERT TabKmenZbozi_EXT(ID, ' + @ExtAtr8Nazev + ') VALUES(' + CAST(@IDKmen AS NVARCHAR(10)) + ', N' + '''' + @ExtAtr8 + '''' + ')'
EXECUTE sp_executesql @SQLString
END
ELSE
BEGIN
SET @ChybaPriImportu=1
IF @TextChybyImportu<>'' SET @TextChybyImportu=@TextChybyImportu + ' | '
SET @TextChybyImportu = @TextChybyImportu + dbo.hpf_UniImportHlasky('15364319-B20F-4D65-8900-391DE8D4C52F', @JazykVerze, '_'+@ExtAtr8Nazev, DEFAULT, DEFAULT, DEFAULT)
END
IF (@ExtAtr9 IS NOT NULL)AND(@ExtAtr9Nazev IS NOT NULL)
IF (OBJECT_ID('TabKmenZbozi_EXT','U')IS NOT NULL)AND(COLUMNPROPERTY(OBJECT_ID('TabKmenZbozi_EXT','U'),'_'+@ExtAtr9Nazev,'AllowsNull')IS NOT NULL)
BEGIN
SET @ExtAtr9Nazev='_' + @ExtAtr9Nazev
IF EXISTS(SELECT ID FROM TabKmenZbozi_EXT WHERE ID=@IDKmen)
SET @SQLString='UPDATE TabKmenZbozi_EXT SET ' + @ExtAtr9Nazev + '=' + CAST(@ExtAtr9 AS NVARCHAR) + ' WHERE ID=' + CAST(@IDKmen AS NVARCHAR(10))
ELSE
SET @SQLString='INSERT TabKmenZbozi_EXT(ID, ' + @ExtAtr9Nazev + ') VALUES(' + CAST(@IDKmen AS NVARCHAR(10)) + ', ' + CAST(@ExtAtr9 AS NVARCHAR) + ')'
EXECUTE sp_executesql @SQLString
END
ELSE
BEGIN
SET @ChybaPriImportu=1
IF @TextChybyImportu<>'' SET @TextChybyImportu=@TextChybyImportu + ' | '
SET @TextChybyImportu = @TextChybyImportu + dbo.hpf_UniImportHlasky('15364319-B20F-4D65-8900-391DE8D4C52F', @JazykVerze, '_'+@ExtAtr9Nazev, DEFAULT, DEFAULT, DEFAULT)
END
SET @ChybaExtAtr=''
EXEC dbo.hpx_UniImport_ZpracujExtAtr
  @ImportIdent=4,
  @IdImpTable=@ID,
  @IdTargetTable=@IDKmen,
  @Chyba=@ChybaExtAtr OUT
IF @ChybaExtAtr<>''
BEGIN
  SET @ChybaPriImportu=1
  IF @TextChybyImportu<>'' SET @TextChybyImportu=@TextChybyImportu + ' | '
  SET @TextChybyImportu = @TextChybyImportu + dbo.hpf_UniImportHlasky('15364319-B20F-4D65-8900-391DE8D4C52F', @JazykVerze, @ChybaExtAtr, DEFAULT, DEFAULT, DEFAULT)
END
IF OBJECT_ID('dbo.epx_UniImportKmen03', 'P') IS NOT NULL EXEC dbo.epx_UniImportKmen03 @IDKmen
/*--pokud nedoslo k chybe, smazeme zaznam z importni tabulky*/
IF @@ERROR<>0 SET @ChybaPriImportu=1
IF @ChybaPriImportu=0 DELETE FROM dbo.TabUniImportKmen WHERE ID=@ID
/*--pokud probehlo vsechno OK, pustime transakci, jinak vse vratime zpet*/
IF @ChybaPriImportu=1
BEGIN
IF @@trancount>0 ROLLBACK TRAN T1
UPDATE dbo.TabUniImportKmen SET Chyba=@TextChybyImportu, DatumImportu=GETDATE() WHERE ID=@ID
END
ELSE IF @@trancount>0 COMMIT TRAN T1
END
END
END
/*--VERZE IMPORTU C.1------------------------------------------------------------------------------------------------------------*/
IF @InterniVerze=2
BEGIN
/*doplneni nul do registracniho cisla dle globalni konfigurace*/
SET @Nuly=''
SELECT @DelkaReg=DelkaRegCislaZbozi, @Zarovnani=ZarovnaniRegCislaZbozi FROM TabHGlob
IF LEN(@RegCis)>@DelkaReg
BEGIN
SET @ChybaPriImportu=1
UPDATE dbo.TabUniImportKmen SET Chyba=dbo.hpf_UniImportHlasky('0B22315C-C48D-48F3-9E30-153AA961CECD', @JazykVerze, @SkupZbo, @RegCis, DEFAULT, DEFAULT), DatumImportu=GETDATE() WHERE ID=@ID
END
IF @ChybaPriImportu=0
BEGIN
SET @I = @DelkaReg - LEN(@RegCis)
WHILE @I >= 1
BEGIN
  SET @Nuly = @Nuly + '0'
  SET @I = @I - 1
END
IF @Zarovnani=2 SET @RegCis = @Nuly + @RegCis
  ELSE IF @Zarovnani=3 SET @RegCis = @RegCis + @Nuly
END
IF LEN(@SkupZbo)=1 SET @SkupZbo=N'00' + @SkupZbo
IF LEN(@SkupZbo)=2 SET @SkupZbo=N'0'  + @SkupZbo
IF @ChybaPriImportu=0
BEGIN
IF NOT EXISTS(SELECT ID FROM TabKmenZbozi WHERE SkupZbo=@SkupZbo AND RegCis=@RegCis)
BEGIN
BEGIN TRAN T1
/*insertujeme zakladni udaje karty bez navaznych udaju*/
/*existuje skupina zbozi?*/
IF NOT EXISTS(SELECT ID FROM TabSkupinyZbozi WHERE SkupZbo=@SkupZbo)
INSERT TabSkupinyZbozi(SkupZbo) VALUES(@SkupZbo)
IF @RegCis IS NULL
BEGIN
IF EXISTS(SELECT * FROM TabSkupinyZbozi WHERE SkupZbo = @SkupZbo AND Cislovat = 1)
  EXEC dbo.hp_OZ_RegCislo_Autocislovanim @SkupZbo, @RegCis OUTPUT, @AutoCislovani OUTPUT, 1
IF @RegCis IS NULL
BEGIN
  SET @ChybaPriImportu=1
  UPDATE dbo.TabUniImportKmen SET Chyba=dbo.hpf_UniImportHlasky('5AA30F8F-978D-4BD5-AA8B-D07057203168', @JazykVerze, @SkupZbo, DEFAULT, DEFAULT, DEFAULT), DatumImportu=GETDATE() WHERE ID=@ID
END
END
IF @DruhSkladu IS NULL SET @DruhSkladu=1
SET @CLOPopisZbozi=(SELECT TOP 1 ZboziText FROM dbo.TabClaEcit WHERE Nomenklatura=@CelniNomenklatura AND DopKod=ISNULL(@DopKod, '00'))
IF @ChybaPriImportu=0
INSERT TabKmenZbozi(DruhSkladu, SkupZbo, RegCis, Nazev1, Nazev2, Nazev3, Nazev4, SKP, KJDatOd, KJDatDo, Vykres, BaleniTXT, DopKod, ObvyklaZemePuvodu, KontrolaVyrC, Blokovano, Minimum_Baleni_Dodavatel,
VykazLihuObjemVML, VykazLihuProcentoLihu, VykazLihuKoefKEvidMJ, Upozorneni, CLOPopisZbozi, LhutaNaskladneni, Poznamka, Sleva, ZboziSluzba, PocetBaleniVeVrstve, PocetVrstevNaPalete, PLUKod, BodovaHodnota)
VALUES(@DruhSkladu, @SkupZbo, @RegCis, ISNULL(@Nazev1, ''), ISNULL(@Nazev2, ''), ISNULL(@Nazev3, ''), ISNULL(@Nazev4, ''),
ISNULL(@SKP, ''), @KJDatOd, @KJDatDo, @Vykres, ISNULL(@BaleniTXT, ''), ISNULL(@DopKod, ''), @ObvyklaZemePuvodu, @KontrolaVyrC,
@Blokovano, @Minimum_Baleni_Dodavatel, @VykazLihuObjemVML, @VykazLihuProcentoLihu, @VykazLihuKoefKEvidMJ, ISNULL(@Upozorneni, ''), @CLOPopisZbozi, @LhutaNaskladneni, @Poznamka, ISNULL(@Sleva, 0),
ISNULL(@ZboziSluzba, 0), ISNULL(@PocetBaleniVeVrstve, 0), ISNULL(@PocetVrstevNaPalete, 0), ISNULL(@PLUKod, ''), ISNULL(@BodovaHodnota, 0))
IF @@ERROR<>0 SET @ChybaPriImportu=1
/*dohledani ID kmene, hodi se v dalsi casti importu*/
SET @IDKmen=SCOPE_IDENTITY()
IF ISNULL(@MJRecyk, '')<>'' 
BEGIN
  IF NOT EXISTS(SELECT ID FROM TabMJ WHERE Kod=@MJRecyk)
    INSERT TabMJ(Kod) VALUES(@MJRecyk)
END
IF NOT EXISTS(SELECT * FROM TabKmenZboziDodatek WHERE ID=@IDKmen)
  INSERT TabKmenZboziDodatek(ID) VALUES(@IDKmen)
UPDATE TabKmenZboziDodatek SET
   KodRecyk=@KodRecyk
 , CastkaHistRecyk=@CastkaHistRecyk
 , CastkaGarRecyk=@CastkaGarRecyk
 , MJRecyk=@MJRecyk
 , PrepMJRecyk=@PrepMJRecyk
WHERE ID=@IDKmen
/*MJevidence*/
IF @MJevidence IS NOT NULL
BEGIN
  IF NOT EXISTS(SELECT ID FROM TabMJ WHERE Kod=@MJevidence)
    INSERT TabMJ(Kod) VALUES(@MJevidence)
  UPDATE TabKmenZbozi SET MJEvidence=@MJEvidence WHERE ID=@IDKmen
  IF @@ERROR<>0 SET @ChybaPriImportu=1
END
/*MJvstup*/
IF (@MJvstup IS NOT NULL)AND(@MJevidence IS NOT NULL)
BEGIN
IF @MJVstup=@MJEvidence UPDATE TabKmenZbozi SET MJvstup=@MJvstup WHERE ID=@IDKmen
ELSE
BEGIN
IF dbo.hfx_UniImportKontrolaVztahuMJ(@MJEvidence, @MJVstup, NULL, NULL, @IDKmen) = 1
  UPDATE TabKmenZbozi SET MJvstup=@MJvstup WHERE ID=@IDKmen
ELSE
BEGIN
SET @ChybaPriImportu=1
IF @TextChybyImportu<>'' SET @TextChybyImportu=@TextChybyImportu + ' | '
SET @TextChybyImportu = @TextChybyImportu + dbo.hpf_UniImportHlasky('1E3241C1-0B92-482B-9C6F-1CF47F45AA23', @JazykVerze, @MJvstup, DEFAULT, DEFAULT, DEFAULT)
END
END
END
/*MJvystup*/
IF (@MJvystup IS NOT NULL)AND(@MJevidence IS NOT NULL)
BEGIN
IF @MJVystup=@MJEvidence UPDATE TabKmenZbozi SET MJvystup=@MJvystup WHERE ID=@IDKmen
ELSE
BEGIN
IF dbo.hfx_UniImportKontrolaVztahuMJ(@MJEvidence, NULL, @MJVystup, NULL, @IDKmen) = 1
  UPDATE TabKmenZbozi SET MJvystup=@MJvystup WHERE ID=@IDKmen
ELSE
BEGIN
SET @ChybaPriImportu=1
IF @TextChybyImportu<>'' SET @TextChybyImportu=@TextChybyImportu + ' | '
SET @TextChybyImportu = @TextChybyImportu + dbo.hpf_UniImportHlasky('ACD18CCD-048D-494F-8914-66C4DBD38B40', @JazykVerze, @MJvystup, DEFAULT, DEFAULT, DEFAULT)
END
END
END
IF (@MJInventura IS NOT NULL)AND(@MJevidence IS NOT NULL)
BEGIN
IF @MJInventura=@MJEvidence UPDATE TabKmenZbozi SET MJInventura=@MJInventura WHERE ID=@IDKmen
ELSE
BEGIN
IF dbo.hfx_UniImportKontrolaVztahuMJ(@MJEvidence, NULL, NULL, @MJInventura, @IDKmen) = 1
  UPDATE TabKmenZbozi SET MJInventura=@MJInventura WHERE ID=@IDKmen
ELSE
BEGIN
SET @ChybaPriImportu=1
IF @TextChybyImportu<>'' SET @TextChybyImportu=@TextChybyImportu + ' | '
SET @TextChybyImportu = @TextChybyImportu + dbo.hpf_UniImportHlasky('D756F518-D5C8-4845-B378-93412F2FC605', @JazykVerze, @MJInventura, DEFAULT, DEFAULT, DEFAULT)
END
END
END
IF	   @ZarukaVstup		IS NOT NULL
OR @TypZarukaVstup	IS NOT NULL
OR @ZarukaVystup	IS NOT NULL
OR @TypZarukaVystup	IS NOT NULL
OR @DodaciLhuta		IS NOT NULL
OR @TypDodaciLhuty	IS NOT NULL
UPDATE TabKmenZbozi
SET
ZarukaVstup	=ISNULL(@ZarukaVstup	,ZarukaVstup)
,TypZarukaVstup	=ISNULL(@TypZarukaVstup	,TypZarukaVstup)
,ZarukaVystup	=ISNULL(@ZarukaVystup	,ZarukaVystup)
,TypZarukaVystup=ISNULL(@TypZarukaVystup,TypZarukaVystup)
,DodaciLhuta	=ISNULL(@DodaciLhuta	,DodaciLhuta)
,TypDodaciLhuty	=ISNULL(@TypDodaciLhuty	,TypDodaciLhuty)
WHERE ID=@IDKmen
IF @@ERROR<>0 SET @ChybaPriImportu=1
/*Aktualni dodavatel*/
IF @Aktualni_Dodavatel IS NOT NULL
IF EXISTS(SELECT ID FROM TabCisOrg WHERE CisloOrg=@Aktualni_Dodavatel)
BEGIN
UPDATE TabKmenZbozi SET Aktualni_Dodavatel=@Aktualni_Dodavatel WHERE ID=@IDKmen
IF @@ERROR<>0 SET @ChybaPriImportu=1
END
ELSE
BEGIN
SET @ChybaPriImportu=1
IF @TextChybyImportu<>'' SET @TextChybyImportu=@TextChybyImportu + ' | '
SET @TextChybyImportu = @TextChybyImportu + dbo.hpf_UniImportHlasky('8B0B3077-6061-4544-BFD3-E6DADCC06599', @JazykVerze, CAST(@Aktualni_Dodavatel AS NVARCHAR(10)), DEFAULT, DEFAULT, DEFAULT)
END
/*Vyrobce*/
IF @Vyrobce IS NOT NULL
IF EXISTS(SELECT ID FROM TabCisOrg WHERE CisloOrg=@Vyrobce)
BEGIN
UPDATE TabKmenZbozi SET Vyrobce=@Vyrobce WHERE ID=@IDKmen
IF @@ERROR<>0 SET @ChybaPriImportu=1
END
ELSE
BEGIN
SET @ChybaPriImportu=1
IF @TextChybyImportu<>'' SET @TextChybyImportu=@TextChybyImportu + ' | '
SET @TextChybyImportu = @TextChybyImportu + dbo.hpf_UniImportHlasky('B497DA2F-6958-4357-871C-B95842DE3BE3', @JazykVerze, @Vyrobce, DEFAULT, DEFAULT, DEFAULT)
END
IF	   @Minimum_Dodavatel	IS NOT NULL
OR @Minimum_Odberatel	IS NOT NULL
OR @Sirka				IS NOT NULL
OR @Vyska				IS NOT NULL
OR @Hloubka				IS NOT NULL
OR @Objem				IS NOT NULL
OR @Hmotnost			IS NOT NULL
OR @VychoziMnozstvi		IS NOT NULL
OR @PrepMnozstvi		IS NOT NULL
UPDATE TabKmenZbozi
SET  Minimum_Dodavatel	=ISNULL(@Minimum_Dodavatel	, Minimum_Dodavatel)
,Minimum_Odberatel	=ISNULL(@Minimum_Odberatel	, Minimum_Odberatel)
,Sirka				=ISNULL(@Sirka				, Sirka)
,Vyska				=ISNULL(@Vyska				, Vyska)
,Hloubka			=ISNULL(@Hloubka			, Hloubka)
,Objem				=ISNULL(@Objem				, Objem)
,Hmotnost			=ISNULL(@Hmotnost			, Hmotnost)
,VychoziMnozstvi	=ISNULL(@VychoziMnozstvi	, VychoziMnozstvi)
,PrepMnozstvi		=ISNULL(@PrepMnozstvi		, PrepMnozstvi)
WHERE ID=@IDKmen
IF @@ERROR<>0 SET @ChybaPriImportu=1
/*SazbaDPHVstup*/
IF @SazbaDPHVstup IS NOT NULL
IF dbo.hpf_UniImportExistujeSazbaDPH(@SazbaDPHVstup, NULL) = 1
BEGIN
UPDATE TabKmenZbozi SET SazbaDPHVstup=@SazbaDPHVstup WHERE ID=@IDKmen
IF @@ERROR<>0 SET @ChybaPriImportu=1
END
ELSE
BEGIN
SET @ChybaPriImportu=1
IF @TextChybyImportu<>'' SET @TextChybyImportu=@TextChybyImportu + ' | '
SET @TextChybyImportu = @TextChybyImportu + dbo.hpf_UniImportHlasky('593FB54F-C1E7-48E4-996E-C499F540EF4F', @JazykVerze, CAST(@SazbaDPHVstup AS NVARCHAR(20)), DEFAULT, DEFAULT, DEFAULT)
END
/*SazbaDPHVystup*/
IF @SazbaDPHVystup IS NOT NULL
IF dbo.hpf_UniImportExistujeSazbaDPH(@SazbaDPHVystup, NULL) = 1
BEGIN
UPDATE TabKmenZbozi SET SazbaDPHVystup=@SazbaDPHVystup WHERE ID=@IDKmen
IF @@ERROR<>0 SET @ChybaPriImportu=1
END
ELSE
BEGIN
SET @ChybaPriImportu=1
IF @TextChybyImportu<>'' SET @TextChybyImportu=@TextChybyImportu + ' | '
SET @TextChybyImportu = @TextChybyImportu + dbo.hpf_UniImportHlasky('593FB54F-C1E7-48E4-996E-C499F540EF4F', @JazykVerze, CAST(@SazbaDPHVystup AS NVARCHAR(20)), DEFAULT, DEFAULT, DEFAULT)
END
/*CelniNomenklatura*/
IF @CelniNomenklatura IS NOT NULL UPDATE TabKmenZbozi SET CelniNomenklatura=@CelniNomenklatura WHERE ID=@IDKmen
IF @@ERROR<>0 SET @ChybaPriImportu=1
IF @ChybaPriImportu=0
BEGIN
SET @CLOPopisZbozi=(SELECT TOP 1 ZboziText FROM dbo.TabClaEcit WHERE Nomenklatura=@CelniNomenklatura AND DopKod=ISNULL(@DopKod, '00'))
UPDATE TabKmenZbozi SET CLOPopisZbozi=@CLOPopisZbozi WHERE ID=@IDKmen
END
/*IdSortiment*/
IF @IdSortiment IS NOT NULL
BEGIN
SET @IdSortPom=(SELECT ID FROM TabSortiment WHERE KatAllTecky=@IdSortiment)
IF @IdSortPom IS NOT NULL
BEGIN
UPDATE TabKmenZbozi SET IdSortiment=@IdSortPom WHERE ID=@IDKmen
IF @@ERROR<>0 SET @ChybaPriImportu=1
END
ELSE
BEGIN
SET @ChybaPriImportu=1
IF @TextChybyImportu<>'' SET @TextChybyImportu=@TextChybyImportu + ' | '
SET @TextChybyImportu = @TextChybyImportu + dbo.hpf_UniImportHlasky('FFFFEEC2-6C60-40D1-84D8-854C408A6F4D', @JazykVerze, @IdSortiment, DEFAULT, DEFAULT, DEFAULT)
END
END
/*BarCode*/
IF @BarCode IS NOT NULL
IF @BarCode<>''
BEGIN
IF NOT EXISTS(SELECT * FROM TabBarCodeZbo WHERE BarCode=@BarCode)
  INSERT TabBarCodeZbo(IDKmenZbo, BarCode, DoplnkovyKod) VALUES(@IDKmen, @BarCode, @DoplnkovyKod)
ELSE
BEGIN
SET @ChybaPriImportu=1
IF @TextChybyImportu<>'' SET @TextChybyImportu=@TextChybyImportu + ' | '
SET @TextChybyImportu = @TextChybyImportu + dbo.hpf_UniImportHlasky('BE79245C-ABF2-4A3A-90E6-585C7B00440E', @JazykVerze, @BarCode, DEFAULT, DEFAULT, DEFAULT)
END
END
IF (ISNULL(@KodZbozi, '')<>'')AND(@ChybaPriImportu=0)
BEGIN
SET @IDKodPDP=(SELECT ID FROM TabCisKoduPDP WHERE KodZbozi=@KodZbozi)
IF @IDKodPDP IS NULL
BEGIN
SET @ChybaPriImportu=1
IF @TextChybyImportu<>'' SET @TextChybyImportu=@TextChybyImportu + ' | '
SET @TextChybyImportu = @TextChybyImportu + dbo.hpf_UniImportHlasky('4E6E8339-BE7B-4A8B-8C5A-D82DFFC78849', @JazykVerze, ISNULL(@KodZbozi, ''), DEFAULT, DEFAULT, DEFAULT)
END
ELSE
UPDATE TabKmenZbozi SET IDKodPDP=@IDKodPDP WHERE ID=@IDKmen
END
IF @UKod IS NOT NULL
BEGIN
IF NOT EXISTS(SELECT * FROM TabSkupUKod WHERE ID=@UKod)
BEGIN
SET @ChybaPriImportu=1
IF @TextChybyImportu<>'' SET @TextChybyImportu=@TextChybyImportu + ' | '
SET @TextChybyImportu = @TextChybyImportu + dbo.hpf_UniImportHlasky('A9340307-9957-4D2C-BE6C-4E35F106D06D', @JazykVerze, DEFAULT, DEFAULT, DEFAULT, DEFAULT)
END
ELSE
UPDATE TabKmenZbozi SET UKod=@UKod WHERE ID=@IDKmen
END
IF ISNULL(@CisloUcetPrijem, '')<>'' 
BEGIN
IF NOT EXISTS(SELECT * FROM TabCisUct WHERE CisloUcet=@CisloUcetPrijem)
BEGIN
SET @ChybaPriImportu=1
IF @TextChybyImportu<>'' SET @TextChybyImportu=@TextChybyImportu + ' | '
SET @TextChybyImportu = @TextChybyImportu + dbo.hpf_UniImportHlasky('DDD57F75-B6F7-4647-8D32-6AFB8447E1D7', @JazykVerze, @CisloUcetPrijem, DEFAULT, DEFAULT, DEFAULT)
END
ELSE
UPDATE TabKmenZbozi SET CisloUcetPrijem=@CisloUcetPrijem WHERE ID=@IDKmen
END
IF ISNULL(@CisloUcetVydej, '')<>'' 
BEGIN
IF NOT EXISTS(SELECT * FROM TabCisUct WHERE CisloUcet=@CisloUcetVydej)
BEGIN
SET @ChybaPriImportu=1
IF @TextChybyImportu<>'' SET @TextChybyImportu=@TextChybyImportu + ' | '
SET @TextChybyImportu = @TextChybyImportu + dbo.hpf_UniImportHlasky('DDD57F75-B6F7-4647-8D32-6AFB8447E1D7', @JazykVerze, @CisloUcetVydej, DEFAULT, DEFAULT, DEFAULT)
END
ELSE
UPDATE TabKmenZbozi SET CisloUcetVydej=@CisloUcetVydej WHERE ID=@IDKmen
END
IF ISNULL(@CisloUcetVydejEC, '')<>'' 
BEGIN
IF NOT EXISTS(SELECT * FROM TabCisUct WHERE CisloUcet=@CisloUcetVydejEC)
BEGIN
SET @ChybaPriImportu=1
IF @TextChybyImportu<>'' SET @TextChybyImportu=@TextChybyImportu + ' | '
SET @TextChybyImportu = @TextChybyImportu + dbo.hpf_UniImportHlasky('DDD57F75-B6F7-4647-8D32-6AFB8447E1D7', @JazykVerze, @CisloUcetVydejEC, DEFAULT, DEFAULT, DEFAULT)
END
ELSE
UPDATE TabKmenZbozi SET CisloUcetVydejEC=@CisloUcetVydejEC WHERE ID=@IDKmen
END
IF ISNULL(@CisloUcetFAPrij, '')<>'' 
BEGIN
IF NOT EXISTS(SELECT * FROM TabCisUct WHERE CisloUcet=@CisloUcetFAPrij)
BEGIN
SET @ChybaPriImportu=1
IF @TextChybyImportu<>'' SET @TextChybyImportu=@TextChybyImportu + ' | '
SET @TextChybyImportu = @TextChybyImportu + dbo.hpf_UniImportHlasky('DDD57F75-B6F7-4647-8D32-6AFB8447E1D7', @JazykVerze, @CisloUcetFAPrij, DEFAULT, DEFAULT, DEFAULT)
END
ELSE
UPDATE TabKmenZbozi SET CisloUcetFAPrij=@CisloUcetFAPrij WHERE ID=@IDKmen
END
IF ISNULL(@CisloUcetFAVyd, '')<>'' 
BEGIN
IF NOT EXISTS(SELECT * FROM TabCisUct WHERE CisloUcet=@CisloUcetFAVyd)
BEGIN
SET @ChybaPriImportu=1
IF @TextChybyImportu<>'' SET @TextChybyImportu=@TextChybyImportu + ' | '
SET @TextChybyImportu = @TextChybyImportu + dbo.hpf_UniImportHlasky('DDD57F75-B6F7-4647-8D32-6AFB8447E1D7', @JazykVerze, @CisloUcetFAVyd, DEFAULT, DEFAULT, DEFAULT)
END
ELSE
UPDATE TabKmenZbozi SET CisloUcetFAVyd=@CisloUcetFAVyd WHERE ID=@IDKmen
END
/*externi atributy*/
/*--ex. atrb. 1 - typ NVARCHAR(30)*/
IF (@ExtAtr1 IS NOT NULL)AND(@ExtAtr1Nazev IS NOT NULL)
BEGIN
IF (OBJECT_ID('TabKmenZbozi_EXT','U')IS NOT NULL)AND(COLUMNPROPERTY(OBJECT_ID('TabKmenZbozi_EXT','U'),'_'+@ExtAtr1Nazev,'AllowsNull')IS NOT NULL)
BEGIN
SET @ExtAtr1Nazev='_' + @ExtAtr1Nazev
IF EXISTS(SELECT ID FROM TabKmenZbozi_EXT WHERE ID=@IDKmen)
SET @SQLString='UPDATE TabKmenZbozi_EXT SET ' + @ExtAtr1Nazev + '=N' + '''' + @ExtAtr1 + '''' + ' WHERE ID=' + CAST(@IDKmen AS NVARCHAR(10))
ELSE
SET @SQLString='INSERT TabKmenZbozi_EXT(ID, ' + @ExtAtr1Nazev + ') VALUES(' + CAST(@IDKmen AS NVARCHAR(10)) + ', N' + '''' + @ExtAtr1 + '''' + ')'
EXEC sp_executesql @SQLString
END
ELSE
BEGIN
SET @ChybaPriImportu=1
IF @TextChybyImportu<>'' SET @TextChybyImportu=@TextChybyImportu + ' | '
SET @TextChybyImportu = @TextChybyImportu + dbo.hpf_UniImportHlasky('15364319-B20F-4D65-8900-391DE8D4C52F', @JazykVerze, '_'+@ExtAtr1Nazev, DEFAULT, DEFAULT, DEFAULT)
END
END
/*--ex. atrb. 2 - typ NVARCHAR(255)*/
IF (@ExtAtr2 IS NOT NULL)AND(@ExtAtr2Nazev IS NOT NULL)
IF (OBJECT_ID('TabKmenZbozi_EXT','U')IS NOT NULL)AND(COLUMNPROPERTY(OBJECT_ID('TabKmenZbozi_EXT','U'),'_'+@ExtAtr2Nazev,'AllowsNull')IS NOT NULL)
BEGIN
SET @ExtAtr2Nazev='_' + @ExtAtr2Nazev
IF EXISTS(SELECT ID FROM TabKmenZbozi_EXT WHERE ID=@IDKmen)
SET @SQLString='UPDATE TabKmenZbozi_EXT SET ' + @ExtAtr2Nazev + '=N' + '''' + @ExtAtr2 + '''' + ' WHERE ID=' + CAST(@IDKmen AS NVARCHAR(10))
ELSE
SET @SQLString='INSERT TabKmenZbozi_EXT(ID, ' + @ExtAtr2Nazev + ') VALUES(' + CAST(@IDKmen AS NVARCHAR(10)) + ', N' + '''' + @ExtAtr2 + '''' + ')'
EXECUTE sp_executesql @SQLString
END
ELSE
BEGIN
SET @ChybaPriImportu=1
IF @TextChybyImportu<>'' SET @TextChybyImportu=@TextChybyImportu + ' | '
SET @TextChybyImportu = @TextChybyImportu + dbo.hpf_UniImportHlasky('15364319-B20F-4D65-8900-391DE8D4C52F', @JazykVerze, '_'+@ExtAtr2Nazev, DEFAULT, DEFAULT, DEFAULT)
END
/*--ex. atrb. 3 - typ DATETIME*/
IF (@ExtAtr3 IS NOT NULL)AND(@ExtAtr3Nazev IS NOT NULL)
IF (OBJECT_ID('TabKmenZbozi_EXT','U')IS NOT NULL)AND(COLUMNPROPERTY(OBJECT_ID('TabKmenZbozi_EXT','U'),'_'+@ExtAtr3Nazev,'AllowsNull')IS NOT NULL)
BEGIN
SET @ExtAtr3Nazev='_' + @ExtAtr3Nazev
IF EXISTS(SELECT ID FROM TabKmenZbozi_EXT WHERE ID=@IDKmen)
SET @SQLString='UPDATE TabKmenZbozi_EXT SET ' + @ExtAtr3Nazev + '=' + '''' + CONVERT(NVARCHAR(10),@ExtAtr3, 112) + '''' + ' WHERE ID=' + CAST(@IDKmen AS NVARCHAR(10))
ELSE
SET @SQLString='INSERT TabKmenZbozi_EXT(ID, ' + @ExtAtr3Nazev + ') VALUES(' + CAST(@IDKmen AS NVARCHAR(10)) + ', ' + '''' + CONVERT(NVARCHAR(10),@ExtAtr3, 112) + '''' + ')'
EXECUTE sp_executesql @SQLString
END
ELSE
BEGIN
SET @ChybaPriImportu=1
IF @TextChybyImportu<>'' SET @TextChybyImportu=@TextChybyImportu + ' | '
SET @TextChybyImportu = @TextChybyImportu + dbo.hpf_UniImportHlasky('15364319-B20F-4D65-8900-391DE8D4C52F', @JazykVerze, '_'+@ExtAtr3Nazev, DEFAULT, DEFAULT, DEFAULT)
END
/*--ex. atrb. 4 - typ NUMERIC*/
IF (@ExtAtr4 IS NOT NULL)AND(@ExtAtr4Nazev IS NOT NULL)
IF (OBJECT_ID('TabKmenZbozi_EXT','U')IS NOT NULL)AND(COLUMNPROPERTY(OBJECT_ID('TabKmenZbozi_EXT','U'),'_'+@ExtAtr4Nazev,'AllowsNull')IS NOT NULL)
BEGIN
SET @ExtAtr4Nazev='_' + @ExtAtr4Nazev
IF EXISTS(SELECT ID FROM TabKmenZbozi_EXT WHERE ID=@IDKmen)
SET @SQLString='UPDATE TabKmenZbozi_EXT SET ' + @ExtAtr4Nazev + '=' + CAST(@ExtAtr4 AS NVARCHAR(26)) +  ' WHERE ID=' + CAST(@IDKmen AS NVARCHAR(10))
ELSE
SET @SQLString='INSERT TabKmenZbozi_EXT(ID, ' + @ExtAtr4Nazev + ') VALUES(' + CAST(@IDKmen AS NVARCHAR(10)) + ', ' + CAST(@ExtAtr4 AS NVARCHAR(26)) + ')'
EXECUTE sp_executesql @SQLString
END
ELSE
BEGIN
SET @ChybaPriImportu=1
IF @TextChybyImportu<>'' SET @TextChybyImportu=@TextChybyImportu + ' | '
SET @TextChybyImportu = @TextChybyImportu + dbo.hpf_UniImportHlasky('15364319-B20F-4D65-8900-391DE8D4C52F', @JazykVerze, '_'+@ExtAtr4Nazev, DEFAULT, DEFAULT, DEFAULT)
END
/*--ex. atrb. 5 - typ NVARCHAR(255)*/
IF (@ExtAtr5 IS NOT NULL)AND(@ExtAtr5Nazev IS NOT NULL)
IF (OBJECT_ID('TabKmenZbozi_EXT','U')IS NOT NULL)AND(COLUMNPROPERTY(OBJECT_ID('TabKmenZbozi_EXT','U'),'_'+@ExtAtr5Nazev,'AllowsNull')IS NOT NULL)
BEGIN
SET @ExtAtr5Nazev='_' + @ExtAtr5Nazev
IF EXISTS(SELECT ID FROM TabKmenZbozi_EXT WHERE ID=@IDKmen)
SET @SQLString='UPDATE TabKmenZbozi_EXT SET ' + @ExtAtr5Nazev + '=N' + '''' + @ExtAtr5 + '''' + ' WHERE ID=' + CAST(@IDKmen AS NVARCHAR(10))
ELSE
SET @SQLString='INSERT TabKmenZbozi_EXT(ID, ' + @ExtAtr5Nazev + ') VALUES(' + CAST(@IDKmen AS NVARCHAR(10)) + ', N' + '''' + @ExtAtr5 + '''' + ')'
EXECUTE sp_executesql @SQLString
END
ELSE
BEGIN
SET @ChybaPriImportu=1
IF @TextChybyImportu<>'' SET @TextChybyImportu=@TextChybyImportu + ' | '
SET @TextChybyImportu = @TextChybyImportu + dbo.hpf_UniImportHlasky('15364319-B20F-4D65-8900-391DE8D4C52F', @JazykVerze, '_'+@ExtAtr5Nazev, DEFAULT, DEFAULT, DEFAULT)
END
/*--ex. atrb. 6 - typ NVARCHAR(255)*/
IF (@ExtAtr6 IS NOT NULL)AND(@ExtAtr6Nazev IS NOT NULL)
IF (OBJECT_ID('TabKmenZbozi_EXT','U')IS NOT NULL)AND(COLUMNPROPERTY(OBJECT_ID('TabKmenZbozi_EXT','U'),'_'+@ExtAtr6Nazev,'AllowsNull')IS NOT NULL)
BEGIN
SET @ExtAtr6Nazev='_' + @ExtAtr6Nazev
IF EXISTS(SELECT ID FROM TabKmenZbozi_EXT WHERE ID=@IDKmen)
SET @SQLString='UPDATE TabKmenZbozi_EXT SET ' + @ExtAtr6Nazev + '=N' + '''' + @ExtAtr6 + '''' + ' WHERE ID=' + CAST(@IDKmen AS NVARCHAR(10))
ELSE
SET @SQLString='INSERT TabKmenZbozi_EXT(ID, ' + @ExtAtr6Nazev + ') VALUES(' + CAST(@IDKmen AS NVARCHAR(10)) + ', N' + '''' + @ExtAtr6 + '''' + ')'
EXECUTE sp_executesql @SQLString
END
ELSE
BEGIN
SET @ChybaPriImportu=1
IF @TextChybyImportu<>'' SET @TextChybyImportu=@TextChybyImportu + ' | '
SET @TextChybyImportu = @TextChybyImportu + dbo.hpf_UniImportHlasky('15364319-B20F-4D65-8900-391DE8D4C52F', @JazykVerze, '_'+@ExtAtr6Nazev, DEFAULT, DEFAULT, DEFAULT)
END
/*--ex. atrb. 7 - typ NVARCHAR(255)*/
IF (@ExtAtr7 IS NOT NULL)AND(@ExtAtr7Nazev IS NOT NULL)
IF (OBJECT_ID('TabKmenZbozi_EXT','U')IS NOT NULL)AND(COLUMNPROPERTY(OBJECT_ID('TabKmenZbozi_EXT','U'),'_'+@ExtAtr7Nazev,'AllowsNull')IS NOT NULL)
BEGIN
SET @ExtAtr7Nazev='_' + @ExtAtr7Nazev
IF EXISTS(SELECT ID FROM TabKmenZbozi_EXT WHERE ID=@IDKmen)
SET @SQLString='UPDATE TabKmenZbozi_EXT SET ' + @ExtAtr7Nazev + '=N' + '''' + @ExtAtr7 + '''' + ' WHERE ID=' + CAST(@IDKmen AS NVARCHAR(10))
ELSE
SET @SQLString='INSERT TabKmenZbozi_EXT(ID, ' + @ExtAtr7Nazev + ') VALUES(' + CAST(@IDKmen AS NVARCHAR(10)) + ', N' + '''' + @ExtAtr7 + '''' + ')'
EXECUTE sp_executesql @SQLString
END
ELSE
BEGIN
SET @ChybaPriImportu=1
IF @TextChybyImportu<>'' SET @TextChybyImportu=@TextChybyImportu + ' | '
SET @TextChybyImportu = @TextChybyImportu + dbo.hpf_UniImportHlasky('15364319-B20F-4D65-8900-391DE8D4C52F', @JazykVerze, '_'+@ExtAtr7Nazev, DEFAULT, DEFAULT, DEFAULT)
END
/*--ex. atrb. 8 - typ NVARCHAR(255)*/
IF (@ExtAtr8 IS NOT NULL)AND(@ExtAtr8Nazev IS NOT NULL)
IF (OBJECT_ID('TabKmenZbozi_EXT','U')IS NOT NULL)AND(COLUMNPROPERTY(OBJECT_ID('TabKmenZbozi_EXT','U'),'_'+@ExtAtr8Nazev,'AllowsNull')IS NOT NULL)
BEGIN
SET @ExtAtr8Nazev='_' + @ExtAtr8Nazev
IF EXISTS(SELECT ID FROM TabKmenZbozi_EXT WHERE ID=@IDKmen)
SET @SQLString='UPDATE TabKmenZbozi_EXT SET ' + @ExtAtr8Nazev + '=N' + '''' + @ExtAtr8 + '''' + ' WHERE ID=' + CAST(@IDKmen AS NVARCHAR(10))
ELSE
SET @SQLString='INSERT TabKmenZbozi_EXT(ID, ' + @ExtAtr8Nazev + ') VALUES(' + CAST(@IDKmen AS NVARCHAR(10)) + ', N' + '''' + @ExtAtr8 + '''' + ')'
EXECUTE sp_executesql @SQLString
END
ELSE
BEGIN
SET @ChybaPriImportu=1
IF @TextChybyImportu<>'' SET @TextChybyImportu=@TextChybyImportu + ' | '
SET @TextChybyImportu = @TextChybyImportu + dbo.hpf_UniImportHlasky('15364319-B20F-4D65-8900-391DE8D4C52F', @JazykVerze, '_'+@ExtAtr8Nazev, DEFAULT, DEFAULT, DEFAULT)
END
IF (@ExtAtr9 IS NOT NULL)AND(@ExtAtr9Nazev IS NOT NULL)
IF (OBJECT_ID('TabKmenZbozi_EXT','U')IS NOT NULL)AND(COLUMNPROPERTY(OBJECT_ID('TabKmenZbozi_EXT','U'),'_'+@ExtAtr9Nazev,'AllowsNull')IS NOT NULL)
BEGIN
SET @ExtAtr9Nazev='_' + @ExtAtr9Nazev
IF EXISTS(SELECT ID FROM TabKmenZbozi_EXT WHERE ID=@IDKmen)
SET @SQLString='UPDATE TabKmenZbozi_EXT SET ' + @ExtAtr9Nazev + '=' + CAST(@ExtAtr9 AS NVARCHAR) + ' WHERE ID=' + CAST(@IDKmen AS NVARCHAR(10))
ELSE
SET @SQLString='INSERT TabKmenZbozi_EXT(ID, ' + @ExtAtr9Nazev + ') VALUES(' + CAST(@IDKmen AS NVARCHAR(10)) + ', ' + CAST(@ExtAtr9 AS NVARCHAR) + ')'
EXECUTE sp_executesql @SQLString
END
ELSE
BEGIN
SET @ChybaPriImportu=1
IF @TextChybyImportu<>'' SET @TextChybyImportu=@TextChybyImportu + ' | '
SET @TextChybyImportu = @TextChybyImportu + dbo.hpf_UniImportHlasky('15364319-B20F-4D65-8900-391DE8D4C52F', @JazykVerze, '_'+@ExtAtr9Nazev, DEFAULT, DEFAULT, DEFAULT)
END
SET @ChybaExtAtr=''
EXEC dbo.hpx_UniImport_ZpracujExtAtr
  @ImportIdent=4,
  @IdImpTable=@ID,
  @IdTargetTable=@IDKmen,
  @Chyba=@ChybaExtAtr OUT
IF @ChybaExtAtr<>''
BEGIN
  SET @ChybaPriImportu=1
  IF @TextChybyImportu<>'' SET @TextChybyImportu=@TextChybyImportu + ' | '
  SET @TextChybyImportu = @TextChybyImportu + dbo.hpf_UniImportHlasky('15364319-B20F-4D65-8900-391DE8D4C52F', @JazykVerze, @ChybaExtAtr, DEFAULT, DEFAULT, DEFAULT)
END
IF OBJECT_ID('dbo.epx_UniImportKmen03', 'P') IS NOT NULL EXEC dbo.epx_UniImportKmen03 @IDKmen
/*--pokud nedoslo k chybe, smazeme zaznam z importni tabulky*/
IF @@ERROR<>0 SET @ChybaPriImportu=1
IF @ChybaPriImportu=0 DELETE FROM dbo.TabUniImportKmen WHERE ID=@ID
/*--pokud probehlo vsechno OK, pustime transakci, jinak vse vratime zpet*/
IF @ChybaPriImportu=1
BEGIN
IF @@trancount>0 ROLLBACK TRAN T1
UPDATE dbo.TabUniImportKmen SET Chyba=@TextChybyImportu, DatumImportu=GETDATE() WHERE ID=@ID
END
ELSE IF @@trancount>0 COMMIT TRAN T1
END
ELSE
BEGIN
SET @IDKmen=(SELECT ID FROM TabKmenZbozi WHERE SkupZbo=@SkupZbo AND RegCis=@RegCis)
SET @Nazev1_U=NULL
SET @Nazev2_U=NULL
SET @Nazev3_U=NULL
SET @Nazev4_U=NULL
SET @SKP_U=NULL
SET @MJEvidence_U=NULL
SET @MJVstup_U=NULL
SET @MJVystup_U=NULL
SET @MJInventura_U=NULL
SET @KJDatOd_U=NULL
SET @KJDatDo_U=NULL
SET @Vykres_U=NULL
SET @ZarukaVstup_U=NULL
SET @TypZarukaVstup_U=NULL
SET @ZarukaVystup_U=NULL
SET @TypZarukaVystup_U=NULL
SET @DodaciLhuta_U=NULL
SET @TypDodaciLhuty_U=NULL
SET @BaleniTXT_U=NULL
SET @Aktualni_Dodavatel_U=NULL
SET @Minimum_Dodavatel_U=NULL
SET @Minimum_Odberatel_U=NULL
SET @Sirka_U=NULL
SET @Vyska_U=NULL
SET @Hloubka_U=NULL
SET @Objem_U=NULL
SET @Hmotnost_U=NULL
SET @IdSortiment_U=NULL
SET @Vyrobce_U=NULL
SET @VychoziMnozstvi_U=NULL
SET @PrepMnozstvi_U=NULL
SET @SazbaDPHVstup_U=NULL
SET @SazbaDPHVystup_U=NULL
SET @CelniNomenklatura_U=NULL
SET @DopKod_U=NULL
SET @ObvyklaZemePuvodu_U=NULL
SET @KontrolaVyrC_U=NULL
SET @Blokovano_U=NULL
SET @Minimum_Baleni_Dodavatel_U=NULL
SET @VykazLihuObjemVML_U=NULL
SET @VykazLihuProcentoLihu_U=NULL
SET @VykazLihuKoefKEvidMJ_U=NULL
SET @Upozorneni_U=NULL
SET @KodZbozi_U=NULL
SET @LhutaNaskladneni_U=NULL
SET @Poznamka_U=NULL
SET @UKod_U=NULL
SET @CisloUcetPrijem_U=NULL
SET @CisloUcetVydej_U=NULL
SET @CisloUcetVydejEC_U=NULL
SET @CisloUcetFAPrij_U=NULL
SET @CisloUcetFAVyd_U=NULL
SET @Sleva_U=NULL
SET @KodRecyk_U=NULL
SET @CastkaHistRecyk_U=NULL
SET @CastkaGarRecyk_U=NULL
SET @MJRecyk_U=NULL
SET @PrepMJRecyk_U=NULL
SET @ZboziSluzba_U=NULL
SET @PocetBaleniVeVrstve_U=NULL
SET @PocetVrstevNaPalete_U=NULL
SET @PLUKod_U=NULL
SET @BodovaHodnota_U=NULL
SELECT  @Nazev1_U=Nazev1,
@Nazev2_U=Nazev2,
@Nazev3_U=Nazev3,
@Nazev4_U=Nazev4,
@SKP_U=SKP,
@MJEvidence_U=MJEvidence,
@MJVstup_U=MJVstup,
@MJVystup_U=MJVystup,
@MJInventura_U=MJInventura,
@KJDatOd_U=KJDatOd,
@KJDatDo_U=KJDatDo,
@Vykres_U=Vykres,
@ZarukaVstup_U=ZarukaVstup,
@TypZarukaVstup_U=TypZarukaVstup,
@ZarukaVystup_U=ZarukaVystup,
@TypZarukaVystup_U=TypZarukaVystup,
@DodaciLhuta_U=DodaciLhuta,
@TypDodaciLhuty_U=TypDodaciLhuty,
@BaleniTXT_U=BaleniTXT,
@Aktualni_Dodavatel_U=Aktualni_Dodavatel,
@Minimum_Dodavatel_U=Minimum_Dodavatel,
@Minimum_Odberatel_U=Minimum_Odberatel,
@Sirka_U=Sirka,
@Vyska_U=Vyska,
@Hloubka_U=Hloubka,
@Objem_U=Objem,
@Hmotnost_U=Hmotnost,
@IdSortiment_U=IdSortiment,
@Vyrobce_U=Vyrobce,
@VychoziMnozstvi_U=VychoziMnozstvi,
@PrepMnozstvi_U=PrepMnozstvi,
@SazbaDPHVstup_U=SazbaDPHVstup,
@SazbaDPHVystup_U=SazbaDPHVystup,
@CelniNomenklatura_U=CelniNomenklatura,
@DopKod_U=DopKod,
@ObvyklaZemePuvodu_U=ObvyklaZemePuvodu,
@KontrolaVyrC_U=KontrolaVyrC,
@Blokovano_U=Blokovano,
@Minimum_Baleni_Dodavatel_U=Minimum_Baleni_Dodavatel,
@VykazLihuObjemVML_U=VykazLihuObjemVML,
@VykazLihuProcentoLihu_U=VykazLihuProcentoLihu,
@VykazLihuKoefKEvidMJ_U=VykazLihuKoefKEvidMJ,
@Upozorneni_U=Upozorneni,
@LhutaNaskladneni_U=LhutaNaskladneni,
@Poznamka_U=Poznamka,
@UKod_U=UKod,
@CisloUcetPrijem_U=CisloUcetPrijem,
@CisloUcetVydej_U=CisloUcetVydej,
@CisloUcetVydejEC_U=CisloUcetVydejEC,
@CisloUcetFAPrij_U=CisloUcetFAPrij,
@CisloUcetFAVyd_U=CisloUcetFAVyd,
@Sleva_U=Sleva,
@ZboziSluzba_U=ZboziSluzba,
@PocetBaleniVeVrstve_U=PocetBaleniVeVrstve,
@PocetVrstevNaPalete_U=PocetVrstevNaPalete,
@PLUKod_U=PLUKod,
@BodovaHodnota_U=BodovaHodnota
FROM TabKmenZbozi
WHERE TabKmenZbozi.ID=@IDKmen
SELECT 
  @KodRecyk_U=KodRecyk
, @CastkaHistRecyk_U=CastkaHistRecyk
, @CastkaGarRecyk_U=CastkaGarRecyk
, @MJRecyk_U=MJRecyk
, @PrepMJRecyk_U=PrepMJRecyk
FROM TabKmenZboziDodatek
WHERE ID=@IDKmen
SET @KodZbozi_U=(SELECT KodZbozi FROM TabCisKoduPDP WHERE ID=(SELECT IDKodPDP FROM TabKmenZbozi WHERE ID=@IDKmen))
SELECT  @Nazev1_B=Nazev1,
@Nazev2_B=Nazev2,
@Nazev3_B=Nazev3,
@Nazev4_B=Nazev4,
@Poznamka_B=Poznamka,
@SKP_B=SKP,
@MJEvidence_B=MJEvidence,
@MJVstup_B=MJVstup,
@MJVystup_B=MJVystup,
@MJInventura_B=MJInventura,
@KJDatOd_B=KJDatOd,
@KJDatDo_B=KJDatDo,
@Vykres_B=Vykres,
@ZarukaVstup_B=ZarukaVstup,
@TypZarukaVstup_B=TypZarukaVstup,
@ZarukaVystup_B=ZarukaVystup,
@TypZarukaVystup_B=TypZarukaVystup,
@DodaciLhuta_B=DodaciLhuta,
@TypDodaciLhuty_B=TypDodaciLhuty,
@BaleniTXT_B=BaleniTXT,
@Aktualni_Dodavatel_B=Aktualni_Dodavatel,
@Minimum_Dodavatel_B=Minimum_Dodavatel,
@Minimum_Odberatel_B=Minimum_Odberatel,
@Sirka_B=Sirka,
@Vyska_B=Vyska,
@Hloubka_B=Hloubka,
@Objem_B=Objem,
@Hmotnost_B=Hmotnost,
@IdSortiment_B=IdSortiment,
@Vyrobce_B=Vyrobce,
@VychoziMnozstvi_B=VychoziMnozstvi,
@PrepMnozstvi_B=PrepMnozstvi,
@SazbaDPHVstup_B=SazbaDPHVstup,
@SazbaDPHVystup_B=SazbaDPHVystup,
@CelniNomenklatura_B=CelniNomenklatura,
@DopKod_B=DopKod,
@ObvyklaZemePuvodu_B=ObvyklaZemePuvodu,
@KontrolaVyrC_B=KontrolaVyrC,
@Blokovano_B=Blokovano,
@Minimum_Baleni_Dodavatel_B=Minimum_Baleni_Dodavatel,
@VykazLihuObjemVML_B=VykazLihuObjemVML,
@VykazLihuProcentoLihu_B=VykazLihuProcentoLihu,
@VykazLihuKoefKEvidMJ_B=VykazLihuKoefKEvidMJ,
@Upozorneni_B=Upozorneni,
@KodZbozi_B=KodZbozi,
@LhutaNaskladneni_B=LhutaNaskladneni,
@UKod_B=UKod,
@CisloUcetPrijem_B=CisloUcetPrijem,
@CisloUcetVydej_B=CisloUcetVydej,
@CisloUcetVydejEC_B=CisloUcetVydejEC,
@CisloUcetFAPrij_B=CisloUcetFAPrij,
@CisloUcetFAVyd_B=CisloUcetFAVyd,
@Sleva_B=Sleva,
@KodRecyk_B=KodRecyk,
@CastkaHistRecyk_B=CastkaHistRecyk,
@CastkaGarRecyk_B=CastkaGarRecyk,
@MJRecyk_B=MJRecyk,
@PrepMJRecyk_B=PrepMJRecyk,
@ZboziSluzba_B=ZboziSluzba,
@PocetBaleniVeVrstve_B=PocetBaleniVeVrstve,
@PocetVrstevNaPalete_B=PocetVrstevNaPalete,
@PLUKod_B=PLUKod,
@BodovaHodnota_B=BodovaHodnota,
@DoplnkovyKod_B=DoplnkovyKod,
@ExtAtr1_B=ExtAtr1,
@ExtAtr2_B=ExtAtr2,
@ExtAtr3_B=ExtAtr3,
@ExtAtr4_B=ExtAtr4,
@ExtAtr5_B=ExtAtr5,
@ExtAtr6_B=ExtAtr6,
@ExtAtr7_B=ExtAtr7,
@ExtAtr8_B=ExtAtr8,
@ExtAtr9_B=ExtAtr9
FROM TabUniImportKmenUp
WHERE IdImpTable=@ID
IF @Nazev1_B=1 SET @Nazev1_U=@Nazev1
IF @Nazev2_B=1 SET @Nazev2_U=@Nazev2
IF @Nazev3_B=1 SET @Nazev3_U=@Nazev3
IF @Nazev4_B=1 SET @Nazev4_U=@Nazev4
IF @SKP_B=1 SET @SKP_U=@SKP
IF @MJEvidence_B=1 SET @MJEvidence_U=@MJEvidence
IF @MJVstup_B=1 SET @MJVstup_U=@MJVstup
IF @MJVystup_B=1 SET @MJVystup_U=@MJVystup
IF @MJInventura_B=1 SET @MJInventura_U=@MJInventura
IF @KJDatOd_B=1 SET @KJDatOd_U=@KJDatOd
IF @KJDatDo_B=1 SET @KJDatDo_U=@KJDatDo
IF @Vykres_B=1 SET @Vykres_U=@Vykres
IF @ZarukaVstup_B=1 SET @ZarukaVstup_U=@ZarukaVstup
IF @TypZarukaVstup_B=1 SET @TypZarukaVstup_U=@TypZarukaVstup
IF @ZarukaVystup_B=1 SET @ZarukaVystup_U=@ZarukaVystup
IF @TypZarukaVystup_B=1 SET @TypZarukaVystup_U=@TypZarukaVystup
IF @DodaciLhuta_B=1 SET @DodaciLhuta_U=@DodaciLhuta
IF @TypDodaciLhuty_B=1 SET @TypDodaciLhuty_U=@TypDodaciLhuty
IF @BaleniTXT_B=1 SET @BaleniTXT_U=@BaleniTXT
IF @Aktualni_Dodavatel_B=1 SET @Aktualni_Dodavatel_U=@Aktualni_Dodavatel
IF @Minimum_Dodavatel_B=1 SET @Minimum_Dodavatel_U=@Minimum_Dodavatel
IF @Minimum_Odberatel_B=1 SET @Minimum_Odberatel_U=@Minimum_Odberatel
IF @Sirka_B=1 SET @Sirka_U=@Sirka
IF @Vyska_B=1 SET @Vyska_U=@Vyska
IF @Hloubka_B=1 SET @Hloubka_U=@Hloubka
IF @Objem_B=1 SET @Objem_U=@Objem
IF @Hmotnost_B=1 SET @Hmotnost_U=@Hmotnost
IF @IdSortiment_B=1 SET @IdSortiment_U=@IdSortiment
ELSE                SET @IdSortiment_U=(SELECT KatAllTecky FROM TabSortiment WHERE ID=@IdSortiment_U)
IF @Vyrobce_B=1 SET @Vyrobce_U=@Vyrobce
IF @VychoziMnozstvi_B=1 SET @VychoziMnozstvi_U=@VychoziMnozstvi
IF @PrepMnozstvi_B=1 SET @PrepMnozstvi_U=@PrepMnozstvi
IF @SazbaDPHVstup_B=1 SET @SazbaDPHVstup_U=@SazbaDPHVstup
IF @SazbaDPHVystup_B=1 SET @SazbaDPHVystup_U=@SazbaDPHVystup
IF @CelniNomenklatura_B=1 SET @CelniNomenklatura_U=@CelniNomenklatura
IF @DopKod_B=1 SET @DopKod_U=@DopKod
IF @ObvyklaZemePuvodu_B=1 SET @ObvyklaZemePuvodu_U=@ObvyklaZemePuvodu
IF @KontrolaVyrC_B=1 SET @KontrolaVyrC_U=@KontrolaVyrC
IF @Blokovano_B=1 SET @Blokovano_U=@Blokovano
IF @Minimum_Baleni_Dodavatel_B=1 SET @Minimum_Baleni_Dodavatel_U=@Minimum_Baleni_Dodavatel
IF @VykazLihuObjemVML_B=1 SET @VykazLihuObjemVML_U = @VykazLihuObjemVML
IF @VykazLihuProcentoLihu_B=1 SET @VykazLihuProcentoLihu_U = @VykazLihuProcentoLihu
IF @VykazLihuKoefKEvidMJ_B=1 SET @VykazLihuKoefKEvidMJ_U = @VykazLihuKoefKEvidMJ
IF @Upozorneni_B=1 SET @Upozorneni_U = @Upozorneni
IF @KodZbozi_B=1 SET @KodZbozi_U = @KodZbozi
IF @LhutaNaskladneni_B=1 SET @LhutaNaskladneni_U = @LhutaNaskladneni
IF @Poznamka_B=1 SET @Poznamka_U = @Poznamka
IF @UKod_B=1 SET @UKod_U = @UKod
IF @CisloUcetPrijem_B=1 SET @CisloUcetPrijem_U = @CisloUcetPrijem
IF @CisloUcetVydej_B=1 SET @CisloUcetVydej_U = @CisloUcetVydej
IF @CisloUcetVydejEC_B=1 SET @CisloUcetVydejEC_U = @CisloUcetVydejEC
IF @CisloUcetFAPrij_B=1 SET @CisloUcetFAPrij_U = @CisloUcetFAPrij
IF @CisloUcetFAVyd_B=1 SET @CisloUcetFAVyd_U = @CisloUcetFAVyd
IF @Sleva_B=1 SET @Sleva_U = @Sleva
IF @KodRecyk_B=1 SET @KodRecyk_U=@KodRecyk
IF @CastkaHistRecyk_B=1 SET @CastkaHistRecyk_U=@CastkaHistRecyk
IF @CastkaGarRecyk_B=1 SET @CastkaGarRecyk_U=@CastkaGarRecyk
IF @MJRecyk_B=1 SET @MJRecyk_U=@MJRecyk
IF @PrepMJRecyk_B=1 SET @PrepMJRecyk_U=@PrepMJRecyk
IF @ZboziSluzba_B=1 SET @ZboziSluzba_U=@ZboziSluzba
IF @PocetBaleniVeVrstve_B=1 SET @PocetBaleniVeVrstve_U=@PocetBaleniVeVrstve
IF @PocetVrstevNaPalete_B=1 SET @PocetVrstevNaPalete_U=@PocetVrstevNaPalete
IF @PLUKod_B=1 SET @PLUKod_U=@PLUKod
IF @BodovaHodnota_B=1 SET @BodovaHodnota_U=@BodovaHodnota
BEGIN TRAN T1
/*updatujeme zakladni udaje karty bez navaznych udaju*/
IF @DruhSkladu IS NULL SET @DruhSkladu=1
IF @ChybaPriImportu=0
  UPDATE TabKmenZbozi SET
    Nazev1=@Nazev1_U,
    Nazev2=@Nazev2_U,
    Nazev3=@Nazev3_U,
    Nazev4=@Nazev4_U,
    SKP=@SKP_U,
    KJDatOd=@KJDatOd_U,
    KJDatDo=@KJDatDo_U,
    Vykres=@Vykres_U,
    BaleniTXT=ISNULL(@BaleniTXT_U, ''),
    DopKod=@DopKod_U,
    ObvyklaZemePuvodu=@ObvyklaZemePuvodu_U,
    KontrolaVyrC=@KontrolaVyrC_U,
    Blokovano=@Blokovano_U,
    Minimum_Baleni_Dodavatel=@Minimum_Baleni_Dodavatel_U,
    VykazLihuObjemVML=@VykazLihuObjemVML_U,
    VykazLihuProcentoLihu=@VykazLihuProcentoLihu_U,
    VykazLihuKoefKEvidMJ=@VykazLihuKoefKEvidMJ_U,
    Upozorneni=ISNULL(@Upozorneni_U, ''),
    LhutaNaskladneni=@LhutaNaskladneni_U,
    Poznamka=@Poznamka_U,
    Sleva=ISNULL(@Sleva_U, 0),
    ZboziSluzba=ISNULL(@ZboziSluzba_U, 0),
    PocetBaleniVeVrstve=ISNULL(@PocetBaleniVeVrstve_U, 0),
    PocetVrstevNaPalete=ISNULL(@PocetVrstevNaPalete_U, 0),
    PLUKod=ISNULL(@PLUKod_U, ''),
    BodovaHodnota=ISNULL(@BodovaHodnota_U, 0),
    Zmenil=SUSER_SNAME(),
    DatZmeny=GETDATE()
  WHERE ID=@IDKmen
IF @@ERROR<>0 SET @ChybaPriImportu=1
IF @ChybaPriImportu=0
BEGIN
IF ISNULL(@MJRecyk_U, '')<>'' 
BEGIN
  IF NOT EXISTS(SELECT ID FROM TabMJ WHERE Kod=@MJRecyk_U)
    INSERT TabMJ(Kod) VALUES(@MJRecyk_U)
END
IF NOT EXISTS(SELECT * FROM TabKmenZboziDodatek WHERE ID=@IDKmen)
  INSERT TabKmenZboziDodatek(ID) VALUES(@IDKmen)
UPDATE TabKmenZboziDodatek SET
   KodRecyk=@KodRecyk_U
 , CastkaHistRecyk=@CastkaHistRecyk_U
 , CastkaGarRecyk=@CastkaGarRecyk_U
 , MJRecyk=@MJRecyk_U
 , PrepMJRecyk=@PrepMJRecyk_U
WHERE ID=@IDKmen
END
/*MJevidence*/
IF @MJevidence_U IS NOT NULL
BEGIN
  IF NOT EXISTS(SELECT ID FROM TabMJ WHERE Kod=@MJevidence_U)
    INSERT TabMJ(Kod) VALUES(@MJevidence_U)
  UPDATE TabKmenZbozi SET MJEvidence=@MJEvidence_U WHERE ID=@IDKmen
  IF @@ERROR<>0 SET @ChybaPriImportu=1
END
/*MJvstup*/
IF (@MJvstup_U IS NOT NULL)AND(@MJevidence_U IS NOT NULL)
BEGIN
IF @MJVstup_U=@MJEvidence_U UPDATE TabKmenZbozi SET MJvstup=@MJvstup_U WHERE ID=@IDKmen
ELSE
BEGIN
IF dbo.hfx_UniImportKontrolaVztahuMJ(@MJEvidence_U, @MJVstup_U, NULL, NULL, @IDKmen) = 1
  UPDATE TabKmenZbozi SET MJvstup=@MJvstup_U WHERE ID=@IDKmen
ELSE
BEGIN
SET @ChybaPriImportu=1
IF @TextChybyImportu<>'' SET @TextChybyImportu=@TextChybyImportu + ' | '
SET @TextChybyImportu = @TextChybyImportu + dbo.hpf_UniImportHlasky('1E3241C1-0B92-482B-9C6F-1CF47F45AA23', @JazykVerze, @MJvstup_U, DEFAULT, DEFAULT, DEFAULT)
END
END
END
/*MJvystup*/
IF (@MJvystup_U IS NOT NULL)AND(@MJevidence_U IS NOT NULL)
BEGIN
IF @MJVystup_U=@MJEvidence_U UPDATE TabKmenZbozi SET MJvystup=@MJvystup_U WHERE ID=@IDKmen
ELSE
BEGIN
IF dbo.hfx_UniImportKontrolaVztahuMJ(@MJEvidence_U, NULL, @MJVystup_U, NULL, @IDKmen) = 1
  UPDATE TabKmenZbozi SET MJvystup=@MJvystup_U WHERE ID=@IDKmen
ELSE
BEGIN
SET @ChybaPriImportu=1
IF @TextChybyImportu<>'' SET @TextChybyImportu=@TextChybyImportu + ' | '
SET @TextChybyImportu = @TextChybyImportu + dbo.hpf_UniImportHlasky('ACD18CCD-048D-494F-8914-66C4DBD38B40', @JazykVerze, @MJvystup_U, DEFAULT, DEFAULT, DEFAULT)
END
END
END
IF (@MJInventura_U IS NOT NULL)AND(@MJevidence_U IS NOT NULL)
BEGIN
IF @MJInventura_U=@MJEvidence_U UPDATE TabKmenZbozi SET MJInventura=@MJInventura_U WHERE ID=@IDKmen
ELSE
BEGIN
IF dbo.hfx_UniImportKontrolaVztahuMJ(@MJEvidence_U, NULL, NULL, @MJInventura_U, @IDKmen) = 1
  UPDATE TabKmenZbozi SET MJInventura=@MJInventura_U WHERE ID=@IDKmen
ELSE
BEGIN
SET @ChybaPriImportu=1
IF @TextChybyImportu<>'' SET @TextChybyImportu=@TextChybyImportu + ' | '
SET @TextChybyImportu = @TextChybyImportu + dbo.hpf_UniImportHlasky('D756F518-D5C8-4845-B378-93412F2FC605', @JazykVerze, @MJInventura_U, DEFAULT, DEFAULT, DEFAULT)
END
END
END
IF	   @ZarukaVstup_U		IS NOT NULL
OR @TypZarukaVstup_U	IS NOT NULL
OR @ZarukaVystup_U		IS NOT NULL
OR @TypZarukaVystup_U	IS NOT NULL
OR @DodaciLhuta_U		IS NOT NULL
OR @TypDodaciLhuty_U	IS NOT NULL
UPDATE TabKmenZbozi
SET
ZarukaVstup	=ISNULL(@ZarukaVstup_U		,ZarukaVstup)
,TypZarukaVstup	=ISNULL(@TypZarukaVstup_U	,TypZarukaVstup)
,ZarukaVystup	=ISNULL(@ZarukaVystup_U		,ZarukaVystup)
,TypZarukaVystup=ISNULL(@TypZarukaVystup_U	,TypZarukaVystup)
,DodaciLhuta	=ISNULL(@DodaciLhuta_U		,DodaciLhuta)
,TypDodaciLhuty	=ISNULL(@TypDodaciLhuty_U	,TypDodaciLhuty)
WHERE ID=@IDKmen
IF @@ERROR<>0 SET @ChybaPriImportu=1
/*Aktualni dodavatel*/
IF @Aktualni_Dodavatel_U IS NOT NULL
IF EXISTS(SELECT ID FROM TabCisOrg WHERE CisloOrg=@Aktualni_Dodavatel_U)
BEGIN
UPDATE TabKmenZbozi SET Aktualni_Dodavatel=@Aktualni_Dodavatel_U WHERE ID=@IDKmen
IF @@ERROR<>0 SET @ChybaPriImportu=1
END
ELSE
BEGIN
SET @ChybaPriImportu=1
IF @TextChybyImportu<>'' SET @TextChybyImportu=@TextChybyImportu + ' | '
SET @TextChybyImportu = @TextChybyImportu + dbo.hpf_UniImportHlasky('8B0B3077-6061-4544-BFD3-E6DADCC06599', @JazykVerze, CAST(@Aktualni_Dodavatel_U AS NVARCHAR(10)), DEFAULT, DEFAULT, DEFAULT)
END
/*Vyrobce*/
IF @Vyrobce_U IS NOT NULL
IF EXISTS(SELECT ID FROM TabCisOrg WHERE CisloOrg=@Vyrobce_U)
BEGIN
UPDATE TabKmenZbozi SET Vyrobce=@Vyrobce_U WHERE ID=@IDKmen
IF @@ERROR<>0 SET @ChybaPriImportu=1
END
ELSE
BEGIN
SET @ChybaPriImportu=1
IF @TextChybyImportu<>'' SET @TextChybyImportu=@TextChybyImportu + ' | '
SET @TextChybyImportu = @TextChybyImportu + dbo.hpf_UniImportHlasky('B497DA2F-6958-4357-871C-B95842DE3BE3', @JazykVerze, CAST(@Vyrobce_U AS NVARCHAR(10)), DEFAULT, DEFAULT, DEFAULT)
END
IF	   @Minimum_Dodavatel_U	IS NOT NULL
OR @Minimum_Odberatel_U	IS NOT NULL
OR @Sirka_U				IS NOT NULL
OR @Vyska_U				IS NOT NULL
OR @Hloubka_U			IS NOT NULL
OR @Objem_U				IS NOT NULL
OR @Hmotnost_U			IS NOT NULL
OR @VychoziMnozstvi_U	IS NOT NULL
OR @PrepMnozstvi_U		IS NOT NULL
UPDATE TabKmenZbozi
SET  Minimum_Dodavatel	=ISNULL(@Minimum_Dodavatel_U, Minimum_Dodavatel)
,Minimum_Odberatel	=ISNULL(@Minimum_Odberatel_U, Minimum_Odberatel)
,Sirka				=ISNULL(@Sirka_U			, Sirka)
,Vyska				=ISNULL(@Vyska_U			, Vyska)
,Hloubka			=ISNULL(@Hloubka_U			, Hloubka)
,Objem				=ISNULL(@Objem_U			, Objem)
,Hmotnost			=ISNULL(@Hmotnost_U			, Hmotnost)
,VychoziMnozstvi	=ISNULL(@VychoziMnozstvi_U	, VychoziMnozstvi)
,PrepMnozstvi		=ISNULL(@PrepMnozstvi_U		, PrepMnozstvi)
WHERE ID=@IDKmen
IF @@ERROR<>0 SET @ChybaPriImportu=1
/*SazbaDPHVstup*/
IF @SazbaDPHVstup_U IS NOT NULL
IF dbo.hpf_UniImportExistujeSazbaDPH(@SazbaDPHVstup_U, NULL) = 1
BEGIN
UPDATE TabKmenZbozi SET SazbaDPHVstup=@SazbaDPHVstup_U WHERE ID=@IDKmen
IF @@ERROR<>0 SET @ChybaPriImportu=1
END
ELSE
BEGIN
SET @ChybaPriImportu=1
IF @TextChybyImportu<>'' SET @TextChybyImportu=@TextChybyImportu + ' | '
SET @TextChybyImportu = @TextChybyImportu + dbo.hpf_UniImportHlasky('593FB54F-C1E7-48E4-996E-C499F540EF4F', @JazykVerze, CAST(@SazbaDPHVstup_U AS NVARCHAR(20)), DEFAULT, DEFAULT, DEFAULT)
END
/*SazbaDPHVystup*/
IF @SazbaDPHVystup_U IS NOT NULL
IF dbo.hpf_UniImportExistujeSazbaDPH(@SazbaDPHVystup_U, NULL) = 1
BEGIN
UPDATE TabKmenZbozi SET SazbaDPHVystup=@SazbaDPHVystup_U WHERE ID=@IDKmen
IF @@ERROR<>0 SET @ChybaPriImportu=1
END
ELSE
BEGIN
SET @ChybaPriImportu=1
IF @TextChybyImportu<>'' SET @TextChybyImportu=@TextChybyImportu + ' | '
SET @TextChybyImportu = @TextChybyImportu + dbo.hpf_UniImportHlasky('593FB54F-C1E7-48E4-996E-C499F540EF4F', @JazykVerze, CAST(@SazbaDPHVystup_U AS NVARCHAR(20)), DEFAULT, DEFAULT, DEFAULT)
END
/*CelniNomenklatura*/
IF @CelniNomenklatura_U IS NOT NULL UPDATE TabKmenZbozi SET CelniNomenklatura=@CelniNomenklatura_U WHERE ID=@IDKmen
IF @@ERROR<>0 SET @ChybaPriImportu=1
IF (@ChybaPriImportu=0)AND((SELECT CLOPopisZbozi FROM TabKmenZbozi WHERE ID=@IDKmen) IS NULL)
BEGIN
SET @CLOPopisZbozi=(SELECT TOP 1 ZboziText FROM dbo.TabClaEcit WHERE Nomenklatura=@CelniNomenklatura AND DopKod=ISNULL(@DopKod, '00'))
UPDATE TabKmenZbozi SET CLOPopisZbozi=@CLOPopisZbozi WHERE ID=@IDKmen
END
/*IdSortiment*/
IF @IdSortiment_U IS NOT NULL
BEGIN
SET @IdSortPom=(SELECT ID FROM TabSortiment WHERE KatAllTecky=@IdSortiment_U)
IF @IdSortPom IS NOT NULL
BEGIN
UPDATE TabKmenZbozi SET IdSortiment=@IdSortPom WHERE ID=@IDKmen
IF @@ERROR<>0 SET @ChybaPriImportu=1
END
ELSE
BEGIN
SET @ChybaPriImportu=1
IF @TextChybyImportu<>'' SET @TextChybyImportu=@TextChybyImportu + ' | '
SET @TextChybyImportu = @TextChybyImportu + dbo.hpf_UniImportHlasky('FFFFEEC2-6C60-40D1-84D8-854C408A6F4D', @JazykVerze, @IdSortiment_U, DEFAULT, DEFAULT, DEFAULT)
END
END
/*BarCode*/
IF @BarCode IS NOT NULL
IF @BarCode<>''
BEGIN
IF NOT EXISTS(SELECT * FROM TabBarCodeZbo WHERE BarCode=@BarCode)
  INSERT TabBarCodeZbo(IDKmenZbo, BarCode, DoplnkovyKod) VALUES(@IDKmen, @BarCode, @DoplnkovyKod)
ELSE
BEGIN
IF EXISTS(SELECT * FROM TabBarCodeZbo WHERE BarCode=@BarCode AND IDKmenZbo<>@IDKmen)
BEGIN
SET @ChybaPriImportu=1
IF @TextChybyImportu<>'' SET @TextChybyImportu=@TextChybyImportu + ' | '
SET @TextChybyImportu = @TextChybyImportu + dbo.hpf_UniImportHlasky('B3371D78-2C40-447D-ADDF-7EA82198480C', @JazykVerze, @BarCode, DEFAULT, DEFAULT, DEFAULT)
END
ELSE
BEGIN
  IF (ISNULL(@DoplnkovyKod, '')<>'')AND(@ChybaPriImportu=0)AND(ISNULL(@DoplnkovyKod_B, 0)=1)
    UPDATE TabBarCodeZbo SET DoplnkovyKod=@DoplnkovyKod WHERE BarCode=@BarCode
END
END
END
IF (ISNULL(@KodZbozi_U, '')<>'')AND(@ChybaPriImportu=0)
BEGIN
SET @IDKodPDP=(SELECT ID FROM TabCisKoduPDP WHERE KodZbozi=@KodZbozi_U)
IF @IDKodPDP IS NULL
BEGIN
SET @ChybaPriImportu=1
IF @TextChybyImportu<>'' SET @TextChybyImportu=@TextChybyImportu + ' | '
SET @TextChybyImportu = @TextChybyImportu + dbo.hpf_UniImportHlasky('4E6E8339-BE7B-4A8B-8C5A-D82DFFC78849', @JazykVerze, ISNULL(@KodZbozi_U, ''), DEFAULT, DEFAULT, DEFAULT)
END
ELSE
UPDATE TabKmenZbozi SET IDKodPDP=@IDKodPDP WHERE ID=@IDKmen
END
IF @UKod_U IS NOT NULL
BEGIN
IF NOT EXISTS(SELECT * FROM TabSkupUKod WHERE ID=@UKod_U)
BEGIN
SET @ChybaPriImportu=1
IF @TextChybyImportu<>'' SET @TextChybyImportu=@TextChybyImportu + ' | '
SET @TextChybyImportu = @TextChybyImportu + dbo.hpf_UniImportHlasky('A9340307-9957-4D2C-BE6C-4E35F106D06D', @JazykVerze, DEFAULT, DEFAULT, DEFAULT, DEFAULT)
END
ELSE
UPDATE TabKmenZbozi SET UKod=@UKod_U WHERE ID=@IDKmen
END
IF ISNULL(@CisloUcetPrijem_U, '')<>'' 
BEGIN
IF NOT EXISTS(SELECT * FROM TabCisUct WHERE CisloUcet=@CisloUcetPrijem_U)
BEGIN
SET @ChybaPriImportu=1
IF @TextChybyImportu<>'' SET @TextChybyImportu=@TextChybyImportu + ' | '
SET @TextChybyImportu = @TextChybyImportu + dbo.hpf_UniImportHlasky('DDD57F75-B6F7-4647-8D32-6AFB8447E1D7', @JazykVerze, @CisloUcetPrijem_U, DEFAULT, DEFAULT, DEFAULT)
END
ELSE
UPDATE TabKmenZbozi SET CisloUcetPrijem=@CisloUcetPrijem_U WHERE ID=@IDKmen
END
IF ISNULL(@CisloUcetVydej_U, '')<>'' 
BEGIN
IF NOT EXISTS(SELECT * FROM TabCisUct WHERE CisloUcet=@CisloUcetVydej_U)
BEGIN
SET @ChybaPriImportu=1
IF @TextChybyImportu<>'' SET @TextChybyImportu=@TextChybyImportu + ' | '
SET @TextChybyImportu = @TextChybyImportu + dbo.hpf_UniImportHlasky('DDD57F75-B6F7-4647-8D32-6AFB8447E1D7', @JazykVerze, @CisloUcetVydej_U, DEFAULT, DEFAULT, DEFAULT)
END
ELSE
UPDATE TabKmenZbozi SET CisloUcetVydej=@CisloUcetVydej_U WHERE ID=@IDKmen
END
IF ISNULL(@CisloUcetVydejEC_U, '')<>'' 
BEGIN
IF NOT EXISTS(SELECT * FROM TabCisUct WHERE CisloUcet=@CisloUcetVydejEC_U)
BEGIN
SET @ChybaPriImportu=1
IF @TextChybyImportu<>'' SET @TextChybyImportu=@TextChybyImportu + ' | '
SET @TextChybyImportu = @TextChybyImportu + dbo.hpf_UniImportHlasky('DDD57F75-B6F7-4647-8D32-6AFB8447E1D7', @JazykVerze, @CisloUcetVydejEC_U, DEFAULT, DEFAULT, DEFAULT)
END
ELSE
UPDATE TabKmenZbozi SET CisloUcetVydejEC=@CisloUcetVydejEC_U WHERE ID=@IDKmen
END
IF ISNULL(@CisloUcetFAPrij_U, '')<>'' 
BEGIN
IF NOT EXISTS(SELECT * FROM TabCisUct WHERE CisloUcet=@CisloUcetFAPrij_U)
BEGIN
SET @ChybaPriImportu=1
IF @TextChybyImportu<>'' SET @TextChybyImportu=@TextChybyImportu + ' | '
SET @TextChybyImportu = @TextChybyImportu + dbo.hpf_UniImportHlasky('DDD57F75-B6F7-4647-8D32-6AFB8447E1D7', @JazykVerze, @CisloUcetFAPrij_U, DEFAULT, DEFAULT, DEFAULT)
END
ELSE
UPDATE TabKmenZbozi SET CisloUcetFAPrij=@CisloUcetFAPrij_U WHERE ID=@IDKmen
END
IF ISNULL(@CisloUcetFAVyd_U, '')<>'' 
BEGIN
IF NOT EXISTS(SELECT * FROM TabCisUct WHERE CisloUcet=@CisloUcetFAVyd_U)
BEGIN
SET @ChybaPriImportu=1
IF @TextChybyImportu<>'' SET @TextChybyImportu=@TextChybyImportu + ' | '
SET @TextChybyImportu = @TextChybyImportu + dbo.hpf_UniImportHlasky('DDD57F75-B6F7-4647-8D32-6AFB8447E1D7', @JazykVerze, @CisloUcetFAVyd_U, DEFAULT, DEFAULT, DEFAULT)
END
ELSE
UPDATE TabKmenZbozi SET CisloUcetFAVyd=@CisloUcetFAVyd_U WHERE ID=@IDKmen
END
SET @SQLString=''
IF (@ExtAtr1 IS NOT NULL)AND(@ExtAtr1Nazev IS NOT NULL)
BEGIN
IF (OBJECT_ID('TabKmenZbozi_EXT','U')IS NOT NULL)AND(COLUMNPROPERTY(OBJECT_ID('TabKmenZbozi_EXT','U'),'_'+@ExtAtr1Nazev,'AllowsNull')IS NOT NULL)
BEGIN
SET @ExtAtr1Nazev='_' + @ExtAtr1Nazev
IF EXISTS(SELECT ID FROM TabKmenZbozi_EXT WHERE ID=@IDKmen)
BEGIN
IF @ExtAtr1_B=1
SET @SQLString='UPDATE TabKmenZbozi_EXT SET ' + @ExtAtr1Nazev + '=N' + '''' + @ExtAtr1 + '''' + ' WHERE ID=' + CAST(@IDKmen AS NVARCHAR(10))
END
ELSE
SET @SQLString='INSERT TabKmenZbozi_EXT(ID, ' + @ExtAtr1Nazev + ') VALUES(' + CAST(@IDKmen AS NVARCHAR(10)) + ', N' + '''' + @ExtAtr1 + '''' + ')'
EXEC sp_executesql @SQLString
END
ELSE
BEGIN
SET @ChybaPriImportu=1
IF @TextChybyImportu<>'' SET @TextChybyImportu=@TextChybyImportu + ' | '
SET @TextChybyImportu = @TextChybyImportu + dbo.hpf_UniImportHlasky('15364319-B20F-4D65-8900-391DE8D4C52F', @JazykVerze, '_'+@ExtAtr1Nazev, DEFAULT, DEFAULT, DEFAULT)
END
END
SET @SQLString=''
IF (@ExtAtr2 IS NOT NULL)AND(@ExtAtr2Nazev IS NOT NULL)
IF (OBJECT_ID('TabKmenZbozi_EXT','U')IS NOT NULL)AND(COLUMNPROPERTY(OBJECT_ID('TabKmenZbozi_EXT','U'),'_'+@ExtAtr2Nazev,'AllowsNull')IS NOT NULL)
BEGIN
SET @ExtAtr2Nazev='_' + @ExtAtr2Nazev
IF EXISTS(SELECT ID FROM TabKmenZbozi_EXT WHERE ID=@IDKmen)
BEGIN
IF @ExtAtr2_B=1
SET @SQLString='UPDATE TabKmenZbozi_EXT SET ' + @ExtAtr2Nazev + '=N' + '''' + @ExtAtr2 + '''' + ' WHERE ID=' + CAST(@IDKmen AS NVARCHAR(10))
END
ELSE
SET @SQLString='INSERT TabKmenZbozi_EXT(ID, ' + @ExtAtr2Nazev + ') VALUES(' + CAST(@IDKmen AS NVARCHAR(10)) + ', N' + '''' + @ExtAtr2 + '''' + ')'
EXECUTE sp_executesql @SQLString
END
ELSE
BEGIN
SET @ChybaPriImportu=1
IF @TextChybyImportu<>'' SET @TextChybyImportu=@TextChybyImportu + ' | '
SET @TextChybyImportu = @TextChybyImportu + dbo.hpf_UniImportHlasky('15364319-B20F-4D65-8900-391DE8D4C52F', @JazykVerze, '_'+@ExtAtr2Nazev, DEFAULT, DEFAULT, DEFAULT)
END
SET @SQLString=''
IF (@ExtAtr3 IS NOT NULL)AND(@ExtAtr3Nazev IS NOT NULL)
IF (OBJECT_ID('TabKmenZbozi_EXT','U')IS NOT NULL)AND(COLUMNPROPERTY(OBJECT_ID('TabKmenZbozi_EXT','U'),'_'+@ExtAtr3Nazev,'AllowsNull')IS NOT NULL)
BEGIN
SET @ExtAtr3Nazev='_' + @ExtAtr3Nazev
IF EXISTS(SELECT ID FROM TabKmenZbozi_EXT WHERE ID=@IDKmen)
BEGIN
IF @ExtAtr3_B=1
SET @SQLString='UPDATE TabKmenZbozi_EXT SET ' + @ExtAtr3Nazev + '=' + '''' + CONVERT(NVARCHAR(10),@ExtAtr3, 112) + '''' + ' WHERE ID=' + CAST(@IDKmen AS NVARCHAR(10))
END
ELSE
SET @SQLString='INSERT TabKmenZbozi_EXT(ID, ' + @ExtAtr3Nazev + ') VALUES(' + CAST(@IDKmen AS NVARCHAR(10)) + ', ' + '''' + CONVERT(NVARCHAR(10),@ExtAtr3, 112) + '''' + ')'
EXECUTE sp_executesql @SQLString
END
ELSE
BEGIN
SET @ChybaPriImportu=1
IF @TextChybyImportu<>'' SET @TextChybyImportu=@TextChybyImportu + ' | '
SET @TextChybyImportu = @TextChybyImportu + dbo.hpf_UniImportHlasky('15364319-B20F-4D65-8900-391DE8D4C52F', @JazykVerze, '_'+@ExtAtr3Nazev, DEFAULT, DEFAULT, DEFAULT)
END
SET @SQLString=''
IF (@ExtAtr4 IS NOT NULL)AND(@ExtAtr4Nazev IS NOT NULL)
IF (OBJECT_ID('TabKmenZbozi_EXT','U')IS NOT NULL)AND(COLUMNPROPERTY(OBJECT_ID('TabKmenZbozi_EXT','U'),'_'+@ExtAtr4Nazev,'AllowsNull')IS NOT NULL)
BEGIN
SET @ExtAtr4Nazev='_' + @ExtAtr4Nazev
IF EXISTS(SELECT ID FROM TabKmenZbozi_EXT WHERE ID=@IDKmen)
BEGIN
IF @ExtAtr4_B=1
SET @SQLString='UPDATE TabKmenZbozi_EXT SET ' + @ExtAtr4Nazev + '=' + CAST(@ExtAtr4 AS NVARCHAR(26)) +  ' WHERE ID=' + CAST(@IDKmen AS NVARCHAR(10))
END
ELSE
SET @SQLString='INSERT TabKmenZbozi_EXT(ID, ' + @ExtAtr4Nazev + ') VALUES(' + CAST(@IDKmen AS NVARCHAR(10)) + ', ' + CAST(@ExtAtr4 AS NVARCHAR(26)) + ')'
EXECUTE sp_executesql @SQLString
END
ELSE
BEGIN
SET @ChybaPriImportu=1
IF @TextChybyImportu<>'' SET @TextChybyImportu=@TextChybyImportu + ' | '
SET @TextChybyImportu = @TextChybyImportu + dbo.hpf_UniImportHlasky('15364319-B20F-4D65-8900-391DE8D4C52F', @JazykVerze, '_'+@ExtAtr4Nazev, DEFAULT, DEFAULT, DEFAULT)
END
SET @SQLString=''
IF (@ExtAtr5 IS NOT NULL)AND(@ExtAtr5Nazev IS NOT NULL)
IF (OBJECT_ID('TabKmenZbozi_EXT','U')IS NOT NULL)AND(COLUMNPROPERTY(OBJECT_ID('TabKmenZbozi_EXT','U'),'_'+@ExtAtr5Nazev,'AllowsNull')IS NOT NULL)
BEGIN
SET @ExtAtr5Nazev='_' + @ExtAtr5Nazev
IF EXISTS(SELECT ID FROM TabKmenZbozi_EXT WHERE ID=@IDKmen)
BEGIN
IF @ExtAtr5_B=1
SET @SQLString='UPDATE TabKmenZbozi_EXT SET ' + @ExtAtr5Nazev + '=N' + '''' + @ExtAtr5 + '''' + ' WHERE ID=' + CAST(@IDKmen AS NVARCHAR(10))
END
ELSE
SET @SQLString='INSERT TabKmenZbozi_EXT(ID, ' + @ExtAtr5Nazev + ') VALUES(' + CAST(@IDKmen AS NVARCHAR(10)) + ', N' + '''' + @ExtAtr5 + '''' + ')'
EXECUTE sp_executesql @SQLString
END
ELSE
BEGIN
SET @ChybaPriImportu=1
IF @TextChybyImportu<>'' SET @TextChybyImportu=@TextChybyImportu + ' | '
SET @TextChybyImportu = @TextChybyImportu + dbo.hpf_UniImportHlasky('15364319-B20F-4D65-8900-391DE8D4C52F', @JazykVerze, '_'+@ExtAtr5Nazev, DEFAULT, DEFAULT, DEFAULT)
END
SET @SQLString=''
IF (@ExtAtr6 IS NOT NULL)AND(@ExtAtr6Nazev IS NOT NULL)
IF (OBJECT_ID('TabKmenZbozi_EXT','U')IS NOT NULL)AND(COLUMNPROPERTY(OBJECT_ID('TabKmenZbozi_EXT','U'),'_'+@ExtAtr6Nazev,'AllowsNull')IS NOT NULL)
BEGIN
SET @ExtAtr6Nazev='_' + @ExtAtr6Nazev
IF EXISTS(SELECT ID FROM TabKmenZbozi_EXT WHERE ID=@IDKmen)
BEGIN
IF @ExtAtr6_B=1
SET @SQLString='UPDATE TabKmenZbozi_EXT SET ' + @ExtAtr6Nazev + '=N' + '''' + @ExtAtr6 + '''' + ' WHERE ID=' + CAST(@IDKmen AS NVARCHAR(10))
END
ELSE
SET @SQLString='INSERT TabKmenZbozi_EXT(ID, ' + @ExtAtr6Nazev + ') VALUES(' + CAST(@IDKmen AS NVARCHAR(10)) + ', N' + '''' + @ExtAtr6 + '''' + ')'
EXECUTE sp_executesql @SQLString
END
ELSE
BEGIN
SET @ChybaPriImportu=1
IF @TextChybyImportu<>'' SET @TextChybyImportu=@TextChybyImportu + ' | '
SET @TextChybyImportu = @TextChybyImportu + dbo.hpf_UniImportHlasky('15364319-B20F-4D65-8900-391DE8D4C52F', @JazykVerze, '_'+@ExtAtr6Nazev, DEFAULT, DEFAULT, DEFAULT)
END
SET @SQLString=''
IF (@ExtAtr7 IS NOT NULL)AND(@ExtAtr7Nazev IS NOT NULL)
IF (OBJECT_ID('TabKmenZbozi_EXT','U')IS NOT NULL)AND(COLUMNPROPERTY(OBJECT_ID('TabKmenZbozi_EXT','U'),'_'+@ExtAtr7Nazev,'AllowsNull')IS NOT NULL)
BEGIN
SET @ExtAtr7Nazev='_' + @ExtAtr7Nazev
IF EXISTS(SELECT ID FROM TabKmenZbozi_EXT WHERE ID=@IDKmen)
BEGIN
IF @ExtAtr7_B=1
SET @SQLString='UPDATE TabKmenZbozi_EXT SET ' + @ExtAtr7Nazev + '=N' + '''' + @ExtAtr7 + '''' + ' WHERE ID=' + CAST(@IDKmen AS NVARCHAR(10))
END
ELSE
SET @SQLString='INSERT TabKmenZbozi_EXT(ID, ' + @ExtAtr7Nazev + ') VALUES(' + CAST(@IDKmen AS NVARCHAR(10)) + ', N' + '''' + @ExtAtr7 + '''' + ')'
EXECUTE sp_executesql @SQLString
END
ELSE
BEGIN
SET @ChybaPriImportu=1
IF @TextChybyImportu<>'' SET @TextChybyImportu=@TextChybyImportu + ' | '
SET @TextChybyImportu = @TextChybyImportu + dbo.hpf_UniImportHlasky('15364319-B20F-4D65-8900-391DE8D4C52F', @JazykVerze, '_'+@ExtAtr7Nazev, DEFAULT, DEFAULT, DEFAULT)
END
SET @SQLString=''
IF (@ExtAtr8 IS NOT NULL)AND(@ExtAtr8Nazev IS NOT NULL)
IF (OBJECT_ID('TabKmenZbozi_EXT','U')IS NOT NULL)AND(COLUMNPROPERTY(OBJECT_ID('TabKmenZbozi_EXT','U'),'_'+@ExtAtr8Nazev,'AllowsNull')IS NOT NULL)
BEGIN
SET @ExtAtr8Nazev='_' + @ExtAtr8Nazev
IF EXISTS(SELECT ID FROM TabKmenZbozi_EXT WHERE ID=@IDKmen)
BEGIN
IF @ExtAtr8_B=1
SET @SQLString='UPDATE TabKmenZbozi_EXT SET ' + @ExtAtr8Nazev + '=N' + '''' + @ExtAtr8 + '''' + ' WHERE ID=' + CAST(@IDKmen AS NVARCHAR(10))
END
ELSE
SET @SQLString='INSERT TabKmenZbozi_EXT(ID, ' + @ExtAtr8Nazev + ') VALUES(' + CAST(@IDKmen AS NVARCHAR(10)) + ', N' + '''' + @ExtAtr8 + '''' + ')'
EXECUTE sp_executesql @SQLString
END
ELSE
BEGIN
SET @ChybaPriImportu=1
IF @TextChybyImportu<>'' SET @TextChybyImportu=@TextChybyImportu + ' | '
SET @TextChybyImportu = @TextChybyImportu + dbo.hpf_UniImportHlasky('15364319-B20F-4D65-8900-391DE8D4C52F', @JazykVerze, '_'+@ExtAtr8Nazev, DEFAULT, DEFAULT, DEFAULT)
END
SET @SQLString=''
IF (@ExtAtr9 IS NOT NULL)AND(@ExtAtr9Nazev IS NOT NULL)
IF (OBJECT_ID('TabKmenZbozi_EXT','U')IS NOT NULL)AND(COLUMNPROPERTY(OBJECT_ID('TabKmenZbozi_EXT','U'),'_'+@ExtAtr9Nazev,'AllowsNull')IS NOT NULL)
BEGIN
SET @ExtAtr9Nazev='_' + @ExtAtr9Nazev
IF EXISTS(SELECT ID FROM TabKmenZbozi_EXT WHERE ID=@IDKmen)
BEGIN
IF @ExtAtr9_B=1
SET @SQLString='UPDATE TabKmenZbozi_EXT SET ' + @ExtAtr9Nazev + '=' + CAST(@ExtAtr9 AS NVARCHAR) + ' WHERE ID=' + CAST(@IDKmen AS NVARCHAR(10))
END
ELSE
SET @SQLString='INSERT TabKmenZbozi_EXT(ID, ' + @ExtAtr9Nazev + ') VALUES(' + CAST(@IDKmen AS NVARCHAR(10)) + ', ' + CAST(@ExtAtr9 AS NVARCHAR) + ')'
EXECUTE sp_executesql @SQLString
END
ELSE
BEGIN
SET @ChybaPriImportu=1
IF @TextChybyImportu<>'' SET @TextChybyImportu=@TextChybyImportu + ' | '
SET @TextChybyImportu = @TextChybyImportu + dbo.hpf_UniImportHlasky('15364319-B20F-4D65-8900-391DE8D4C52F', @JazykVerze, '_'+@ExtAtr9Nazev, DEFAULT, DEFAULT, DEFAULT)
END
SET @ChybaExtAtr=''
EXEC dbo.hpx_UniImport_ZpracujExtAtr
  @ImportIdent=4,
  @IdImpTable=@ID,
  @IdTargetTable=@IDKmen,
  @Chyba=@ChybaExtAtr OUT
IF @ChybaExtAtr<>''
BEGIN
  SET @ChybaPriImportu=1
  IF @TextChybyImportu<>'' SET @TextChybyImportu=@TextChybyImportu + ' | '
  SET @TextChybyImportu = @TextChybyImportu + dbo.hpf_UniImportHlasky('15364319-B20F-4D65-8900-391DE8D4C52F', @JazykVerze, @ChybaExtAtr, DEFAULT, DEFAULT, DEFAULT)
END
IF OBJECT_ID('dbo.epx_UniImportKmen03', 'P') IS NOT NULL EXEC dbo.epx_UniImportKmen03 @IDKmen
/*--pokud nedoslo k chybe, smazeme zaznam z importni tabulky*/
IF @@ERROR<>0 SET @ChybaPriImportu=1
IF @ChybaPriImportu=0 DELETE FROM dbo.TabUniImportKmen WHERE ID=@ID
/*--pokud probehlo vsechno OK, pustime transakci, jinak vse vratime zpet*/
IF @ChybaPriImportu=1
BEGIN
IF @@trancount>0 ROLLBACK TRAN T1
UPDATE dbo.TabUniImportKmen SET Chyba=@TextChybyImportu, DatumImportu=GETDATE() WHERE ID=@ID
END
ELSE IF @@trancount>0 COMMIT TRAN T1
END
END
END
END TRY
BEGIN CATCH
  UPDATE TabUniImportKmen SET Chyba=ISNULL(CAST(Chyba AS NVARCHAR(MAX)), N'') + N' !! ' + ISNULL(dbo.hf_TextInterniHlasky(ERROR_MESSAGE(), @JazykVerze), N'') + N' ## ' + ISNULL(ERROR_PROCEDURE(), N'') + N' (Ln ' + ISNULL(CAST(ERROR_LINE() AS NVARCHAR), N'') + N')'  WHERE ID=@ID
END CATCH
/*--PRI PRIDANI NOVE VERZE IMPORTU PRIDAT NOVE PROMENNE I SEM*/
FETCH NEXT FROM c INTO @ID, @InterniVerze, @SkupZbo, @RegCis, @DruhSkladu, @Nazev1, @Nazev2, @Nazev3, @Nazev4, @SKP, @MJEvidence,
@MJvstup, @MJvystup, @MJInventura, @KJDatOd, @KJDatDo, @Vykres, @ZarukaVstup, @TypZarukaVstup, @ZarukaVystup,
@TypZarukaVystup, @DodaciLhuta, @TypDodaciLhuty, @BaleniTXT, @Aktualni_Dodavatel,
@Minimum_Dodavatel, @Minimum_Odberatel, @Sirka, @Vyska, @Hloubka, @Objem, @Hmotnost,
@IdSortiment, @Vyrobce, @VychoziMnozstvi, @PrepMnozstvi, @SazbaDPHVstup, @SazbaDPHVystup,
@CelniNomenklatura, @DopKod, @ObvyklaZemePuvodu, @BarCode, @ExtAtr1, @ExtAtr1Nazev, @ExtAtr2, @ExtAtr2Nazev, @ExtAtr3,
@ExtAtr3Nazev, @ExtAtr4, @ExtAtr4Nazev,
@ExtAtr5, @ExtAtr5Nazev, @ExtAtr6, @ExtAtr6Nazev, @ExtAtr7, @ExtAtr7Nazev, @ExtAtr8, @ExtAtr8Nazev, @ExtAtr9, @ExtAtr9Nazev,
@KontrolaVyrC, @Blokovano, @Minimum_Baleni_Dodavatel, @VykazLihuObjemVML, @VykazLihuProcentoLihu, @VykazLihuKoefKEvidMJ, @Upozorneni, @KodZbozi, @LhutaNaskladneni,
@Poznamka, @UKod,
@CisloUcetPrijem, @CisloUcetVydej, @CisloUcetVydejEC, @CisloUcetFAPrij, @CisloUcetFAVyd, @Sleva,
@KodRecyk, @CastkaHistRecyk, @CastkaGarRecyk, @MJRecyk, @PrepMJRecyk, @ZboziSluzba, @PocetBaleniVeVrstve, @PocetVrstevNaPalete,
@PLUKod, @BodovaHodnota, @DoplnkovyKod
IF @@fetch_status<>0 BREAK
END
CLOSE c
DEALLOCATE c
GO

