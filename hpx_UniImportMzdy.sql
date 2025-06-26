USE [RayService]
GO

/****** Object:  StoredProcedure [dbo].[hpx_UniImportMzdy]    Script Date: 26.06.2025 10:19:33 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

/*rpObecneImporty.Import*/CREATE PROC [dbo].[hpx_UniImportMzdy]
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
SET @PocetRadkuImpTabulky=(SELECT COUNT(*) FROM TabUniImportMzdy WHERE Chyba IS NULL AND ((@PouzeZaznamyDleLogin=1 AND Autor=SUSER_SNAME())OR(@PouzeZaznamyDleLogin=0)) )
SET @InfoText = dbo.hpf_UniImportHlasky('959B5166-6EEF-44A5-B4AC-DA13F5642C08', @JazykVerze, 'TabUniImportMzdy', CAST(@PocetRadkuImpTabulky AS NVARCHAR), DEFAULT, DEFAULT)
IF @InfoText IS NOT NULL
  EXEC dbo.hp_ZapisDoZurnalu 1, 77, @InfoText
IF OBJECT_ID('dbo.epx_UniImportMzdy02', 'P') IS NOT NULL EXEC dbo.epx_UniImportMzdy02
DECLARE @ChybaPriImportu BIT, @TextChybyImportu NVARCHAR(4000), @IDZam INT, @IDObdobi INT, @Rok SMALLINT,
@Symbol_Poradi INT, @Datum_pom DATETIME, @DovNepretzityPP BIT, @DovolenaNarok DECIMAL(4,1), @RokKalendare SMALLINT,
@IdVozidlo_ID INT, @DenniUvazekKal NUMERIC(9,2), @RodneCislo_TEMP NVARCHAR(11),
@PorCislo INT, @IDUstavu INT, @IDUctu INT, @IDPausal INT, @TEMPSTR NVARCHAR(20), @NazevBankSpoj NVARCHAR(100), @IdTabZamMzd INT, @ResultDov BIT
DECLARE @KodCinnosti TINYINT, @KodCinnosti_Dflt INT, @JeKodOK BIT, @VstupniFormular TINYINT
DECLARE @ID INT, @InterniVerze INT, @Cislo INT, @RodneCislo NVARCHAR(11), @Alias NVARCHAR(15), @DatumVznikuPP DATETIME, @DruhPP TINYINT,
@DatumVynetiES DATETIME, @DatumUkonceniPP DATETIME, @DuvodVynetiES TINYINT, @DatumNavratuES DATETIME,
@DatumZmenyVynetiES DATETIME, @ZmenaDuvoduVynetiES TINYINT, @DruhMzdyMesHod SMALLINT, @MSZakladniMzda INT,
@ZakladniPlat NUMERIC(19,2), @DruhKalendare NVARCHAR(3), @TydenniUvazek NUMERIC(9,2), @DenniUvazek NUMERIC(9,2),
@ROPocatek DATETIME, @DovPrumer NUMERIC(19,6), @DNPPrumer NUMERIC(19,6), @BlokMinMzdy TINYINT,
@Automat BIT, @KontrolaMesFondu BIT, @AutomDopocetHodin BIT, @DNPvPodpurciDobe BIT, @SrazitZP_MVZ BIT,
@OcrOsamelyPrac BIT, @DovOmlAbsBR NUMERIC(9,2), @DovNeomlAbsBR NUMERIC(9,2), @DovCerpaniBR NUMERIC(9,2),
@KalDnyNemDuch NUMERIC(9,2), @PrescasyHodin NUMERIC(9,2), @PohotovostHodin NUMERIC(9,2), @DohodaPPHodin NUMERIC(9,2),
@ZamestnaniRoky TINYINT, @ZamestnaniDny SMALLINT, @PraxeRoky TINYINT, @PraxeDny SMALLINT, @DanitMzdu BIT,
@TypDane TINYINT, @Odpocet1Mesic BIT, @Sleva_S_CID BIT, @Sleva_S_PID BIT, @Sleva_S_POP BIT, @Sleva_S_STD BIT,
@Sleva_S_ZTPP BIT, @PocitatZdrPoj TINYINT, @ZdravPojistovna NVARCHAR(3), @CisloPojistence NVARCHAR(15), @SlevaZP1Mesic BIT, @PouzitMinZakZP BIT,
@PocitatSocPoj TINYINT, @SocPojDatumOd DATETIME, @DovNarokZakladni NUMERIC(9,2), @DovPredminRok_N NUMERIC(9,2),
@DovMinulyRok_S NUMERIC(9,2), @DovMinulyRok_N NUMERIC(9,2), @DovKraceniRucne NUMERIC(9,2), @DovProlpOdchod BIT,
@DovNadLimit TINYINT, @DovKraceni NUMERIC(9,2), @Stredisko NVARCHAR(30), @IdVozidlo NVARCHAR(20),
@Zakazka NVARCHAR(15), @NakladovyOkruh NVARCHAR(15), @VyzivovanychOsob SMALLINT, @UcetniSkupina SMALLINT,
@KodVzdelani NVARCHAR(3), @ZPS SMALLINT, @Kzam NVARCHAR(8), @ProfeseCislo NVARCHAR(6), @ProfeseNazev NVARCHAR(100), @Pracoviste_NUTS NVARCHAR(6), @KodPostaveni NVARCHAR(6), @DruhDuchodu SMALLINT, @DatumNaroku DATETIME, @DatumPriznani DATETIME,
@ZakladniMzdaZkr NUMERIC(19,2), @RodinnyPrislusnik BIT, @Pausal BIT, @PrijmeniRP NVARCHAR(100), @JmenoRP NVARCHAR(100),
@RodneCisloRP NVARCHAR(11), @DatumNarozeniRP DATETIME, @VztahRP TINYINT, @Sleva_Z_DT BIT, @Sleva_Z_DTZP BIT, @CisloMS INT, @Koruny NUMERIC(19,2),
@DatumOd DATETIME, @Platnost_1_12 BIT, @Platnost_UKPP BIT, @DatumDo DATETIME, @CisloUctu NVARCHAR(40), @KodUstavu NVARCHAR(15), @VariabilniSymbol NVARCHAR(20),
@KonstantniSymbol NVARCHAR(10), @SpecifickySymbol NVARCHAR(10), @DatumOdRP DATETIME,
@DatumDoRP DATETIME, @CelkemSrazit NUMERIC(19,2), @MzdovaUcetni NVARCHAR(20), @Mistr NVARCHAR(20), @VyplatniStredisko NVARCHAR(20), @MzdovyUtvar NVARCHAR(20),
@ProcentoTEMP NUMERIC(5,2), @CisloSmlouvyPF NVARCHAR(30), @DosudSrazeno NUMERIC(19,2), @Procento NUMERIC(5,2), @Pobocka NVARCHAR(5),
@VedeniZamest BIT, @Pracoviste_Zeme NVARCHAR(3), @AdrTrvZeme NVARCHAR(3), @CzIsco NVARCHAR(7), @PracovisteId NVARCHAR(30),
@KodUzemi NVARCHAR(20), @KodUzemiNazev NVARCHAR(255), @DuvodUkonceniPP NVARCHAR(10), @DalsiPP INT, @ZamMRozsahu BIT, @Odbory BIT, @OdboryMS INT,
@OdboryMinSrazit NUMERIC(19,2), @OdboryMaxSrazit NUMERIC(19,2),
@VypovedLhutaOd DATETIME, @VypovedUkonceniPP DATETIME, @ZkusebniDoba DATETIME, @NerezidentDane BIT, @DuchSporeni_Od DATETIME,
@MenaBankSpoj NVARCHAR(3), @DatumDoruceni DATETIME, @IBANElektronicky NVARCHAR(40), @CisloBSUcto INT, @Kategorie NVARCHAR(10), @PoznamkaRP NVARCHAR(MAX),
@Platnost_1 BIT, @Platnost_2 BIT, @Platnost_3 BIT, @Platnost_4 BIT, @Platnost_5 BIT, @Platnost_6 BIT, @Platnost_7 BIT, @Platnost_8 BIT, @Platnost_9 BIT, @Platnost_10 BIT, @Platnost_11 BIT, @Platnost_12 BIT,
@Dan_PodpisProhl BIT, @KodCinnosti_SP TINYINT, @ZahrPojistne BIT, @PlatovaTrida NVARCHAR(2), @PlatovyStupen NVARCHAR(2), @Odstavec SMALLINT,
@Skola NVARCHAR(255), @Zkouska NVARCHAR(50), @Ukonceno DATETIME, @Sleva_Z_DT2 BIT, @Sleva_Z_DT3 BIT, @Sleva_Z_DTZ2 BIT, @Sleva_Z_DTZ3 BIT, @KoefZkrUvazek NUMERIC(19,6),
@VekAut_Vypnout BIT, @OdborVzd NVARCHAR(30), @RocniMSKontejner1 NUMERIC(19,2), @RocniMSKontejner2 NUMERIC(19,2), @RocniMSKontejner3 NUMERIC(19,2), @RocniMSKontejner4 NUMERIC(19,2),
@Hodiny NUMERIC(9,2), @Sazba NUMERIC(19,6), @DruhMzdyMesHodCis TINYINT, @SVR_Deponovano BIT, @SVR_NabytiPM DATETIME, @SVR_Vystavitel INT,
@BonusDny_Narok NUMERIC(9,2), @PocetVychDeti SMALLINT, @DruhMzdy NVARCHAR(2), @DatumFuze DATETIME, @ZakladSocPoj NUMERIC(19,2), @ZakladSocPojNeohr NUMERIC(19,2),
@DovVykonPraceBR NUMERIC(9,2), @DatumOdeslani DATETIME, @ZM_CM_Castka NUMERIC(19,6), @ZM_CM_Kod NVARCHAR(3), @ZM_CM_Kurz NUMERIC(19,6), @CM_Zaokrouhleni SMALLINT,
@SWIFTUstavu NVARCHAR(15), @DnyVykonuPrace NUMERIC(9,2), @DatumVypovedi DATETIME, @PrispevkyPFaZP NUMERIC(19,2), @DovZustatekMR NUMERIC(9,2),
@DovZustMR_DplUdaj NUMERIC(9,2), @DovKraceniNeomlA NUMERIC(9,2), @PoznamkaPaus NVARCHAR(255)
SET @IDObdobi=(SELECT IdObdobi FROM TabMzdObd WHERE Stav=1)
SET @Rok=(SELECT Rok FROM TabMzdObd WHERE IdObdobi=@IDObdobi)
DECLARE c CURSOR LOCAL FAST_FORWARD FOR
/*PRI PRIDANI NOVE VERZE IMPORTU PRIDAT NOVE PROMENNE I SEM*/----------------------------------------
SELECT ID, InterniVerze, Cislo, RodneCislo, DatumVznikuPP, DruhPP, DatumVynetiES, DatumUkonceniPP, DuvodVynetiES, DatumNavratuES,
DatumZmenyVynetiES, ZmenaDuvoduVynetiES, DruhMzdyMesHod, MSZakladniMzda, ZakladniPlat, DruhKalendare, TydenniUvazek, DenniUvazek,
ROPocatek, DovPrumer, DNPPrumer, BlokMinMzdy, Automat, KontrolaMesFondu, AutomDopocetHodin, DNPvPodpurciDobe, SrazitZP_MVZ,
OcrOsamelyPrac, DovOmlAbsBR, DovNeomlAbsBR, DovCerpaniBR, KalDnyNemDuch, PrescasyHodin, PohotovostHodin, DohodaPPHodin,
ZamestnaniRoky, ZamestnaniDny, PraxeRoky, PraxeDny, DanitMzdu, TypDane, Odpocet1Mesic, Sleva_S_CID, Sleva_S_PID, Sleva_S_POP,
Sleva_S_STD, Sleva_S_ZTPP, PocitatZdrPoj, ZdravPojistovna, CisloPojistence, SlevaZP1Mesic, PouzitMinZakZP, PocitatSocPoj, SocPojDatumOd,
DovNarokZakladni, DovPredminRok_N, DovMinulyRok_S, DovMinulyRok_N, DovKraceniRucne, DovProlpOdchod, DovNadLimit, DovKraceni,
DovNepretzityPP, Stredisko, IdVozidlo, Zakazka, NakladovyOkruh, VyzivovanychOsob, UcetniSkupina, KodVzdelani, ZPS,
Kzam, ProfeseCislo, ProfeseNazev, Pracoviste_NUTS, KodPostaveni, VedeniZamest, Pracoviste_Zeme, DruhDuchodu, DatumNaroku, DatumPriznani, ZakladniMzdaZkr, RodinnyPrislusnik, Pausal, PrijmeniRP, JmenoRP, RodneCisloRP,
VztahRP, Sleva_Z_DT, Sleva_Z_DTZP, CisloMS, Koruny, DatumOd, Platnost_1_12, CisloUctu, KodUstavu,
VariabilniSymbol, KonstantniSymbol, SpecifickySymbol, DatumOdRP, DatumDoRP, CelkemSrazit, MzdovaUcetni, Mistr, VyplatniStredisko, MzdovyUtvar, NazevBankSpoj, CisloSmlouvyPF,
DosudSrazeno, Procento, Pobocka, AdrTrvZeme, CzIsco, PracovisteId, KodUzemi, KodUzemiNazev, DuvodUkonceniPP, DalsiPP, ZamMRozsahu, Odbory, OdboryMS, OdboryMinSrazit, OdboryMaxSrazit,
DatumDo, Platnost_UKPP, VypovedLhutaOd, VypovedUkonceniPP, ZkusebniDoba, NerezidentDane, DuchSporeni_Od, DatumNarozeniRP, MenaBankSpoj, DatumDoruceni, IBANElektronicky, CisloBSUcto, Kategorie, PoznamkaRP,
Platnost_1, Platnost_2, Platnost_3, Platnost_4, Platnost_5, Platnost_6, Platnost_7, Platnost_8, Platnost_9, Platnost_10, Platnost_11, Platnost_12, Dan_PodpisProhl, KodCinnosti_SP, ZahrPojistne,
PlatovaTrida, PlatovyStupen, Odstavec, Skola, Zkouska, Ukonceno, Sleva_Z_DT2, Sleva_Z_DT3, Sleva_Z_DTZ2, Sleva_Z_DTZ3, KoefZkrUvazek, VekAut_Vypnout, OdborVzd,
RocniMSKontejner1, RocniMSKontejner2, RocniMSKontejner3, RocniMSKontejner4, Hodiny, Sazba, SVR_Deponovano, SVR_NabytiPM, SVR_Vystavitel, BonusDny_Narok, Alias, PocetVychDeti, DruhMzdy,
DatumFuze, ZakladSocPoj, ZakladSocPojNeohr, DovVykonPraceBR, DatumOdeslani, ZM_CM_Castka, ZM_CM_Kod, SWIFTUstavu, DnyVykonuPrace, DatumVypovedi,
PrispevkyPFaZP, DovZustatekMR, DovZustMR_DplUdaj, DovKraceniNeomlA, PoznamkaPaus
FROM dbo.TabUniImportMzdy
WHERE Chyba IS NULL
 AND ((@PouzeZaznamyDleLogin=1 AND Autor=SUSER_SNAME())OR(@PouzeZaznamyDleLogin=0)) 
