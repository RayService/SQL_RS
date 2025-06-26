USE [RayService]
GO

/****** Object:  StoredProcedure [dbo].[hpx_UniImportOrg]    Script Date: 26.06.2025 10:20:23 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

/*rpObecneImporty.Import*/CREATE PROC [dbo].[hpx_UniImportOrg]
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
SET @PocetRadkuImpTabulky=(SELECT COUNT(*) FROM TabUniImportOrg WHERE Chyba IS NULL AND ((@PouzeZaznamyDleLogin=1 AND Autor=SUSER_SNAME())OR(@PouzeZaznamyDleLogin=0)) )
SET @InfoText = dbo.hpf_UniImportHlasky('959B5166-6EEF-44A5-B4AC-DA13F5642C08', @JazykVerze, 'TabUniImportOrg', CAST(@PocetRadkuImpTabulky AS NVARCHAR), DEFAULT, DEFAULT)
IF @InfoText IS NOT NULL
  EXEC dbo.hp_ZapisDoZurnalu 1, 77, @InfoText
IF OBJECT_ID('dbo.epx_UniImportOrg02', 'P') IS NOT NULL EXEC dbo.epx_UniImportOrg02
DECLARE @ChybaPriImportu BIT, @IDOrg INT, @CisloKOs INT, @IDKOs INT, @IDUstavu INT, @SQLString NVARCHAR(4000), @ChybaExtAtr NVARCHAR(4000), @ErrNo INT,
@TextChybyImportu NVARCHAR(4000), @CisloOrgMax INT, @CisloOrgMin INT,
/*PRI PRIDANI NOVE VERZE IMPORTU PRIDAT DEKLARACE NOVYCH PROMENNYCH I SEM*/
@ID INT, @InterniVerze INT, @CisloOrg INT, @CisloOrgDOS NVARCHAR(20), @Nazev NVARCHAR(255), @DruhyNazev NVARCHAR(100),
@Ulice NVARCHAR(100), @PopCislo NVARCHAR(15), @OrCislo NVARCHAR(15), @Misto NVARCHAR(100), @PSC NVARCHAR(10),
@PoBox NVARCHAR(40), @IdZeme NVARCHAR(3), @ICO NVARCHAR(20), @DIC NVARCHAR(15), @JeOdberatel BIT, @JeDodavatel BIT,
@Fakturacni BIT, @MU BIT, @Prijemce BIT, @Telefon NVARCHAR(255), @Mobil NVARCHAR(255), @Fax NVARCHAR(255),
@Email NVARCHAR(255), @HromadneProEmail NVARCHAR(255), @WWW NVARCHAR(255), @KOJmeno NVARCHAR(20), @KOPrijmeni NVARCHAR(40), @KOTelefon NVARCHAR(255),
@KOMobil NVARCHAR(255), @KOFax NVARCHAR(255), @KOEmail NVARCHAR(255), @CisloUctu NVARCHAR(40), @KodUstavu NVARCHAR(15),
@IBANElektronicky NVARCHAR(40), @NazevBankSpoj NVARCHAR(100), @MenaBankSpoj NVARCHAR(3), @LhutaSplatnosti SMALLINT, @ExtAtr1 NVARCHAR(30), @ExtAtr1Nazev NVARCHAR(127),
@ExtAtr2 NVARCHAR(255), @ExtAtr2Nazev NVARCHAR(127), @ExtAtr3 DATETIME, @ExtAtr3Nazev NVARCHAR(127),
@ExtAtr4 NUMERIC(19,6), @ExtAtr4Nazev NVARCHAR(127), @FormaUhrady NVARCHAR(30),
@VariabilniSymbol NVARCHAR(20), @KonstantniSymbol NVARCHAR(10), @SpecifickySymbol NVARCHAR(10), @IDVztahKOsOrg INT, @CarovyKodEAN NVARCHAR(13), @VernostniProgram BIT,
@ExtAtr5 NVARCHAR(255), @ExtAtr5Nazev NVARCHAR(127),
@ExtAtr6 NVARCHAR(255), @ExtAtr6Nazev NVARCHAR(127),
@ExtAtr7 NVARCHAR(255), @ExtAtr7Nazev NVARCHAR(127),
@ExtAtr8 NVARCHAR(255), @ExtAtr8Nazev NVARCHAR(127),
@ExtAtr9 BIT, @ExtAtr9Nazev NVARCHAR(127),
@PostAddress NVARCHAR(255), @DatumNeupominani DATETIME, @DICsk NVARCHAR(15), @Kredit NUMERIC(19,6), @OdpOs INT, @DruhDopravy TINYINT, @DodaciPodminky NVARCHAR(3),
@CenovaUroven INT, @CenovaUrovenNakup INT, @Mena NVARCHAR(3), @NadrizenaOrg INT, @Stav TINYINT, @PravniForma TINYINT, @LhutaSplatnostiDodavatel SMALLINT,
@SWIFTUstavu NVARCHAR(15), @Jazyk NVARCHAR(15), @Upozorneni NVARCHAR(255), @IDKateg INT, @Kategorie NVARCHAR(30),
@Prijmeni NVARCHAR(100), @Jmeno NVARCHAR(100), @RodneCislo NVARCHAR(11), @DatumNarozeni DATETIME,
@KOFunkce NVARCHAR(255),
@HromadneProEmailAutomat NVARCHAR(255),
@VstupniCenaDod SMALLINT, @VstupniCenaOdb SMALLINT,
@CisloOrgDOS_U NVARCHAR(20),
@Nazev_U NVARCHAR(255),
@DruhyNazev_U NVARCHAR(100),
@Ulice_U NVARCHAR(100),
@PopCislo_U NVARCHAR(15),
@OrCislo_U NVARCHAR(15),
@Misto_U NVARCHAR(100),
@PSC_U NVARCHAR(10),
@PoBox_U NVARCHAR(40),
@IdZeme_U NVARCHAR(3),
@ICO_U NVARCHAR(20),
@DIC_U NVARCHAR(15),
@DICsk_U NVARCHAR(15),
@JeOdberatel_U BIT,
@JeDodavatel_U BIT,
@Fakturacni_U BIT,
@MU_U BIT,
@Prijemce_U BIT,
@VernostniProgram_U BIT,
@LhutaSplatnosti_U SMALLINT,
@LhutaSplatnostiDodavatel_U SMALLINT,
@FormaUhrady_U NVARCHAR(30),
@CarovyKodEAN_U NVARCHAR(13),
@PostAddress_U NVARCHAR(255),
@DatumNeupominani_U DATETIME,
@Kredit_U NUMERIC(19,6),
@OdpOs_U INT,
@DruhDopravy_U TINYINT,
@DodaciPodminky_U NVARCHAR(3),
@CenovaUroven_U INT,
@CenovaUrovenNakup_U INT,
@Mena_U NVARCHAR(3),
@NadrizenaOrg_U INT,
@Stav_U TINYINT,
@PravniForma_U TINYINT,
@Jazyk_U NVARCHAR(15),
@Upozorneni_U NVARCHAR(255),
@Kategorie_U NVARCHAR(30),
@Prijmeni_U NVARCHAR(100),
@Jmeno_U NVARCHAR(100),
@RodneCislo_U NVARCHAR(11),
@DatumNarozeni_U DATETIME,
@VstupniCenaDod_U SMALLINT,
@VstupniCenaOdb_U SMALLINT,
@CisloOrgDOS_B BIT,
@Nazev_B BIT,
@DruhyNazev_B BIT,
@Ulice_B BIT,
@PopCislo_B BIT,
@OrCislo_B BIT,
@Misto_B BIT,
@PSC_B BIT,
@PoBox_B BIT,
@IdZeme_B BIT,
@ICO_B BIT,
@DIC_B BIT,
@DICsk_B BIT,
@JeOdberatel_B BIT,
@JeDodavatel_B BIT,
@Fakturacni_B BIT,
@MU_B BIT,
@Prijemce_B BIT,
@VernostniProgram_B BIT,
@LhutaSplatnosti_B BIT,
@LhutaSplatnostiDodavatel_B BIT,
@FormaUhrady_B BIT,
@Poznamka_B BIT,
@ExtAtr1_B BIT,
@ExtAtr2_B BIT,
@ExtAtr3_B BIT,
@ExtAtr4_B BIT,
@ExtAtr5_B BIT,
@ExtAtr6_B BIT,
@ExtAtr7_B BIT,
@ExtAtr8_B BIT,
@ExtAtr9_B BIT,
@CarovyKodEAN_B BIT,
@PostAddress_B BIT,
@DatumNeupominani_B BIT,
@Kredit_B BIT,
@OdpOs_B BIT,
@DruhDopravy_B BIT,
@DodaciPodminky_B BIT,
@CenovaUroven_B BIT,
@CenovaUrovenNakup_B BIT,
@Mena_B BIT,
@NadrizenaOrg_B BIT,
@Stav_B BIT,
@PravniForma_B BIT,
@Jazyk_B BIT,
@Upozorneni_B BIT,
@Kategorie_B BIT,
@Prijmeni_B BIT,
@Jmeno_B BIT,
@RodneCislo_B BIT,
@DatumNarozeni_B BIT,
@VstupniCenaDod_B BIT,
@VstupniCenaOdb_B BIT
DECLARE c CURSOR LOCAL FAST_FORWARD FOR
/*PRI PRIDANI NOVE VERZE IMPORTU PRIDAT NOVE PROMENNE I SEM*/
SELECT ID, InterniVerze, CisloOrg, CisloOrgDOS, Nazev, DruhyNazev, Ulice, PopCislo, OrCislo, Misto, PSC, PoBox,
IdZeme, ICO, DIC, JeOdberatel, JeDodavatel, Fakturacni, MU, Prijemce, Telefon, Mobil, Fax, Email,
WWW, KOJmeno, KOPrijmeni, KOTelefon, KOMobil, KOFax, KOEmail, CisloUctu, KodUstavu, IBANElektronicky, NazevBankSpoj, MenaBankSpoj,
LhutaSplatnosti, FormaUhrady, ISNULL(VariabilniSymbol, ''), ISNULL(KonstantniSymbol, ''), ISNULL(SpecifickySymbol, ''),
ExtAtr1, ExtAtr1Nazev, ExtAtr2, ExtAtr2Nazev, ExtAtr3, ExtAtr3Nazev, ExtAtr4, ExtAtr4Nazev, HromadneProEmail, CarovyKodEAN, VernostniProgram,
ExtAtr5, ExtAtr5Nazev, ExtAtr6, ExtAtr6Nazev, ExtAtr7, ExtAtr7Nazev, ExtAtr8, ExtAtr8Nazev, ExtAtr9, ExtAtr9Nazev, ISNULL(PostAddress, ''), DatumNeupominani, DICsk, Kredit, OdpOs,
DruhDopravy, ISNULL(DodaciPodminky, ''), CenovaUroven, CenovaUrovenNakup, Mena, NadrizenaOrg, Stav, ISNULL(PravniForma, 0), LhutaSplatnostiDodavatel, SWIFTUstavu,
Jazyk, Upozorneni, Kategorie, Prijmeni, Jmeno, RodneCislo, DatumNarozeni, KOFunkce, HromadneProEmailAutomat,
ISNULL(VstupniCenaDod, 100), ISNULL(VstupniCenaOdb, 100)
FROM dbo.TabUniImportOrg
WHERE Chyba IS NULL
 AND ((@PouzeZaznamyDleLogin=1 AND Autor=SUSER_SNAME())OR(@PouzeZaznamyDleLogin=0)) 
OPEN c
/*PRI PRIDANI NOVE VERZE IMPORTU PRIDAT NOVE PROMENNE I SEM*/
FETCH NEXT FROM c INTO @ID, @InterniVerze, @CisloOrg, @CisloOrgDOS, @Nazev, @DruhyNazev, @Ulice, @PopCislo, @OrCislo,
@Misto, @PSC, @PoBox, @IdZeme, @ICO, @DIC, @JeOdberatel, @JeDodavatel, @Fakturacni, @MU,
@Prijemce, @Telefon, @Mobil, @Fax, @Email, @WWW, @KOJmeno, @KOPrijmeni, @KOTelefon,
@KOMobil, @KOFax, @KOEmail, @CisloUctu, @KodUstavu, @IBANElektronicky, @NazevBankSpoj, @MenaBankSpoj, @LhutaSplatnosti, @FormaUhrady,
@VariabilniSymbol, @KonstantniSymbol, @SpecifickySymbol, @ExtAtr1,
@ExtAtr1Nazev, @ExtAtr2, @ExtAtr2Nazev, @ExtAtr3, @ExtAtr3Nazev, @ExtAtr4, @ExtAtr4Nazev, @HromadneProEmail, @CarovyKodEAN, @VernostniProgram,
@ExtAtr5, @ExtAtr5Nazev, @ExtAtr6, @ExtAtr6Nazev, @ExtAtr7, @ExtAtr7Nazev, @ExtAtr8, @ExtAtr8Nazev, @ExtAtr9, @ExtAtr9Nazev, @PostAddress, @DatumNeupominani, @DICsk, @Kredit, @OdpOs,
@DruhDopravy, @DodaciPodminky, @CenovaUroven, @CenovaUrovenNakup, @Mena, @NadrizenaOrg, @Stav, @PravniForma, @LhutaSplatnostiDodavatel, @SWIFTUstavu,
@Jazyk, @Upozorneni, @Kategorie, @Prijmeni, @Jmeno, @RodneCislo, @DatumNarozeni, @KOFunkce, @HromadneProEmailAutomat,
@VstupniCenaDod, @VstupniCenaOdb
WHILE 1=1
BEGIN
SET @ChybaPriImportu=0
SET @TextChybyImportu=''
SET @IDOrg=NULL
/*VERZE IMPORTU C.1----------------------------------------------------------------------------------------------------------*/
IF @InterniVerze=1
BEGIN
/*--pokud je CisloOrg vyplneno, overim, jestli uz existuje a pokud ano, chyba a konec*/
IF ((@CisloOrg IS NOT NULL)AND(EXISTS(SELECT ID FROM TabCisOrg WHERE CisloOrg=@CisloOrg)))
BEGIN
  UPDATE dbo.TabUniImportOrg SET Chyba = dbo.hpf_UniImportHlasky('BFC9E4B3-64F6-4992-A388-0A51F266CC54', @JazykVerze, CAST(@CisloOrg AS NVARCHAR(10)), DEFAULT, DEFAULT, DEFAULT), DatumImportu=GETDATE() WHERE ID=@ID
END
ELSE
BEGIN
BEGIN TRAN T1
/*pokud CisloOrg neni vyplneno, tak vygeneruju*/
SET @CisloOrgMin=(SELECT CisloOrgMin FROM TabHGlob)
IF @CisloOrgMin IS NULL SET @CisloOrgMin=1
SET @CisloOrgMax=(SELECT CisloOrgMax FROM TabHGlob)
IF @CisloOrgMax IS NULL SET @CisloOrgMax=2147483647
IF @CisloOrg IS NULL
BEGIN
  EXEC @CisloOrg=dbo.hp_NajdiPrvniVolny 'TabCisOrg','CisloOrg',@CisloOrgMin,@CisloOrgMax,'',1,1