ORDER BY ID ASC
OPEN c
/*PRI PRIDANI NOVE VERZE IMPORTU PRIDAT NOVE PROMENNE I SEM*/----------------------------------------
FETCH NEXT FROM c INTO @ID, @InterniVerze, @Cislo, @RodneCislo, @DatumVznikuPP, @DruhPP, @DatumVynetiES, @DatumUkonceniPP,
@DuvodVynetiES, @DatumNavratuES, @DatumZmenyVynetiES, @ZmenaDuvoduVynetiES, @DruhMzdyMesHod, @MSZakladniMzda,
@ZakladniPlat, @DruhKalendare, @TydenniUvazek, @DenniUvazek, @ROPocatek, @DovPrumer, @DNPPrumer,
@BlokMinMzdy, @Automat, @KontrolaMesFondu, @AutomDopocetHodin, @DNPvPodpurciDobe, @SrazitZP_MVZ,
@OcrOsamelyPrac, @DovOmlAbsBR, @DovNeomlAbsBR, @DovCerpaniBR, @KalDnyNemDuch, @PrescasyHodin,
@PohotovostHodin, @DohodaPPHodin, @ZamestnaniRoky, @ZamestnaniDny, @PraxeRoky, @PraxeDny, @DanitMzdu,
@TypDane, @Odpocet1Mesic, @Sleva_S_CID, @Sleva_S_PID, @Sleva_S_POP, @Sleva_S_STD, @Sleva_S_ZTPP,
@PocitatZdrPoj, @ZdravPojistovna, @CisloPojistence, @SlevaZP1Mesic, @PouzitMinZakZP, @PocitatSocPoj, @SocPojDatumOd,
@DovNarokZakladni, @DovPredminRok_N, @DovMinulyRok_S, @DovMinulyRok_N, @DovKraceniRucne, @DovProlpOdchod,
@DovNadLimit, @DovKraceni, @DovNepretzityPP, @Stredisko, @IdVozidlo, @Zakazka, @NakladovyOkruh,
@VyzivovanychOsob, @UcetniSkupina, @KodVzdelani, @ZPS, @Kzam, @ProfeseCislo, @ProfeseNazev, @Pracoviste_NUTS, @KodPostaveni, @VedeniZamest, @Pracoviste_Zeme, @DruhDuchodu, @DatumNaroku, @DatumPriznani,
@ZakladniMzdaZkr, @RodinnyPrislusnik, @Pausal, @PrijmeniRP, @JmenoRP, @RodneCisloRP, @VztahRP,
@Sleva_Z_DT, @Sleva_Z_DTZP, @CisloMS, @Koruny, @DatumOd, @Platnost_1_12, @CisloUctu, @KodUstavu,
@VariabilniSymbol, @KonstantniSymbol, @SpecifickySymbol, @DatumOdRP, @DatumDoRP, @CelkemSrazit, @MzdovaUcetni, @Mistr, @VyplatniStredisko, @MzdovyUtvar,
@NazevBankSpoj, @CisloSmlouvyPF, @DosudSrazeno, @Procento, @Pobocka, @AdrTrvZeme, @CzIsco, @PracovisteId, @KodUzemi, @KodUzemiNazev, @DuvodUkonceniPP, @DalsiPP,
@ZamMRozsahu, @Odbory, @OdboryMS, @OdboryMinSrazit, @OdboryMaxSrazit, @DatumDo, @Platnost_UKPP,
@VypovedLhutaOd, @VypovedUkonceniPP, @ZkusebniDoba, @NerezidentDane, @DuchSporeni_Od, @DatumNarozeniRP, @MenaBankSpoj, @DatumDoruceni, @IBANElektronicky, @CisloBSUcto, @Kategorie, @PoznamkaRP,
@Platnost_1, @Platnost_2, @Platnost_3, @Platnost_4, @Platnost_5, @Platnost_6, @Platnost_7, @Platnost_8, @Platnost_9, @Platnost_10, @Platnost_11, @Platnost_12, @Dan_PodpisProhl, @KodCinnosti_SP,
@ZahrPojistne, @PlatovaTrida, @PlatovyStupen, @Odstavec, @Skola, @Zkouska, @Ukonceno, @Sleva_Z_DT2, @Sleva_Z_DT3, @Sleva_Z_DTZ2, @Sleva_Z_DTZ3, @KoefZkrUvazek,
@VekAut_Vypnout, @OdborVzd, @RocniMSKontejner1, @RocniMSKontejner2, @RocniMSKontejner3, @RocniMSKontejner4, @Hodiny, @Sazba, @SVR_Deponovano, @SVR_NabytiPM, @SVR_Vystavitel,
@BonusDny_Narok, @Alias, @PocetVychDeti, @DruhMzdy, @DatumFuze, @ZakladSocPoj, @ZakladSocPojNeohr, @DovVykonPraceBR, @DatumOdeslani, @ZM_CM_Castka, @ZM_CM_Kod, @SWIFTUstavu, @DnyVykonuPrace,
@DatumVypovedi, @PrispevkyPFaZP, @DovZustatekMR, @DovZustMR_DplUdaj, @DovKraceniNeomlA, @PoznamkaPaus
WHILE 1=1
BEGIN
SET @ChybaPriImportu=0
SET @TextChybyImportu=''
SET @IDZam=NULL
IF @InterniVerze=1
BEGIN
BEGIN TRAN T1
IF (@Cislo IS NULL)AND(@RodneCislo IS NULL)AND(@Alias IS NULL)  /*--neni vyplneno ani osobni ani rodne cislo, nelze pokracovat*/
BEGIN
SET @ChybaPriImportu=1
IF @TextChybyImportu<>'' SET @TextChybyImportu=@TextChybyImportu + ' | '
SET @TextChybyImportu = @TextChybyImportu + dbo.hpf_UniImportHlasky('47FE31D6-7E03-48B6-A644-5693A293BAA4', @JazykVerze, DEFAULT, DEFAULT, DEFAULT, DEFAULT)
END
IF @ChybaPriImportu=0               /*--dohledani ID zamestnance bud podle OsCisla nebo RC*/
BEGIN
IF @Cislo IS NOT NULL SET @IDZam=(SELECT ID FROM TabCisZam WHERE Cislo=@Cislo)
ELSE
IF @RodneCislo IS NOT NULL
BEGIN
IF (SELECT COUNT(*) FROM TabCisZam WHERE RodneCislo=@RodneCislo)>1
BEGIN
SET @ChybaPriImportu=1
IF @TextChybyImportu<>'' SET @TextChybyImportu=@TextChybyImportu + ' | '
SET @TextChybyImportu = @TextChybyImportu + dbo.hpf_UniImportHlasky('B0C56CD2-EAF8-4EC1-BAD9-3C272384F68E', @JazykVerze, DEFAULT, DEFAULT, DEFAULT, DEFAULT)
END
ELSE SET @IDZam=(SELECT ID FROM TabCisZam WHERE RodneCislo=@RodneCislo)
END
ELSE
IF @Alias IS NOT NULL
BEGIN
IF (SELECT COUNT(*) FROM TabCisZam WHERE Alias=@Alias)>1
BEGIN
SET @ChybaPriImportu=1
IF @TextChybyImportu<>'' SET @TextChybyImportu=@TextChybyImportu + ' | '
SET @TextChybyImportu = @TextChybyImportu + dbo.hpf_UniImportHlasky('E85CC864-4038-4343-94FA-0966FE985963', @JazykVerze, DEFAULT, DEFAULT, DEFAULT, DEFAULT)
END
ELSE SET @IDZam=(SELECT ID FROM TabCisZam WHERE Alias=@Alias)
END
END
IF @ChybaPriImportu=0               /*--povedlo se ID dohledat? pokud ano, pokracuj v importu*/
BEGIN
IF @IDZam IS NULL /*--zamestnanec nenalezen*/
BEGIN
SET @ChybaPriImportu=1
IF @TextChybyImportu<>'' SET @TextChybyImportu=@TextChybyImportu + ' | '
SET @TextChybyImportu = @TextChybyImportu + dbo.hpf_UniImportHlasky('A774CDE5-6416-4D37-8370-BE07671162F5', @JazykVerze, DEFAULT, DEFAULT, DEFAULT, DEFAULT)
END
ELSE
BEGIN  ---****ZACATEK IMPORTU
IF (@RodinnyPrislusnik=0)AND(@Pausal=0)  --nejedna se ani o pausaly, ani o rod. prisl.
BEGIN  --**MZDOVE UDAJE
IF NOT EXISTS(SELECT * FROM TabZamMzd WHERE ZamestnanecID=@IDZam AND IdObdobi=@IdObdobi)
EXEC hp_PridejMzdovouVetu @IDZam, @IdObdobi
ELSE
BEGIN
SET @ChybaPriImportu=1
IF @TextChybyImportu<>'' SET @TextChybyImportu=@TextChybyImportu + ' | '
SET @TextChybyImportu = @TextChybyImportu + dbo.hpf_UniImportHlasky('9D69C76F-D70C-4999-84EE-D5425F02007A', @JazykVerze, ISNULL(CAST(@Cislo AS NVARCHAR(10)), N'<!!>'), ISNULL(@RodneCislo, N'<!!>'), DEFAULT, DEFAULT)
END
IF (@DatumVznikuPP IS NOT NULL)AND(@DatumUkonceniPP IS NOT NULL)
IF @DatumVznikuPP>@DatumUkonceniPP
BEGIN
SET @ChybaPriImportu=1
IF @TextChybyImportu<>'' SET @TextChybyImportu=@TextChybyImportu + ' | '
SET @TextChybyImportu = @TextChybyImportu + dbo.hpf_UniImportHlasky('51AE805B-02FB-4FE0-B496-AD2AB74F6B0E', @JazykVerze, DEFAULT, DEFAULT, DEFAULT, DEFAULT)
END
IF (@DatumVznikuPP IS NULL)AND(@DatumUkonceniPP IS NOT NULL)
BEGIN
SET @ChybaPriImportu=1
IF @TextChybyImportu<>'' SET @TextChybyImportu=@TextChybyImportu + ' | '
SET @TextChybyImportu = @TextChybyImportu + dbo.hpf_UniImportHlasky('9FF9A2A0-802F-4556-9940-9FDF7EE7D06B', @JazykVerze, DEFAULT, DEFAULT, DEFAULT, DEFAULT)
END
IF @DuvodUkonceniPP IS NOT NULL
  IF NOT EXISTS(SELECT 0 FROM TabUkonPV WHERE Kod=@DuvodUkonceniPP)
BEGIN
SET @ChybaPriImportu=1
IF @TextChybyImportu<>'' SET @TextChybyImportu=@TextChybyImportu + ' | '
SET @TextChybyImportu = @TextChybyImportu + dbo.hpf_UniImportHlasky('A24A0653-5109-48D2-9C55-DDD6D1E194BF', @JazykVerze, DEFAULT, DEFAULT, DEFAULT, DEFAULT)
END
IF @DalsiPP IS NOT NULL
BEGIN
  IF @DruhPP IN (0,1,8)
  BEGIN
SET @ChybaPriImportu=1
IF @TextChybyImportu<>'' SET @TextChybyImportu=@TextChybyImportu + ' | '
SET @TextChybyImportu = @TextChybyImportu + dbo.hpf_UniImportHlasky('24449493-0C59-4B67-B271-EA5515BE6B83', @JazykVerze, DEFAULT, DEFAULT, DEFAULT, DEFAULT)
  END
  ELSE
  BEGIN
    IF NOT EXISTS(SELECT * FROM TabZamMzd WHERE IdObdobi=@IdObdobi AND ZamestnanecId=(SELECT ID FROM TabCisZam WHERE Cislo=@DalsiPP))
    BEGIN
      SET @ChybaPriImportu=1
      IF @TextChybyImportu<>'' SET @TextChybyImportu=@TextChybyImportu + ' | '
      SET @TextChybyImportu = @TextChybyImportu + dbo.hpf_UniImportHlasky('D40BAE63-CAE9-435B-AA7B-9FB5C8597132', @JazykVerze, DEFAULT, DEFAULT, DEFAULT, DEFAULT)
    END
  END
END
IF (@DatumVynetiES IS NOT NULL)AND(@DatumUkonceniPP IS NOT NULL)
IF @DatumVynetiES>@DatumUkonceniPP
BEGIN
SET @ChybaPriImportu=1
IF @TextChybyImportu<>'' SET @TextChybyImportu=@TextChybyImportu + ' | '
SET @TextChybyImportu = @TextChybyImportu + dbo.hpf_UniImportHlasky('293F40DC-286E-4FA0-882F-C88E6898906E', @JazykVerze, DEFAULT, DEFAULT, DEFAULT, DEFAULT)
END
IF @DatumZmenyVynetiES IS NOT NULL
BEGIN
IF @DatumNavratuES IS NULL
BEGIN
SET @ChybaPriImportu=1
IF @TextChybyImportu<>'' SET @TextChybyImportu=@TextChybyImportu + ' | '
SET @TextChybyImportu = @TextChybyImportu + dbo.hpf_UniImportHlasky('AF39FE0A-0095-4AE8-A3DF-CC8AFDD41A71', @JazykVerze, DEFAULT, DEFAULT, DEFAULT, DEFAULT)
END
ELSE
IF @DatumUkonceniPP IS NOT NULL
IF @DatumZmenyVynetiES>@DatumUkonceniPP
BEGIN
SET @ChybaPriImportu=1
IF @TextChybyImportu<>'' SET @TextChybyImportu=@TextChybyImportu + ' | '
SET @TextChybyImportu = @TextChybyImportu + dbo.hpf_UniImportHlasky('F84F540F-B9ED-4744-A80F-83D87F795C3C', @JazykVerze, DEFAULT, DEFAULT, DEFAULT, DEFAULT)
END
END
IF NOT EXISTS(SELECT TabCisMzSl.*
FROM TabCisMzSl
LEFT OUTER JOIN TabSkupMS VMzSlSkupinaMS ON VMzSlSkupinaMS.SkupinaMS=TabCisMzSl.SkupinaMS AND VMzSlSkupinaMS.IdObdobi=TabCisMzSl.IdObdobi
WHERE ((TabCisMzSl.CisloMzSl=@MSZakladniMzda)AND(TabCisMzSl.IdObdobi=@IDObdobi)AND
(EXISTS (SELECT Typ FROM TabSkupMS WHERE TabSkupMS.Typ = 0 AND TabCisMzSl.SkupinaMS = TabSkupMS.SkupinaMS AND TabCisMzSl.IdObdobi=TabSkupMS.IdObdobi
AND TabCisMzSl.IdObdobi=@IDObdobi AND (TabCisMzSl.Vypocet_ZakladProVypocet=1 AND TabCisMzSl.VstupniFormular=1 OR TabCisMzSl.Vypocet_ZakladProVypocet=0
AND TabCisMzSl.VstupniFormular=5) AND TabCisMzSl.Konstanty_DoPausalu=0 AND TabCisMzSl.Konstanty_DoPredzpracovani=0))))
BEGIN
SET @ChybaPriImportu=1
IF @TextChybyImportu<>'' SET @TextChybyImportu=@TextChybyImportu + ' | '
SET @TextChybyImportu = @TextChybyImportu + dbo.hpf_UniImportHlasky('868B6951-0390-4060-9175-CDB51BC31C66', @JazykVerze, DEFAULT, DEFAULT, DEFAULT, DEFAULT)
END
IF @DruhKalendare IS NULL
SET @DruhKalendare=(SELECT TypKalendare FROM TabMzKons WHERE IdObdobi=@IdObdobi)
IF @DruhKalendare IS NOT NULL
BEGIN
IF NOT EXISTS(SELECT *
FROM TabMzKalendar
WHERE Cislo=@DruhKalendare
AND Rok=@Rok)
BEGIN
SET @ChybaPriImportu=1
IF @TextChybyImportu<>'' SET @TextChybyImportu=@TextChybyImportu + ' | '
SET @TextChybyImportu = @TextChybyImportu + dbo.hpf_UniImportHlasky('588C6B2E-05AA-4C2C-8FA1-0B2B3A028DB2', @JazykVerze, @DruhKalendare, DEFAULT, DEFAULT, DEFAULT)
END
ELSE SET @RokKalendare=@Rok
END
ELSE SET @RokKalendare=NULL
IF (@TydenniUvazek=0)AND(@DruhKalendare IS NOT NULL)AND(@ChybaPriImportu=0) --tydenni uvazek nevyplnen, kalendar ano a existuje (chyba=0) -> pokusime se nacist z kalendare
SET @TydenniUvazek=(SELECT UvazekTyden
FROM TabMzKalendar
WHERE Cislo=@DruhKalendare
AND Rok=@Rok)
IF (@DenniUvazek=0)AND(@DruhKalendare IS NOT NULL)AND(@ChybaPriImportu=0) --denni uvazek nevyplnen, kalendar ano a existuje (chyba=0) -> pokusime se nacist z kalendare
SET @DenniUvazek=(SELECT UvazekDen
FROM TabMzKalendar
WHERE Cislo=@DruhKalendare
AND Rok=@Rok)
IF @KoefZkrUvazek<>1
BEGIN
  SET @TydenniUvazek=@TydenniUvazek*@KoefZkrUvazek
  SET @DenniUvazek=@DenniUvazek*@KoefZkrUvazek
END
IF @ZakladniMzdaZkr=0 -- pokud je atribut nula (=pravdepodobne nevyplnen), zpracovavame dal, jinak ponecham hodnotu v importu
BEGIN
IF @KoefZkrUvazek<>1
BEGIN
  SET @ZakladniMzdaZkr=@KoefZkrUvazek*@ZakladniPlat
END
ELSE
BEGIN
SET @DenniUvazekKal=(SELECT UvazekDen FROM TabMzKalendar
WHERE Cislo=@DruhKalendare
AND Rok=@Rok)
IF @DenniUvazekKal IS NOT NULL
IF (@DenniUvazek<>@DenniUvazekKal)AND(@DenniUvazek<>0)AND(@DenniUvazekKal<>0)
SET @ZakladniMzdaZkr=(@DenniUvazek/@DenniUvazekKal)*@ZakladniPlat
END
END
IF @DanitMzdu=0
BEGIN
SET @TypDane=0
SET @Odpocet1Mesic=0
END
IF @Odpocet1Mesic IS NULL
IF @DatumVznikuPP IS NOT NULL
IF DATEPART(d, @DatumVznikuPP)=1 SET @Odpocet1Mesic=1
ELSE SET @Odpocet1Mesic=0
IF @Odpocet1Mesic IS NULL SET @Odpocet1Mesic=0
IF (@PocitatZdrPoj=0)OR(@PocitatZdrPoj=2)
BEGIN  --je vyplnena a existuje zdravotni pojistovna?
IF @ZdravPojistovna IS NULL
BEGIN
SET @ChybaPriImportu=1
IF @TextChybyImportu<>'' SET @TextChybyImportu=@TextChybyImportu + ' | '
SET @TextChybyImportu = @TextChybyImportu + dbo.hpf_UniImportHlasky('723BCBF3-678E-4BA9-9A0D-F1BE9C978330', @JazykVerze, DEFAULT, DEFAULT, DEFAULT, DEFAULT)
END
ELSE
IF NOT EXISTS(SELECT * FROM TabZdrPoj WHERE Kod=@ZdravPojistovna AND IdObdobi=@IdObdobi)
BEGIN
SET @ChybaPriImportu=1
IF @TextChybyImportu<>'' SET @TextChybyImportu=@TextChybyImportu + ' | '
SET @TextChybyImportu = @TextChybyImportu + dbo.hpf_UniImportHlasky('C8970632-4DE9-4764-B002-A734353DF24F', @JazykVerze, ISNULL(@ZdravPojistovna, ''), DEFAULT, DEFAULT, DEFAULT)
END
END
ELSE
  SET @ZdravPojistovna=NULL