END
IF @@ERROR<>0 SET @ChybaPriImportu=1
/*zeme*/
IF @IdZeme IS NOT NULL
BEGIN
IF NOT EXISTS(SELECT ID FROM TabZeme WHERE ISOKod=@IdZeme) INSERT TabZeme(ISOKod, SmeroveCislo, Nazev) VALUES(@IdZeme, '', '')
IF @@ERROR<>0 SET @ChybaPriImportu=1
END
/*forma uhrady*/
IF @FormaUhrady IS NOT NULL
BEGIN
IF NOT EXISTS(SELECT * FROM TabFormaUhrady WHERE FormaUhrady=@FormaUhrady) INSERT TabFormaUhrady(FormaUhrady) VALUES(@FormaUhrady)
IF @@ERROR<>0 SET @ChybaPriImportu=1
END
IF @Mena IS NOT NULL
  IF NOT EXISTS(SELECT * FROM TabKodMen WHERE Kod=@Mena)
    INSERT TabKodMen(Kod, Nazev) VALUES(@Mena, '')
SET @IDKateg=NULL
IF ISNULL(@Kategorie, '')<>''
BEGIN
  SET @IDKateg=(SELECT TOP 1 ID FROM TabKategOrg WHERE Nazev=@Kategorie)
  IF @IDKateg IS NULL
  BEGIN
    INSERT TabKategOrg(Nazev) VALUES(@Kategorie)
    SET @IDKateg=SCOPE_IDENTITY()
  END
END
/*insertujeme zakladni udaje organizace*/
INSERT TabCisOrg(CisloOrg, CisloOrgDOS, Nazev, DruhyNazev, Ulice, PopCislo, OrCislo, Misto, PoBox, ICO, JeOdberatel, JeDodavatel,
                 Fakturacni, MU, Prijemce, LhutaSplatnosti, IdZeme, FormaUhrady, PostAddress, VernostniProgram, CarovyKodEAN, DatumNeupominani, DICsk, Kredit, DruhDopravy, DodaciPodminky, Mena, Stav, PravniForma,
                 LhutaSplatnostiDodavatel, Upozorneni, IDKateg, Prijmeni, Jmeno, RodneCislo, DatumNarozeni, VstupniCenaDod, VstupniCenaOdb)
VALUES(@CisloOrg, ISNULL(@CisloOrgDOS,''), ISNULL(@Nazev,''), ISNULL(@DruhyNazev,''), ISNULL(@Ulice,''), ISNULL(@PopCislo,''), ISNULL(@OrCislo,''), ISNULL(@Misto,''),
@PoBox, @ICO, @JeOdberatel, @JeDodavatel, @Fakturacni, @MU, @Prijemce, @LhutaSplatnosti, @IdZeme, @FormaUhrady, @PostAddress, @VernostniProgram, @CarovyKodEAN, @DatumNeupominani, @DICsk, ISNULL(@Kredit, 0), @DruhDopravy, @DodaciPodminky,
@Mena, @Stav, ISNULL(@PravniForma, 0), @LhutaSplatnostiDodavatel, @Upozorneni, @IDKateg, ISNULL(@Prijmeni, ''), ISNULL(@Jmeno, ''), ISNULL(@RodneCislo, ''), @DatumNarozeni, @VstupniCenaDod, @VstupniCenaOdb)
IF @@ERROR<>0 SET @ChybaPriImportu=1
/*dohledani ID organizace, hodi se v dalsi casti importu*/
SET @IDOrg=SCOPE_IDENTITY()
/*poznamka*/
UPDATE TabCisOrg SET TabCisOrg.Poznamka=TabUniImportOrg.Poznamka
FROM TabUniImportOrg
WHERE TabUniImportOrg.ID=@ID AND TabCisOrg.CisloOrg=@CisloOrg
IF @@ERROR<>0 SET @ChybaPriImportu=1
/*PSC*/
IF @PSC IS NOT NULL
BEGIN
UPDATE TabCisOrg SET PSC=@PSC WHERE CisloOrg=@CisloOrg
IF NOT EXISTS(SELECT ID FROM TabPSC WHERE Cislo=@PSC) INSERT TabPSC(Cislo) VALUES(@PSC)
END
IF @@ERROR<>0 SET @ChybaPriImportu=1
/*kontakty*/
IF @Telefon IS NOT NULL
IF NOT EXISTS(SELECT ID FROM TabKontakty WHERE IDVztahKOsOrg IS NULL AND IDOrg=@IDOrg AND Spojeni=@Telefon AND Druh=1)
INSERT TabKontakty(IDOrg, Spojeni, Druh) VALUES(@IDOrg, @Telefon, 1)
IF @@ERROR<>0 SET @ChybaPriImportu=1
IF @Mobil IS NOT NULL
IF NOT EXISTS(SELECT ID FROM TabKontakty WHERE IDVztahKOsOrg IS NULL AND IDOrg=@IDOrg AND Spojeni=@Mobil AND Druh=2)
INSERT TabKontakty(IDOrg, Spojeni, Druh) VALUES(@IDOrg, @Mobil, 2)
IF @@ERROR<>0 SET @ChybaPriImportu=1
IF @Fax IS NOT NULL
IF NOT EXISTS(SELECT ID FROM TabKontakty WHERE IDVztahKOsOrg IS NULL AND IDOrg=@IDOrg AND Spojeni=@Fax AND Druh=3)
INSERT TabKontakty(IDOrg, Spojeni, Druh) VALUES(@IDOrg, @Fax, 3)
IF @@ERROR<>0 SET @ChybaPriImportu=1
IF @Email IS NOT NULL
IF NOT EXISTS(SELECT ID FROM TabKontakty WHERE IDVztahKOsOrg IS NULL AND IDOrg=@IDOrg AND Spojeni=@Email AND Druh=6)
INSERT TabKontakty(IDOrg, Spojeni, Druh) VALUES(@IDOrg, @Email, 6)
IF @@ERROR<>0 SET @ChybaPriImportu=1
IF @WWW IS NOT NULL
IF NOT EXISTS(SELECT ID FROM TabKontakty WHERE IDVztahKOsOrg IS NULL AND IDOrg=@IDOrg AND Spojeni=@WWW AND Druh=7)
INSERT TabKontakty(IDOrg, Spojeni, Druh) VALUES(@IDOrg, @WWW, 7)
IF @@ERROR<>0 SET @ChybaPriImportu=1
IF @HromadneProEmail IS NOT NULL
IF NOT EXISTS(SELECT ID FROM TabKontakty WHERE IDVztahKOsOrg IS NULL AND IDOrg=@IDOrg AND Spojeni=@HromadneProEmail AND Druh=10)
INSERT TabKontakty(IDOrg, Spojeni, Druh) VALUES(@IDOrg, @HromadneProEmail, 10)
IF @@ERROR<>0 SET @ChybaPriImportu=1
IF @HromadneProEmailAutomat IS NOT NULL
IF NOT EXISTS(SELECT ID FROM TabKontakty WHERE IDVztahKOsOrg IS NULL AND IDOrg=@IDOrg AND Spojeni=@HromadneProEmailAutomat AND Druh=17)
INSERT TabKontakty(IDOrg, Spojeni, Druh) VALUES(@IDOrg, @HromadneProEmailAutomat, 17)
IF @@ERROR<>0 SET @ChybaPriImportu=1
/*kontaktni osoba*/
IF @KOPrijmeni IS NOT NULL
BEGIN
EXEC @CisloKOs=dbo.hp_NajdiPrvniVolny 'TabCisKOs','Cislo',1,999999,'',1,1
INSERT TabCisKOs(Cislo, Jmeno, Prijmeni, RodnePrijmeni, TitulPred, TitulZa, RodneCislo, MistoNarozeni, Ulice, Misto, Narodnost, CisloOP, CisloPasu)
VALUES(@CisloKOs, @KOJmeno, @KOPrijmeni, '', '', '', '', '', '', '', '', '', '')
IF @@ERROR<>0 SET @ChybaPriImportu=1
SET @IDKOs=(SELECT ID FROM TabCisKOs WHERE Cislo=@CisloKOs)
INSERT TabVztahOrgKOs(IDOrg, IDCisKOs, Funkce) VALUES(@IDOrg, @IDKOs, ISNULL(@KOFunkce, ''))
IF @@ERROR<>0 SET @ChybaPriImportu=1
SET @IDVztahKOsOrg=(SELECT ID FROM TabVztahOrgKOs WHERE IDOrg=@IDOrg AND IDCisKOs=@IDKOs)
IF @KOTelefon IS NOT NULL
IF NOT EXISTS(SELECT ID FROM TabKontakty WHERE IDOrg=@IDOrg AND IDCisKOs=@IDKOs AND Spojeni=@KOTelefon AND Druh=1)
INSERT TabKontakty(IDOrg, IDCisKOs, Spojeni, Druh, IDVztahKOsOrg) VALUES(@IDOrg, @IDKOs, @KOTelefon, 1, @IDVztahKOsOrg)
IF @@ERROR<>0 SET @ChybaPriImportu=1
IF @KOMobil IS NOT NULL
IF NOT EXISTS(SELECT ID FROM TabKontakty WHERE IDOrg=@IDOrg AND IDCisKOs=@IDKOs AND Spojeni=@KOMobil AND Druh=2)
INSERT TabKontakty(IDOrg, IDCisKOs, Spojeni, Druh, IDVztahKOsOrg) VALUES(@IDOrg, @IDKOs, @KOMobil, 2, @IDVztahKOsOrg)
IF @@ERROR<>0 SET @ChybaPriImportu=1
IF @KOFax IS NOT NULL
IF NOT EXISTS(SELECT ID FROM TabKontakty WHERE IDOrg=@IDOrg AND IDCisKOs=@IDKOs AND Spojeni=@KOFax AND Druh=3)
INSERT TabKontakty(IDOrg, IDCisKOs, Spojeni, Druh, IDVztahKOsOrg) VALUES(@IDOrg, @IDKOs, @KOFax, 3, @IDVztahKOsOrg)
IF @@ERROR<>0 SET @ChybaPriImportu=1
IF @KOEmail IS NOT NULL
IF NOT EXISTS(SELECT ID FROM TabKontakty WHERE IDOrg=@IDOrg AND IDCisKOs=@IDKOs AND Spojeni=@KOEmail AND Druh=6)
INSERT TabKontakty(IDOrg, IDCisKOs, Spojeni, Druh, IDVztahKOsOrg) VALUES(@IDOrg, @IDKOs, @KOEmail, 6, @IDVztahKOsOrg)
IF @@ERROR<>0 SET @ChybaPriImportu=1
END
/*bankovni spojeni*/
IF (@CisloUctu IS NOT NULL)OR(@IBANElektronicky IS NOT NULL)
BEGIN
IF @KodUstavu IS NOT NULL
  IF NOT EXISTS(SELECT TOP 1 ID FROM TabPenezniUstavy WHERE KodUstavu=@KodUstavu)
INSERT TabPenezniUstavy(KodUstavu, SWIFTUstavu) VALUES(@KodUstavu, ISNULL(@SWIFTUstavu, ''))
IF @@ERROR<>0 SET @ChybaPriImportu=1
IF (@KodUstavu IS NULL)AND(@SWIFTUstavu IS NOT NULL)
  IF NOT EXISTS(SELECT * FROM TabPenezniUstavy WHERE SWIFTUstavu=@SWIFTUstavu)
INSERT TabPenezniUstavy(SWIFTUstavu, TypUstavu) VALUES(@SWIFTUstavu, 1)
IF @@ERROR<>0 SET @ChybaPriImportu=1
SET @IDUstavu=NULL
IF @MenaBankSpoj IS NOT NULL
  IF NOT EXISTS(SELECT * FROM TabKodMen WHERE Kod=@MenaBankSpoj)
    INSERT TabKodMen(Kod, Nazev) VALUES(@MenaBankSpoj, '')
IF @KodUstavu IS NOT NULL SET @IDUstavu=(SELECT TOP 1 ID FROM TabPenezniUstavy WHERE KodUstavu=@KodUstavu)
IF (@KodUstavu IS NULL)AND(@SWIFTUstavu IS NOT NULL) SET @IDUstavu=(SELECT TOP 1 ID FROM TabPenezniUstavy WHERE SWIFTUstavu=@SWIFTUstavu)
INSERT TabBankSpojeni(IDOrg, IDUstavu, NazevBankSpoj, Mena, CisloUctu, VariabilniSymbol, KonstantniSymbol, SpecifickySymbol, IBANElektronicky, Prednastaveno)
VALUES(@IDOrg, @IDUstavu, ISNULL(@NazevBankSpoj, ''), @MenaBankSpoj, ISNULL(@CisloUctu, ''), @VariabilniSymbol, @KonstantniSymbol, @SpecifickySymbol, ISNULL(@IBANElektronicky, ''), 1)
IF @@ERROR<>0 SET @ChybaPriImportu=1
END
IF (@ChybaPriImportu=0)AND(ISNULL(@DIC, '')<>'')
BEGIN
  EXEC dbo.hp_VAT_ID_kontrola @DIC, @ErrNo OUT
  IF @ErrNo<>0
  BEGIN
  SET @ChybaPriImportu=1
  IF @TextChybyImportu<>'' SET @TextChybyImportu=@TextChybyImportu + ' | '
  SET @TextChybyImportu = @TextChybyImportu + dbo.hpf_UniImportHlasky('7721501C-2718-4B19-99AE-5E28101752F4', @JazykVerze, DEFAULT, DEFAULT, DEFAULT, DEFAULT)
  END
  ELSE
    UPDATE TabCisOrg SET DIC=@DIC WHERE ID=@IDOrg
END
IF @OdpOs IS NOT NULL
BEGIN
  IF EXISTS(SELECT 0 FROM TabCisZam WHERE Cislo=@OdpOs)
  BEGIN
    UPDATE TabCisOrg SET OdpOs = (SELECT ID FROM TabCisZam WHERE Cislo=@OdpOs)
    WHERE ID = @IDOrg
  END
  ELSE
  BEGIN
  SET @ChybaPriImportu=1
  IF @TextChybyImportu<>'' SET @TextChybyImportu=@TextChybyImportu + ' | '
  SET @TextChybyImportu = @TextChybyImportu + dbo.hpf_UniImportHlasky('FF69ED3B-1439-44E5-A410-85F62ED7A790', @JazykVerze, DEFAULT, DEFAULT, DEFAULT, DEFAULT)
  END
END
IF @CenovaUroven IS NOT NULL
BEGIN
  IF EXISTS(SELECT * FROM TabCisNC WHERE CenovaUroven = @CenovaUroven)
  BEGIN
    UPDATE TabCisOrg SET CenovaUroven = @CenovaUroven
    WHERE ID = @IDOrg
  END
  ELSE
  BEGIN
  SET @ChybaPriImportu=1
  IF @TextChybyImportu<>'' SET @TextChybyImportu=@TextChybyImportu + ' | '
  SET @TextChybyImportu = @TextChybyImportu + dbo.hpf_UniImportHlasky('69ECBD4F-214D-4FE9-A5A4-27D4F980E426', @JazykVerze, DEFAULT, DEFAULT, DEFAULT, DEFAULT)
  END