IF @AdrTrvZeme IS NOT NULL
IF NOT EXISTS(SELECT * FROM TabZeme WHERE ISOKod=@AdrTrvZeme)
BEGIN
SET @ChybaPriImportu=1
IF @TextChybyImportu<>'' SET @TextChybyImportu=@TextChybyImportu + ' | '
SET @TextChybyImportu = @TextChybyImportu + dbo.hpf_UniImportHlasky('9213B835-CFAD-470C-B47B-135E85397F40', @JazykVerze, ISNULL(@AdrTrvZeme, ''), DEFAULT, DEFAULT, DEFAULT)
END
IF @PocitatZdrPoj=0 SET @SlevaZP1Mesic=0
IF @PocitatZdrPoj=1
BEGIN
SET @SlevaZP1Mesic=0
SET @PouzitMinZakZP=0
END
IF @PocitatZdrPoj=2 SET @PouzitMinZakZP=0
IF @PocitatSocPoj=1 SET @SocPojDatumOd=NULL
IF (@PocitatSocPoj<>1)AND(@SocPojDatumOd IS NULL)AND(@DatumVznikuPP IS NOT NULL)
BEGIN
SET @Datum_pom=@DatumVznikuPP
WHILE 1=1
BEGIN
IF (SELECT MKD.TypDne+MKD.Svatek
FROM TabMzKalendarDny MKD
LEFT OUTER JOIN TabMzKalendar MK ON MK.ID=MKD.IdKalendar
WHERE MKD.Datum=@Datum_pom
AND MK.Cislo='001'
AND MK.Rok=DATEPART(yyyy, @DatumVznikuPP))>0
SET @Datum_pom=DATEADD(day, 1, @Datum_pom)
ELSE BREAK
END
SET @SocPojDatumOd=@Datum_pom
END
IF @ZkusebniDoba IS NULL
BEGIN
IF @DatumVznikuPP IS NOT NULL
BEGIN
SET @Datum_pom=DATEADD(d, -1, DATEADD(m, ((SELECT DelkaZkusebDoby FROM TabMzKons WHERE IdObdobi = @IdObdobi)), @DatumVznikuPP))
WHILE 1=1
BEGIN
IF (SELECT MKD.TypDne+MKD.Svatek
FROM TabMzKalendarDny MKD
LEFT OUTER JOIN TabMzKalendar MK ON MK.ID=MKD.IdKalendar
WHERE MKD.Datum=@Datum_pom
AND MK.Cislo='001'
AND MK.Rok=DATEPART(yyyy, @Datum_pom))>0
SET @Datum_pom=DATEADD(day, 1, @Datum_pom)
ELSE BREAK
END
SET @ZkusebniDoba=@Datum_pom
END
END
IF @Stredisko IS NOT NULL
IF NOT EXISTS(SELECT * FROM TabStrom WHERE Cislo=@Stredisko)
BEGIN
SET @ChybaPriImportu=1
IF @TextChybyImportu<>'' SET @TextChybyImportu=@TextChybyImportu + ' | '
SET @TextChybyImportu = @TextChybyImportu + dbo.hpf_UniImportHlasky('A5C75180-8F27-42D7-9B23-0632710E6EB5', @JazykVerze, ISNULL(@Stredisko, ''), DEFAULT, DEFAULT, DEFAULT)
END
IF @IdVozidlo IS NOT NULL
BEGIN
IF NOT EXISTS(SELECT * FROM TabIVozidlo WHERE EvCislo=@IdVozidlo)
BEGIN
SET @IdVozidlo_ID=NULL
SET @ChybaPriImportu=1
IF @TextChybyImportu<>'' SET @TextChybyImportu=@TextChybyImportu + ' | '
SET @TextChybyImportu = @TextChybyImportu + dbo.hpf_UniImportHlasky('432E30F9-89CE-4AFD-8960-FFCA1125F1A4', @JazykVerze, ISNULL(@IdVozidlo, ''), DEFAULT, DEFAULT, DEFAULT)
END
ELSE SET @IdVozidlo_ID=(SELECT ID FROM TabIVozidlo WHERE EvCislo=@IdVozidlo)
END
ELSE SET @IdVozidlo_ID=NULL
IF @Zakazka IS NOT NULL
IF NOT EXISTS(SELECT * FROM TabZakazka WHERE CisloZakazky=@Zakazka)
BEGIN
SET @ChybaPriImportu=1
IF @TextChybyImportu<>'' SET @TextChybyImportu=@TextChybyImportu + ' | '
SET @TextChybyImportu = @TextChybyImportu + dbo.hpf_UniImportHlasky('F8F59726-1E74-4FC0-90BF-94425A2D5019', @JazykVerze, ISNULL(@Zakazka, ''), DEFAULT, DEFAULT, DEFAULT)
END
IF @NakladovyOkruh IS NOT NULL
IF NOT EXISTS(SELECT * FROM TabNakladovyOkruh WHERE Cislo=@NakladovyOkruh)
BEGIN
SET @ChybaPriImportu=1
IF @TextChybyImportu<>'' SET @TextChybyImportu=@TextChybyImportu + ' | '
SET @TextChybyImportu = @TextChybyImportu + dbo.hpf_UniImportHlasky('C452A8EC-9169-4F93-9EC4-A27217E0FBA7', @JazykVerze, ISNULL(@NakladovyOkruh, ''), DEFAULT, DEFAULT, DEFAULT)
END
IF @DruhPP IN (7, 8, 12, 14) SET @BlokMinMzdy=5
IF @Pobocka IS NOT NULL
IF NOT EXISTS(SELECT * FROM TabMzPobocky WHERE Kod=@Pobocka AND IdObdobi=@IdObdobi)
BEGIN
SET @ChybaPriImportu=1
IF @TextChybyImportu<>'' SET @TextChybyImportu=@TextChybyImportu + ' | '
SET @TextChybyImportu = @TextChybyImportu + dbo.hpf_UniImportHlasky('D40B5C11-7CC1-483B-AB76-A2FFBADC6A8D', @JazykVerze, ISNULL(@Pobocka, ''), DEFAULT, DEFAULT, DEFAULT)
END
IF @OdboryMS IS NULL
  SET @OdboryMS=(SELECT SrazetOdboryMS FROM TabMzKons WHERE IdObdobi=@IdObdobi)
IF @OdboryMS IS NOT NULL
  IF NOT EXISTS(
SELECT 0
FROM TabCisMzSl
LEFT OUTER JOIN TabSkupMS VMzSlSkupinaMS ON VMzSlSkupinaMS.SkupinaMS=TabCisMzSl.SkupinaMS AND VMzSlSkupinaMS.IdObdobi=TabCisMzSl.IdObdobi
WHERE TabCisMzSl.CisloMzSl = @OdboryMS
AND ((TabCisMzSl.IdObdobi=@IdObdobi)
AND(EXISTS (SELECT Typ FROM TabSkupMS
WHERE TabSkupMS.Typ = 10
AND TabCisMzSl.SkupinaMS = TabSkupMS.SkupinaMS
AND TabCisMzSl.IdObdobi=TabSkupMS.IdObdobi
AND TabCisMzSl.IdObdobi=@IdObdobi
AND TabCisMzSl.Vypocet_ZakladProVypocet=2)))
           )
BEGIN
SET @ChybaPriImportu=1
IF @TextChybyImportu<>'' SET @TextChybyImportu=@TextChybyImportu + ' | '
SET @TextChybyImportu = @TextChybyImportu + dbo.hpf_UniImportHlasky('61FE4052-5D65-4C0E-B791-5C10BB333AA8', @JazykVerze, CAST(@OdboryMS AS NVARCHAR(3)), DEFAULT, DEFAULT, DEFAULT)
END
IF @KodCinnosti_SP IS NULL
BEGIN
  SET @KodCinnosti = NULL
  SET @KodCinnosti_Dflt = NULL
  SET @JeKodOK = NULL
  EXEC dbo.hp_MzVratKodCinnostiCZ
     @IdObdobi=@IdObdobi
   , @ZamestnanecId=@IDZam
   , @DruhPP=@DruhPP
   , @DatumVznikuPP=@DatumVznikuPP
   , @KodCinnosti_Test = NULL
   , @KodCinnosti_SP=@KodCinnosti OUT
   , @KodCinnosti_Dflt=@KodCinnosti_Dflt OUT
   , @JeKodOK=@JeKodOK OUT
   , @LzeKodUrcit=NULL
  IF (@KodCinnosti IS NOT NULL)AND(@JeKodOK=1)
    SET @KodCinnosti_SP=@KodCinnosti
END
IF NOT(((@PlatovaTrida IS NULL)AND(@PlatovyStupen IS NULL)AND(@Odstavec IS NULL))
OR
((@PlatovaTrida IS NOT NULL)AND(@PlatovyStupen IS NOT NULL)AND(@Odstavec IS NOT NULL)))
BEGIN
SET @ChybaPriImportu=1
IF @TextChybyImportu<>'' SET @TextChybyImportu=@TextChybyImportu + ' | '
SET @TextChybyImportu = @TextChybyImportu + dbo.hpf_UniImportHlasky('EE063F31-AA64-425C-ADF9-BC574E521C5F', @JazykVerze, DEFAULT, DEFAULT, DEFAULT, DEFAULT)
END
IF @PlatovaTrida IS NOT NULL
  SET @DruhMzdyMesHodCis=@DruhMzdyMesHod
ELSE
  SET @DruhMzdyMesHodCis=NULL
IF @ZM_CM_Castka<>0
BEGIN
  SELECT @ZM_CM_Kurz=Kurz, @CM_Zaokrouhleni=Zaokrouhleni FROM TabMZKurzList WHERE Mena=@ZM_CM_Kod AND IdObdobi=@IdObdobi
  IF ISNULL(@ZM_CM_Kurz, 0)=0
BEGIN
SET @ChybaPriImportu=1
IF @TextChybyImportu<>'' SET @TextChybyImportu=@TextChybyImportu + ' | '
SET @TextChybyImportu = @TextChybyImportu + dbo.hpf_UniImportHlasky('CAD6AF96-1EF8-4A46-AC37-28FC34E622A8', @JazykVerze, DEFAULT, DEFAULT, DEFAULT, DEFAULT)
END
ELSE
BEGIN
  SET @ZakladniPlat=@ZM_CM_Castka*@ZM_CM_Kurz
  SET @ZakladniPlat=ROUND(@ZakladniPlat, @CM_Zaokrouhleni)
END
END
ELSE
  SET @ZM_CM_Kod=NULL
IF @ChybaPriImportu=0
BEGIN
UPDATE TabZamMzd SET
DatumVznikuPP=@DatumVznikuPP,
ZkusebniDoba=@ZkusebniDoba,
DruhPP=@DruhPP,
DatumVynetiES=@DatumVynetiES,
DatumUkonceniPP=@DatumUkonceniPP,
DuvodVynetiES=@DuvodVynetiES,
DatumNavratuES=@DatumNavratuES,
DatumZmenyVynetiES=@DatumZmenyVynetiES,
ZmenaDuvoduVynetiES=@ZmenaDuvoduVynetiES,
DruhMzdyMesHod=@DruhMzdyMesHod,
DruhMzdyMesHodCis=@DruhMzdyMesHodCis,
MSZakladniMzda=@MSZakladniMzda,
ZakladniPlat=@ZakladniPlat,
DruhKalendare=@DruhKalendare,
RokKalendare=@RokKalendare,
TydenniUvazek=@TydenniUvazek,
DenniUvazek=@DenniUvazek,
ZakladniMzdaZkr=@ZakladniMzdaZkr,
ROPocatek=ISNULL(@ROPocatek, @DatumVznikuPP),
DovPrumer=@DovPrumer,
DNPPrumer=@DNPPrumer,
BlokMinMzdy=@BlokMinMzdy,
Automat=@Automat,
KontrolaMesFondu=@KontrolaMesFondu,
AutomDopocetHodin=@AutomDopocetHodin,
DNPvPodpurciDobe=@DNPvPodpurciDobe,
SrazitZP_MVZ=@SrazitZP_MVZ,
OcrOsamelyPrac=@OcrOsamelyPrac,
DanitMzdu=@DanitMzdu,
TypDane=@TypDane,
Odpocet1Mesic=@Odpocet1Mesic,
PocitatZdrPoj=@PocitatZdrPoj,
ZdravPojistovna=@ZdravPojistovna,
SlevaZP1Mesic=@SlevaZP1Mesic,
PouzitMinZakZP=@PouzitMinZakZP,
PocitatSocPoj=@PocitatSocPoj,
SocPojDatumOd=@SocPojDatumOd,
DovKraceni=@DovKraceni,
Stredisko=@Stredisko,
IdVozidlo=@IdVozidlo_ID,
Zakazka=@Zakazka,
NakladovyOkruh=@NakladovyOkruh,
VyzivovanychOsob=@VyzivovanychOsob,
UcetniSkupina=@UcetniSkupina,
MzdovaUcetni=ISNULL(@MzdovaUcetni, ''),
Mistr=ISNULL(@Mistr, ''),
VyplatniStredisko=ISNULL(@VyplatniStredisko, ''),
MzdovyUtvar=ISNULL(@MzdovyUtvar, ''),
Pobocka=@Pobocka,
AdrTrvZeme=@AdrTrvZeme,
DuvodUkonceniPP=@DuvodUkonceniPP,
DalsiPP=@DalsiPP,
ZamMRozsahu=@ZamMRozsahu,
Odbory=@Odbory,
OdboryMS=(CASE WHEN @Odbory=1 THEN @OdboryMS ELSE NULL END),
OdboryMinSrazit=(CASE WHEN @Odbory=1 THEN @OdboryMinSrazit ELSE 0 END),
OdboryMaxSrazit=(CASE WHEN @Odbory=1 THEN @OdboryMaxSrazit ELSE 0 END),
VypovedLhutaOd=@VypovedLhutaOd,
VypovedUkonceniPP=@VypovedUkonceniPP,
NerezidentDane=@NerezidentDane,
DuchSporeni_Od=@DuchSporeni_Od,
Kategorie=ISNULL(@Kategorie, ''),
Dan_PodpisProhl = ISNULL(@Dan_PodpisProhl, 0),
KodCinnosti_SP = @KodCinnosti_SP,
ZahrPojistne = @ZahrPojistne,
VekAut_Vypnout=@VekAut_Vypnout,
PlatovaTrida=@PlatovaTrida,
PlatovyStupen=@PlatovyStupen,
Odstavec=@Odstavec,
BonusDny_Narok=ISNULL(@BonusDny_Narok, 0),
PocetVychDeti=ISNULL(@PocetVychDeti, 0),
DruhMzdy=ISNULL(@DruhMzdy, ''),
DatumFuze=@DatumFuze,
DovVykonPraceBR=@DovVykonPraceBR,
DatumOdeslani=@DatumOdeslani,
ZM_CM_Castka=@ZM_CM_Castka,
ZM_CM_Kod=@ZM_CM_Kod,
DatumVypovedi=@DatumVypovedi
WHERE ZamestnanecID=@IDZam AND IdObdobi=@IdObdobi
END
IF @ChybaPriImportu=0
IF @CisloPojistence IS NOT NULL
UPDATE TabZamMzd SET CisloPojistence=@CisloPojistence
WHERE ZamestnanecID=@IDZam AND IdObdobi=@IdObdobi
IF @ChybaPriImportu=0
BEGIN
IF EXISTS(SELECT * FROM TabMzPocHod WHERE ZamestnanecID=@IdZam AND Rok=@Rok)
UPDATE TabMzPocHod SET
DovOmlAbsBR=@DovOmlAbsBR,
DovNeomlAbsBR=@DovNeomlAbsBR,
DovCerpaniBR=@DovCerpaniBR,
KalDnyNemDuch=@KalDnyNemDuch,
PrescasyHodin=@PrescasyHodin,
PohotovostHodin=@PohotovostHodin,
DohodaPPHodin=@DohodaPPHodin,
ZamestnaniRoky=@ZamestnaniRoky,
ZamestnaniDny=@ZamestnaniDny,
PraxeRoky=@PraxeRoky,
PraxeDny=@PraxeDny,
RocniMSKontejner1=ISNULL(@RocniMSKontejner1, 0),
RocniMSKontejner2=ISNULL(@RocniMSKontejner2, 0),
RocniMSKontejner3=ISNULL(@RocniMSKontejner3, 0),
RocniMSKontejner4=ISNULL(@RocniMSKontejner4, 0),
ZakladSocPoj=ISNULL(@ZakladSocPoj, 0),
ZakladSocPojNeohr=ISNULL(@ZakladSocPojNeohr, 0),
DnyVykonuPrace=@DnyVykonuPrace,
PrispevkyPFaZP=ISNULL(@PrispevkyPFaZP, 0)
WHERE ZamestnanecID=@IDZam AND Rok=@Rok
ELSE
BEGIN
INSERT TabMzPocHod(ZamestnanecId, Rok, DovOmlAbsBR, DovNeomlAbsBR, DovCerpaniBR, KalDnyNemDuch, PrescasyHodin, PohotovostHodin, DohodaPPHodin, ZamestnaniRoky, ZamestnaniDny, PraxeRoky, PraxeDny, RocniMSKontejner1, RocniMSKontejner2, RocniMSKontejner3, RocniMSKontejner4, ZakladSocPoj, ZakladSocPojNeohr, DnyVykonuPrace, PrispevkyPFaZP)
VALUES(@IdZam, @Rok, @DovOmlAbsBR, @DovNeomlAbsBR, @DovCerpaniBR, @KalDnyNemDuch, @PrescasyHodin, @PohotovostHodin, @DohodaPPHodin, @ZamestnaniRoky, @ZamestnaniDny, @PraxeRoky, @PraxeDny, ISNULL(@RocniMSKontejner1, 0), ISNULL(@RocniMSKontejner2, 0), ISNULL(@RocniMSKontejner3, 0), ISNULL(@RocniMSKontejner4, 0), ISNULL(@ZakladSocPoj, 0), ISNULL(@ZakladSocPojNeohr, 0), @DnyVykonuPrace, ISNULL(@PrispevkyPFaZP, 0))
END
END
IF @ChybaPriImportu=0
BEGIN
IF @TypDane=0
BEGIN
IF @Sleva_S_CID=1
BEGIN
SET @Symbol_Poradi=NULL
SELECT @Symbol_Poradi=MAX(Symbol_Poradi)
FROM TabMzdOdpPolMzd
WHERE Symbol='S_CID' AND IdObdobi=@IdObdobi AND ZamestnanecID=@IDZam
IF @Symbol_Poradi IS NULL SET @Symbol_Poradi=1
ELSE SET @Symbol_Poradi=@Symbol_Poradi+1
INSERT TabMzdOdpPolMzd(Symbol, Symbol_Poradi, IdObdobi, ZamestnanecID)
VALUES ('S_CID', @Symbol_Poradi, @IdObdobi, @IDZam)
END
IF @Sleva_S_PID=1
BEGIN
SET @Symbol_Poradi=NULL
SELECT @Symbol_Poradi=MAX(Symbol_Poradi)
FROM TabMzdOdpPolMzd
WHERE Symbol='S_PID' AND IdObdobi=@IdObdobi AND ZamestnanecID=@IDZam
IF @Symbol_Poradi IS NULL SET @Symbol_Poradi=1
ELSE SET @Symbol_Poradi=@Symbol_Poradi+1
INSERT TabMzdOdpPolMzd(Symbol, Symbol_Poradi, IdObdobi, ZamestnanecID)
VALUES ('S_PID', @Symbol_Poradi, @IdObdobi, @IDZam)
END
IF @Sleva_S_POP=1
BEGIN
SET @Symbol_Poradi=NULL
SELECT @Symbol_Poradi=MAX(Symbol_Poradi)
FROM TabMzdOdpPolMzd
WHERE Symbol='S_POP' AND IdObdobi=@IdObdobi AND ZamestnanecID=@IDZam
IF @Symbol_Poradi IS NULL SET @Symbol_Poradi=1
ELSE SET @Symbol_Poradi=@Symbol_Poradi+1
INSERT TabMzdOdpPolMzd(Symbol, Symbol_Poradi, IdObdobi, ZamestnanecID)
VALUES ('S_POP', @Symbol_Poradi, @IdObdobi, @IDZam)
END
IF @Sleva_S_STD=1
BEGIN
SET @Symbol_Poradi=NULL
SELECT @Symbol_Poradi=MAX(Symbol_Poradi)
FROM TabMzdOdpPolMzd
WHERE Symbol='S_STD' AND IdObdobi=@IdObdobi AND ZamestnanecID=@IDZam
IF @Symbol_Poradi IS NULL SET @Symbol_Poradi=1
ELSE SET @Symbol_Poradi=@Symbol_Poradi+1
INSERT TabMzdOdpPolMzd(Symbol, Symbol_Poradi, IdObdobi, ZamestnanecID)
VALUES ('S_STD', @Symbol_Poradi, @IdObdobi, @IDZam)
END
IF @Sleva_S_ZTPP=1
BEGIN
SET @Symbol_Poradi=NULL
SELECT @Symbol_Poradi=MAX(Symbol_Poradi)
FROM TabMzdOdpPolMzd
WHERE Symbol='S_ZTPP' AND IdObdobi=@IdObdobi AND ZamestnanecID=@IDZam
IF @Symbol_Poradi IS NULL SET @Symbol_Poradi=1
ELSE SET @Symbol_Poradi=@Symbol_Poradi+1
INSERT TabMzdOdpPolMzd(Symbol, Symbol_Poradi, IdObdobi, ZamestnanecID)
VALUES ('S_ZTPP', @Symbol_Poradi, @IdObdobi, @IDZam)
END
END
END
IF @ChybaPriImportu=0
IF @KodVzdelani IS NOT NULL
BEGIN
IF NOT EXISTS(SELECT * FROM TabVzdel WHERE CisloVzd=@KodVzdelani)
BEGIN
SET @ChybaPriImportu=1
IF @TextChybyImportu<>'' SET @TextChybyImportu=@TextChybyImportu + ' | '
SET @TextChybyImportu = @TextChybyImportu + dbo.hpf_UniImportHlasky('55B23949-9283-4338-AC7B-C12DD6E8438A', @JazykVerze, ISNULL(@KodVzdelani, ''), DEFAULT, DEFAULT, DEFAULT)
END
ELSE
BEGIN
SET @Symbol_Poradi=NULL
SELECT @Symbol_Poradi=MAX(Poradi)
FROM TabZamVzd
WHERE ZamestnanecID=@IDZam
IF @Symbol_Poradi IS NULL SET @Symbol_Poradi=1
ELSE SET @Symbol_Poradi=@Symbol_Poradi+1
INSERT TabZamVzd(ZamestnanecId, Poradi, Kod, Skola, Zkouska, Ukonceno, OdborVzd)
VALUES(@IDZam, @Symbol_Poradi, @KodVzdelani, ISNULL(@Skola, ''), ISNULL(@Zkouska, ''), @Ukonceno, @OdborVzd)
END
END
IF @ChybaPriImportu=0
IF @KZam IS NOT NULL
UPDATE TabZamPer SET
KZam=@KZam
WHERE ZamestnanecID=@IDZam AND IdObdobi=@IdObdobi
IF @ChybaPriImportu=0
IF @KodPostaveni IS NOT NULL
BEGIN
IF EXISTS(SELECT * FROM TabCzICSE WHERE Kod=@KodPostaveni)
UPDATE TabZamPer SET
KodPostaveni=@KodPostaveni
WHERE ZamestnanecID=@IDZam AND IdObdobi=@IdObdobi
ELSE
BEGIN
SET @ChybaPriImportu=1
IF @TextChybyImportu<>'' SET @TextChybyImportu=@TextChybyImportu + ' | '
SET @TextChybyImportu = @TextChybyImportu + dbo.hpf_UniImportHlasky('519EAC6F-D091-472C-A5C2-8A8CAF396E55', @JazykVerze, ISNULL(@KodPostaveni, ''), DEFAULT, DEFAULT, DEFAULT)
END
END
IF @ChybaPriImportu=0
IF @ProfeseCislo IS NOT NULL
BEGIN
UPDATE TabZamPer SET
Profese=@ProfeseCislo
WHERE ZamestnanecID=@IDZam AND IdObdobi=@IdObdobi
IF NOT EXISTS(SELECT * FROM TabProfes WHERE Cislo=@ProfeseCislo)
  INSERT TabProfes(Cislo, Nazev) VALUES(@ProfeseCislo, ISNULL(@ProfeseNazev, ''))