END
IF @CenovaUrovenNakup IS NOT NULL
BEGIN
  IF EXISTS(SELECT * FROM TabCisNC WHERE CenovaUroven = @CenovaUrovenNakup)
  BEGIN
    UPDATE TabCisOrg SET CenovaUrovenNakup = @CenovaUrovenNakup
    WHERE ID = @IDOrg
  END
  ELSE
  BEGIN
  SET @ChybaPriImportu=1
  IF @TextChybyImportu<>'' SET @TextChybyImportu=@TextChybyImportu + ' | '
  SET @TextChybyImportu = @TextChybyImportu + dbo.hpf_UniImportHlasky('69ECBD4F-214D-4FE9-A5A4-27D4F980E426', @JazykVerze, DEFAULT, DEFAULT, DEFAULT, DEFAULT)
  END
END
IF @NadrizenaOrg IS NOT NULL
BEGIN
  IF EXISTS(SELECT * FROM TabCisOrg WHERE CisloOrg = @NadrizenaOrg)
  BEGIN
    UPDATE TabCisOrg SET NadrizenaOrg = @NadrizenaOrg
    WHERE ID = @IDOrg
  END
  ELSE
  BEGIN
  SET @ChybaPriImportu=1
  IF @TextChybyImportu<>'' SET @TextChybyImportu=@TextChybyImportu + ' | '
  SET @TextChybyImportu = @TextChybyImportu + dbo.hpf_UniImportHlasky('2B45B17B-5764-474D-9051-9A01977C24AD', @JazykVerze, DEFAULT, DEFAULT, DEFAULT, DEFAULT)
  END
END
IF @Jazyk IS NOT NULL
BEGIN
  IF EXISTS(SELECT * FROM TabJazyky WHERE Jazyk=@Jazyk)
  BEGIN
    UPDATE TabCisOrg SET Jazyk = @Jazyk
    WHERE ID = @IDOrg
  END
  ELSE
  BEGIN
  SET @ChybaPriImportu=1
  IF @TextChybyImportu<>'' SET @TextChybyImportu=@TextChybyImportu + ' | '
  SET @TextChybyImportu = @TextChybyImportu + dbo.hpf_UniImportHlasky('84E0557B-6B64-450A-A84E-4DF53A77CF13', @JazykVerze, DEFAULT, DEFAULT, DEFAULT, DEFAULT)
  END
END
/*externi atributy*/
/*--ex. atrb. 1 - typ NVARCHAR(30)*/
IF (@ExtAtr1 IS NOT NULL)AND(@ExtAtr1Nazev IS NOT NULL)
BEGIN
IF (OBJECT_ID('TabCisOrg_EXT','U')IS NOT NULL)AND(COLUMNPROPERTY(OBJECT_ID('TabCisOrg_EXT','U'),'_'+@ExtAtr1Nazev,'AllowsNull')IS NOT NULL)
BEGIN
SET @ExtAtr1Nazev='_' + @ExtAtr1Nazev
IF EXISTS(SELECT ID FROM TabCisOrg_EXT WHERE ID=@IDOrg)
SET @SQLString='UPDATE TabCisOrg_EXT SET ' + @ExtAtr1Nazev + '=N' + '''' + @ExtAtr1 + '''' + ' WHERE ID=' + CAST(@IDOrg AS NVARCHAR(10))
ELSE
SET @SQLString='INSERT TabCisOrg_EXT(ID, ' + @ExtAtr1Nazev + ') VALUES(' + CAST(@IDOrg AS NVARCHAR(10)) + ', N' + '''' + @ExtAtr1 + '''' + ')'
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
IF (OBJECT_ID('TabCisOrg_EXT','U')IS NOT NULL)AND(COLUMNPROPERTY(OBJECT_ID('TabCisOrg_EXT','U'),'_'+@ExtAtr2Nazev,'AllowsNull')IS NOT NULL)
BEGIN
SET @ExtAtr2Nazev='_' + @ExtAtr2Nazev
IF EXISTS(SELECT ID FROM TabCisOrg_EXT WHERE ID=@IDOrg)
SET @SQLString='UPDATE TabCisOrg_EXT SET ' + @ExtAtr2Nazev + '=N' + '''' + @ExtAtr2 + '''' + ' WHERE ID=' + CAST(@IDOrg AS NVARCHAR(10))
ELSE
SET @SQLString='INSERT TabCisOrg_EXT(ID, ' + @ExtAtr2Nazev + ') VALUES(' + CAST(@IDOrg AS NVARCHAR(10)) + ', N' + '''' + @ExtAtr2 + '''' + ')'
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
IF (OBJECT_ID('TabCisOrg_EXT','U')IS NOT NULL)AND(COLUMNPROPERTY(OBJECT_ID('TabCisOrg_EXT','U'),'_'+@ExtAtr3Nazev,'AllowsNull')IS NOT NULL)
BEGIN
SET @ExtAtr3Nazev='_' + @ExtAtr3Nazev
IF EXISTS(SELECT ID FROM TabCisOrg_EXT WHERE ID=@IDOrg)
SET @SQLString='UPDATE TabCisOrg_EXT SET ' + @ExtAtr3Nazev + '=' + '''' + CONVERT(NVARCHAR(10),@ExtAtr3, 112) + '''' + ' WHERE ID=' + CAST(@IDOrg AS NVARCHAR(10))
ELSE
SET @SQLString='INSERT TabCisOrg_EXT(ID, ' + @ExtAtr3Nazev + ') VALUES(' + CAST(@IDOrg AS NVARCHAR(10)) + ', ' + '''' + CONVERT(NVARCHAR(10),@ExtAtr3, 112) + '''' + ')'
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
IF (OBJECT_ID('TabCisOrg_EXT','U')IS NOT NULL)AND(COLUMNPROPERTY(OBJECT_ID('TabCisOrg_EXT','U'),'_'+@ExtAtr4Nazev,'AllowsNull')IS NOT NULL)
BEGIN
SET @ExtAtr4Nazev='_' + @ExtAtr4Nazev
IF EXISTS(SELECT ID FROM TabCisOrg_EXT WHERE ID=@IDOrg)
SET @SQLString='UPDATE TabCisOrg_EXT SET ' + @ExtAtr4Nazev + '=' + CAST(@ExtAtr4 AS NVARCHAR(26)) +  ' WHERE ID=' + CAST(@IDOrg AS NVARCHAR(10))
ELSE
SET @SQLString='INSERT TabCisOrg_EXT(ID, ' + @ExtAtr4Nazev + ') VALUES(' + CAST(@IDOrg AS NVARCHAR(10)) + ', ' + CAST(@ExtAtr4 AS NVARCHAR(26)) + ')'
EXECUTE sp_executesql @SQLString
END
ELSE
BEGIN
SET @ChybaPriImportu=1
IF @TextChybyImportu<>'' SET @TextChybyImportu=@TextChybyImportu + ' | '
SET @TextChybyImportu = @TextChybyImportu + dbo.hpf_UniImportHlasky('15364319-B20F-4D65-8900-391DE8D4C52F', @JazykVerze, '_'+@ExtAtr4Nazev, DEFAULT, DEFAULT, DEFAULT)
END
IF (@ExtAtr5 IS NOT NULL)AND(@ExtAtr5Nazev IS NOT NULL)
IF (OBJECT_ID('TabCisOrg_EXT','U')IS NOT NULL)AND(COLUMNPROPERTY(OBJECT_ID('TabCisOrg_EXT','U'),'_'+@ExtAtr5Nazev,'AllowsNull')IS NOT NULL)
BEGIN
SET @ExtAtr5Nazev='_' + @ExtAtr5Nazev
IF EXISTS(SELECT ID FROM TabCisOrg_EXT WHERE ID=@IDOrg)
SET @SQLString='UPDATE TabCisOrg_EXT SET ' + @ExtAtr5Nazev + '=N' + '''' + @ExtAtr5 + '''' + ' WHERE ID=' + CAST(@IDOrg AS NVARCHAR(10))
ELSE
SET @SQLString='INSERT TabCisOrg_EXT(ID, ' + @ExtAtr5Nazev + ') VALUES(' + CAST(@IDOrg AS NVARCHAR(10)) + ', N' + '''' + @ExtAtr5 + '''' + ')'
EXECUTE sp_executesql @SQLString
END
ELSE
BEGIN
SET @ChybaPriImportu=1
IF @TextChybyImportu<>'' SET @TextChybyImportu=@TextChybyImportu + ' | '
SET @TextChybyImportu = @TextChybyImportu + dbo.hpf_UniImportHlasky('15364319-B20F-4D65-8900-391DE8D4C52F', @JazykVerze, '_'+@ExtAtr5Nazev, DEFAULT, DEFAULT, DEFAULT)
END
IF (@ExtAtr6 IS NOT NULL)AND(@ExtAtr6Nazev IS NOT NULL)
IF (OBJECT_ID('TabCisOrg_EXT','U')IS NOT NULL)AND(COLUMNPROPERTY(OBJECT_ID('TabCisOrg_EXT','U'),'_'+@ExtAtr6Nazev,'AllowsNull')IS NOT NULL)
BEGIN
SET @ExtAtr6Nazev='_' + @ExtAtr6Nazev
IF EXISTS(SELECT ID FROM TabCisOrg_EXT WHERE ID=@IDOrg)
SET @SQLString='UPDATE TabCisOrg_EXT SET ' + @ExtAtr6Nazev + '=N' + '''' + @ExtAtr6 + '''' + ' WHERE ID=' + CAST(@IDOrg AS NVARCHAR(10))
ELSE
SET @SQLString='INSERT TabCisOrg_EXT(ID, ' + @ExtAtr6Nazev + ') VALUES(' + CAST(@IDOrg AS NVARCHAR(10)) + ', N' + '''' + @ExtAtr6 + '''' + ')'
EXECUTE sp_executesql @SQLString
END
ELSE
BEGIN
SET @ChybaPriImportu=1
IF @TextChybyImportu<>'' SET @TextChybyImportu=@TextChybyImportu + ' | '
SET @TextChybyImportu = @TextChybyImportu + dbo.hpf_UniImportHlasky('15364319-B20F-4D65-8900-391DE8D4C52F', @JazykVerze, '_'+@ExtAtr6Nazev, DEFAULT, DEFAULT, DEFAULT)
END
IF (@ExtAtr7 IS NOT NULL)AND(@ExtAtr7Nazev IS NOT NULL)
IF (OBJECT_ID('TabCisOrg_EXT','U')IS NOT NULL)AND(COLUMNPROPERTY(OBJECT_ID('TabCisOrg_EXT','U'),'_'+@ExtAtr7Nazev,'AllowsNull')IS NOT NULL)
BEGIN
SET @ExtAtr7Nazev='_' + @ExtAtr7Nazev
IF EXISTS(SELECT ID FROM TabCisOrg_EXT WHERE ID=@IDOrg)
SET @SQLString='UPDATE TabCisOrg_EXT SET ' + @ExtAtr7Nazev + '=N' + '''' + @ExtAtr7 + '''' + ' WHERE ID=' + CAST(@IDOrg AS NVARCHAR(10))
ELSE
SET @SQLString='INSERT TabCisOrg_EXT(ID, ' + @ExtAtr7Nazev + ') VALUES(' + CAST(@IDOrg AS NVARCHAR(10)) + ', N' + '''' + @ExtAtr7 + '''' + ')'
EXECUTE sp_executesql @SQLString
END
ELSE
BEGIN
SET @ChybaPriImportu=1
IF @TextChybyImportu<>'' SET @TextChybyImportu=@TextChybyImportu + ' | '
SET @TextChybyImportu = @TextChybyImportu + dbo.hpf_UniImportHlasky('15364319-B20F-4D65-8900-391DE8D4C52F', @JazykVerze, '_'+@ExtAtr7Nazev, DEFAULT, DEFAULT, DEFAULT)
END
IF (@ExtAtr8 IS NOT NULL)AND(@ExtAtr8Nazev IS NOT NULL)
IF (OBJECT_ID('TabCisOrg_EXT','U')IS NOT NULL)AND(COLUMNPROPERTY(OBJECT_ID('TabCisOrg_EXT','U'),'_'+@ExtAtr8Nazev,'AllowsNull')IS NOT NULL)
BEGIN
SET @ExtAtr8Nazev='_' + @ExtAtr8Nazev
IF EXISTS(SELECT ID FROM TabCisOrg_EXT WHERE ID=@IDOrg)
SET @SQLString='UPDATE TabCisOrg_EXT SET ' + @ExtAtr8Nazev + '=N' + '''' + @ExtAtr8 + '''' + ' WHERE ID=' + CAST(@IDOrg AS NVARCHAR(10))
ELSE
SET @SQLString='INSERT TabCisOrg_EXT(ID, ' + @ExtAtr8Nazev + ') VALUES(' + CAST(@IDOrg AS NVARCHAR(10)) + ', N' + '''' + @ExtAtr8 + '''' + ')'
EXECUTE sp_executesql @SQLString
END
ELSE
BEGIN
SET @ChybaPriImportu=1
IF @TextChybyImportu<>'' SET @TextChybyImportu=@TextChybyImportu + ' | '
SET @TextChybyImportu = @TextChybyImportu + dbo.hpf_UniImportHlasky('15364319-B20F-4D65-8900-391DE8D4C52F', @JazykVerze, '_'+@ExtAtr8Nazev, DEFAULT, DEFAULT, DEFAULT)
END
IF (@ExtAtr9 IS NOT NULL)AND(@ExtAtr9Nazev IS NOT NULL)
IF (OBJECT_ID('TabCisOrg_EXT','U')IS NOT NULL)AND(COLUMNPROPERTY(OBJECT_ID('TabCisOrg_EXT','U'),'_'+@ExtAtr9Nazev,'AllowsNull')IS NOT NULL)
BEGIN
SET @ExtAtr9Nazev='_' + @ExtAtr9Nazev
IF EXISTS(SELECT ID FROM TabCisOrg_EXT WHERE ID=@IDOrg)
SET @SQLString='UPDATE TabCisOrg_EXT SET ' + @ExtAtr9Nazev + '=' + CAST(@ExtAtr9 AS NVARCHAR) + ' WHERE ID=' + CAST(@IDOrg AS NVARCHAR(10))
ELSE
SET @SQLString='INSERT TabCisOrg_EXT(ID, ' + @ExtAtr9Nazev + ') VALUES(' + CAST(@IDOrg AS NVARCHAR(10)) + ', ' + CAST(@ExtAtr9 AS NVARCHAR) + ')'
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
  @ImportIdent=0,
  @IdImpTable=@ID,
  @IdTargetTable=@IDOrg,
  @Chyba=@ChybaExtAtr OUT
IF @ChybaExtAtr<>''
BEGIN
  SET @ChybaPriImportu=1
  IF @TextChybyImportu<>'' SET @TextChybyImportu=@TextChybyImportu + ' | '
  SET @TextChybyImportu = @TextChybyImportu + dbo.hpf_UniImportHlasky('15364319-B20F-4D65-8900-391DE8D4C52F', @JazykVerze, @ChybaExtAtr, DEFAULT, DEFAULT, DEFAULT)