END
IF @ChybaPriImportu=0
IF @Pracoviste_NUTS IS NOT NULL
UPDATE TabZamPer SET
Pracoviste_NUTS=@Pracoviste_NUTS
WHERE ZamestnanecID=@IDZam AND IdObdobi=@IdObdobi
IF @ChybaPriImportu=0
UPDATE TabZamPer SET
ZPS=@ZPS
WHERE ZamestnanecID=@IDZam AND IdObdobi=@IdObdobi
IF @ChybaPriImportu=0
IF @VedeniZamest IS NOT NULL
UPDATE TabZamPer SET
VedeniZamest=@VedeniZamest
WHERE ZamestnanecID=@IDZam AND IdObdobi=@IdObdobi
IF @ChybaPriImportu=0
IF @Pracoviste_Zeme IS NOT NULL
BEGIN
IF NOT EXISTS(SELECT * FROM TabZeme WHERE ISOKod=@Pracoviste_Zeme)
  INSERT TabZeme(ISOKod, SmeroveCislo, Nazev) VALUES(@Pracoviste_Zeme, '', '')
UPDATE TabZamPer SET
Pracoviste_Zeme=@Pracoviste_Zeme
WHERE ZamestnanecID=@IDZam AND IdObdobi=@IdObdobi
END
IF @ChybaPriImportu=0
IF @PracovisteId IS NOT NULL
UPDATE TabZamPer SET
PracovisteId=@PracovisteId
WHERE ZamestnanecID=@IDZam AND IdObdobi=@IdObdobi
IF @ChybaPriImportu=0
IF @CzIsco IS NOT NULL
UPDATE TabZamPer SET
CzIsco=@CzIsco
WHERE ZamestnanecID=@IDZam AND IdObdobi=@IdObdobi
IF @ChybaPriImportu=0
IF @KodUzemi IS NOT NULL
BEGIN
UPDATE TabZamPer SET
KodUzemi=@KodUzemi
WHERE ZamestnanecID=@IDZam AND IdObdobi=@IdObdobi
IF NOT EXISTS(SELECT 0 FROM TabMzStatistika WHERE Cislo=@KodUzemi AND Skupina=1)
  INSERT TabMzStatistika(Cislo, Skupina, Popis)
  VALUES(@KodUzemi, 1, ISNULL(@KodUzemiNazev, ''))
END
IF @KoefZkrUvazek<>1
UPDATE TabZamPer SET
KoefZkrUvazek=@KoefZkrUvazek
WHERE ZamestnanecID=@IDZam AND IdObdobi=@IdObdobi
IF (@DruhDuchodu IS NOT NULL)AND(@DatumNaroku IS NOT NULL)
BEGIN
IF @ChybaPriImportu=0
BEGIN
INSERT TabDuchod(ZamestnanecId, IdObdobi, Poradi, DruhDuchodu, DatumNaroku, DatumPriznani)
VALUES(@IDZam, @IdObdobi, 1, @DruhDuchodu, @DatumNaroku, @DatumPriznani)
END
END
ELSE
BEGIN
IF ((@DruhDuchodu IS NOT NULL)AND(@DatumNaroku IS NULL)) OR ((@DruhDuchodu IS NULL)AND(@DatumNaroku IS NOT NULL))
BEGIN
  SET @ChybaPriImportu=1
  IF @TextChybyImportu<>'' SET @TextChybyImportu=@TextChybyImportu + ' | '
  SET @TextChybyImportu = @TextChybyImportu + dbo.hpf_UniImportHlasky('257D0DEE-C953-4EED-97B5-35570D2BF368', @JazykVerze, DEFAULT, DEFAULT, DEFAULT, DEFAULT)
END
END
SET @IdTabZamMzd = (SELECT ID FROM TabZamMzd WHERE ZamestnanecId=@IdZam AND IdObdobi = @IdObdobi)
IF OBJECT_ID('dbo.epx_UniImportMzdy03', 'P') IS NOT NULL EXEC dbo.epx_UniImportMzdy03 @IdTabZamMzd
END --**   MZDOVE UDAJE
IF (@RodinnyPrislusnik=1)AND(@Pausal=0)
BEGIN
SET @RodneCislo_TEMP=NULL
IF NOT EXISTS(SELECT * FROM TabZamMzd WHERE ZamestnanecID=@IDZam AND IdObdobi=@IdObdobi)
BEGIN
SET @ChybaPriImportu=1
IF @TextChybyImportu<>'' SET @TextChybyImportu=@TextChybyImportu + ' | '
SET @TextChybyImportu = @TextChybyImportu + dbo.hpf_UniImportHlasky('9455D755-881E-489C-9C39-BE08AED5FA62', @JazykVerze, DEFAULT, DEFAULT, DEFAULT, DEFAULT)
END
ELSE  --zakladame RP k zamestnanci
BEGIN
IF EXISTS(SELECT * FROM TabZamVyp WHERE IdObdobi=@IdObdobi AND ZamestnanecId=@IDZam)
BEGIN
SET @ChybaPriImportu=1
IF @TextChybyImportu<>'' SET @TextChybyImportu=@TextChybyImportu + ' | '
SET @TextChybyImportu = @TextChybyImportu + dbo.hpf_UniImportHlasky('45AA4244-BAB5-4172-90E3-FF818C856B85', @JazykVerze, DEFAULT, DEFAULT, DEFAULT, DEFAULT)
END
ELSE
BEGIN
IF ((ISNULL(@JmenoRP, '')<>'')AND(ISNULL(@RodneCisloRP, '')<>'')) OR ((ISNULL(@JmenoRP, '')<>'')AND(@DatumNarozeniRP IS NOT NULL))
BEGIN
IF @DatumNarozeniRP IS NULL
BEGIN
SET @RodneCislo_TEMP=@RodneCisloRP
SET @DatumNarozeniRP=NULL
IF IsNumeric(SUBSTRING(@RodneCislo_TEMP, 1,6))=1
IF ((CAST(SUBSTRING(@RodneCislo_TEMP, 1, 2) AS INT)>0)AND(CAST(SUBSTRING(@RodneCislo_TEMP, 1, 2) AS INT)<=99)
AND(CAST(SUBSTRING(@RodneCislo_TEMP, 3, 2) AS INT)>0)AND(CAST(SUBSTRING(@RodneCislo_TEMP, 3, 2) AS INT)<=62)
AND(CAST(SUBSTRING(@RodneCislo_TEMP, 5, 2) AS INT)>0)AND(CAST(SUBSTRING(@RodneCislo_TEMP, 5, 2) AS INT)<=31))
BEGIN
IF CAST(SUBSTRING(@RodneCislo_TEMP, 3, 1) AS INT) IN (5, 6)
SET @RodneCislo_TEMP = LEFT(@RodneCislo_TEMP, 2)+ CAST(CAST(SUBSTRING(@RodneCislo_TEMP, 3, 1) AS INT)-5 AS VARCHAR)+ SUBSTRING(@RodneCislo_TEMP, 4, 3)
SET @DatumNarozeniRP = CONVERT(DATETIME, LEFT(@RodneCislo_TEMP, 6))
END
END
IF NOT EXISTS(SELECT * FROM TabZamRPr WHERE IdObdobi=@IdObdobi AND ZamestnanecId=@IDZam AND Jmeno=@JmenoRP AND RodneCislo=ISNULL(@RodneCisloRP, ''))
BEGIN
INSERT TabZamRPr(IdObdobi, ZamestnanecId, Prijmeni, Jmeno, RodneCislo, DatumNarozeni, Vztah, Zamestnavatel, Poznamka)
VALUES(@IdObdobi, @IDZam, ISNULL(@PrijmeniRP, ''), @JmenoRP, ISNULL(@RodneCisloRP, ''), @DatumNarozeniRP, @VztahRP, '', @PoznamkaRP)
IF @Sleva_Z_DT=1
BEGIN
SET @Symbol_Poradi=NULL
SELECT @Symbol_Poradi=MAX(Symbol_Poradi)
FROM TabMzdOdpPolMzd
WHERE Symbol='Z_DT' AND IdObdobi=@IdObdobi AND ZamestnanecID=@IDZam
IF @Symbol_Poradi IS NULL SET @Symbol_Poradi=1
ELSE SET @Symbol_Poradi=@Symbol_Poradi+1
INSERT TabMzdOdpPolMzd(Symbol, Symbol_Poradi, IdObdobi, ZamestnanecID, RodneCislo, Jmeno, DatumOd, DatumDo)
VALUES ('Z_DT', @Symbol_Poradi, @IdObdobi, @IDZam, ISNULL(@RodneCisloRP, ''), @JmenoRP, @DatumOdRP, @DatumDoRP)
END
IF @Sleva_Z_DT2=1
BEGIN
SET @Symbol_Poradi=NULL
SELECT @Symbol_Poradi=MAX(Symbol_Poradi)
FROM TabMzdOdpPolMzd
WHERE Symbol='Z_DT2' AND IdObdobi=@IdObdobi AND ZamestnanecID=@IDZam
IF @Symbol_Poradi IS NULL SET @Symbol_Poradi=1
ELSE SET @Symbol_Poradi=@Symbol_Poradi+1
INSERT TabMzdOdpPolMzd(Symbol, Symbol_Poradi, IdObdobi, ZamestnanecID, RodneCislo, Jmeno, DatumOd, DatumDo)
VALUES ('Z_DT2', @Symbol_Poradi, @IdObdobi, @IDZam, ISNULL(@RodneCisloRP, ''), @JmenoRP, @DatumOdRP, @DatumDoRP)
END
IF @Sleva_Z_DT3=1
BEGIN
SET @Symbol_Poradi=NULL
SELECT @Symbol_Poradi=MAX(Symbol_Poradi)
FROM TabMzdOdpPolMzd
WHERE Symbol='Z_DT3' AND IdObdobi=@IdObdobi AND ZamestnanecID=@IDZam
IF @Symbol_Poradi IS NULL SET @Symbol_Poradi=1
ELSE SET @Symbol_Poradi=@Symbol_Poradi+1
INSERT TabMzdOdpPolMzd(Symbol, Symbol_Poradi, IdObdobi, ZamestnanecID, RodneCislo, Jmeno, DatumOd, DatumDo)
VALUES ('Z_DT3', @Symbol_Poradi, @IdObdobi, @IDZam, ISNULL(@RodneCisloRP, ''), @JmenoRP, @DatumOdRP, @DatumDoRP)
END
IF @Sleva_Z_DTZP=1
BEGIN
SET @Symbol_Poradi=NULL
SELECT @Symbol_Poradi=MAX(Symbol_Poradi)
FROM TabMzdOdpPolMzd
WHERE Symbol='Z_DTZP' AND IdObdobi=@IdObdobi AND ZamestnanecID=@IDZam
IF @Symbol_Poradi IS NULL SET @Symbol_Poradi=1
ELSE SET @Symbol_Poradi=@Symbol_Poradi+1
INSERT TabMzdOdpPolMzd(Symbol, Symbol_Poradi, IdObdobi, ZamestnanecID, RodneCislo, Jmeno, DatumOd, DatumDo)
VALUES ('Z_DTZP', @Symbol_Poradi, @IdObdobi, @IDZam, ISNULL(@RodneCisloRP, ''), @JmenoRP, @DatumOdRP, @DatumDoRP)
END
IF @Sleva_Z_DTZ2=1
BEGIN
SET @Symbol_Poradi=NULL
SELECT @Symbol_Poradi=MAX(Symbol_Poradi)
FROM TabMzdOdpPolMzd
WHERE Symbol='Z_DTZ2' AND IdObdobi=@IdObdobi AND ZamestnanecID=@IDZam
IF @Symbol_Poradi IS NULL SET @Symbol_Poradi=1
ELSE SET @Symbol_Poradi=@Symbol_Poradi+1
INSERT TabMzdOdpPolMzd(Symbol, Symbol_Poradi, IdObdobi, ZamestnanecID, RodneCislo, Jmeno, DatumOd, DatumDo)
VALUES ('Z_DTZ2', @Symbol_Poradi, @IdObdobi, @IDZam, ISNULL(@RodneCisloRP, ''), @JmenoRP, @DatumOdRP, @DatumDoRP)
END
IF @Sleva_Z_DTZ3=1
BEGIN
SET @Symbol_Poradi=NULL
SELECT @Symbol_Poradi=MAX(Symbol_Poradi)
FROM TabMzdOdpPolMzd
WHERE Symbol='Z_DTZ3' AND IdObdobi=@IdObdobi AND ZamestnanecID=@IDZam
IF @Symbol_Poradi IS NULL SET @Symbol_Poradi=1
ELSE SET @Symbol_Poradi=@Symbol_Poradi+1
INSERT TabMzdOdpPolMzd(Symbol, Symbol_Poradi, IdObdobi, ZamestnanecID, RodneCislo, Jmeno, DatumOd, DatumDo)
VALUES ('Z_DTZ3', @Symbol_Poradi, @IdObdobi, @IDZam, ISNULL(@RodneCisloRP, ''), @JmenoRP, @DatumOdRP, @DatumDoRP)
END
END
ELSE
BEGIN
SET @ChybaPriImportu=1
IF @TextChybyImportu<>'' SET @TextChybyImportu=@TextChybyImportu + ' | '
SET @TextChybyImportu = @TextChybyImportu + dbo.hpf_UniImportHlasky('005C1BE9-2D9E-441B-976C-D15A09B8B57E', @JazykVerze, DEFAULT, DEFAULT, DEFAULT, DEFAULT)
END
END
ELSE
BEGIN
SET @ChybaPriImportu=1
IF @TextChybyImportu<>'' SET @TextChybyImportu=@TextChybyImportu + ' | '
SET @TextChybyImportu = @TextChybyImportu + dbo.hpf_UniImportHlasky('BFA65C33-F6C7-4F35-B4ED-60DD3ECFB6D3', @JazykVerze, DEFAULT, DEFAULT, DEFAULT, DEFAULT)
END
END
END
END --**RODINNI PRISLUSNICI
IF (@Pausal=1)AND(@RodinnyPrislusnik=0)
BEGIN
IF NOT EXISTS(SELECT * FROM TabZamMzd WHERE ZamestnanecID=@IDZam AND IdObdobi=@IdObdobi)
BEGIN
SET @ChybaPriImportu=1
IF @TextChybyImportu<>'' SET @TextChybyImportu=@TextChybyImportu + ' | '
SET @TextChybyImportu = @TextChybyImportu + dbo.hpf_UniImportHlasky('778B1335-FCBE-4600-93E0-DB43CE1C186B', @JazykVerze, DEFAULT, DEFAULT, DEFAULT, DEFAULT)
END
ELSE  --zakladame pausaly k zamestnanci
BEGIN
IF EXISTS(SELECT * FROM TabZamVyp WHERE IdObdobi=@IdObdobi AND ZamestnanecId=@IDZam)
BEGIN
SET @ChybaPriImportu=1
IF @TextChybyImportu<>'' SET @TextChybyImportu=@TextChybyImportu + ' | '
SET @TextChybyImportu = @TextChybyImportu + dbo.hpf_UniImportHlasky('45AA4244-BAB5-4172-90E3-FF818C856B85', @JazykVerze, DEFAULT, DEFAULT, DEFAULT, DEFAULT)
END
ELSE
BEGIN
IF @CisloMS IS NOT NULL
BEGIN
IF NOT EXISTS(SELECT * FROM TabCisMzSl
WHERE ((TabCisMzSl.IdObdobi=@IdObdobi)AND
(TabCisMzSl.IdObdobi=@IdObdobi AND TabCisMzSl.Konstanty_DoPausalu=1))
AND CisloMzSl=@CisloMS)
BEGIN
SET @ChybaPriImportu=1
IF @TextChybyImportu<>'' SET @TextChybyImportu=@TextChybyImportu + ' | '
SET @TextChybyImportu = @TextChybyImportu + dbo.hpf_UniImportHlasky('D49DD197-314F-4154-8B39-1DDBFD159B72', @JazykVerze, CAST(@CisloMS AS VARCHAR), DEFAULT, DEFAULT, DEFAULT)
END
ELSE
BEGIN
IF (
(SELECT ISNULL(SUM(P.Procento), 0)
FROM TabMzPaus P
LEFT OUTER JOIN TabCisMzSl MS ON MS.IdObdobi=P.IdObdobi AND MS.CisloMzSl=P.CisloMS
WHERE P.IdObdobi=@IdObdobi
AND P.ZamestnanecId=@IdZam
AND MS.Vypocet_ZakladProVypocet=3)
+
ISNULL((SELECT Vypocet_Procento FROM TabCisMzSl
WHERE IdObdobi=@IdObdobi
AND CisloMzSl=@CisloMS
AND Vypocet_ZakladProVypocet=3), 0)
)>100
BEGIN
SET @ChybaPriImportu=1
IF @TextChybyImportu<>'' SET @TextChybyImportu=@TextChybyImportu + ' | '
SET @TextChybyImportu = @TextChybyImportu + dbo.hpf_UniImportHlasky('A7256CA0-0365-4A39-8D7A-CDAD5C8A0F05', @JazykVerze, CAST(@CisloMS AS VARCHAR), DEFAULT, DEFAULT, DEFAULT)
END
ELSE
BEGIN
IF (ISNULL(@DosudSrazeno, 0)>ISNULL(@CelkemSrazit, 0))
BEGIN
  SET @ChybaPriImportu=1
  IF @TextChybyImportu<>'' SET @TextChybyImportu=@TextChybyImportu + ' | '
  SET @TextChybyImportu = @TextChybyImportu + dbo.hpf_UniImportHlasky('A10D3EFB-6EFA-4267-8A07-519EFA50CEA0', @JazykVerze, DEFAULT, DEFAULT, DEFAULT, DEFAULT)