END
IF OBJECT_ID('dbo.epx_UniImportOrg03', 'P') IS NOT NULL EXEC dbo.epx_UniImportOrg03 @IDOrg
/*--pokud nedoslo k chybe, smazeme zaznam z importni tabulky*/
IF @@ERROR<>0 SET @ChybaPriImportu=1
IF @ChybaPriImportu=0 DELETE FROM dbo.TabUniImportOrg WHERE ID=@ID
/*--pokud probehlo vsechno OK, pustime transakci, jinak vse vratime zpet*/
IF @ChybaPriImportu=1
BEGIN
IF @@trancount>0 ROLLBACK TRAN T1
UPDATE dbo.TabUniImportOrg SET Chyba=@TextChybyImportu, DatumImportu=GETDATE() WHERE ID=@ID
END
ELSE IF @@trancount>0 COMMIT TRAN T1
END
END
/*--VERZE IMPORTU C.1--------------------------------------------------------------------------------------------------------------*/
IF @InterniVerze=2
BEGIN
IF ((@CisloOrg IS NOT NULL)AND(EXISTS(SELECT ID FROM TabCisOrg WHERE CisloOrg=@CisloOrg)))
BEGIN /* ORGANIZACE UZ EXISTUJE, DELAME UPDATE*/------------------------------------------------------------------------
BEGIN TRAN T1
SET @IDOrg=(SELECT ID FROM TabCisOrg WHERE CisloOrg=@CisloOrg)
SET @CisloOrgDOS_U=NULL
SET @Nazev_U=NULL
SET @DruhyNazev_U=NULL
SET @Ulice_U=NULL
SET @PopCislo_U=NULL
SET @OrCislo_U=NULL
SET @Misto_U=NULL
SET @PSC_U=NULL
SET @PoBox_U=NULL
SET @IdZeme_U=NULL
SET @ICO_U=NULL
SET @DIC_U=NULL
SET @DICsk_U=NULL
SET @JeOdberatel_U=NULL
SET @JeDodavatel_U=NULL
SET @Fakturacni_U=NULL
SET @MU_U=NULL
SET @Prijemce_U=NULL
SET @VernostniProgram_U=NULL
SET @LhutaSplatnosti_U=NULL
SET @LhutaSplatnostiDodavatel_U=NULL
SET @FormaUhrady_U=NULL
SET @CarovyKodEAN_U=NULL
SET @PostAddress_U=NULL
SET @DatumNeupominani_U=NULL
SET @Kredit_U=NULL
SET @OdpOs_U=NULL
SET @DruhDopravy_U=NULL
SET @DodaciPodminky_U=NULL
SET @CenovaUroven_U=NULL
SET @CenovaUrovenNakup_U=NULL
SET @Mena_U = NULL
SET @NadrizenaOrg_U = NULL
SET @Stav_U = NULL
SET @PravniForma_U = NULL
SET @Jazyk_U = NULL
SET @Upozorneni_U = NULL
SET @Prijmeni_U = NULL
SET @Jmeno_U = NULL
SET @RodneCislo_U = NULL
SET @DatumNarozeni_U = NULL
SET @VstupniCenaDod_U = NULL
SET @VstupniCenaOdb_U = NULL
SELECT @CisloOrgDOS_U=CisloOrgDOS,
@Nazev_U=Nazev,
@DruhyNazev_U=DruhyNazev,
@Ulice_U=Ulice,
@PopCislo_U=PopCislo,
@OrCislo_U=OrCislo,
@Misto_U=Misto,
@PSC_U=PSC,
@PoBox_U=PoBox,
@IdZeme_U=IdZeme,
@ICO_U=ICO,
@DIC_U=DIC,
@DICsk_U=DICsk,
@JeOdberatel_U=JeOdberatel,
@JeDodavatel_U=JeDodavatel,
@Fakturacni_U=Fakturacni,
@MU_U=MU,
@Prijemce_U=Prijemce,
@VernostniProgram_U=VernostniProgram,
@LhutaSplatnosti_U=LhutaSplatnosti,
@LhutaSplatnostiDodavatel_U=LhutaSplatnostiDodavatel,
@FormaUhrady_U=FormaUhrady,
@CarovyKodEAN_U=CarovyKodEAN,
@PostAddress_U=PostAddress,
@DatumNeupominani_U=DatumNeupominani,
@Kredit_U=Kredit,
@OdpOs_U=OdpOs,
@DruhDopravy_U=DruhDopravy,
@DodaciPodminky_U=DodaciPodminky,
@CenovaUroven_U=CenovaUroven,
@CenovaUrovenNakup_U=CenovaUrovenNakup,
@Mena_U=Mena,
@NadrizenaOrg_U=NadrizenaOrg,
@Stav_U=Stav,
@PravniForma_U=PravniForma,
@Jazyk_U=Jazyk,
@Upozorneni_U=Upozorneni,
@Prijmeni_U = Prijmeni,
@Jmeno_U = Jmeno,
@RodneCislo_U = RodneCislo,
@DatumNarozeni_U = DatumNarozeni,
@VstupniCenaDod_U = VstupniCenaDod,
@VstupniCenaOdb_U = VstupniCenaOdb
FROM TabCisOrg
WHERE ID=@IDOrg

SELECT @CisloOrgDOS_B=CisloOrgDOS,
@Nazev_B=Nazev,
@DruhyNazev_B=DruhyNazev,
@Ulice_B=Ulice,
@PopCislo_B=PopCislo,
@OrCislo_B=OrCislo,
@Misto_B=Misto,
@PSC_B=PSC,
@PoBox_B=PoBox,
@IdZeme_B=IdZeme,
@ICO_B=ICO,
@DIC_B=DIC,
@DICsk_B=DICsk,
@JeOdberatel_B=JeOdberatel,
@JeDodavatel_B=JeDodavatel,
@Fakturacni_B=Fakturacni,
@MU_B=MU,
@Prijemce_B=Prijemce,
@VernostniProgram_B=VernostniProgram,
@LhutaSplatnosti_B=LhutaSplatnosti,
@LhutaSplatnostiDodavatel_B=LhutaSplatnostiDodavatel,
@FormaUhrady_B=FormaUhrady,
@Poznamka_B=Poznamka,
@ExtAtr1_B=ExtAtr1,
@ExtAtr2_B=ExtAtr2,
@ExtAtr3_B=ExtAtr3,
@ExtAtr4_B=ExtAtr4,
@ExtAtr5_B=ExtAtr5,
@ExtAtr6_B=ExtAtr6,
@ExtAtr7_B=ExtAtr7,
@ExtAtr8_B=ExtAtr8,
@ExtAtr9_B=ExtAtr9,
@CarovyKodEAN_B=CarovyKodEAN,
@PostAddress_B=PostAddress,
@DatumNeupominani_B=DatumNeupominani,
@Kredit_B=Kredit,
@OdpOs_B=OdpOs,
@DruhDopravy_B=DruhDopravy,
@DodaciPodminky_B=DodaciPodminky,
@CenovaUroven_B=CenovaUroven,
@CenovaUrovenNakup_B=CenovaUrovenNakup,
@Mena_B=Mena,
@NadrizenaOrg_B=NadrizenaOrg,
@Stav_B=Stav,
@PravniForma_B=PravniForma,
@Jazyk_B=Jazyk,
@Upozorneni_B=Upozorneni,
@Kategorie_B=Kategorie,
@Prijmeni_B = Prijmeni,
@Jmeno_B = Jmeno,
@RodneCislo_B = RodneCislo,
@DatumNarozeni_B = DatumNarozeni,
@VstupniCenaDod_B = VstupniCenaDod,
@VstupniCenaOdb_B = VstupniCenaOdb
FROM TabUniImportOrgUp
WHERE IdImpTable=@ID
IF @CisloOrgDOS_B=1 SET @CisloOrgDOS_U=@CisloOrgDOS
IF @Nazev_B=1 SET @Nazev_U=@Nazev
IF @DruhyNazev_B=1 SET @DruhyNazev_U=@DruhyNazev
IF @Ulice_B=1 SET @Ulice_U=@Ulice
IF @PopCislo_B=1 SET @PopCislo_U=@PopCislo
IF @OrCislo_B=1 SET @OrCislo_U=@OrCislo
IF @Misto_B=1 SET @Misto_U=@Misto
IF @PSC_B=1 SET @PSC_U=@PSC
IF @PoBox_B=1 SET @PoBox_U=@PoBox
IF @IdZeme_B=1 SET @IdZeme_U=@IdZeme
IF @ICO_B=1 SET @ICO_U=@ICO
IF @DIC_B=1 SET @DIC_U=@DIC
IF @DICsk_B=1 SET @DICsk_U=@DICsk
IF @JeOdberatel_B=1 SET @JeOdberatel_U=@JeOdberatel
IF @JeDodavatel_B=1 SET @JeDodavatel_U=@JeDodavatel
IF @Fakturacni_B=1 SET @Fakturacni_U=@Fakturacni
IF @MU_B=1 SET @MU_U=@MU
IF @Prijemce_B=1 SET @Prijemce_U=@Prijemce
IF @VernostniProgram_B=1 SET @VernostniProgram_U=@VernostniProgram
IF @LhutaSplatnosti_B=1 SET @LhutaSplatnosti_U=@LhutaSplatnosti
IF @LhutaSplatnostiDodavatel_B=1 SET @LhutaSplatnostiDodavatel_U=@LhutaSplatnostiDodavatel
IF @FormaUhrady_B=1 SET @FormaUhrady_U=@FormaUhrady
IF @CarovyKodEAN_B=1 SET @CarovyKodEAN_U=@CarovyKodEAN
IF @PostAddress_B=1 SET @PostAddress_U=@PostAddress
IF @DatumNeupominani_B=1 SET @DatumNeupominani_U=@DatumNeupominani
IF @Kredit_B=1 SET @Kredit_U=@Kredit
IF @DruhDopravy_B=1 SET @DruhDopravy_U=@DruhDopravy
IF @DodaciPodminky_B=1 SET @DodaciPodminky_U=@DodaciPodminky
IF @CenovaUroven_B=1 SET @CenovaUroven_U=@CenovaUroven
IF @CenovaUrovenNakup_B=1 SET @CenovaUrovenNakup_U=@CenovaUrovenNakup
IF @Mena_B=1 SET @Mena_U=@Mena
IF @NadrizenaOrg_B=1 SET @NadrizenaOrg_U=@NadrizenaOrg
IF @Stav_B=1 SET @Stav_U=@Stav
IF @PravniForma_B=1 SET @PravniForma_U=@PravniForma
IF @Jazyk_B=1 SET @Jazyk_U=@Jazyk
IF @Upozorneni_B=1 SET @Upozorneni_U=@Upozorneni
IF @Prijmeni_B=1 SET @Prijmeni_U=@Prijmeni
IF @Jmeno_B=1 SET @Jmeno_U=@Jmeno
IF @RodneCislo_B=1 SET @RodneCislo_U=@RodneCislo
IF @DatumNarozeni_B=1 SET @DatumNarozeni_U=@DatumNarozeni
IF @VstupniCenaDod_B=1 SET @VstupniCenaDod_U=@VstupniCenaDod
IF @VstupniCenaOdb_B=1 SET @VstupniCenaOdb_U=@VstupniCenaOdb
IF @IdZeme_U IS NOT NULL
BEGIN
IF NOT EXISTS(SELECT ID FROM TabZeme WHERE ISOKod=@IdZeme_U) INSERT TabZeme(ISOKod, SmeroveCislo, Nazev) VALUES(@IdZeme_U, '', '')
IF @@ERROR<>0 SET @ChybaPriImportu=1
END
IF @PSC_U IS NOT NULL
BEGIN
IF NOT EXISTS(SELECT ID FROM TabPSC WHERE Cislo=@PSC_U) INSERT TabPSC(Cislo) VALUES(@PSC_U)
END
IF @@ERROR<>0 SET @ChybaPriImportu=1
/*forma uhrady*/
IF @FormaUhrady IS NOT NULL
BEGIN
IF NOT EXISTS(SELECT * FROM TabFormaUhrady WHERE FormaUhrady=@FormaUhrady) INSERT TabFormaUhrady(FormaUhrady) VALUES(@FormaUhrady)
IF @@ERROR<>0 SET @ChybaPriImportu=1
END
SET @IDKateg=(SELECT IDKateg FROM TabCisOrg WHERE ID=@IDOrg)
IF (ISNULL(@Kategorie, '')<>'')AND(@Kategorie_B=1)
BEGIN
  SET @IDKateg=(SELECT TOP 1 ID FROM TabKategOrg WHERE Nazev=@Kategorie)
  IF @IDKateg IS NULL
  BEGIN
    INSERT TabKategOrg(Nazev) VALUES(@Kategorie)
    SET @IDKateg=SCOPE_IDENTITY()
  END
END
IF @Mena_U IS NOT NULL
  IF NOT EXISTS(SELECT * FROM TabKodMen WHERE Kod=@Mena_U)
    INSERT TabKodMen(Kod, Nazev) VALUES(@Mena_U, '')