END
ELSE
BEGIN
SET @PorCislo=(SELECT ISNULL(MAX(PorCislo)+1, 1) FROM TabMzPaus WHERE ZamestnanecId=@IdZam)
IF @DatumOd IS NULL
BEGIN
SET @TEMPSTR=(SELECT SUBSTRING(CAST(Mesic+100 AS VARCHAR), 2, 2)
FROM TabMzdObd
WHERE IdObdobi=@IdObdobi)
SET @TEMPSTR=CAST(@Rok AS VARCHAR) + @TEMPSTR + '01'
SET @DatumOd=@TEMPSTR
END
IF @Procento IS NULL
BEGIN
  SET @ProcentoTEMP=(SELECT Vypocet_Procento
                     FROM TabCisMzSl
                     LEFT OUTER JOIN TabSkupMS VMzSlSkupinaMS ON VMzSlSkupinaMS.SkupinaMS=TabCisMzSl.SkupinaMS AND VMzSlSkupinaMS.IdObdobi=TabCisMzSl.IdObdobi
                     WHERE ((TabCisMzSl.IdObdobi=@IdObdobi)AND(TabCisMzSl.VstupniFormular=7)AND(CisloMzSl=@CisloMS)))
  IF @ProcentoTEMP IS NULL SET @ProcentoTEMP=100
END
ELSE
SET @ProcentoTEMP=@Procento
IF (@CisloBSUcto IS NOT NULL) AND @CisloUctu<>''
  IF NOT EXISTS(SELECT * FROM TabBankSpojUcto WHERE Cislo = @CisloBSUcto)
  BEGIN
  SET @ChybaPriImportu=1
  IF @TextChybyImportu<>'' SET @TextChybyImportu=@TextChybyImportu + ' | '
  SET @TextChybyImportu = @TextChybyImportu + dbo.hpf_UniImportHlasky('2997DE23-0AA5-4F4D-97ED-9C6DD5765C76', @JazykVerze, DEFAULT, DEFAULT, DEFAULT, DEFAULT)
  END
IF ISNULL(@Platnost_1_12, 0) = 1
BEGIN
  SET @Platnost_1 = 1
  SET @Platnost_2 = 1
  SET @Platnost_3 = 1
  SET @Platnost_4 = 1
  SET @Platnost_5 = 1
  SET @Platnost_6 = 1
  SET @Platnost_7 = 1
  SET @Platnost_8 = 1
  SET @Platnost_9 = 1
  SET @Platnost_10 = 1
  SET @Platnost_11 = 1
  SET @Platnost_12 = 1
END
IF @SVR_Vystavitel IS NOT NULL
  IF NOT EXISTS(SELECT * FROM TabCisOrg WHERE CisloOrg=@SVR_Vystavitel)
  BEGIN
  SET @ChybaPriImportu=1
  IF @TextChybyImportu<>'' SET @TextChybyImportu=@TextChybyImportu + ' | '
  SET @TextChybyImportu = @TextChybyImportu + dbo.hpf_UniImportHlasky('3C62354C-D965-41BB-8A75-9E9AD802AB58', @JazykVerze, CAST(@SVR_Vystavitel AS NVARCHAR), DEFAULT, DEFAULT, DEFAULT)
  END
IF @ChybaPriImportu=0
BEGIN
SET @VstupniFormular=(SELECT VstupniFormular FROM TabCisMzSl WHERE IdObdobi=@IDObdobi AND CisloMzSl=@CisloMS)
IF @VstupniFormular=0
BEGIN
  SET @Hodiny=0
  SET @Sazba=0
IF (SELECT VMzSlSkupinaMS.Typ
FROM TabCisMzSl
LEFT OUTER JOIN TabSkupMS VMzSlSkupinaMS ON VMzSlSkupinaMS.SkupinaMS=TabCisMzSl.SkupinaMS AND VMzSlSkupinaMS.IdObdobi=TabCisMzSl.IdObdobi
WHERE TabCisMzSl.IdObdobi=@IDObdobi AND TabCisMzSl.CisloMzSl=@CisloMS)<>10
SET @ProcentoTEMP=0
END
IF @VstupniFormular=1
BEGIN
  SET @Koruny=0
  SET @Sazba=0
  SET @ProcentoTEMP=0
END
IF @VstupniFormular=3
BEGIN
  SET @ProcentoTEMP=0
END
IF @VstupniFormular=5
BEGIN
  SET @ProcentoTEMP=0
  SET @Sazba=0
END
IF @VstupniFormular=7
BEGIN
  SET @Hodiny=0
  SET @Sazba=0
  SET @Koruny=0
END
IF @VstupniFormular IN(0, 1, 3, 5, 7)
INSERT TabMzPaus(IdObdobi, ZamestnanecId, PorCislo, CisloMS, Koruny, DatumOd, CelkemSrazit, Platnost_1, Platnost_2, Platnost_3, Platnost_4, Platnost_5, Platnost_6, Platnost_7, Platnost_8, Platnost_9, Platnost_10, Platnost_11, Platnost_12, Procento, CisloSmlouvyPF, DosudSrazeno, DatumDo, Platnost_UKPP, DatumDoruceni, Hodiny, Sazba, SVR_Deponovano, SVR_NabytiPM, SVR_Vystavitel, Info)
VALUES(@IDObdobi, @IDZam, @PorCislo, @CisloMS, @Koruny, @DatumOd, @CelkemSrazit, @Platnost_1, @Platnost_2,
@Platnost_3, @Platnost_4, @Platnost_5, @Platnost_6, @Platnost_7, @Platnost_8, @Platnost_9, @Platnost_10, @Platnost_11,
@Platnost_12, @ProcentoTEMP, ISNULL(@CisloSmlouvyPF, ''), ISNULL(@DosudSrazeno, 0), @DatumDo, ISNULL(@Platnost_UKPP, 0), @DatumDoruceni, @Hodiny, @Sazba, @SVR_Deponovano, @SVR_NabytiPM, @SVR_Vystavitel, @PoznamkaPaus)
END
IF @ChybaPriImportu=0 AND ((ISNULL(@CisloUctu, '')<>'')OR(ISNULL(@IBANElektronicky, '')<>''))
BEGIN
IF @KodUstavu IS NOT NULL
  IF NOT EXISTS(SELECT * FROM TabPenezniUstavy WHERE KodUstavu=@KodUstavu)
INSERT TabPenezniUstavy(KodUstavu, SWIFTUstavu) VALUES(@KodUstavu, ISNULL(@SWIFTUstavu, ''))
IF (@KodUstavu IS NULL)AND(@SWIFTUstavu IS NOT NULL)
  IF NOT EXISTS(SELECT * FROM TabPenezniUstavy WHERE SWIFTUstavu=@SWIFTUstavu)