UPDATE TabCisOrg SET
CisloOrgDOS=ISNULL(@CisloOrgDOS_U, ''),
Nazev=ISNULL(@Nazev_U, ''),
DruhyNazev=ISNULL(@DruhyNazev_U, ''),
Ulice=ISNULL(@Ulice_U, ''),
PopCislo=ISNULL(@PopCislo_U, ''),
OrCislo=ISNULL(@OrCislo_U, ''),
Misto=ISNULL(@Misto_U, ''),
PSC=@PSC_U,
PoBox=@PoBox_U,
IdZeme=@IdZeme_U,
ICO=@ICO_U,
DICsk=@DICsk_U,
JeOdberatel=ISNULL(@JeOdberatel_U, 0),
JeDodavatel=ISNULL(@JeDodavatel_U, 0),
Fakturacni=ISNULL(@Fakturacni_U, 0),
MU=ISNULL(@MU_U, 0),
Prijemce=ISNULL(@Prijemce_U, 0),
VernostniProgram=ISNULL(@VernostniProgram_U, 0),
LhutaSplatnosti=@LhutaSplatnosti_U,
LhutaSplatnostiDodavatel=@LhutaSplatnostiDodavatel_U,
FormaUhrady=@FormaUhrady_U,
CarovyKodEAN=@CarovyKodEAN_U,
PostAddress = @PostAddress_U,
DatumNeupominani = @DatumNeupominani_U,
Kredit = ISNULL(@Kredit_U, 0),
DruhDopravy = @DruhDopravy_U,
DodaciPodminky = @DodaciPodminky_U,
Mena = @Mena_U,
Stav = @Stav_U,
PravniForma = @PravniForma_U,
Upozorneni = @Upozorneni_U,
IDKateg = @IDKateg,
Prijmeni=ISNULL(@Prijmeni_U, ''),
Jmeno=ISNULL(@Jmeno_U, ''),
RodneCislo=ISNULL(@RodneCislo_U, ''),
DatumNarozeni=@DatumNarozeni_U,
VstupniCenaDod=ISNULL(@VstupniCenaDod_U, 100),
VstupniCenaOdb=ISNULL(@VstupniCenaOdb_U, 100),
Zmenil=SUSER_SNAME(),
DatZmeny=GETDATE()
WHERE ID=@IDOrg
IF @Poznamka_B=1
UPDATE TabCisOrg SET TabCisOrg.Poznamka=TabUniImportOrg.Poznamka
FROM TabUniImportOrg
WHERE TabUniImportOrg.ID=@ID AND TabCisOrg.CisloOrg=@CisloOrg
IF @Telefon IS NOT NULL
IF NOT EXISTS(SELECT ID FROM TabKontakty WHERE IDVztahKOsOrg IS NULL AND IDOrg=@IDOrg AND Spojeni=@Telefon AND Druh=1)
INSERT TabKontakty(IDOrg, Spojeni, Druh) VALUES(@IDOrg, @Telefon, 1)
IF @@ERROR<>0 SET @ChybaPriImportu=1
IF @Mobil IS NOT NULL
IF NOT EXISTS(SELECT ID FROM TabKontakty WHERE IDVztahKOsOrg IS NULL AND IDOrg=@IDOrg AND Spojeni=@Mobil AND Druh=2)
INSERT TabKontakty(IDOrg, Spojeni, Druh) VALUES(@IDOrg, @Mobil, 2)
IF @@ERROR<>0 SET @ChybaPriImportu=1
IF @Fax IS NOT NULL
IF NOT EXISTS(SELECT ID FROM TabKontakty WHERE IDVztahKOsOrg IS NULL AND IDOrg=@IDOrg AND Spojeni=@Fax AND Druh=3)
INSERT TabKontakty(IDOrg, Spojeni, Druh) VALUES(@IDOrg, @Fax, 3)
IF @@ERROR<>0 SET @ChybaPriImportu=1
IF @Email IS NOT NULL
IF NOT EXISTS(SELECT ID FROM TabKontakty WHERE IDVztahKOsOrg IS NULL AND IDOrg=@IDOrg AND Spojeni=@Email AND Druh=6)
INSERT TabKontakty(IDOrg, Spojeni, Druh) VALUES(@IDOrg, @Email, 6)
IF @@ERROR<>0 SET @ChybaPriImportu=1
IF @WWW IS NOT NULL
IF NOT EXISTS(SELECT ID FROM TabKontakty WHERE IDVztahKOsOrg IS NULL AND IDOrg=@IDOrg AND Spojeni=@WWW AND Druh=7)
INSERT TabKontakty(IDOrg, Spojeni, Druh) VALUES(@IDOrg, @WWW, 7)
IF @@ERROR<>0 SET @ChybaPriImportu=1
IF @HromadneProEmail IS NOT NULL
IF NOT EXISTS(SELECT ID FROM TabKontakty WHERE IDVztahKOsOrg IS NULL AND IDOrg=@IDOrg AND Spojeni=@HromadneProEmail AND Druh=10)
INSERT TabKontakty(IDOrg, Spojeni, Druh) VALUES(@IDOrg, @HromadneProEmail, 10)
IF @@ERROR<>0 SET @ChybaPriImportu=1
IF @HromadneProEmailAutomat IS NOT NULL
IF NOT EXISTS(SELECT ID FROM TabKontakty WHERE IDVztahKOsOrg IS NULL AND IDOrg=@IDOrg AND Spojeni=@HromadneProEmailAutomat AND Druh=17)
INSERT TabKontakty(IDOrg, Spojeni, Druh) VALUES(@IDOrg, @HromadneProEmailAutomat, 17)
IF @@ERROR<>0 SET @ChybaPriImportu=1
IF @KOPrijmeni IS NOT NULL
BEGIN
EXEC @CisloKOs=dbo.hp_NajdiPrvniVolny 'TabCisKOs','Cislo',1,999999,'',1,1
INSERT TabCisKOs(Cislo, Jmeno, Prijmeni, RodnePrijmeni, TitulPred, TitulZa, RodneCislo, MistoNarozeni, Ulice, Misto, Narodnost, CisloOP, CisloPasu)
VALUES(@CisloKOs, @KOJmeno, @KOPrijmeni, '', '', '', '', '', '', '', '', '', '')
IF @@ERROR<>0 SET @ChybaPriImportu=1
SET @IDKOs=(SELECT ID FROM TabCisKOs WHERE Cislo=@CisloKOs)
INSERT TabVztahOrgKOs(IDOrg, IDCisKOs, Funkce) VALUES(@IDOrg, @IDKOs, ISNULL(@KOFunkce, ''))
IF @@ERROR<>0 SET @ChybaPriImportu=1
SET @IDVztahKOsOrg=(SELECT ID FROM TabVztahOrgKOs WHERE IDOrg=@IDOrg AND IDCisKOs=@IDKOs)
IF @KOTelefon IS NOT NULL
IF NOT EXISTS(SELECT ID FROM TabKontakty WHERE IDOrg=@IDOrg AND IDCisKOs=@IDKOs AND Spojeni=@KOTelefon AND Druh=1)
INSERT TabKontakty(IDOrg, IDCisKOs, Spojeni, Druh, IDVztahKOsOrg) VALUES(@IDOrg, @IDKOs, @KOTelefon, 1, @IDVztahKOsOrg)
IF @@ERROR<>0 SET @ChybaPriImportu=1
IF @KOMobil IS NOT NULL
IF NOT EXISTS(SELECT ID FROM TabKontakty WHERE IDOrg=@IDOrg AND IDCisKOs=@IDKOs AND Spojeni=@KOMobil AND Druh=2)
INSERT TabKontakty(IDOrg, IDCisKOs, Spojeni, Druh, IDVztahKOsOrg) VALUES(@IDOrg, @IDKOs, @KOMobil, 2, @IDVztahKOsOrg)
IF @@ERROR<>0 SET @ChybaPriImportu=1
IF @KOFax IS NOT NULL
IF NOT EXISTS(SELECT ID FROM TabKontakty WHERE IDOrg=@IDOrg AND IDCisKOs=@IDKOs AND Spojeni=@KOFax AND Druh=3)
INSERT TabKontakty(IDOrg, IDCisKOs, Spojeni, Druh, IDVztahKOsOrg) VALUES(@IDOrg, @IDKOs, @KOFax, 3, @IDVztahKOsOrg)
IF @@ERROR<>0 SET @ChybaPriImportu=1
IF @KOEmail IS NOT NULL
IF NOT EXISTS(SELECT ID FROM TabKontakty WHERE IDOrg=@IDOrg AND IDCisKOs=@IDKOs AND Spojeni=@KOEmail AND Druh=6)
INSERT TabKontakty(IDOrg, IDCisKOs, Spojeni, Druh, IDVztahKOsOrg) VALUES(@IDOrg, @IDKOs, @KOEmail, 6, @IDVztahKOsOrg)
IF @@ERROR<>0 SET @ChybaPriImportu=1
END
/*bankovni spojeni*/
IF (@CisloUctu IS NOT NULL)OR(@IBANElektronicky IS NOT NULL)
BEGIN
IF @KodUstavu IS NOT NULL
  IF NOT EXISTS(SELECT TOP 1 ID FROM TabPenezniUstavy WHERE KodUstavu=@KodUstavu)
INSERT TabPenezniUstavy(KodUstavu, SWIFTUstavu) VALUES(@KodUstavu, ISNULL(@SWIFTUstavu, ''))
IF @@ERROR<>0 SET @ChybaPriImportu=1
IF (@KodUstavu IS NULL)AND(@SWIFTUstavu IS NOT NULL)
  IF NOT EXISTS(SELECT * FROM TabPenezniUstavy WHERE SWIFTUstavu=@SWIFTUstavu)
INSERT TabPenezniUstavy(SWIFTUstavu, TypUstavu) VALUES(@SWIFTUstavu, 1)
IF @@ERROR<>0 SET @ChybaPriImportu=1
SET @IDUstavu=NULL
IF @MenaBankSpoj IS NOT NULL
  IF NOT EXISTS(SELECT * FROM TabKodMen WHERE Kod=@MenaBankSpoj)
    INSERT TabKodMen(Kod, Nazev) VALUES(@MenaBankSpoj, '')
IF @KodUstavu IS NOT NULL SET @IDUstavu=(SELECT TOP 1 ID FROM TabPenezniUstavy WHERE KodUstavu=@KodUstavu)
IF (@KodUstavu IS NULL)AND(@SWIFTUstavu IS NOT NULL) SET @IDUstavu=(SELECT TOP 1 ID FROM TabPenezniUstavy WHERE SWIFTUstavu=@SWIFTUstavu)
INSERT TabBankSpojeni(IDOrg, IDUstavu, NazevBankSpoj, Mena, CisloUctu, VariabilniSymbol, KonstantniSymbol, SpecifickySymbol, IBANElektronicky, Prednastaveno)
VALUES(@IDOrg, @IDUstavu, ISNULL(@NazevBankSpoj, ''), @MenaBankSpoj, ISNULL(@CisloUctu, ''), @VariabilniSymbol, @KonstantniSymbol, @SpecifickySymbol, ISNULL(@IBANElektronicky, ''), 1)
IF @@ERROR<>0 SET @ChybaPriImportu=1
END
IF (@OdpOs IS NOT NULL)AND(@OdpOs_B=1)
BEGIN
  IF EXISTS(SELECT 0 FROM TabCisZam WHERE Cislo=@OdpOs)
  BEGIN
    UPDATE TabCisOrg SET OdpOs = (SELECT ID FROM TabCisZam WHERE Cislo=@OdpOs)
    WHERE ID = @IDOrg
  END
  ELSE
  BEGIN
  SET @ChybaPriImportu=1
  IF @TextChybyImportu<>'' SET @TextChybyImportu=@TextChybyImportu + ' | '
  SET @TextChybyImportu = @TextChybyImportu + dbo.hpf_UniImportHlasky('FF69ED3B-1439-44E5-A410-85F62ED7A790', @JazykVerze, DEFAULT, DEFAULT, DEFAULT, DEFAULT)
  END
END
IF (@ChybaPriImportu=0)AND(ISNULL(@DIC_U, '')<>'')
BEGIN
  EXEC dbo.hp_VAT_ID_kontrola @DIC_U, @ErrNo OUT
  IF @ErrNo<>0
  BEGIN
  SET @ChybaPriImportu=1
  IF @TextChybyImportu<>'' SET @TextChybyImportu=@TextChybyImportu + ' | '
  SET @TextChybyImportu = @TextChybyImportu + dbo.hpf_UniImportHlasky('7721501C-2718-4B19-99AE-5E28101752F4', @JazykVerze, DEFAULT, DEFAULT, DEFAULT, DEFAULT)
  END
  ELSE
    UPDATE TabCisOrg SET DIC=@DIC_U WHERE ID=@IDOrg
END
IF @CenovaUroven IS NOT NULL
BEGIN
  IF EXISTS(SELECT * FROM TabCisNC WHERE CenovaUroven = @CenovaUroven)
  BEGIN
    UPDATE TabCisOrg SET CenovaUroven = @CenovaUroven
    WHERE ID = @IDOrg
  END
  ELSE
  BEGIN
  SET @ChybaPriImportu=1
  IF @TextChybyImportu<>'' SET @TextChybyImportu=@TextChybyImportu + ' | '
  SET @TextChybyImportu = @TextChybyImportu + dbo.hpf_UniImportHlasky('69ECBD4F-214D-4FE9-A5A4-27D4F980E426', @JazykVerze, DEFAULT, DEFAULT, DEFAULT, DEFAULT)
  END
END
IF @CenovaUrovenNakup IS NOT NULL
BEGIN
  IF EXISTS(SELECT * FROM TabCisNC WHERE CenovaUroven = @CenovaUrovenNakup)
  BEGIN
    UPDATE TabCisOrg SET CenovaUrovenNakup = @CenovaUrovenNakup
    WHERE ID = @IDOrg
  END
  ELSE
  BEGIN
  SET @ChybaPriImportu=1
  IF @TextChybyImportu<>'' SET @TextChybyImportu=@TextChybyImportu + ' | '
  SET @TextChybyImportu = @TextChybyImportu + dbo.hpf_UniImportHlasky('69ECBD4F-214D-4FE9-A5A4-27D4F980E426', @JazykVerze, DEFAULT, DEFAULT, DEFAULT, DEFAULT)
  END
END
IF @NadrizenaOrg IS NOT NULL
BEGIN
  IF EXISTS(SELECT * FROM TabCisOrg WHERE CisloOrg = @NadrizenaOrg)
  BEGIN
    UPDATE TabCisOrg SET NadrizenaOrg = @NadrizenaOrg
    WHERE ID = @IDOrg
  END
  ELSE
  BEGIN
  SET @ChybaPriImportu=1
  IF @TextChybyImportu<>'' SET @TextChybyImportu=@TextChybyImportu + ' | '
  SET @TextChybyImportu = @TextChybyImportu + dbo.hpf_UniImportHlasky('2B45B17B-5764-474D-9051-9A01977C24AD', @JazykVerze, DEFAULT, DEFAULT, DEFAULT, DEFAULT)
  END
END
IF @Jazyk IS NOT NULL
BEGIN
  IF EXISTS(SELECT * FROM TabJazyky WHERE Jazyk=@Jazyk)
  BEGIN
    UPDATE TabCisOrg SET Jazyk = @Jazyk
    WHERE ID = @IDOrg
  END
  ELSE
  BEGIN
  SET @ChybaPriImportu=1
  IF @TextChybyImportu<>'' SET @TextChybyImportu=@TextChybyImportu + ' | '
  SET @TextChybyImportu = @TextChybyImportu + dbo.hpf_UniImportHlasky('84E0557B-6B64-450A-A84E-4DF53A77CF13', @JazykVerze, DEFAULT, DEFAULT, DEFAULT, DEFAULT)
  END
END
SET @SQLString=''
IF (@ExtAtr1 IS NOT NULL)AND(@ExtAtr1Nazev IS NOT NULL)
BEGIN
IF (OBJECT_ID('TabCisOrg_EXT','U')IS NOT NULL)AND(COLUMNPROPERTY(OBJECT_ID('TabCisOrg_EXT','U'),'_'+@ExtAtr1Nazev,'AllowsNull')IS NOT NULL)
BEGIN
SET @ExtAtr1Nazev='_' + @ExtAtr1Nazev
IF EXISTS(SELECT ID FROM TabCisOrg_EXT WHERE ID=@IDOrg)
BEGIN
IF @ExtAtr1_B=1
SET @SQLString='UPDATE TabCisOrg_EXT SET ' + @ExtAtr1Nazev + '=N' + '''' + @ExtAtr1 + '''' + ' WHERE ID=' + CAST(@IDOrg AS NVARCHAR(10))
END
ELSE
SET @SQLString='INSERT TabCisOrg_EXT(ID, ' + @ExtAtr1Nazev + ') VALUES(' + CAST(@IDOrg AS NVARCHAR(10)) + ', N' + '''' + @ExtAtr1 + '''' + ')'
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
IF (OBJECT_ID('TabCisOrg_EXT','U')IS NOT NULL)AND(COLUMNPROPERTY(OBJECT_ID('TabCisOrg_EXT','U'),'_'+@ExtAtr2Nazev,'AllowsNull')IS NOT NULL)
BEGIN
SET @ExtAtr2Nazev='_' + @ExtAtr2Nazev
IF EXISTS(SELECT ID FROM TabCisOrg_EXT WHERE ID=@IDOrg)
BEGIN
IF @ExtAtr2_B=1
SET @SQLString='UPDATE TabCisOrg_EXT SET ' + @ExtAtr2Nazev + '=' + '''' + @ExtAtr2 + '''' + ' WHERE ID=' + CAST(@IDOrg AS NVARCHAR(10))
END
ELSE
SET @SQLString='INSERT TabCisOrg_EXT(ID, ' + @ExtAtr2Nazev + ') VALUES(' + CAST(@IDOrg AS NVARCHAR(10)) + ', ' + '''' + @ExtAtr2 + '''' + ')'
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
IF (OBJECT_ID('TabCisOrg_EXT','U')IS NOT NULL)AND(COLUMNPROPERTY(OBJECT_ID('TabCisOrg_EXT','U'),'_'+@ExtAtr3Nazev,'AllowsNull')IS NOT NULL)
BEGIN
SET @ExtAtr3Nazev='_' + @ExtAtr3Nazev
IF EXISTS(SELECT ID FROM TabCisOrg_EXT WHERE ID=@IDOrg)
BEGIN
IF @ExtAtr3_B=1
SET @SQLString='UPDATE TabCisOrg_EXT SET ' + @ExtAtr3Nazev + '=' + '''' + CONVERT(NVARCHAR(10),@ExtAtr3, 112) + '''' + ' WHERE ID=' + CAST(@IDOrg AS NVARCHAR(10))
END
ELSE
SET @SQLString='INSERT TabCisOrg_EXT(ID, ' + @ExtAtr3Nazev + ') VALUES(' + CAST(@IDOrg AS NVARCHAR(10)) + ', ' + '''' + CONVERT(NVARCHAR(10),@ExtAtr3, 112) + '''' + ')'
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
IF (OBJECT_ID('TabCisOrg_EXT','U')IS NOT NULL)AND(COLUMNPROPERTY(OBJECT_ID('TabCisOrg_EXT','U'),'_'+@ExtAtr4Nazev,'AllowsNull')IS NOT NULL)
BEGIN
SET @ExtAtr4Nazev='_' + @ExtAtr4Nazev
IF EXISTS(SELECT ID FROM TabCisOrg_EXT WHERE ID=@IDOrg)
BEGIN
IF @ExtAtr4_B=1
SET @SQLString='UPDATE TabCisOrg_EXT SET ' + @ExtAtr4Nazev + '=' + CAST(@ExtAtr4 AS NVARCHAR(26)) +  ' WHERE ID=' + CAST(@IDOrg AS NVARCHAR(10))
END
ELSE
SET @SQLString='INSERT TabCisOrg_EXT(ID, ' + @ExtAtr4Nazev + ') VALUES(' + CAST(@IDOrg AS NVARCHAR(10)) + ', ' + CAST(@ExtAtr4 AS NVARCHAR(26)) + ')'
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
IF (OBJECT_ID('TabCisOrg_EXT','U')IS NOT NULL)AND(COLUMNPROPERTY(OBJECT_ID('TabCisOrg_EXT','U'),'_'+@ExtAtr5Nazev,'AllowsNull')IS NOT NULL)
BEGIN
SET @ExtAtr5Nazev='_' + @ExtAtr5Nazev
IF EXISTS(SELECT ID FROM TabCisOrg_EXT WHERE ID=@IDOrg)
BEGIN
IF @ExtAtr5_B=1
SET @SQLString='UPDATE TabCisOrg_EXT SET ' + @ExtAtr5Nazev + '=' + '''' + @ExtAtr5 + '''' + ' WHERE ID=' + CAST(@IDOrg AS NVARCHAR(10))
END
ELSE
SET @SQLString='INSERT TabCisOrg_EXT(ID, ' + @ExtAtr5Nazev + ') VALUES(' + CAST(@IDOrg AS NVARCHAR(10)) + ', ' + '''' + @ExtAtr5 + '''' + ')'
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
IF (OBJECT_ID('TabCisOrg_EXT','U')IS NOT NULL)AND(COLUMNPROPERTY(OBJECT_ID('TabCisOrg_EXT','U'),'_'+@ExtAtr6Nazev,'AllowsNull')IS NOT NULL)
BEGIN
SET @ExtAtr6Nazev='_' + @ExtAtr6Nazev
IF EXISTS(SELECT ID FROM TabCisOrg_EXT WHERE ID=@IDOrg)
BEGIN
IF @ExtAtr6_B=1
SET @SQLString='UPDATE TabCisOrg_EXT SET ' + @ExtAtr6Nazev + '=' + '''' + @ExtAtr6 + '''' + ' WHERE ID=' + CAST(@IDOrg AS NVARCHAR(10))
END
ELSE
SET @SQLString='INSERT TabCisOrg_EXT(ID, ' + @ExtAtr6Nazev + ') VALUES(' + CAST(@IDOrg AS NVARCHAR(10)) + ', ' + '''' + @ExtAtr6 + '''' + ')'
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
IF (OBJECT_ID('TabCisOrg_EXT','U')IS NOT NULL)AND(COLUMNPROPERTY(OBJECT_ID('TabCisOrg_EXT','U'),'_'+@ExtAtr7Nazev,'AllowsNull')IS NOT NULL)
BEGIN
SET @ExtAtr7Nazev='_' + @ExtAtr7Nazev
IF EXISTS(SELECT ID FROM TabCisOrg_EXT WHERE ID=@IDOrg)
BEGIN
IF @ExtAtr7_B=1
SET @SQLString='UPDATE TabCisOrg_EXT SET ' + @ExtAtr7Nazev + '=' + '''' + @ExtAtr7 + '''' + ' WHERE ID=' + CAST(@IDOrg AS NVARCHAR(10))
END
ELSE
SET @SQLString='INSERT TabCisOrg_EXT(ID, ' + @ExtAtr7Nazev + ') VALUES(' + CAST(@IDOrg AS NVARCHAR(10)) + ', ' + '''' + @ExtAtr7 + '''' + ')'
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
IF (OBJECT_ID('TabCisOrg_EXT','U')IS NOT NULL)AND(COLUMNPROPERTY(OBJECT_ID('TabCisOrg_EXT','U'),'_'+@ExtAtr8Nazev,'AllowsNull')IS NOT NULL)
BEGIN
SET @ExtAtr8Nazev='_' + @ExtAtr8Nazev
IF EXISTS(SELECT ID FROM TabCisOrg_EXT WHERE ID=@IDOrg)
BEGIN
IF @ExtAtr8_B=1
SET @SQLString='UPDATE TabCisOrg_EXT SET ' + @ExtAtr8Nazev + '=' + '''' + @ExtAtr8 + '''' + ' WHERE ID=' + CAST(@IDOrg AS NVARCHAR(10))
END
ELSE
SET @SQLString='INSERT TabCisOrg_EXT(ID, ' + @ExtAtr8Nazev + ') VALUES(' + CAST(@IDOrg AS NVARCHAR(10)) + ', ' + '''' + @ExtAtr8 + '''' + ')'
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
IF (OBJECT_ID('TabCisOrg_EXT','U')IS NOT NULL)AND(COLUMNPROPERTY(OBJECT_ID('TabCisOrg_EXT','U'),'_'+@ExtAtr9Nazev,'AllowsNull')IS NOT NULL)
BEGIN
SET @ExtAtr9Nazev='_' + @ExtAtr9Nazev
IF EXISTS(SELECT ID FROM TabCisOrg_EXT WHERE ID=@IDOrg)
BEGIN
IF @ExtAtr9_B=1
SET @SQLString='UPDATE TabCisOrg_EXT SET ' + @ExtAtr9Nazev + '=' + CAST(@ExtAtr9 AS NVARCHAR) + ' WHERE ID=' + CAST(@IDOrg AS NVARCHAR(10))
END
ELSE
SET @SQLString='INSERT TabCisOrg_EXT(ID, ' + @ExtAtr9Nazev + ') VALUES(' + CAST(@IDOrg AS NVARCHAR(10)) + ', ' + CAST(@ExtAtr9 AS NVARCHAR) + ')'
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
  @ImportIdent=0,
  @IdImpTable=@ID,
  @IdTargetTable=@IDOrg,
  @Chyba=@ChybaExtAtr OUT
IF @ChybaExtAtr<>''
BEGIN
  SET @ChybaPriImportu=1
  IF @TextChybyImportu<>'' SET @TextChybyImportu=@TextChybyImportu + ' | '
  SET @TextChybyImportu = @TextChybyImportu + dbo.hpf_UniImportHlasky('15364319-B20F-4D65-8900-391DE8D4C52F', @JazykVerze, @ChybaExtAtr, DEFAULT, DEFAULT, DEFAULT)
END
IF OBJECT_ID('dbo.epx_UniImportOrg03', 'P') IS NOT NULL EXEC dbo.epx_UniImportOrg03 @IDOrg
IF @@ERROR<>0 SET @ChybaPriImportu=1
IF @ChybaPriImportu=0 DELETE FROM dbo.TabUniImportOrg WHERE ID=@ID
IF @ChybaPriImportu=1
BEGIN
IF @@trancount>0 ROLLBACK TRAN T1
UPDATE dbo.TabUniImportOrg SET Chyba=@TextChybyImportu, DatumImportu=GETDATE() WHERE ID=@ID
END
ELSE IF @@trancount>0 COMMIT TRAN T1
END   /* *ORGANIZACE UZ EXISTUJE, DELAME UPDATE*/------------------------------------------------------------------------
ELSE
BEGIN /* ORGANIZACE JESTE NEEXISTUJE, ZAKLADAME NOVOU*/
BEGIN TRAN T1
SET @CisloOrgMin=(SELECT CisloOrgMin FROM TabHGlob)
IF @CisloOrgMin IS NULL SET @CisloOrgMin=1
SET @CisloOrgMax=(SELECT CisloOrgMax FROM TabHGlob)
IF @CisloOrgMax IS NULL SET @CisloOrgMax=2147483647
IF @CisloOrg IS NULL
BEGIN
EXEC @CisloOrg=dbo.hp_NajdiPrvniVolny 'TabCisOrg','CisloOrg',@CisloOrgMin,@CisloOrgMax,'',1,1
END
IF @@ERROR<>0 SET @ChybaPriImportu=1
IF @IdZeme IS NOT NULL
BEGIN
IF NOT EXISTS(SELECT ID FROM TabZeme WHERE ISOKod=@IdZeme) INSERT TabZeme(ISOKod, SmeroveCislo, Nazev) VALUES(@IdZeme, '', '')
IF @@ERROR<>0 SET @ChybaPriImportu=1
END
/*forma uhrady*/
IF @FormaUhrady IS NOT NULL
BEGIN
IF NOT EXISTS(SELECT * FROM TabFormaUhrady WHERE FormaUhrady=@FormaUhrady) INSERT TabFormaUhrady(FormaUhrady) VALUES(@FormaUhrady)
IF @@ERROR<>0 SET @ChybaPriImportu=1
END
IF @Mena IS NOT NULL
  IF NOT EXISTS(SELECT * FROM TabKodMen WHERE Kod=@Mena)
    INSERT TabKodMen(Kod, Nazev) VALUES(@Mena, '')
SET @IDKateg=NULL
IF ISNULL(@Kategorie, '')<>''
BEGIN
  SET @IDKateg=(SELECT TOP 1 ID FROM TabKategOrg WHERE Nazev=@Kategorie)
  IF @IDKateg IS NULL
  BEGIN
    INSERT TabKategOrg(Nazev) VALUES(@Kategorie)
    SET @IDKateg=SCOPE_IDENTITY()
  END
END
INSERT TabCisOrg(CisloOrg, CisloOrgDOS, Nazev, DruhyNazev, Ulice, PopCislo, OrCislo, Misto, PoBox, ICO, JeOdberatel, JeDodavatel, Fakturacni, MU, Prijemce,
                 LhutaSplatnosti, IdZeme, FormaUhrady, CarovyKodEAN, VernostniProgram, PostAddress, DatumNeupominani, DICsk, Kredit, DruhDopravy, DodaciPodminky, Mena, Stav, PravniForma, LhutaSplatnostiDodavatel, Upozorneni, IDKateg,
                 Prijmeni, Jmeno, RodneCislo, DatumNarozeni, VstupniCenaDod, VstupniCenaOdb)