INSERT TabPenezniUstavy(SWIFTUstavu, TypUstavu) VALUES(@SWIFTUstavu, 1)
SET @IDUstavu=NULL
IF @KodUstavu IS NOT NULL SET @IDUstavu=(SELECT TOP 1 ID FROM TabPenezniUstavy WHERE KodUstavu=@KodUstavu)
IF (@KodUstavu IS NULL)AND(@SWIFTUstavu IS NOT NULL) SET @IDUstavu=(SELECT TOP 1 ID FROM TabPenezniUstavy WHERE SWIFTUstavu=@SWIFTUstavu)
IF ISNULL(@CisloUctu, '')<>''
SET @IDUctu=(SELECT TOP 1 B.ID
FROM TabBankSpojeni B
WHERE B.CisloUctu=ISNULL(@CisloUctu, '')
AND ISNULL(B.IdUstavu, -1)=ISNULL(@IDUstavu, -1)
AND B.VariabilniSymbol=ISNULL(@VariabilniSymbol, '')
AND B.KonstantniSymbol=ISNULL(@KonstantniSymbol, '')
AND B.SpecifickySymbol=ISNULL(@SpecifickySymbol, '')
AND B.IDZam=@IDZam
)
ELSE
SET @IDUctu=(SELECT TOP 1 B.ID
FROM TabBankSpojeni B
WHERE B.IBANElektronicky=ISNULL(@IBANElektronicky, '')
AND ISNULL(B.IdUstavu, -1)=ISNULL(@IDUstavu, -1)
AND B.VariabilniSymbol=ISNULL(@VariabilniSymbol, '')
AND B.KonstantniSymbol=ISNULL(@KonstantniSymbol, '')
AND B.SpecifickySymbol=ISNULL(@SpecifickySymbol, '')
AND B.IDZam=@IDZam
)
IF @IDUctu IS NULL
BEGIN
IF @MenaBankSpoj IS NOT NULL
  IF NOT EXISTS(SELECT * FROM TabKodMen WHERE Kod=@MenaBankSpoj)
    INSERT TabKodMen(Kod, Nazev) VALUES(@MenaBankSpoj, '')
IF ISNULL(@NazevBankSpoj, '')=''
  SET @NazevBankSpoj=(SELECT SUBSTRING(LTRIM(ISNULL(Prijmeni, '') + ' ' + ISNULL(Jmeno, '') + ' ' + CAST(@CisloMS AS VARCHAR)), 1, 30)
FROM TabCisZam
WHERE ID=@IDZam)
INSERT TabBankSpojeni(IDZam, IDUstavu, NazevBankSpoj, CisloUctu, VariabilniSymbol, KonstantniSymbol, SpecifickySymbol, Mena, IBANElektronicky, CisloBSUcto)
VALUES(@IDZam, @IDUstavu, @NazevBankSpoj, ISNULL(@CisloUctu, ''), ISNULL(@VariabilniSymbol, ''), ISNULL(@KonstantniSymbol, ''), ISNULL(@SpecifickySymbol, ''), @MenaBankSpoj, ISNULL(@IBANElektronicky, ''), @CisloBSUcto)
SET @IDUctu=SCOPE_IDENTITY()
END
SET @IDPausal=(SELECT ID FROM TabMzPaus
WHERE IDObdobi=@IDObdobi AND
ZamestnanecId=@IDZam AND
PorCislo=@PorCislo AND
CisloMS=@CisloMS)
UPDATE TabMzPaus SET
BankSpojeni=@IDUctu
WHERE ID=@IDPausal
END
END
END
END
END
ELSE
BEGIN
SET @ChybaPriImportu=1
IF @TextChybyImportu<>'' SET @TextChybyImportu=@TextChybyImportu + ' | '
SET @TextChybyImportu = @TextChybyImportu + dbo.hpf_UniImportHlasky('FEECA15F-E9E8-4799-BC1F-06A3D3EB0622', @JazykVerze, DEFAULT, DEFAULT, DEFAULT, DEFAULT)
END
END
END
END --**PAUSALY
IF (@Pausal=1)AND(@RodinnyPrislusnik=1)
BEGIN
SET @ChybaPriImportu=1
IF @TextChybyImportu<>'' SET @TextChybyImportu=@TextChybyImportu + ' | '
SET @TextChybyImportu = @TextChybyImportu + dbo.hpf_UniImportHlasky('A64C58EE-1324-49FC-BCA3-9437A2175240', @JazykVerze, DEFAULT, DEFAULT, DEFAULT, DEFAULT)
END
END    ---****KONEC IMPORTU
END  /*--povedlo se ID dohledat? pokud ano, pokracuj v importu*/
IF @@ERROR<>0 SET @ChybaPriImportu=1
IF @ChybaPriImportu=0 DELETE FROM dbo.TabUniImportMzdy WHERE ID=@ID
IF @ChybaPriImportu=1
BEGIN
IF @@trancount>0 ROLLBACK TRAN T1
UPDATE dbo.TabUniImportMzdy SET Chyba=@TextChybyImportu, DatumImportu=GETDATE() WHERE ID=@ID
END
ELSE
BEGIN
IF @@trancount>0 COMMIT TRAN T1
IF (@RodinnyPrislusnik=0)AND(@Pausal=0)
BEGIN
EXEC dbo.hp_MzVytvorOsobniKalendar @IDZam, @DruhKalendare, @RokKalendare, @ResultDov OUT
IF @DovNepretzityPP IS NULL
BEGIN
IF @DatumVznikuPP IS NULL SET @DovNepretzityPP=0
ELSE
IF (DATEPART(d, @DatumVznikuPP))<>1 SET @DovNepretzityPP=0
ELSE SET @DovNepretzityPP=1
END
EXEC dbo.hp_MzNarokNaDovolenouPP
@ZamestnanecId = @IDZam,
@IdObdobi = @IdObdobi,
@DatumNastupu = @DatumVznikuPP,
@DatumUkonceni = @DatumUkonceniPP,
@DovolenaRocniNarok = @DovNarokZakladni,
@NeprerusenyPP = @DovNepretzityPP,
@VojakZPovolani = 0,
@KalRok = @RokKalendare,
@KalCislo = @DruhKalendare,
@DovolenaNarok = @DovolenaNarok OUT
IF @ChybaPriImportu=0
BEGIN
UPDATE TabZamMzd SET
DovNarokZakladni=@DovNarokZakladni,
DovKraceni=@DovKraceni + ISNULL(@DovKraceniNeomlA, 0),
DovKraceniRucne=@DovKraceniRucne,
DovNepretzityPP=@DovNepretzityPP,
DovZustatekMR=ISNULL(@DovZustatekMR, 0),
DovZustMR_DplUdaj=@DovZustMR_DplUdaj,
DovKraceniNeomlA=ISNULL(@DovKraceniNeomlA, 0),
DovNarokBR=@DovolenaNarok,
DovNarokCelkem=ISNULL(@DovolenaNarok, 0),
DovZustatekBR=ISNULL(ISNULL(@DovolenaNarok, 0) - @DovCerpaniBR - @DovKraceniRucne, 0),
DovProlpOdchod=@DovProlpOdchod
WHERE ZamestnanecID=@IDZam AND IdObdobi=@IdObdobi
END
END
END
END
FETCH NEXT FROM c INTO @ID, @InterniVerze, @Cislo, @RodneCislo, @DatumVznikuPP, @DruhPP, @DatumVynetiES, @DatumUkonceniPP,
@DuvodVynetiES, @DatumNavratuES, @DatumZmenyVynetiES, @ZmenaDuvoduVynetiES, @DruhMzdyMesHod, @MSZakladniMzda,
@ZakladniPlat, @DruhKalendare, @TydenniUvazek, @DenniUvazek, @ROPocatek, @DovPrumer, @DNPPrumer,
@BlokMinMzdy, @Automat, @KontrolaMesFondu, @AutomDopocetHodin, @DNPvPodpurciDobe, @SrazitZP_MVZ,
@OcrOsamelyPrac, @DovOmlAbsBR, @DovNeomlAbsBR, @DovCerpaniBR, @KalDnyNemDuch, @PrescasyHodin,
@PohotovostHodin, @DohodaPPHodin, @ZamestnaniRoky, @ZamestnaniDny, @PraxeRoky, @PraxeDny, @DanitMzdu,
@TypDane, @Odpocet1Mesic, @Sleva_S_CID, @Sleva_S_PID, @Sleva_S_POP, @Sleva_S_STD, @Sleva_S_ZTPP,
@PocitatZdrPoj, @ZdravPojistovna, @CisloPojistence, @SlevaZP1Mesic, @PouzitMinZakZP, @PocitatSocPoj, @SocPojDatumOd,
@DovNarokZakladni, @DovPredminRok_N, @DovMinulyRok_S, @DovMinulyRok_N, @DovKraceniRucne, @DovProlpOdchod,
@DovNadLimit, @DovKraceni, @DovNepretzityPP, @Stredisko, @IdVozidlo, @Zakazka, @NakladovyOkruh,
@VyzivovanychOsob, @UcetniSkupina, @KodVzdelani, @ZPS, @Kzam, @ProfeseCislo, @ProfeseNazev, @Pracoviste_NUTS, @KodPostaveni, @VedeniZamest, @Pracoviste_Zeme, @DruhDuchodu, @DatumNaroku, @DatumPriznani,
@ZakladniMzdaZkr, @RodinnyPrislusnik, @Pausal, @PrijmeniRP, @JmenoRP, @RodneCisloRP, @VztahRP,
@Sleva_Z_DT, @Sleva_Z_DTZP, @CisloMS, @Koruny, @DatumOd, @Platnost_1_12, @CisloUctu, @KodUstavu,
@VariabilniSymbol, @KonstantniSymbol, @SpecifickySymbol, @DatumOdRP, @DatumDoRP, @CelkemSrazit,
@MzdovaUcetni, @Mistr, @VyplatniStredisko, @MzdovyUtvar, @NazevBankSpoj, @CisloSmlouvyPF, @DosudSrazeno, @Procento, @Pobocka, @AdrTrvZeme, @CzIsco, @PracovisteId,
@KodUzemi, @KodUzemiNazev, @DuvodUkonceniPP, @DalsiPP, @ZamMRozsahu, @Odbory, @OdboryMS, @OdboryMinSrazit, @OdboryMaxSrazit, @DatumDo, @Platnost_UKPP,
@VypovedLhutaOd, @VypovedUkonceniPP, @ZkusebniDoba, @NerezidentDane, @DuchSporeni_Od, @DatumNarozeniRP, @MenaBankSpoj, @DatumDoruceni, @IBANElektronicky, @CisloBSUcto, @Kategorie, @PoznamkaRP,
@Platnost_1, @Platnost_2, @Platnost_3, @Platnost_4, @Platnost_5, @Platnost_6, @Platnost_7, @Platnost_8, @Platnost_9, @Platnost_10, @Platnost_11, @Platnost_12, @Dan_PodpisProhl, @KodCinnosti_SP,
@ZahrPojistne, @PlatovaTrida, @PlatovyStupen, @Odstavec, @Skola, @Zkouska, @Ukonceno, @Sleva_Z_DT2, @Sleva_Z_DT3, @Sleva_Z_DTZ2, @Sleva_Z_DTZ3, @KoefZkrUvazek,
@VekAut_Vypnout, @OdborVzd, @RocniMSKontejner1, @RocniMSKontejner2, @RocniMSKontejner3, @RocniMSKontejner4, @Hodiny, @Sazba, @SVR_Deponovano, @SVR_NabytiPM, @SVR_Vystavitel,
@BonusDny_Narok, @Alias, @PocetVychDeti, @DruhMzdy, @DatumFuze, @ZakladSocPoj, @ZakladSocPojNeohr, @DovVykonPraceBR, @DatumOdeslani, @ZM_CM_Castka, @ZM_CM_Kod, @SWIFTUstavu, @DnyVykonuPrace, @DatumVypovedi,
@PrispevkyPFaZP, @DovZustatekMR, @DovZustMR_DplUdaj, @DovKraceniNeomlA, @PoznamkaPaus
IF @@fetch_status<>0 BREAK
END
CLOSE c
DEALLOCATE c
GO