VALUES(@CisloOrg, ISNULL(@CisloOrgDOS,''), ISNULL(@Nazev,''), ISNULL(@DruhyNazev,''), ISNULL(@Ulice,''), ISNULL(@PopCislo,''), ISNULL(@OrCislo,''), ISNULL(@Misto,''),
@PoBox, @ICO, @JeOdberatel, @JeDodavatel, @Fakturacni, @MU, @Prijemce, @LhutaSplatnosti, @IdZeme, @FormaUhrady, @CarovyKodEAN, @VernostniProgram, @PostAddress, @DatumNeupominani, @DICsk, ISNULL(@Kredit, 0), @DruhDopravy,
@DodaciPodminky, @Mena, @Stav, ISNULL(@PravniForma, 0), @LhutaSplatnostiDodavatel, @Upozorneni, @IDKateg, ISNULL(@Prijmeni, ''), ISNULL(@Jmeno, ''), ISNULL(@RodneCislo, ''), @DatumNarozeni, @VstupniCenaDod, @VstupniCenaOdb)
IF @@ERROR<>0 SET @ChybaPriImportu=1
SET @IDOrg=SCOPE_IDENTITY()
UPDATE TabCisOrg SET TabCisOrg.Poznamka=TabUniImportOrg.Poznamka
FROM TabUniImportOrg
WHERE TabUniImportOrg.ID=@ID AND TabCisOrg.CisloOrg=@CisloOrg
IF @@ERROR<>0 SET @ChybaPriImportu=1
IF @PSC IS NOT NULL
BEGIN
UPDATE TabCisOrg SET PSC=@PSC WHERE CisloOrg=@CisloOrg
IF NOT EXISTS(SELECT ID FROM TabPSC WHERE Cislo=@PSC) INSERT TabPSC(Cislo) VALUES(@PSC)
END
IF @@ERROR<>0 SET @ChybaPriImportu=1
IF @Telefon IS NOT NULL
IF NOT EXISTS(SELECT ID FROM TabKontakty WHERE IDVztahKOsOrg IS NULL AND IDOrg=@IDOrg AND Spojeni=@Telefon AND Druh=1)
INSERT TabKontakty(IDOrg, Spojeni, Druh) VALUES(@IDOrg, @Telefon, 1)
IF @@ERROR<>0 SET @ChybaPriImportu=1
IF @Mobil IS NOT NULL
IF NOT EXISTS(SELECT ID FROM TabKontakty WHERE IDVztahKOsOrg IS NULL AND IDOrg=@IDOrg AND Spojeni=@Mobil AND Druh=2)
INSERT TabKontakty(IDOrg, Spojeni, Druh) VALUES(@IDOrg, @Mobil, 2)
IF @@ERROR<>0 SET @ChybaPriImportu=1
IF @Fax IS NOT NULL
IF NOT EXISTS(SELECT ID FROM TabKontakty WHERE IDVztahKOsOrg IS NULL AND IDOrg=@IDOrg AND Spojeni=@Fax AND Druh=3)
INSERT TabKontakty(IDOrg, Spojeni, Druh) VALUES(@IDOrg, @Fax, 3)
IF @@ERROR<>0 SET @ChybaPriImportu=1
IF @Email IS NOT NULL
IF NOT EXISTS(SELECT ID FROM TabKontakty WHERE IDVztahKOsOrg IS NULL AND IDOrg=@IDOrg AND Spojeni=@Email AND Druh=6)
INSERT TabKontakty(IDOrg, Spojeni, Druh) VALUES(@IDOrg, @Email, 6)
IF @@ERROR<>0 SET @ChybaPriImportu=1
IF @WWW IS NOT NULL
IF NOT EXISTS(SELECT ID FROM TabKontakty WHERE IDVztahKOsOrg IS NULL AND IDOrg=@IDOrg AND Spojeni=@WWW AND Druh=7)
INSERT TabKontakty(IDOrg, Spojeni, Druh) VALUES(@IDOrg, @WWW, 7)
IF @@ERROR<>0 SET @ChybaPriImportu=1
IF @HromadneProEmail IS NOT NULL
IF NOT EXISTS(SELECT ID FROM TabKontakty WHERE IDVztahKOsOrg IS NULL AND IDOrg=@IDOrg AND Spojeni=@HromadneProEmail AND Druh=10)
INSERT TabKontakty(IDOrg, Spojeni, Druh) VALUES(@IDOrg, @HromadneProEmail, 10)
IF @@ERROR<>0 SET @ChybaPriImportu=1
IF @HromadneProEmailAutomat IS NOT NULL
IF NOT EXISTS(SELECT ID FROM TabKontakty WHERE IDVztahKOsOrg IS NULL AND IDOrg=@IDOrg AND Spojeni=@HromadneProEmailAutomat AND Druh=17)
INSERT TabKontakty(IDOrg, Spojeni, Druh) VALUES(@IDOrg, @HromadneProEmailAutomat, 17)
IF @@ERROR<>0 SET @ChybaPriImportu=1
IF @KOPrijmeni IS NOT NULL
BEGIN
EXEC @CisloKOs=dbo.hp_NajdiPrvniVolny 'TabCisKOs','Cislo',1,999999,'',1,1
INSERT TabCisKOs(Cislo, Jmeno, Prijmeni, RodnePrijmeni, TitulPred, TitulZa, RodneCislo, MistoNarozeni, Ulice, Misto, Narodnost, CisloOP, CisloPasu)
VALUES(@CisloKOs, @KOJmeno, @KOPrijmeni, '', '', '', '', '', '', '', '', '', '')
IF @@ERROR<>0 SET @ChybaPriImportu=1
SET @IDKOs=(SELECT ID FROM TabCisKOs WHERE Cislo=@CisloKOs)
INSERT TabVztahOrgKOs(IDOrg, IDCisKOs, Funkce) VALUES(@IDOrg, @IDKOs, ISNULL(@KOFunkce, ''))
IF @@ERROR<>0 SET @ChybaPriImportu=1
SET @IDVztahKOsOrg=(SELECT ID FROM TabVztahOrgKOs WHERE IDOrg=@IDOrg AND IDCisKOs=@IDKOs)
IF @KOTelefon IS NOT NULL
IF NOT EXISTS(SELECT ID FROM TabKontakty WHERE IDOrg=@IDOrg AND IDCisKOs=@IDKOs AND Spojeni=@KOTelefon AND Druh=1)
INSERT TabKontakty(IDOrg, IDCisKOs, Spojeni, Druh, IDVztahKOsOrg) VALUES(@IDOrg, @IDKOs, @KOTelefon, 1, @IDVztahKOsOrg)
IF @@ERROR<>0 SET @ChybaPriImportu=1
IF @KOMobil IS NOT NULL
IF NOT EXISTS(SELECT ID FROM TabKontakty WHERE IDOrg=@IDOrg AND IDCisKOs=@IDKOs AND Spojeni=@KOMobil AND Druh=2)
INSERT TabKontakty(IDOrg, IDCisKOs, Spojeni, Druh, IDVztahKOsOrg) VALUES(@IDOrg, @IDKOs, @KOMobil, 2, @IDVztahKOsOrg)
IF @@ERROR<>0 SET @ChybaPriImportu=1
IF @KOFax IS NOT NULL
IF NOT EXISTS(SELECT ID FROM TabKontakty WHERE IDOrg=@IDOrg AND IDCisKOs=@IDKOs AND Spojeni=@KOFax AND Druh=3)
INSERT TabKontakty(IDOrg, IDCisKOs, Spojeni, Druh, IDVztahKOsOrg) VALUES(@IDOrg, @IDKOs, @KOFax, 3, @IDVztahKOsOrg)
IF @@ERROR<>0 SET @ChybaPriImportu=1
IF @KOEmail IS NOT NULL
IF NOT EXISTS(SELECT ID FROM TabKontakty WHERE IDOrg=@IDOrg AND IDCisKOs=@IDKOs AND Spojeni=@KOEmail AND Druh=6)
INSERT TabKontakty(IDOrg, IDCisKOs, Spojeni, Druh, IDVztahKOsOrg) VALUES(@IDOrg, @IDKOs, @KOEmail, 6, @IDVztahKOsOrg)
IF @@ERROR<>0 SET @ChybaPriImportu=1
END
/*bankovni spojeni*/
IF (@CisloUctu IS NOT NULL)OR(@IBANElektronicky IS NOT NULL)
BEGIN
IF @KodUstavu IS NOT NULL
  IF NOT EXISTS(SELECT TOP 1 ID FROM TabPenezniUstavy WHERE KodUstavu=@KodUstavu)
INSERT TabPenezniUstavy(KodUstavu, SWIFTUstavu) VALUES(@KodUstavu, ISNULL(@SWIFTUstavu, ''))
IF @@ERROR<>0 SET @ChybaPriImportu=1
IF (@KodUstavu IS NULL)AND(@SWIFTUstavu IS NOT NULL)
  IF NOT EXISTS(SELECT * FROM TabPenezniUstavy WHERE SWIFTUstavu=@SWIFTUstavu)
INSERT TabPenezniUstavy(SWIFTUstavu, TypUstavu) VALUES(@SWIFTUstavu, 1)
IF @@ERROR<>0 SET @ChybaPriImportu=1
SET @IDUstavu=NULL
IF @MenaBankSpoj IS NOT NULL
  IF NOT EXISTS(SELECT * FROM TabKodMen WHERE Kod=@MenaBankSpoj)
    INSERT TabKodMen(Kod, Nazev) VALUES(@MenaBankSpoj, '')
IF @KodUstavu IS NOT NULL SET @IDUstavu=(SELECT TOP 1 ID FROM TabPenezniUstavy WHERE KodUstavu=@KodUstavu)
IF (@KodUstavu IS NULL)AND(@SWIFTUstavu IS NOT NULL) SET @IDUstavu=(SELECT TOP 1 ID FROM TabPenezniUstavy WHERE SWIFTUstavu=@SWIFTUstavu)
INSERT TabBankSpojeni(IDOrg, IDUstavu, NazevBankSpoj, Mena, CisloUctu, VariabilniSymbol, KonstantniSymbol, SpecifickySymbol, IBANElektronicky, Prednastaveno)
VALUES(@IDOrg, @IDUstavu, ISNULL(@NazevBankSpoj, ''), @MenaBankSpoj, ISNULL(@CisloUctu, ''), @VariabilniSymbol, @KonstantniSymbol, @SpecifickySymbol, ISNULL(@IBANElektronicky, ''), 1)
IF @@ERROR<>0 SET @ChybaPriImportu=1
END
IF @OdpOs IS NOT NULL
BEGIN
  IF EXISTS(SELECT 0 FROM TabCisZam WHERE Cislo=@OdpOs)
  BEGIN
    UPDATE TabCisOrg SET OdpOs = (SELECT ID FROM TabCisZam WHERE Cislo=@OdpOs)
    WHERE ID = @IDOrg
  END
  ELSE
  BEGIN
  SET @ChybaPriImportu=1
  IF @TextChybyImportu<>'' SET @TextChybyImportu=@TextChybyImportu + ' | '
  SET @TextChybyImportu = @TextChybyImportu + dbo.hpf_UniImportHlasky('FF69ED3B-1439-44E5-A410-85F62ED7A790', @JazykVerze, DEFAULT, DEFAULT, DEFAULT, DEFAULT)
  END
END
IF (@ChybaPriImportu=0)AND(ISNULL(@DIC, '')<>'')
BEGIN
  EXEC dbo.hp_VAT_ID_kontrola @DIC, @ErrNo OUT
  IF @ErrNo<>0
  BEGIN
  SET @ChybaPriImportu=1
  IF @TextChybyImportu<>'' SET @TextChybyImportu=@TextChybyImportu + ' | '
  SET @TextChybyImportu = @TextChybyImportu + dbo.hpf_UniImportHlasky('7721501C-2718-4B19-99AE-5E28101752F4', @JazykVerze, DEFAULT, DEFAULT, DEFAULT, DEFAULT)
  END
  ELSE
    UPDATE TabCisOrg SET DIC=@DIC WHERE ID=@IDOrg
END
IF @CenovaUroven IS NOT NULL
BEGIN
  IF EXISTS(SELECT * FROM TabCisNC WHERE CenovaUroven = @CenovaUroven)
  BEGIN
    UPDATE TabCisOrg SET CenovaUroven = @CenovaUroven
    WHERE ID = @IDOrg
  END
  ELSE
  BEGIN
  SET @ChybaPriImportu=1
  IF @TextChybyImportu<>'' SET @TextChybyImportu=@TextChybyImportu + ' | '
  SET @TextChybyImportu = @TextChybyImportu + dbo.hpf_UniImportHlasky('69ECBD4F-214D-4FE9-A5A4-27D4F980E426', @JazykVerze, DEFAULT, DEFAULT, DEFAULT, DEFAULT)
  END
END
IF @CenovaUrovenNakup IS NOT NULL
BEGIN
  IF EXISTS(SELECT * FROM TabCisNC WHERE CenovaUroven = @CenovaUrovenNakup)
  BEGIN
    UPDATE TabCisOrg SET CenovaUrovenNakup = @CenovaUrovenNakup
    WHERE ID = @IDOrg
  END
  ELSE
  BEGIN
  SET @ChybaPriImportu=1
  IF @TextChybyImportu<>'' SET @TextChybyImportu=@TextChybyImportu + ' | '
  SET @TextChybyImportu = @TextChybyImportu + dbo.hpf_UniImportHlasky('69ECBD4F-214D-4FE9-A5A4-27D4F980E426', @JazykVerze, DEFAULT, DEFAULT, DEFAULT, DEFAULT)
  END
END
IF @NadrizenaOrg IS NOT NULL
BEGIN
  IF EXISTS(SELECT * FROM TabCisOrg WHERE CisloOrg = @NadrizenaOrg)
  BEGIN
    UPDATE TabCisOrg SET NadrizenaOrg = @NadrizenaOrg
    WHERE ID = @IDOrg
  END
  ELSE
  BEGIN
  SET @ChybaPriImportu=1
  IF @TextChybyImportu<>'' SET @TextChybyImportu=@TextChybyImportu + ' | '
  SET @TextChybyImportu = @TextChybyImportu + dbo.hpf_UniImportHlasky('2B45B17B-5764-474D-9051-9A01977C24AD', @JazykVerze, DEFAULT, DEFAULT, DEFAULT, DEFAULT)
  END
END
IF @Jazyk IS NOT NULL
BEGIN
  IF EXISTS(SELECT * FROM TabJazyky WHERE Jazyk=@Jazyk)
  BEGIN
    UPDATE TabCisOrg SET Jazyk = @Jazyk
    WHERE ID = @IDOrg
  END
  ELSE
  BEGIN
  SET @ChybaPriImportu=1
  IF @TextChybyImportu<>'' SET @TextChybyImportu=@TextChybyImportu + ' | '
  SET @TextChybyImportu = @TextChybyImportu + dbo.hpf_UniImportHlasky('84E0557B-6B64-450A-A84E-4DF53A77CF13', @JazykVerze, DEFAULT, DEFAULT, DEFAULT, DEFAULT)
  END
END
IF (@ExtAtr1 IS NOT NULL)AND(@ExtAtr1Nazev IS NOT NULL)
BEGIN
IF (OBJECT_ID('TabCisOrg_EXT','U')IS NOT NULL)AND(COLUMNPROPERTY(OBJECT_ID('TabCisOrg_EXT','U'),'_'+@ExtAtr1Nazev,'AllowsNull')IS NOT NULL)
BEGIN
SET @ExtAtr1Nazev='_' + @ExtAtr1Nazev
IF EXISTS(SELECT ID FROM TabCisOrg_EXT WHERE ID=@IDOrg)
SET @SQLString='UPDATE TabCisOrg_EXT SET ' + @ExtAtr1Nazev + '=N' + '''' + @ExtAtr1 + '''' + ' WHERE ID=' + CAST(@IDOrg AS NVARCHAR(10))
ELSE
SET @SQLString='INSERT TabCisOrg_EXT(ID, ' + @ExtAtr1Nazev + ') VALUES(' + CAST(@IDOrg AS NVARCHAR(10)) + ', N' + '''' + @ExtAtr1 + '''' + ')'
EXEC sp_executesql @SQLString
END
ELSE
BEGIN
SET @ChybaPriImportu=1
IF @TextChybyImportu<>'' SET @TextChybyImportu=@TextChybyImportu + ' | '
SET @TextChybyImportu = @TextChybyImportu + dbo.hpf_UniImportHlasky('15364319-B20F-4D65-8900-391DE8D4C52F', @JazykVerze, '_'+@ExtAtr1Nazev, DEFAULT, DEFAULT, DEFAULT)
END
END
IF (@ExtAtr2 IS NOT NULL)AND(@ExtAtr2Nazev IS NOT NULL)
IF (OBJECT_ID('TabCisOrg_EXT','U')IS NOT NULL)AND(COLUMNPROPERTY(OBJECT_ID('TabCisOrg_EXT','U'),'_'+@ExtAtr2Nazev,'AllowsNull')IS NOT NULL)
BEGIN
SET @ExtAtr2Nazev='_' + @ExtAtr2Nazev
IF EXISTS(SELECT ID FROM TabCisOrg_EXT WHERE ID=@IDOrg)
SET @SQLString='UPDATE TabCisOrg_EXT SET ' + @ExtAtr2Nazev + '=N' + '''' + @ExtAtr2 + '''' + ' WHERE ID=' + CAST(@IDOrg AS NVARCHAR(10))
ELSE
SET @SQLString='INSERT TabCisOrg_EXT(ID, ' + @ExtAtr2Nazev + ') VALUES(' + CAST(@IDOrg AS NVARCHAR(10)) + ', N' + '''' + @ExtAtr2 + '''' + ')'
EXECUTE sp_executesql @SQLString
END
ELSE
BEGIN
SET @ChybaPriImportu=1
IF @TextChybyImportu<>'' SET @TextChybyImportu=@TextChybyImportu + ' | '
SET @TextChybyImportu = @TextChybyImportu + dbo.hpf_UniImportHlasky('15364319-B20F-4D65-8900-391DE8D4C52F', @JazykVerze, '_'+@ExtAtr2Nazev, DEFAULT, DEFAULT, DEFAULT)
END
IF (@ExtAtr3 IS NOT NULL)AND(@ExtAtr3Nazev IS NOT NULL)
IF (OBJECT_ID('TabCisOrg_EXT','U')IS NOT NULL)AND(COLUMNPROPERTY(OBJECT_ID('TabCisOrg_EXT','U'),'_'+@ExtAtr3Nazev,'AllowsNull')IS NOT NULL)
BEGIN
SET @ExtAtr3Nazev='_' + @ExtAtr3Nazev
IF EXISTS(SELECT ID FROM TabCisOrg_EXT WHERE ID=@IDOrg)
SET @SQLString='UPDATE TabCisOrg_EXT SET ' + @ExtAtr3Nazev + '=' + '''' + CONVERT(NVARCHAR(10),@ExtAtr3, 112) + '''' + ' WHERE ID=' + CAST(@IDOrg AS NVARCHAR(10))
ELSE
SET @SQLString='INSERT TabCisOrg_EXT(ID, ' + @ExtAtr3Nazev + ') VALUES(' + CAST(@IDOrg AS NVARCHAR(10)) + ', ' + '''' + CONVERT(NVARCHAR(10),@ExtAtr3, 112) + '''' + ')'
EXECUTE sp_executesql @SQLString
END
ELSE
BEGIN
SET @ChybaPriImportu=1
IF @TextChybyImportu<>'' SET @TextChybyImportu=@TextChybyImportu + ' | '
SET @TextChybyImportu = @TextChybyImportu + dbo.hpf_UniImportHlasky('15364319-B20F-4D65-8900-391DE8D4C52F', @JazykVerze, '_'+@ExtAtr3Nazev, DEFAULT, DEFAULT, DEFAULT)
END
IF (@ExtAtr4 IS NOT NULL)AND(@ExtAtr4Nazev IS NOT NULL)
IF (OBJECT_ID('TabCisOrg_EXT','U')IS NOT NULL)AND(COLUMNPROPERTY(OBJECT_ID('TabCisOrg_EXT','U'),'_'+@ExtAtr4Nazev,'AllowsNull')IS NOT NULL)
BEGIN
SET @ExtAtr4Nazev='_' + @ExtAtr4Nazev
IF EXISTS(SELECT ID FROM TabCisOrg_EXT WHERE ID=@IDOrg)
SET @SQLString='UPDATE TabCisOrg_EXT SET ' + @ExtAtr4Nazev + '=' + CAST(@ExtAtr4 AS NVARCHAR(26)) +  ' WHERE ID=' + CAST(@IDOrg AS NVARCHAR(10))
ELSE
SET @SQLString='INSERT TabCisOrg_EXT(ID, ' + @ExtAtr4Nazev + ') VALUES(' + CAST(@IDOrg AS NVARCHAR(10)) + ', ' + CAST(@ExtAtr4 AS NVARCHAR(26)) + ')'
EXECUTE sp_executesql @SQLString
END
ELSE
BEGIN
SET @ChybaPriImportu=1
IF @TextChybyImportu<>'' SET @TextChybyImportu=@TextChybyImportu + ' | '
SET @TextChybyImportu = @TextChybyImportu + dbo.hpf_UniImportHlasky('15364319-B20F-4D65-8900-391DE8D4C52F', @JazykVerze, '_'+@ExtAtr4Nazev, DEFAULT, DEFAULT, DEFAULT)
END
IF (@ExtAtr5 IS NOT NULL)AND(@ExtAtr5Nazev IS NOT NULL)
IF (OBJECT_ID('TabCisOrg_EXT','U')IS NOT NULL)AND(COLUMNPROPERTY(OBJECT_ID('TabCisOrg_EXT','U'),'_'+@ExtAtr5Nazev,'AllowsNull')IS NOT NULL)
BEGIN
SET @ExtAtr5Nazev='_' + @ExtAtr5Nazev
IF EXISTS(SELECT ID FROM TabCisOrg_EXT WHERE ID=@IDOrg)
SET @SQLString='UPDATE TabCisOrg_EXT SET ' + @ExtAtr5Nazev + '=N' + '''' + @ExtAtr5 + '''' + ' WHERE ID=' + CAST(@IDOrg AS NVARCHAR(10))
ELSE
SET @SQLString='INSERT TabCisOrg_EXT(ID, ' + @ExtAtr5Nazev + ') VALUES(' + CAST(@IDOrg AS NVARCHAR(10)) + ', N' + '''' + @ExtAtr5 + '''' + ')'
EXECUTE sp_executesql @SQLString
END
ELSE
BEGIN
SET @ChybaPriImportu=1
IF @TextChybyImportu<>'' SET @TextChybyImportu=@TextChybyImportu + ' | '
SET @TextChybyImportu = @TextChybyImportu + dbo.hpf_UniImportHlasky('15364319-B20F-4D65-8900-391DE8D4C52F', @JazykVerze, '_'+@ExtAtr5Nazev, DEFAULT, DEFAULT, DEFAULT)
END
IF (@ExtAtr6 IS NOT NULL)AND(@ExtAtr6Nazev IS NOT NULL)
IF (OBJECT_ID('TabCisOrg_EXT','U')IS NOT NULL)AND(COLUMNPROPERTY(OBJECT_ID('TabCisOrg_EXT','U'),'_'+@ExtAtr6Nazev,'AllowsNull')IS NOT NULL)
BEGIN
SET @ExtAtr6Nazev='_' + @ExtAtr6Nazev
IF EXISTS(SELECT ID FROM TabCisOrg_EXT WHERE ID=@IDOrg)
SET @SQLString='UPDATE TabCisOrg_EXT SET ' + @ExtAtr6Nazev + '=N' + '''' + @ExtAtr6 + '''' + ' WHERE ID=' + CAST(@IDOrg AS NVARCHAR(10))
ELSE
SET @SQLString='INSERT TabCisOrg_EXT(ID, ' + @ExtAtr6Nazev + ') VALUES(' + CAST(@IDOrg AS NVARCHAR(10)) + ', N' + '''' + @ExtAtr6 + '''' + ')'
EXECUTE sp_executesql @SQLString
END
ELSE
BEGIN
SET @ChybaPriImportu=1
IF @TextChybyImportu<>'' SET @TextChybyImportu=@TextChybyImportu + ' | '
SET @TextChybyImportu = @TextChybyImportu + dbo.hpf_UniImportHlasky('15364319-B20F-4D65-8900-391DE8D4C52F', @JazykVerze, '_'+@ExtAtr6Nazev, DEFAULT, DEFAULT, DEFAULT)
END
IF (@ExtAtr7 IS NOT NULL)AND(@ExtAtr7Nazev IS NOT NULL)
IF (OBJECT_ID('TabCisOrg_EXT','U')IS NOT NULL)AND(COLUMNPROPERTY(OBJECT_ID('TabCisOrg_EXT','U'),'_'+@ExtAtr7Nazev,'AllowsNull')IS NOT NULL)
BEGIN
SET @ExtAtr7Nazev='_' + @ExtAtr7Nazev
IF EXISTS(SELECT ID FROM TabCisOrg_EXT WHERE ID=@IDOrg)
SET @SQLString='UPDATE TabCisOrg_EXT SET ' + @ExtAtr7Nazev + '=N' + '''' + @ExtAtr7 + '''' + ' WHERE ID=' + CAST(@IDOrg AS NVARCHAR(10))
ELSE
SET @SQLString='INSERT TabCisOrg_EXT(ID, ' + @ExtAtr7Nazev + ') VALUES(' + CAST(@IDOrg AS NVARCHAR(10)) + ', N' + '''' + @ExtAtr7 + '''' + ')'
EXECUTE sp_executesql @SQLString
END
ELSE
BEGIN
SET @ChybaPriImportu=1
IF @TextChybyImportu<>'' SET @TextChybyImportu=@TextChybyImportu + ' | '
SET @TextChybyImportu = @TextChybyImportu + dbo.hpf_UniImportHlasky('15364319-B20F-4D65-8900-391DE8D4C52F', @JazykVerze, '_'+@ExtAtr7Nazev, DEFAULT, DEFAULT, DEFAULT)
END
IF (@ExtAtr8 IS NOT NULL)AND(@ExtAtr8Nazev IS NOT NULL)
IF (OBJECT_ID('TabCisOrg_EXT','U')IS NOT NULL)AND(COLUMNPROPERTY(OBJECT_ID('TabCisOrg_EXT','U'),'_'+@ExtAtr8Nazev,'AllowsNull')IS NOT NULL)
BEGIN
SET @ExtAtr8Nazev='_' + @ExtAtr8Nazev
IF EXISTS(SELECT ID FROM TabCisOrg_EXT WHERE ID=@IDOrg)
SET @SQLString='UPDATE TabCisOrg_EXT SET ' + @ExtAtr8Nazev + '=N' + '''' + @ExtAtr8 + '''' + ' WHERE ID=' + CAST(@IDOrg AS NVARCHAR(10))
ELSE
SET @SQLString='INSERT TabCisOrg_EXT(ID, ' + @ExtAtr8Nazev + ') VALUES(' + CAST(@IDOrg AS NVARCHAR(10)) + ', N' + '''' + @ExtAtr8 + '''' + ')'
EXECUTE sp_executesql @SQLString
END
ELSE
BEGIN
SET @ChybaPriImportu=1
IF @TextChybyImportu<>'' SET @TextChybyImportu=@TextChybyImportu + ' | '
SET @TextChybyImportu = @TextChybyImportu + dbo.hpf_UniImportHlasky('15364319-B20F-4D65-8900-391DE8D4C52F', @JazykVerze, '_'+@ExtAtr8Nazev, DEFAULT, DEFAULT, DEFAULT)
END
IF (@ExtAtr9 IS NOT NULL)AND(@ExtAtr9Nazev IS NOT NULL)
IF (OBJECT_ID('TabCisOrg_EXT','U')IS NOT NULL)AND(COLUMNPROPERTY(OBJECT_ID('TabCisOrg_EXT','U'),'_'+@ExtAtr9Nazev,'AllowsNull')IS NOT NULL)
BEGIN
SET @ExtAtr9Nazev='_' + @ExtAtr9Nazev
IF EXISTS(SELECT ID FROM TabCisOrg_EXT WHERE ID=@IDOrg)
SET @SQLString='UPDATE TabCisOrg_EXT SET ' + @ExtAtr9Nazev + '=' + CAST(@ExtAtr9 AS NVARCHAR) + ' WHERE ID=' + CAST(@IDOrg AS NVARCHAR(10))
ELSE
SET @SQLString='INSERT TabCisOrg_EXT(ID, ' + @ExtAtr9Nazev + ') VALUES(' + CAST(@IDOrg AS NVARCHAR(10)) + ', ' + CAST(@ExtAtr9 AS NVARCHAR) + ')'
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
  @ImportIdent=0,
  @IdImpTable=@ID,
  @IdTargetTable=@IDOrg,
  @Chyba=@ChybaExtAtr OUT
IF @ChybaExtAtr<>''
BEGIN
  SET @ChybaPriImportu=1
  IF @TextChybyImportu<>'' SET @TextChybyImportu=@TextChybyImportu + ' | '
  SET @TextChybyImportu = @TextChybyImportu + dbo.hpf_UniImportHlasky('15364319-B20F-4D65-8900-391DE8D4C52F', @JazykVerze, @ChybaExtAtr, DEFAULT, DEFAULT, DEFAULT)
END
IF OBJECT_ID('dbo.epx_UniImportOrg03', 'P') IS NOT NULL EXEC dbo.epx_UniImportOrg03 @IDOrg
IF @@ERROR<>0 SET @ChybaPriImportu=1
IF @ChybaPriImportu=0 DELETE FROM dbo.TabUniImportOrg WHERE ID=@ID
IF @ChybaPriImportu=1
BEGIN
IF @@trancount>0 ROLLBACK TRAN T1
UPDATE dbo.TabUniImportOrg SET Chyba=@TextChybyImportu, DatumImportu=GETDATE() WHERE ID=@ID
END
ELSE IF @@trancount>0 COMMIT TRAN T1
END
END
SET @CisloOrg=NULL
/*--PRI PRIDANI NOVE VERZE IMPORTU PRIDAT NOVE PROMENNE I SEM*/
FETCH NEXT FROM c INTO @ID, @InterniVerze, @CisloOrg, @CisloOrgDOS, @Nazev, @DruhyNazev, @Ulice, @PopCislo, @OrCislo,
@Misto, @PSC, @PoBox, @IdZeme, @ICO, @DIC, @JeOdberatel, @JeDodavatel, @Fakturacni, @MU,
@Prijemce, @Telefon, @Mobil, @Fax, @Email, @WWW, @KOJmeno, @KOPrijmeni, @KOTelefon,
@KOMobil, @KOFax, @KOEmail, @CisloUctu, @KodUstavu, @IBANElektronicky, @NazevBankSpoj, @MenaBankSpoj, @LhutaSplatnosti, @FormaUhrady,
@VariabilniSymbol, @KonstantniSymbol, @SpecifickySymbol, @ExtAtr1,
@ExtAtr1Nazev, @ExtAtr2, @ExtAtr2Nazev, @ExtAtr3, @ExtAtr3Nazev, @ExtAtr4, @ExtAtr4Nazev, @HromadneProEmail, @CarovyKodEAN, @VernostniProgram,
@ExtAtr5, @ExtAtr5Nazev, @ExtAtr6, @ExtAtr6Nazev, @ExtAtr7, @ExtAtr7Nazev, @ExtAtr8, @ExtAtr8Nazev, @ExtAtr9, @ExtAtr9Nazev, @PostAddress, @DatumNeupominani, @DICsk, @Kredit, @OdpOs,
@DruhDopravy, @DodaciPodminky, @CenovaUroven, @CenovaUrovenNakup, @Mena, @NadrizenaOrg, @Stav, @PravniForma, @LhutaSplatnostiDodavatel, @SWIFTUstavu,
@Jazyk, @Upozorneni, @Kategorie, @Prijmeni, @Jmeno, @RodneCislo, @DatumNarozeni, @KOFunkce, @HromadneProEmailAutomat,
@VstupniCenaDod, @VstupniCenaOdb
IF @@fetch_status<>0 BREAK
END
CLOSE c
DEALLOCATE c
GO

