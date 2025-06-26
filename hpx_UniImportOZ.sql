USE [RayService]
GO

/****** Object:  StoredProcedure [dbo].[hpx_UniImportOZ]    Script Date: 26.06.2025 10:20:47 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

/*rpObecneImporty.Import*/CREATE PROC [dbo].[hpx_UniImportOZ]
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
SET @PocetRadkuImpTabulky=(SELECT COUNT(*) FROM TabUniImportOZ WHERE Chyba IS NULL AND ((@PouzeZaznamyDleLogin=1 AND Autor=SUSER_SNAME())OR(@PouzeZaznamyDleLogin=0)) )
SET @InfoText = dbo.hpf_UniImportHlasky('959B5166-6EEF-44A5-B4AC-DA13F5642C08', @JazykVerze, 'TabUniImportOZ', CAST(@PocetRadkuImpTabulky AS NVARCHAR), DEFAULT, DEFAULT)
IF @InfoText IS NOT NULL
  EXEC dbo.hp_ZapisDoZurnalu 1, 77, @InfoText
IF OBJECT_ID('dbo.epx_UniImportOZ02', 'P') IS NOT NULL EXEC dbo.epx_UniImportOZ02
DECLARE @IdObdobi INT, @ChybaPriImportu BIT, @TextChybyImportu NVARCHAR(4000), @TextChybyImportuPolozka NVARCHAR(4000), @ChybaExtAtr NVARCHAR(4000), @ChybaVC NVARCHAR(4000), @ChybaZaloha NVARCHAR(4000),
@InterniVerze INT, @IDSklad NVARCHAR(30), @Rada NVARCHAR(3), @CisOrg INT, @IDDoklad INT, @IDPohyb INT, @IDImport INT, @IDObdobiStavu INT,
@Mena NVARCHAR(3), @Kurz NUMERIC(19,6), @JednotkaMeny INT, @SazbaSDPol NUMERIC(19,6),
@SazbaDPHPol NUMERIC(5,2), @VstupniCena TINYINT, @Mnozstvi NUMERIC(19,6), @VstupniCenaProPrepocet TINYINT,
@Sleva NUMERIC(19,6), @DotahovatSazby BIT, @SkupZbo NVARCHAR(3), @RegCis NVARCHAR(30),
@IDZboSklad INT, @IDKmen INT, @StredNaklad NVARCHAR(30), @StredNakladPol NVARCHAR(30), @StredVynos NVARCHAR(30),
@IDPolozky INT, @DIC NVARCHAR(15), @MU INT, @DatPorizeni DATETIME, @UKod INT,
@SazbaDPH NUMERIC(5,2), @SazbaSD NUMERIC(19,6), @FormaUhrady NVARCHAR(30),
@NOkruhCislo NVARCHAR(15), @CisloZakazky NVARCHAR(15), @CisloZakazkyPol NVARCHAR(15), @CisloZam INT, @NavaznaObjednavka NVARCHAR(30),
@ExtAtr1 NVARCHAR(30), @ExtAtr1Nazev NVARCHAR(127), @ExtAtr2 NVARCHAR(255), @ExtAtr2Nazev NVARCHAR(127),
@ExtAtr3 DATETIME, @ExtAtr3Nazev NVARCHAR(127), @ExtAtr4 NUMERIC(19,6), @ExtAtr4Nazev NVARCHAR(127),
@SQLString NVARCHAR(4000), @MJ NVARCHAR(10), @DruhPohybuZbo INT, @PC INT,
@CbezDPH1 NUMERIC(19,6), @CbezDPH2 NUMERIC(19,6), @CbezDPH3 NUMERIC(19,6),
@SazbaDPH1 NUMERIC(5,2), @SazbaDPH2 NUMERIC(5,2), @SazbaDPH3 NUMERIC(5,2),
@POM INT, @NabidkaCenik INT, @Splatnost DATETIME, @DatPovinnostiFa DATETIME,
@Prijemce INT, @MJKarta NVARCHAR(10), @FormaDopravy NVARCHAR(30),
@Nuly NVARCHAR(30), @DelkaReg TINYINT, @Zarovnani TINYINT, @I TINYINT, @DodFak NVARCHAR(20), @BarCode NVARCHAR(50),
@IDKmenBarCode INT, @Zaokrouhleni NUMERIC(19,6), @KurzZaokr NUMERIC(19,6), @MenaZaokr NVARCHAR(3), @Server7 BIT,
@PrepocetZaokr NUMERIC(19,6), @JednotkaZaokr INT, @DUZP DATETIME, @PopisDodavky NVARCHAR(40), @TerminDodavky NVARCHAR(20),
@EvCislo NVARCHAR(20), @EvCisloPol NVARCHAR(20), @IDSkladPol NVARCHAR(30), @CisloNOkruhPol NVARCHAR(15), @CisloZamPol INT, @TextPolozka BIT, @NazevSozNa1 NVARCHAR(100),
@NazevSozNa2 NVARCHAR(100), @NazevSozNa3 NVARCHAR(100), @Popis4 NVARCHAR(100), @Hmotnost NUMERIC(19,6), @ZemePuvodu NVARCHAR(2), @ZemePreference NVARCHAR(3), @DatumDoruceni DATETIME,
@PozadDatDod DATETIME, @PotvrzDatDod DATETIME, @JePDP BIT, @SazbaDPHproPDP NUMERIC(9,2), @DD TINYINT, @DodaciPodminky NVARCHAR(3), @ZemeUrceni NVARCHAR(2),
@DodFakKV NVARCHAR(32), @ZdrojCisKV TINYINT, @DatumKurzu DATETIME, @DatUhrady DATETIME, @CisloUcetPol NVARCHAR(30),
@SPZZobraz NVARCHAR(12), @SPZZobrazPol NVARCHAR(12), @ICO NVARCHAR(20),
@SlevaSozNa NUMERIC(5,2), @SlevaSkupZbo NUMERIC(5,2), @SlevaZboKmen NUMERIC(5,2), @SlevaZboSklad NUMERIC(5,2), @SlevaOrg NUMERIC(5,2), @NastaveniSlev SMALLINT,
@SamoVyZdrojKurzu INT, @SamoVyDatumKurzuDPH DATETIME, @SamoVyKurzDPH NUMERIC(19,6), @SamoVyMnoKurzDPH INT,
@SamoVyZdrojKurzu_HEO INT, @SamoVyDatumKurzuDPH_HEO DATETIME, @SamoVyKurzDPH_HEO NUMERIC(19,6), @SamoVyMnoKurzDPH_HEO INT, @HlavniMena NVARCHAR(3), @KurzEuro NUMERIC(19,6),
@SamoVyMenaDPH_HEO NVARCHAR(3), @KodDanoveKlicePol NVARCHAR(30), @IdDanovyKlic INT, @KodDanovyRezim NVARCHAR(30), @IdDanovyRezim INT,
@DruhPohybuPrevod INT, @TypPrevodky NVARCHAR(3), @IdSkladPrevodu NVARCHAR(30),
@DPHZadanaRucne NUMERIC(19,6), @RucniDPHPovoleno BIT, @CCevidPozadovana NUMERIC(19,6), @VstupniCenaHla TINYINT, @PZ2 NVARCHAR(20),
@IdBankSpoj INT, @CisloUctu NVARCHAR(40), @KodUstavu NVARCHAR(15), @IBANElektronicky NVARCHAR(40),
@DotahovatSazbyImp BIT,
@RezimMOSS TINYINT, @SamoVyDICDPH NVARCHAR(15), @ZemeDPH NVARCHAR(6), @KodUmisteni NVARCHAR(15),
@TypSlevyTxtPol TINYINT, @SlevaTxtPol NUMERIC(19,6),
@PomerKoef NUMERIC(19,6), @PomerKoefPol NUMERIC(19,6),
@KodPDP NVARCHAR(20), @IdKodPDP INT
DECLARE @DD_ORG TINYINT, @DodaciPodminky_ORG NVARCHAR(3), @ZemeUrceni_ORG NVARCHAR(3)
DECLARE @DD_RADA TINYINT, @DodaciPodminky_RADA NVARCHAR(3), @ZemeUrceni_RADA NVARCHAR(3)
DECLARE @IDChybyPolozky INT, @TextChybPol NVARCHAR(4000), @SkladSluzeb NVARCHAR(30)
DECLARE @IdTxtPolozka INT
DECLARE @IdUmisteni INT, @IdVStavUmisteni INT
IF OBJECT_ID('tempdb..#TabTempUziv')IS NULL
  CREATE TABLE #TabTempUziv([Tabulka] [nvarchar] (255) NOT NULL, [Scope_Identity] [int] NULL, Datum DATETIME NULL, Typ INT NULL)
DECLARE @CHYBYPOLOZEK TABLE (ID INT, Chyba NVARCHAR(4000))
/*PRIJEMKY + VYDEJKY + VYDEJKY V EVID. CENE + OBJEDNAVKY + EX.PRIK. + REZERVACE + NAB. SESTAVY + FAKTURY A DOBROPISY*/-------------------------------
DECLARE @IDHlavicky NVARCHAR(30), @Cena NUMERIC(19,6)
SET @TextChybyImportu = dbo.hpf_UniImportHlasky('B8383020-1340-47AB-BAE1-DB327E5CBCA3', @JazykVerze, DEFAULT, DEFAULT, DEFAULT, DEFAULT)
UPDATE dbo.TabUniImportOZ SET DatumImportu = GETDATE(), Chyba=@TextChybyImportu
WHERE DruhPohybuZbo NOT IN(0, 1, 2, 3, 4, 6, 9, 10, 11, 13, 14, 18, 19, 53) AND Chyba IS NULL
SET @TextChybyImportu=''
EXEC dbo.hpx_UniImport_ZpracujDOBJ_OZ
EXEC dbo.hpx_UniImport_ZpracujDOBJ_OZ2
DECLARE c CURSOR LOCAL FAST_FORWARD FOR
SELECT DISTINCT IDHlavicky FROM dbo.TabUniImportOZ
WHERE DruhPohybuZbo IN(0, 1, 2, 3, 4, 6, 9, 10, 11, 13, 14, 18, 19) AND Zaloha=0 AND Chyba IS NULL AND ((@PouzeZaznamyDleLogin=1 AND Autor=SUSER_SNAME())OR(@PouzeZaznamyDleLogin=0)) 
OPEN c
FETCH NEXT FROM c INTO @IDHlavicky
WHILE 1=1
BEGIN
BEGIN TRY
SET @TextChybyImportu=''
SET @ChybaPriImportu=0
SET @IDImport=(SELECT TOP 1 ID FROM dbo.TabUniImportOZ WHERE IDHlavicky=@IDHlavicky AND Chyba IS NULL AND Zaloha=0 AND ((@PouzeZaznamyDleLogin=1 AND Autor=SUSER_SNAME())OR(@PouzeZaznamyDleLogin=0)) )
SET @DruhPohybuZbo=(SELECT TOP 1 DruhPohybuZbo FROM dbo.TabUniImportOZ WHERE IDHlavicky=@IDHlavicky AND Chyba IS NULL AND Zaloha=0 AND ((@PouzeZaznamyDleLogin=1 AND Autor=SUSER_SNAME())OR(@PouzeZaznamyDleLogin=0)) )
BEGIN TRAN T1
/*kontrola polozek - musi mit stejnou menu, kurz i jednotku meny*/
SELECT DISTINCT Kurz, Mena, JednotkaMeny FROM dbo.TabUniImportOZ WHERE IDHlavicky=@IDHlavicky AND Chyba IS NULL AND Zaloha=0 AND ((@PouzeZaznamyDleLogin=1 AND Autor=SUSER_SNAME())OR(@PouzeZaznamyDleLogin=0)) 
IF @@rowcount>1
  BEGIN
  SET @ChybaPriImportu=1
  IF @TextChybyImportu<>'' SET @TextChybyImportu=@TextChybyImportu + ' | '
  SET @TextChybyImportu = @TextChybyImportu + dbo.hpf_UniImportHlasky('712620C5-2051-4ED1-80E3-BA0F4DE89E4E', @JazykVerze, DEFAULT, DEFAULT, DEFAULT, DEFAULT)
  END
SET @SkladSluzeb=(SELECT ISNULL(SkladSluzeb, 'D4B73E394670455489587358B43F09') FROM TabHGlob)
IF (SELECT RuznySkladNaPolAHla FROM TabHGlob)<>0
IF (SELECT COUNT( DISTINCT CASE WHEN IDSkladPol IS NOT NULL THEN IDSkladPol ELSE IDSklad END)
FROM TabUniImportOZ
WHERE IDHlavicky=@IdHlavicky  AND ((@PouzeZaznamyDleLogin=1 AND Autor=SUSER_SNAME())OR(@PouzeZaznamyDleLogin=0))  AND (CASE WHEN IDSkladPol IS NOT NULL THEN IDSkladPol ELSE IDSklad END)<>@SkladSluzeb)>1
BEGIN
  SET @ChybaPriImportu=1
  IF @TextChybyImportu<>'' SET @TextChybyImportu=@TextChybyImportu + ' | '
  SET @TextChybyImportu = @TextChybyImportu + dbo.hpf_UniImportHlasky('230B4AF1-16CB-4374-A0C1-6929BB8AD0B6', @JazykVerze, DEFAULT, DEFAULT, DEFAULT, DEFAULT)
END
/*zalozeni hlavicky*/
SET @DatPorizeni=(SELECT TOP 1 DatPorizeni FROM dbo.TabUniImportOZ WHERE IDHlavicky=@IDHlavicky AND Chyba IS NULL AND Zaloha=0 AND ((@PouzeZaznamyDleLogin=1 AND Autor=SUSER_SNAME())OR(@PouzeZaznamyDleLogin=0)) )
IF @DatPorizeni IS NULL SET @DatPorizeni=GETDATE()
SET @IdObdobi=(SELECT Id FROM TabObdobi WHERE DatumOd<=@DatPorizeni AND DatumDo>=@DatPorizeni AND Uzavreno=0)
IF @IdObdobi IS NULL
BEGIN
SET @ChybaPriImportu=1
IF @TextChybyImportu<>'' SET @TextChybyImportu=@TextChybyImportu + ' | '
SET @TextChybyImportu = @TextChybyImportu + dbo.hpf_UniImportHlasky('6095777A-AEB6-4CDB-A9F7-232286F0B460', @JazykVerze, DEFAULT, DEFAULT, DEFAULT, DEFAULT)
END
SET @IDSklad=(SELECT TOP 1 IDSklad FROM dbo.TabUniImportOZ WHERE IDHlavicky=@IDHlavicky AND Chyba IS NULL AND Zaloha=0 AND ((@PouzeZaznamyDleLogin=1 AND Autor=SUSER_SNAME())OR(@PouzeZaznamyDleLogin=0)) )
IF (@DruhPohybuZbo NOT IN(13, 14, 18, 19))
AND(@IDSklad IS NOT NULL)
AND(NOT EXISTS(SELECT * FROM TabStrom WHERE Cislo=@IDSklad))
BEGIN
SET @ChybaPriImportu=1
IF @TextChybyImportu<>'' SET @TextChybyImportu=@TextChybyImportu + ' | '
SET @TextChybyImportu = @TextChybyImportu + dbo.hpf_UniImportHlasky('32E711C5-DB15-414F-BAD7-B513BB576585', @JazykVerze, @IDSklad, DEFAULT, DEFAULT, DEFAULT)
END
IF (@DruhPohybuZbo NOT IN(13, 14, 18, 19))
AND(@IDSklad IS NULL)
BEGIN
  SET @IDSklad=(SELECT SkladSluzeb FROM TabHGlob)
  IF @IDSklad IS NULL
  BEGIN
    SET @ChybaPriImportu=1
    IF @TextChybyImportu<>'' SET @TextChybyImportu=@TextChybyImportu + ' | '
    SET @TextChybyImportu = @TextChybyImportu + dbo.hpf_UniImportHlasky('3CE7FAE2-A705-4BC9-8F70-18533C4EB0EE', @JazykVerze, DEFAULT, DEFAULT, DEFAULT, DEFAULT)
  END
END
IF @DruhPohybuZbo IN(13, 14, 18, 19)
  SET @IDSklad=NULL
SET @Rada=(SELECT TOP 1 RadaDokladu FROM dbo.TabUniImportOZ WHERE IDHlavicky=@IDHlavicky AND Chyba IS NULL AND Zaloha=0 AND ((@PouzeZaznamyDleLogin=1 AND Autor=SUSER_SNAME())OR(@PouzeZaznamyDleLogin=0)) )
SET @PC=(SELECT TOP 1 PoradoveCislo FROM dbo.TabUniImportOZ WHERE IDHlavicky=@IDHlavicky AND Chyba IS NULL AND Zaloha=0 AND ((@PouzeZaznamyDleLogin=1 AND Autor=SUSER_SNAME())OR(@PouzeZaznamyDleLogin=0)) )
IF ((@DruhPohybuZbo IN(13, 14, 18, 19))
AND(EXISTS(SELECT * FROM TabDokladyZbozi WHERE RadaDokladu=@Rada AND PoradoveCislo=@PC AND DruhPohybuZbo=@DruhPohybuZbo AND Obdobi=@IdObdobi))
)
OR ((@DruhPohybuZbo NOT IN(13, 14, 18, 19))
AND(EXISTS(SELECT * FROM TabDokladyZbozi WHERE RadaDokladu=@Rada AND PoradoveCislo=@PC AND DruhPohybuZbo=@DruhPohybuZbo AND IDSklad=@IDSklad AND Obdobi=@IdObdobi))
)
BEGIN
SET @ChybaPriImportu=1
IF @TextChybyImportu<>'' SET @TextChybyImportu=@TextChybyImportu + ' | '
SET @TextChybyImportu = @TextChybyImportu + dbo.hpf_UniImportHlasky('8777A45A-6D24-4BAF-AF4A-6E09E285FB9B', @JazykVerze, CAST(@PC AS NVARCHAR(10)), @Rada, DEFAULT, DEFAULT)
END
/*existuje rada?*/
SET @Rada=(SELECT TOP 1 RadaDokladu FROM dbo.TabUniImportOZ WHERE IDHlavicky=@IDHlavicky AND Chyba IS NULL AND Zaloha=0 AND ((@PouzeZaznamyDleLogin=1 AND Autor=SUSER_SNAME())OR(@PouzeZaznamyDleLogin=0)) )
IF NOT EXISTS(SELECT * FROM TabDruhDokZbo WHERE DruhPohybuZbo=@DruhPohybuZbo AND RadaDokladu=@Rada)
BEGIN
SET @ChybaPriImportu=1
IF @TextChybyImportu<>'' SET @TextChybyImportu=@TextChybyImportu + ' | '
SET @TextChybyImportu = @TextChybyImportu + dbo.hpf_UniImportHlasky('4BD2A71C-633E-4F18-B07E-2180DA7A5CF4', @JazykVerze, @Rada, DEFAULT, DEFAULT, DEFAULT)
END
/*existuje organizace?*/
SET @CisOrg=(SELECT TOP 1 CisloOrg FROM dbo.TabUniImportOZ WHERE IDHlavicky=@IDHlavicky AND Chyba IS NULL AND Zaloha=0 AND ((@PouzeZaznamyDleLogin=1 AND Autor=SUSER_SNAME())OR(@PouzeZaznamyDleLogin=0)) )
IF @CisOrg IS NOT NULL
BEGIN
  IF NOT EXISTS(SELECT * FROM TabCisOrg WHERE CisloOrg=@CisOrg)
  BEGIN
    SET @ChybaPriImportu=1
    IF @TextChybyImportu<>'' SET @TextChybyImportu=@TextChybyImportu + ' | '
    SET @TextChybyImportu = @TextChybyImportu + dbo.hpf_UniImportHlasky('3D736ACC-09C3-4BA8-A47E-218FD883826A', @JazykVerze, CAST(@CisOrg AS NVARCHAR(10)), DEFAULT, DEFAULT, DEFAULT)
  END
END
IF @CisOrg IS NULL
SET @ICO=(SELECT TOP 1 ICO FROM dbo.TabUniImportOZ WHERE IDHlavicky=@IDHlavicky AND Chyba IS NULL AND Zaloha=0 AND ((@PouzeZaznamyDleLogin=1 AND Autor=SUSER_SNAME())OR(@PouzeZaznamyDleLogin=0)) )
IF (@CisOrg IS NULL)AND(@ICO IS NOT NULL)
IF (SELECT COUNT(*) FROM TabCisOrg WHERE ICO=@ICO)=1
SET @CisOrg=(SELECT CisloOrg FROM TabCisOrg WHERE ICO=@ICO)
IF @CisOrg IS NULL
BEGIN
IF @DruhPohybuZbo NOT IN (18, 19)
BEGIN
SET @MU=(SELECT TOP 1 MistoUrceni FROM dbo.TabUniImportOZ WHERE IDHlavicky=@IDHlavicky AND Chyba IS NULL AND Zaloha=0 AND ((@PouzeZaznamyDleLogin=1 AND Autor=SUSER_SNAME())OR(@PouzeZaznamyDleLogin=0)) )
IF @MU IS NOT NULL
  SET @CisOrg = (SELECT NadrizenaOrg FROM TabCisOrg WHERE CisloOrg = @MU AND MU = 1)
END
END
/*zalozeni hlavicky*/
IF @ChybaPriImportu=0
BEGIN
SET @VstupniCenaHla=(SELECT TOP 1 VstupniCenaHla FROM dbo.TabUniImportOZ WHERE IDHlavicky=@IDHlavicky AND Chyba IS NULL AND Zaloha=0 AND ((@PouzeZaznamyDleLogin=1 AND Autor=SUSER_SNAME())OR(@PouzeZaznamyDleLogin=0)) )
SET @Mena=(SELECT TOP 1 Mena FROM dbo.TabUniImportOZ WHERE IDHlavicky=@IDHlavicky AND Chyba IS NULL AND Zaloha=0 AND ((@PouzeZaznamyDleLogin=1 AND Autor=SUSER_SNAME())OR(@PouzeZaznamyDleLogin=0)) )
SET @Kurz=(SELECT TOP 1 Kurz FROM dbo.TabUniImportOZ WHERE IDHlavicky=@IDHlavicky AND Chyba IS NULL AND Zaloha=0 AND ((@PouzeZaznamyDleLogin=1 AND Autor=SUSER_SNAME())OR(@PouzeZaznamyDleLogin=0)) )
SET @JednotkaMeny=(SELECT TOP 1 JednotkaMeny FROM dbo.TabUniImportOZ WHERE IDHlavicky=@IDHlavicky AND Chyba IS NULL AND Zaloha=0 AND ((@PouzeZaznamyDleLogin=1 AND Autor=SUSER_SNAME())OR(@PouzeZaznamyDleLogin=0)) )
SET @DatumKurzu=(SELECT TOP 1 DatumKurzu FROM dbo.TabUniImportOZ WHERE IDHlavicky=@IDHlavicky AND Chyba IS NULL AND Zaloha=0 AND ((@PouzeZaznamyDleLogin=1 AND Autor=SUSER_SNAME())OR(@PouzeZaznamyDleLogin=0)) )
IF @DatumKurzu IS NULL  SET @DatumKurzu=ISNULL(@DatPorizeni, GETDATE())
IF @Mena IS NULL
  SET @Mena=(SELECT DruhMeny FROM TabDruhDokZbo WHERE DruhPohybuZbo=@DruhPohybuZbo AND RadaDokladu=@Rada)
IF (@Mena IS NOT NULL)
AND(@Mena<>(SELECT Kod FROM TabKodMen WHERE HlavniMena=1))
AND(@Kurz IS NULL)
SELECT TOP 1 @Kurz=Kurz, @JednotkaMeny=JednotkaMeny FROM TabKurzList WHERE Mena=@Mena AND Datum<=@DatumKurzu ORDER BY Datum DESC
IF @Kurz IS NULL
  SET @DatumKurzu=NULL
EXEC hp_InsertHlavickyOZ @IDent=@IDDoklad OUTPUT,
@Sklad=@IDsklad,
@DruhPohybu=@DruhPohybuZbo,
@RadaDokladu=@Rada,
@PC=@PC,
@CisloOrg=@CisOrg,
@DatumPorizeni=@DatPorizeni,
@VstupniCena=@VstupniCenaHla,
@Mena=@Mena
SELECT TOP 1 @PomerKoef=PomerKoef FROM dbo.TabUniImportOZ WHERE IDHlavicky=@IDHlavicky AND Chyba IS NULL AND Zaloha=0 AND ((@PouzeZaznamyDleLogin=1 AND Autor=SUSER_SNAME())OR(@PouzeZaznamyDleLogin=0)) 
UPDATE TabDokladyZbozi SET
  PomerKoef=@PomerKoef
, Kurz=ISNULL(@Kurz, 1)
, JednotkaMeny=ISNULL(@JednotkaMeny, 1)
, DatumKurzu=@DatumKurzu
WHERE ID=@IDDoklad
END
IF @ChybaPriImportu=0
BEGIN
SELECT TOP 1 @RezimMOSS=RezimMOSS, @SamoVyDICDPH=SamoVyDICDPH, @ZemeDPH=ZemeDPH FROM TabUniImportOZ WHERE IDHlavicky=@IDHlavicky AND Chyba IS NULL AND Zaloha=0 AND ((@PouzeZaznamyDleLogin=1 AND Autor=SUSER_SNAME())OR(@PouzeZaznamyDleLogin=0)) 
IF @RezimMOSS IS NULL
  SET @RezimMOSS=(SELECT PrednastaveniRezimuOSS FROM TabDruhDokZbo WHERE RadaDokladu=@Rada AND DruhPohybuZbo=@DruhPohybuZbo)
IF @SamoVyDICDPH IS NOT NULL
  IF NOT EXISTS(SELECT * FROM TabDICOrg WHERE CisloOrg=0 AND DIC=@SamoVyDICDPH)
  BEGIN
SET @ChybaPriImportu=1
IF @TextChybyImportu<>'' SET @TextChybyImportu=@TextChybyImportu + ' | '
SET @TextChybyImportu = @TextChybyImportu + dbo.hpf_UniImportHlasky('7929A253-28BB-41B9-B1E7-70A16D6A7E62', @JazykVerze, @SamoVyDICDPH, DEFAULT, DEFAULT, DEFAULT)
  END
  ELSE
    UPDATE TabDokladyZbozi SET
      RezimMOSS=@RezimMOSS
    , SamoVyDICDPH=@SamoVyDICDPH
    , ZemeDPH=@ZemeDPH
    WHERE ID=@IDDoklad
END
/*zpracovani polozek*/
SET @RucniDPHPovoleno=0
IF @DruhPohybuZbo IN(13, 14)
  SET @RucniDPHPovoleno=(SELECT PovolitUpravuDPH FROM TabDruhDokZbo WHERE RadaDokladu=@Rada AND DruhPohybuZbo=@DruhPohybuZbo)
IF @DruhPohybuZbo IN(18, 19)
  SET @RucniDPHPovoleno=1
DECLARE p CURSOR LOCAL FAST_FORWARD FOR
SELECT ID, InterniVerze, Mena, Kurz, JednotkaMeny, SazbaSDPol, SazbaDPHPol, VstupniCena,
ISNULL(Mnozstvi, 0), ISNULL(Cena, 0), ISNULL(Sleva, 0), IDSklad, SkupZbo, RegCis, BarCode, ISNULL(IDSkladPol, ''), TextPolozka,
NazevSozNa1, NazevSozNa2, NazevSozNa3, Popis4, Hmotnost, ZemePuvodu, ISNULL(ZemePreference, ''), PozadDatDod, PotvrzDatDod, ISNULL(JePDP, 0),
ISNULL(SlevaSozNa, 0), ISNULL(SlevaSkupZbo, 0), ISNULL(SlevaZboKmen, 0), ISNULL(SlevaZboSklad, 0), ISNULL(SlevaOrg, 0), KodDanoveKlicePol, DPHZadanaRucne,
CCevidPozadovana, DotahovatSazby, KodUmisteni, ISNULL(TypSlevyTxtPol, 0), ISNULL(SlevaTxtPol, 0), PomerKoefPol,
KodPDP
FROM dbo.TabUniImportOZ
WHERE IDHlavicky=@IDHlavicky AND Chyba IS NULL AND VC=0 AND Zaloha=0
 AND ((@PouzeZaznamyDleLogin=1 AND Autor=SUSER_SNAME())OR(@PouzeZaznamyDleLogin=0)) 
OPEN p
WHILE 1=1
BEGIN
FETCH NEXT FROM p INTO @IDPolozky, @InterniVerze, @Mena, @Kurz, @JednotkaMeny, @SazbaSDPol, @SazbaDPHPol,
@VstupniCena, @Mnozstvi, @Cena, @Sleva, @IDSklad, @SkupZbo, @RegCis, @BarCode, @IDSkladPol, @TextPolozka, @NazevSozNa1, @NazevSozNa2, @NazevSozNa3, @Popis4,
@Hmotnost, @ZemePuvodu, @ZemePreference, @PozadDatDod, @PotvrzDatDod, @JePDP,
@SlevaSozNa, @SlevaSkupZbo, @SlevaZboKmen, @SlevaZboSklad, @SlevaOrg, @KodDanoveKlicePol, @DPHZadanaRucne, @CCevidPozadovana,
@DotahovatSazbyImp, @KodUmisteni, @TypSlevyTxtPol, @SlevaTxtPol, @PomerKoefPol, @KodPDP
IF @@fetch_status<>0 BREAK
SET @TextChybyImportuPolozka=''
/*kontrola verze importu*/
IF @TextPolozka=1
BEGIN
IF @SazbaDPHPol IS NULL
  SET @DotahovatSazby=1
ELSE
  SET @DotahovatSazby=0
IF @DotahovatSazbyImp IS NOT NULL
SET @DotahovatSazby=@DotahovatSazbyImp
  IF (@DruhPohybuZbo IN (6, 9, 10, 11, 13, 14, 18, 19))
  BEGIN
IF @SazbaDPHPol IS NOT NULL
IF dbo.hpf_UniImportExistujeSazbaDPH(@SazbaDPHPol, @DatPorizeni) = 0
BEGIN
SET @ChybaPriImportu=1
IF @TextChybyImportuPolozka<>'' SET @TextChybyImportuPolozka=@TextChybyImportuPolozka + ' | '
SET @TextChybyImportuPolozka = @TextChybyImportuPolozka + dbo.hpf_UniImportHlasky('593FB54F-C1E7-48E4-996E-C499F540EF4F', @JazykVerze, @SazbaDPHPol, DEFAULT, DEFAULT, DEFAULT)
END
SET @MJ=(SELECT MJ FROM dbo.TabUniImportOZ WHERE ID=@IDPolozky)
  IF @MJ IS NOT NULL
      IF NOT EXISTS(SELECT * FROM TabMJ WHERE Kod=@MJ)
        INSERT TabMJ(Kod) VALUES(@MJ)
IF @VstupniCena>7
BEGIN
SET @ChybaPriImportu=1
IF @TextChybyImportuPolozka<>'' SET @TextChybyImportuPolozka=@TextChybyImportuPolozka + ' | '
SET @TextChybyImportuPolozka = @TextChybyImportuPolozka + dbo.hpf_UniImportHlasky('DE69684F-65E0-44AF-8118-D55D880A00AD', @JazykVerze, DEFAULT, DEFAULT, DEFAULT, DEFAULT)
END
ELSE
BEGIN
  SET @StredNakladPol=NULL
  SET @CisloUcetPol=NULL
  SET @EvCisloPol=NULL
  SET @SPZZobrazPol=NULL
  SET @CisloZakazkyPol=NULL
  SET @CisloNOkruhPol=NULL
  SET @CisloZamPol=NULL
  SELECT @StredNakladPol=StredNakladPol, @CisloUcetPol=CisloUcetPol, @EvCisloPol=EvCisloPol, @CisloZakazkyPol=CisloZakazkyPol, @CisloNOkruhPol=CisloNOkruhPol, @CisloZamPol=CisloZamPol, @SPZZobrazPol=SPZZobrazPol
  FROM dbo.TabUniImportOZ WHERE ID=@IDPolozky
IF @StredNakladPol IS NOT NULL
BEGIN
IF NOT EXISTS(SELECT * FROM TabStrom WHERE Cislo=@StredNakladPol)
BEGIN
  SET @ChybaPriImportu=1
  IF @TextChybyImportuPolozka<>'' SET @TextChybyImportuPolozka=@TextChybyImportuPolozka + ' | '
  SET @TextChybyImportuPolozka = @TextChybyImportuPolozka + dbo.hpf_UniImportHlasky('ED5CBFF2-E377-44A7-980C-2929F89AE8ED', @JazykVerze, @StredNaklad, DEFAULT, DEFAULT, DEFAULT)
END
END
IF @CisloUcetPol IS NOT NULL
BEGIN
IF NOT EXISTS(SELECT * FROM TabCisUct WHERE CisloUcet=@CisloUcetPol)
BEGIN
  SET @ChybaPriImportu=1
  IF @TextChybyImportuPolozka<>'' SET @TextChybyImportuPolozka=@TextChybyImportuPolozka + ' | '
  SET @TextChybyImportuPolozka = @TextChybyImportuPolozka + dbo.hpf_UniImportHlasky('D07B4F21-CFE2-4CB1-94C4-735E895B33CD', @JazykVerze, @CisloUcetPol, DEFAULT, DEFAULT, DEFAULT)
END
END
IF @EvCisloPol IS NOT NULL
BEGIN
IF NOT EXISTS(SELECT * FROM TabIVozidlo WHERE EvCislo=@EvCisloPol)
BEGIN
  SET @ChybaPriImportu=1
  IF @TextChybyImportuPolozka<>'' SET @TextChybyImportuPolozka=@TextChybyImportuPolozka + ' | '
  SET @TextChybyImportuPolozka = @TextChybyImportuPolozka + dbo.hpf_UniImportHlasky('432E30F9-89CE-4AFD-8960-FFCA1125F1A4', @JazykVerze, @EvCisloPol, DEFAULT, DEFAULT, DEFAULT)
END
END
ELSE
IF @SPZZobrazPol IS NOT NULL
  SET @EvCisloPol=(SELECT TOP 1 EvCislo FROM TabIVozidlo WHERE SPZZobraz=@SPZZobrazPol)
IF @CisloZakazkyPol IS NOT NULL
BEGIN
IF NOT EXISTS(SELECT * FROM TabZakazka WHERE CisloZakazky=@CisloZakazkyPol)
BEGIN
  SET @ChybaPriImportu=1
  IF @TextChybyImportuPolozka<>'' SET @TextChybyImportuPolozka=@TextChybyImportuPolozka + ' | '
  SET @TextChybyImportuPolozka = @TextChybyImportuPolozka + dbo.hpf_UniImportHlasky('F8F59726-1E74-4FC0-90BF-94425A2D5019', @JazykVerze, @CisloZakazky, DEFAULT, DEFAULT, DEFAULT)
END
END
IF @CisloNOkruhPol IS NOT NULL
BEGIN
IF NOT EXISTS(SELECT * FROM TabNakladovyOkruh WHERE Cislo=@CisloNOkruhPol)
BEGIN
  SET @ChybaPriImportu=1
  IF @TextChybyImportuPolozka<>'' SET @TextChybyImportuPolozka=@TextChybyImportuPolozka + ' | '
  SET @TextChybyImportuPolozka = @TextChybyImportuPolozka + dbo.hpf_UniImportHlasky('0502CA86-715E-479E-AE3E-D197E78E37D7', @JazykVerze, @StredNaklad, DEFAULT, DEFAULT, DEFAULT)
END
END
IF @CisloZamPol IS NOT NULL
BEGIN
IF NOT EXISTS(SELECT * FROM TabCisZam WHERE Cislo=@CisloZamPol)
BEGIN
  SET @ChybaPriImportu=1
  IF @TextChybyImportuPolozka<>'' SET @TextChybyImportuPolozka=@TextChybyImportuPolozka + ' | '
  SET @TextChybyImportuPolozka = @TextChybyImportuPolozka + dbo.hpf_UniImportHlasky('F5003BED-6EAD-46D1-8C67-305A0EA61705', @JazykVerze, CAST(@CisloZamPol AS NVARCHAR(20)), DEFAULT, DEFAULT, DEFAULT)
END
END
SET @IdDanovyKlic=NULL
IF ISNULL(@KodDanoveKlicePol, '')<>''
BEGIN
  SET @IdDanovyKlic=(SELECT ID FROM TabDanoveKlice WHERE Kod=@KodDanoveKlicePol)
  IF @IdDanovyKlic IS NULL
  BEGIN
    SET @ChybaPriImportu=1
    IF @TextChybyImportuPolozka<>'' SET @TextChybyImportuPolozka=@TextChybyImportuPolozka + ' | '
    SET @TextChybyImportuPolozka = @TextChybyImportuPolozka + dbo.hpf_UniImportHlasky('091A40F2-BE70-4191-86EB-941CD9D78603', @JazykVerze, @KodDanoveKlicePol, DEFAULT, DEFAULT, DEFAULT)
  END
END
IF ISNULL(@KodPDP, '')<>''
BEGIN
  SET @IdKodPDP=(SELECT MAX(ID)
                 FROM TabCisKoduPDP
                 WHERE GETDATE() BETWEEN ISNULL(DatumOd, '19900101') AND ISNULL(DatumDo, '21990101')
                 AND Zeme=N'CZ'
                 AND KodZbozi=@KodPDP)
  IF @IdKodPDP IS NULL
  BEGIN
    SET @ChybaPriImportu=1
    IF @TextChybyImportuPolozka<>'' SET @TextChybyImportuPolozka=@TextChybyImportuPolozka + ' | '
    SET @TextChybyImportuPolozka = @TextChybyImportuPolozka + dbo.hpf_UniImportHlasky('4E6E8339-BE7B-4A8B-8C5A-D82DFFC78849', @JazykVerze, @KodPDP, DEFAULT, DEFAULT, DEFAULT)
  END
END
  IF @ChybaPriImportu=0
    EXEC dbo.hpx_UniImport_ZpracujTextPolozkyOZ @VstupniCena=@VstupniCena
                                               ,@IDDoklad=@IDDoklad
                                               ,@Mnozstvi=@Mnozstvi
                                               ,@Cena=@Cena
                                               ,@SazbaDPHPol=@SazbaDPHPol
                                               ,@MJ=@MJ
                                               ,@IDPolozky=@IDPolozky
                                               ,@Popis=@NazevSozNa1
                                               ,@JePDP=@JePDP
                                               ,@StredNaklad=@StredNakladPol
                                               ,@CisloUcet=@CisloUcetPol
                                               ,@Vozidlo=@EvCisloPol
                                               ,@CisloZakazky=@CisloZakazkyPol
                                               ,@NOkruh=@CisloNOkruhPol
                                               ,@CisloZam=@CisloZamPol
                                               ,@IdDanovyKlic=@IdDanovyKlic
                                               ,@RucniDPHPovoleno=@RucniDPHPovoleno
                                               ,@DPHZadanaRucne=@DPHZadanaRucne
                                               ,@DotahovatSazby=@DotahovatSazby
                                               ,@TypSlevy=@TypSlevyTxtPol
                                               ,@Sleva=@SlevaTxtPol
                                               ,@PomerKoef=@PomerKoefPol
                                               ,@IdKodPDP=@IdKodPDP
                                               ,@IdTxtPolozka=@IdTxtPolozka OUT
  IF @ChybaPriImportu=0
  BEGIN
  SET @ChybaExtAtr=''
  EXEC dbo.hpx_UniImport_ZpracujExtAtr
  @ImportIdent=5,
  @IdImpTable=@IDPolozky,
  @IdTargetTable=@IdTxtPolozka,
  @Chyba=@ChybaExtAtr OUT,
  @Polozky=1,
  @TxtPolozkyOZ=1
  IF @ChybaExtAtr<>''
  BEGIN
    SET @ChybaPriImportu=1
    IF @TextChybyImportuPolozka<>'' SET @TextChybyImportuPolozka=@TextChybyImportuPolozka + ' | '
    SET @TextChybyImportuPolozka = @TextChybyImportuPolozka + dbo.hpf_UniImportHlasky('15364319-B20F-4D65-8900-391DE8D4C52F', @JazykVerze, @ChybaExtAtr, DEFAULT, DEFAULT, DEFAULT)
  END
  END
END
  END
  ELSE
  BEGIN
SET @ChybaPriImportu=1
IF @TextChybyImportuPolozka<>'' SET @TextChybyImportuPolozka=@TextChybyImportuPolozka + ' | '
SET @TextChybyImportuPolozka = @TextChybyImportuPolozka + dbo.hpf_UniImportHlasky('1564B6A5-CDD0-4365-A1C1-9309FA19ACD3', @JazykVerze, DEFAULT, DEFAULT, DEFAULT, DEFAULT)
  END
END
ELSE
BEGIN
/*kontrola existence meny*/
IF @Mena IS NOT NULL
IF NOT EXISTS(SELECT * FROM TabKodMen WHERE Kod=@Mena) INSERT TabKodMen(Kod, Nazev) VALUES(@Mena, '')
IF @Mena IS NULL
  SET @Mena=(SELECT DruhMeny FROM TabDruhDokZbo WHERE DruhPohybuZbo=@DruhPohybuZbo AND RadaDokladu=@Rada)
IF @Mena IS NOT NULL
  IF @Kurz IS NULL
  BEGIN
    SELECT TOP 1 @Kurz=Kurz, @JednotkaMeny=JednotkaMeny FROM TabKurzList WHERE Mena=@Mena AND Datum = (CONVERT([datetime],CONVERT([int],CONVERT([float],@DatPorizeni,0),0),0))
    IF @Kurz IS NULL
      SELECT TOP 1 @Kurz=Kurz, @JednotkaMeny=JednotkaMeny FROM TabKurzList WHERE Mena=@Mena AND Datum <= (CONVERT([datetime],CONVERT([int],CONVERT([float],@DatPorizeni,0),0),0)) ORDER BY Datum DESC
  END
IF @Mena IS NOT NULL
  IF (SELECT HlavniMena FROM TabKodMen WHERE Kod=@Mena)=1
  BEGIN
    SET @Kurz=1
    SET @JednotkaMeny=1
  END
IF @Mena IS NULL
BEGIN
  SET @Kurz=1
  SET @JednotkaMeny=1
END
IF @JednotkaMeny IS NULL SET @JednotkaMeny=1
/*kontrola existence sazby DPH*/
IF @SazbaDPHPol IS NOT NULL
IF dbo.hpf_UniImportExistujeSazbaDPH(@SazbaDPHPol, @DatPorizeni) = 0
BEGIN
SET @ChybaPriImportu=1
IF @TextChybyImportuPolozka<>'' SET @TextChybyImportuPolozka=@TextChybyImportuPolozka + ' | '
SET @TextChybyImportuPolozka = @TextChybyImportuPolozka + dbo.hpf_UniImportHlasky('593FB54F-C1E7-48E4-996E-C499F540EF4F', @JazykVerze, @SazbaDPHPol, DEFAULT, DEFAULT, DEFAULT)
END
/*identifikace druhu vstupni ceny a dotahovani sazeb*/
IF (@SazbaDPHPol IS NULL)AND(@SazbaSDPol IS NULL)
SET @DotahovatSazby=1
ELSE SET @DotahovatSazby=0
IF @DotahovatSazbyImp IS NOT NULL
SET @DotahovatSazby=@DotahovatSazbyImp
IF @SazbaSDPol IS NULL SET @SazbaSDPol=0
IF @VstupniCena IS NULL
BEGIN
SET @VstupniCenaProPrepocet=NULL
SET @VstupniCena=(SELECT VstupniCena FROM TabDruhDokZbo WHERE RadaDokladu=@Rada AND DruhPohybuZbo=@DruhPohybuZbo)
END
ELSE SET @VstupniCenaProPrepocet=0
/*existuje sklad?*/
SET @IDSklad=(SELECT TOP 1 IDSklad FROM dbo.TabUniImportOZ WHERE IDHlavicky=@IDHlavicky AND Chyba IS NULL AND Zaloha=0 AND ((@PouzeZaznamyDleLogin=1 AND Autor=SUSER_SNAME())OR(@PouzeZaznamyDleLogin=0)) )
  IF @IDSklad IS NULL
    SET @IDSklad=(SELECT SkladSluzeb FROM TabHGlob)
IF @IDSkladPol<>'' SET @IDSklad=@IDSkladPol
IF @IDSklad IS NOT NULL
BEGIN
IF NOT EXISTS(SELECT * FROM TabStrom WHERE Cislo=@IDSklad)
BEGIN
SET @ChybaPriImportu=1
IF @TextChybyImportuPolozka<>'' SET @TextChybyImportuPolozka=@TextChybyImportuPolozka + ' | '
SET @TextChybyImportuPolozka = @TextChybyImportuPolozka + dbo.hpf_UniImportHlasky('32E711C5-DB15-414F-BAD7-B513BB576585', @JazykVerze, @IDSklad, DEFAULT, DEFAULT, DEFAULT)
END
END
ELSE
BEGIN
SET @ChybaPriImportu=1
IF @TextChybyImportuPolozka<>'' SET @TextChybyImportuPolozka=@TextChybyImportuPolozka + ' | '
SET @TextChybyImportuPolozka = @TextChybyImportuPolozka + dbo.hpf_UniImportHlasky('3CE7FAE2-A705-4BC9-8F70-18533C4EB0EE', @JazykVerze, DEFAULT, DEFAULT, DEFAULT, DEFAULT)
END
/*vlozeni polozky*/
/*existuje kmenova karta*/
IF (@BarCode IS NOT NULL)AND((@RegCis IS NULL)AND(@SkupZbo IS NULL))
BEGIN
SET @IDKmenBarCode=(SELECT IDKmenZbo FROM TabBarCodeZbo WHERE BarCode=@BarCode)
IF @IDKmenBarCode IS NULL
BEGIN
SET @ChybaPriImportu=1
IF @TextChybyImportuPolozka<>'' SET @TextChybyImportuPolozka=@TextChybyImportuPolozka + ' | '
SET @TextChybyImportuPolozka = @TextChybyImportuPolozka + dbo.hpf_UniImportHlasky('1353FA23-337A-4322-8DAD-F9FD2401D102', @JazykVerze, @BarCode, DEFAULT, DEFAULT, DEFAULT)
END
ELSE
BEGIN
SET @RegCis=NULL
SET @SkupZbo=NULL
SELECT @RegCis=RegCis, @SkupZbo=SkupZbo FROM TabKmenZbozi WHERE ID=@IDKmenBarCode
SET @IDKmen=@IDKmenBarCode
END
END
ELSE
BEGIN
/*doplneni nul do registracniho cisla dle globalni konfigurace*/
SET @Nuly=''
SELECT @DelkaReg=DelkaRegCislaZbozi, @Zarovnani=ZarovnaniRegCislaZbozi FROM TabHGlob
IF LEN(@RegCis)>@DelkaReg
BEGIN
SET @ChybaPriImportu=1
IF @TextChybyImportuPolozka<>'' SET @TextChybyImportuPolozka=@TextChybyImportuPolozka + ' | '
SET @TextChybyImportuPolozka = @TextChybyImportuPolozka + dbo.hpf_UniImportHlasky('0B22315C-C48D-48F3-9E30-153AA961CECD', @JazykVerze, @SkupZbo, @RegCis, DEFAULT, DEFAULT)
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
IF LEN(@SkupZbo)=1 SET @SkupZbo=N'00' + @SkupZbo /*doplneni nul do skupiny zbozi*/
IF LEN(@SkupZbo)=2 SET @SkupZbo=N'0'  + @SkupZbo /*doplneni nul do skupiny zbozi*/
SET @IDKmen=(SELECT ID FROM TabKmenZbozi WHERE RegCis=@RegCis AND SkupZbo=@SkupZbo)
IF @IDKmen IS NULL
BEGIN
SET @ChybaPriImportu=1
IF @TextChybyImportuPolozka<>'' SET @TextChybyImportuPolozka=@TextChybyImportuPolozka + ' | '
SET @TextChybyImportuPolozka = @TextChybyImportuPolozka + dbo.hpf_UniImportHlasky('2D1B6178-C225-4043-89B9-3E1247BBB538', @JazykVerze, ISNULL(CAST(@SkupZbo AS NVARCHAR(20)),'<!!>'), ISNULL(@RegCis, '<!!>'), DEFAULT, DEFAULT)
END
END
IF (SELECT Blokovano FROM TabKmenZbozi WHERE ID=@IDKmen)=1
BEGIN
  SET @ChybaPriImportu=1
  IF @TextChybyImportuPolozka<>'' SET @TextChybyImportuPolozka=@TextChybyImportuPolozka + ' | '
SET @TextChybyImportuPolozka = @TextChybyImportuPolozka + dbo.hpf_UniImportHlasky('F90C9F72-C552-42E0-BE02-449DB992CB9E', @JazykVerze, ISNULL(CAST(@SkupZbo AS NVARCHAR(20)),'<!!>'), ISNULL(@RegCis, '<!!>'), DEFAULT, DEFAULT)
END
/*zalozeni skladove karty--------------------------------------------------------------*/
IF NOT EXISTS(SELECT * FROM TabStavSkladu
              LEFT OUTER JOIN TabKmenZbozi ON TabStavSkladu.IDKmenZbozi=TabKmenZbozi.ID
              WHERE TabStavSkladu.IDSklad = @IDSklad
              AND TabKmenZbozi.RegCis = @RegCis AND TabKmenZbozi.SkupZbo=@SkupZbo)
  IF @ChybaPriImportu=0
    INSERT TabStavSkladu(IDSklad, IDKmenZbozi) VALUES (@IDSklad, @IDKmen)
/*---------------------------------------------------------------------------------------*/
IF (SELECT Blokovano FROM TabStavSkladu WHERE IDKmenZbozi=@IDKmen AND IDSklad=@IDSklad)=1
BEGIN
  SET @ChybaPriImportu=1
  IF @TextChybyImportuPolozka<>'' SET @TextChybyImportuPolozka=@TextChybyImportuPolozka + ' | '
  SET @TextChybyImportuPolozka = @TextChybyImportuPolozka + dbo.hpf_UniImportHlasky('418528D0-4D6E-413D-9F55-EA894243F674', @JazykVerze, ISNULL(CAST(@SkupZbo AS NVARCHAR(20)),'<!!>'), ISNULL(@RegCis, '<!!>'), DEFAULT, DEFAULT)
END
IF @ChybaPriImportu=0
BEGIN
set @IDZboSklad = (select S.ID from TabStavSkladu S join TabKmenZbozi K on S.IDKmenZBozi=K.ID where K.SkupZbo=@SkupZbo and K.RegCis=@RegCis and S.IDSklad=@IDSklad)
IF @DruhPohybuZbo=4
BEGIN
exec hp_InsertPolozkyOZ
@IDENT=@IDpohyb OUT,
@IDDoklad=@IDDoklad,
@DruhPohybu=@DruhPohybuZbo,
@CisloOrg=@CisOrg,
@IDZboSklad=@IDZboSklad,
@Mena=@Mena,
@Kurz=@Kurz,
@JednotkaMeny=@JednotkaMeny,
@KurzEuro=0,
@SazbaSD=@SazbaSDPol,
@SazbaDPH=@SazbaDPHPol,
@ZakazanoDPH=0,
@VstupniCena=@VstupniCena,
@PovolitDuplicitu=1,
@Mnozstvi=@Mnozstvi,
@JCBezDaniKC=0,
@VstupniCenaProPrepocet=0,
@DotahovatSazby=@DotahovatSazby,
@DatPorizeni=@DatPorizeni
END
ELSE
BEGIN
exec hp_InsertPolozkyOZ
@IDENT=@IDpohyb OUT,
@IDDoklad=@IDDoklad,
@DruhPohybu=@DruhPohybuZbo,
@CisloOrg=@CisOrg,
@IDZboSklad=@IDZboSklad,
@Mena=@Mena,
@Kurz=@Kurz,
@JednotkaMeny=@JednotkaMeny,
@KurzEuro=0,
@SazbaSD=@SazbaSDPol,
@SazbaDPH=@SazbaDPHPol,
@ZakazanoDPH=0,
@VstupniCena=@VstupniCena,
@PovolitDuplicitu=1,
@Mnozstvi=@Mnozstvi,
@VstupniCenaProPrepocet=@VstupniCenaProPrepocet,
@DotahovatSazby=@DotahovatSazby,
@DatPorizeni=@DatPorizeni
END
END
UPDATE TabPohybyZbozi SET
 PomerKoef=@PomerKoefPol
WHERE ID=@IDPohyb
/*update polozky*/
IF (@Cena IS NOT NULL)AND(@DruhPohybuZbo<>4)AND(@ChybaPriImportu=0)AND(@VstupniCenaProPrepocet IS NOT NULL)
BEGIN
IF @VstupniCena=0 UPDATE TabPohybyZbozi SET VstupniCena=@VstupniCena, JCBezDaniKC=@Cena WHERE ID=@IDPohyb
IF @VstupniCena=1 UPDATE TabPohybyZbozi SET VstupniCena=@VstupniCena, JCsDPHKc=@Cena WHERE ID=@IDPohyb
IF @VstupniCena=2 UPDATE TabPohybyZbozi SET VstupniCena=@VstupniCena, CCbezDaniKc=@Cena WHERE ID=@IDPohyb
IF @VstupniCena=3 UPDATE TabPohybyZbozi SET VstupniCena=@VstupniCena, CCsDPHKc=@Cena WHERE ID=@IDPohyb
IF @VstupniCena=4 UPDATE TabPohybyZbozi SET VstupniCena=@VstupniCena, JCbezDaniVal=@Cena WHERE ID=@IDPohyb
IF @VstupniCena=5 UPDATE TabPohybyZbozi SET VstupniCena=@VstupniCena, JCsDPHVal=@Cena WHERE ID=@IDPohyb
IF @VstupniCena=6 UPDATE TabPohybyZbozi SET VstupniCena=@VstupniCena, CCbezDaniVal=@Cena WHERE ID=@IDPohyb
IF @VstupniCena=7 UPDATE TabPohybyZbozi SET VstupniCena=@VstupniCena, CCsDPHVal=@Cena WHERE ID=@IDPohyb
IF @VstupniCena=8 UPDATE TabPohybyZbozi SET VstupniCena=@VstupniCena, JCsSDKc=@Cena WHERE ID=@IDPohyb
IF @VstupniCena=9 UPDATE TabPohybyZbozi SET VstupniCena=@VstupniCena, JCsSDKc=@Cena WHERE ID=@IDPohyb
END
IF (@DPHZadanaRucne IS NOT NULL)AND(@ChybaPriImportu=0)AND(@RucniDPHPovoleno=1)
BEGIN
IF @VstupniCena=0 UPDATE TabPohybyZbozi SET JCZadaneDPHKc =@DPHZadanaRucne WHERE ID=@IDPohyb
IF @VstupniCena=2 UPDATE TabPohybyZbozi SET CCZadaneDPHKc =@DPHZadanaRucne WHERE ID=@IDPohyb
IF @VstupniCena=4 UPDATE TabPohybyZbozi SET JCZadaneDPHVal=@DPHZadanaRucne WHERE ID=@IDPohyb
IF @VstupniCena=6 UPDATE TabPohybyZbozi SET CCZadaneDPHVal=@DPHZadanaRucne WHERE ID=@IDPohyb
END
/*nakladove stredisko polozky*/
SET @StredNaklad=(SELECT TOP 1 StredNakladPol FROM dbo.TabUniImportOZ WHERE ID=@IDPolozky)
IF @StredNaklad IS NOT NULL
BEGIN
/*existuje stredisko?*/
IF NOT EXISTS(SELECT * FROM TabStrom WHERE Cislo=@StredNaklad)
BEGIN
SET @ChybaPriImportu=1
IF @TextChybyImportuPolozka<>'' SET @TextChybyImportuPolozka=@TextChybyImportuPolozka + ' | '
SET @TextChybyImportuPolozka = @TextChybyImportuPolozka + dbo.hpf_UniImportHlasky('ED5CBFF2-E377-44A7-980C-2929F89AE8ED', @JazykVerze, @StredNaklad, DEFAULT, DEFAULT, DEFAULT)
END
ELSE
  IF @ChybaPriImportu=0
    UPDATE TabPohybyZbozi SET StredNaklad=@StredNaklad WHERE ID=@IDPohyb
END
SET @CisloNOkruhPol=(SELECT TOP 1 CisloNOkruhPol FROM dbo.TabUniImportOZ WHERE ID=@IDPolozky)
IF @CisloNOkruhPol IS NOT NULL
BEGIN
/*existuje stredisko?*/
IF NOT EXISTS(SELECT * FROM TabNakladovyOkruh WHERE Cislo=@CisloNOkruhPol)
BEGIN
SET @ChybaPriImportu=1
IF @TextChybyImportuPolozka<>'' SET @TextChybyImportuPolozka=@TextChybyImportuPolozka + ' | '
SET @TextChybyImportuPolozka = @TextChybyImportuPolozka + dbo.hpf_UniImportHlasky('0502CA86-715E-479E-AE3E-D197E78E37D7', @JazykVerze, @StredNaklad, DEFAULT, DEFAULT, DEFAULT)
END
ELSE
  IF @ChybaPriImportu=0
    UPDATE TabPohybyZbozi SET CisloNOkruh=@CisloNOkruhPol WHERE ID=@IDPohyb
END
SET @IdDanovyKlic=NULL
IF ISNULL(@KodDanoveKlicePol, '')<>''
BEGIN
  SET @IdDanovyKlic=(SELECT ID FROM TabDanoveKlice WHERE Kod=@KodDanoveKlicePol)
  IF @IdDanovyKlic IS NULL
  BEGIN
    SET @ChybaPriImportu=1
    IF @TextChybyImportuPolozka<>'' SET @TextChybyImportuPolozka=@TextChybyImportuPolozka + ' | '
    SET @TextChybyImportuPolozka = @TextChybyImportuPolozka + dbo.hpf_UniImportHlasky('091A40F2-BE70-4191-86EB-941CD9D78603', @JazykVerze, @KodDanoveKlicePol, DEFAULT, DEFAULT, DEFAULT)
  END
  ELSE
    IF @ChybaPriImportu=0
      UPDATE TabPohybyZbozi SET IdDanovyKlic=@IdDanovyKlic WHERE ID=@IDPohyb
END
IF ISNULL(@KodPDP, '')<>''
BEGIN
  SET @IdKodPDP=(SELECT MAX(ID)
                 FROM TabCisKoduPDP
                 WHERE GETDATE() BETWEEN ISNULL(DatumOd, '19900101') AND ISNULL(DatumDo, '21990101')
                 AND Zeme=N'CZ'
                 AND KodZbozi=@KodPDP)
  IF @IdKodPDP IS NULL
  BEGIN
    SET @ChybaPriImportu=1
    IF @TextChybyImportuPolozka<>'' SET @TextChybyImportuPolozka=@TextChybyImportuPolozka + ' | '
    SET @TextChybyImportuPolozka = @TextChybyImportuPolozka + dbo.hpf_UniImportHlasky('4E6E8339-BE7B-4A8B-8C5A-D82DFFC78849', @JazykVerze, @KodPDP, DEFAULT, DEFAULT, DEFAULT)
  END
  ELSE
    UPDATE TabPohybyZbozi SET IDKodPDP=@IdKodPDP WHERE ID=@IDPohyb
END
/*mnozstevni jednotka*/
  SET @MJ=(SELECT MJ FROM dbo.TabUniImportOZ WHERE ID=@IDPolozky)
  IF @MJ IS NOT NULL
  BEGIN
    SET @MJKarta=(SELECT MJEvidence
                  FROM TabKmenZbozi
                  LEFT OUTER JOIN TabStavSkladu ON TabStavSkladu.IDKmenZbozi=TabKmenZbozi.ID
                  WHERE TabStavSkladu.ID=@IDZboSklad)
    IF @MJKarta IS NULL
    BEGIN
      /*existuje MJ?*/
      IF NOT EXISTS(SELECT * FROM TabMJ WHERE Kod=@MJ)
        INSERT TabMJ(Kod) VALUES(@MJ)
      IF @@ERROR<>0 SET @ChybaPriImportu=1
      IF @ChybaPriImportu=0
        UPDATE TabPohybyZbozi SET MJ=@MJ WHERE ID=@IDPohyb
    END
    ELSE
    IF @MJKarta<>@MJ
    BEGIN
      IF (dbo.hfx_UniImportKontrolaVztahuMJ(@MJKarta, @MJ, NULL, NULL, @IDKmen) = 1)
      OR (dbo.hfx_UniImportKontrolaVztahuMJ(@MJKarta, NULL, @MJ, NULL, @IDKmen) = 1)
      BEGIN
        IF @ChybaPriImportu=0
          UPDATE TabPohybyZbozi SET MJ=@MJ WHERE ID=@IDPohyb
      END
      ELSE
      BEGIN
          SET @ChybaPriImportu=1
          IF @TextChybyImportuPolozka<>'' SET @TextChybyImportuPolozka=@TextChybyImportuPolozka + ' | '
          SET @TextChybyImportuPolozka = @TextChybyImportuPolozka + dbo.hpf_UniImportHlasky('F632EE67-4FE0-4B45-ACD3-377E483B3A08', @JazykVerze, @MJ, DEFAULT, DEFAULT, DEFAULT)
      END
    END
    ELSE
      UPDATE TabPohybyZbozi SET MJ=@MJ WHERE ID=@IDPohyb
  END
/*Poznamka polozky*/
IF @ChybaPriImportu=0
BEGIN
  UPDATE TabPohybyZbozi SET Poznamka=ISNULL(TabUniImportOZ.PoznamkaPol, '')
  FROM TabUniImportOZ
  WHERE TabPohybyZbozi.ID=@IDPohyb AND TabUniImportOZ.ID=@IDPolozky
  IF @@ERROR<>0 SET @ChybaPriImportu=1
END
/*CisloZakazky polozky*/
SET @CisloZakazky=(SELECT CisloZakazkyPol FROM dbo.TabUniImportOZ WHERE ID=@IDPolozky)
IF @CisloZakazky IS NOT NULL
BEGIN
/*existuje zakazka?*/
IF NOT EXISTS(SELECT * FROM TabZakazka WHERE CisloZakazky=@CisloZakazky)
BEGIN
SET @ChybaPriImportu=1
IF @TextChybyImportuPolozka<>'' SET @TextChybyImportuPolozka=@TextChybyImportuPolozka + ' | '
SET @TextChybyImportuPolozka = @TextChybyImportuPolozka + dbo.hpf_UniImportHlasky('F8F59726-1E74-4FC0-90BF-94425A2D5019', @JazykVerze, @CisloZakazky, DEFAULT, DEFAULT, DEFAULT)
END
ELSE
  IF @ChybaPriImportu=0
    UPDATE TabPohybyZbozi SET CisloZakazky=@CisloZakazky WHERE ID=@IDPohyb
END
/*EvCisloPol vozidla polozky*/
SET @EvCisloPol=(SELECT EvCisloPol FROM dbo.TabUniImportOZ WHERE ID=@IDPolozky)
IF @EvCisloPol IS NOT NULL
BEGIN
/*existuje vozidlo?*/
IF NOT EXISTS(SELECT * FROM TabIVozidlo WHERE EvCislo=@EvCisloPol)
BEGIN
SET @ChybaPriImportu=1
IF @TextChybyImportuPolozka<>'' SET @TextChybyImportuPolozka=@TextChybyImportuPolozka + ' | '
SET @TextChybyImportuPolozka = @TextChybyImportuPolozka + dbo.hpf_UniImportHlasky('432E30F9-89CE-4AFD-8960-FFCA1125F1A4', @JazykVerze, @EvCisloPol, DEFAULT, DEFAULT, DEFAULT)
END
ELSE
  IF @ChybaPriImportu=0
    UPDATE TabPohybyZbozi SET IdVozidlo=(SELECT ID FROM TabIVozidlo WHERE EvCislo=@EvCisloPol) WHERE ID=@IDPohyb
END
ELSE
BEGIN
SET @SPZZobrazPol=(SELECT SPZZobrazPol FROM dbo.TabUniImportOZ WHERE ID=@IDPolozky)
IF @SPZZobrazPol IS NOT NULL
BEGIN
  SET @EvCisloPol=(SELECT TOP 1 EvCislo FROM TabIVozidlo WHERE SPZZobraz=@SPZZobrazPol)
  IF @EvCisloPol IS NOT NULL
    UPDATE TabPohybyZbozi SET IdVozidlo=(SELECT ID FROM TabIVozidlo WHERE EvCislo=@EvCisloPol) WHERE ID=@IDPohyb
END
END
/*CisloZam polozky dokladu*/
SET @CisloZamPol=(SELECT CisloZamPol FROM dbo.TabUniImportOZ WHERE ID=@IDPolozky AND Chyba IS NULL)
IF @CisloZamPol IS NOT NULL
BEGIN
/*existuje zamestnanec?*/
IF NOT EXISTS(SELECT * FROM TabCisZam WHERE Cislo=@CisloZamPol)
BEGIN
SET @ChybaPriImportu=1
IF @TextChybyImportuPolozka<>'' SET @TextChybyImportuPolozka=@TextChybyImportuPolozka + ' | '
SET @TextChybyImportuPolozka = @TextChybyImportuPolozka + dbo.hpf_UniImportHlasky('F5003BED-6EAD-46D1-8C67-305A0EA61705', @JazykVerze, CAST(@CisloZamPol AS NVARCHAR(20)), DEFAULT, DEFAULT, DEFAULT)
END
ELSE
  IF @ChybaPriImportu=0
    UPDATE TabPohybyZbozi SET CisloZam=@CisloZamPol WHERE ID=@IDPohyb
END
IF @BarCode IS NOT NULL
BEGIN
  IF EXISTS(SELECT * FROM TabBarCodeZbo WHERE BarCode=@BarCode AND IDKmenZbo=@IDKmen)
    UPDATE TabPohybyZbozi SET BarCode=@BarCode WHERE ID=@IDPohyb
END
ELSE
BEGIN
  UPDATE TabPohybyZbozi SET BarCode=(SELECT TOP 1 BarCode FROM TabBarCodeZbo WHERE IDKmenZbo=@IDKmen AND Prednastaveno=1 ORDER BY Porizeno DESC)
  WHERE ID=@IDPohyb
END
IF (@DruhPohybuZbo IN (0, 1, 6, 18, 19))
BEGIN
IF ISNULL(@KodUmisteni, '')<>''
BEGIN
SET @IdUmisteni=(SELECT ID FROM TabUmisteni WHERE Kod=@KodUmisteni AND IDSklad=@IDSklad)
IF @IdUmisteni IS NULL
BEGIN
  SET @ChybaPriImportu=1
  IF @TextChybyImportuPolozka<>'' SET @TextChybyImportuPolozka=@TextChybyImportuPolozka + ' | '
  SET @TextChybyImportuPolozka = @TextChybyImportuPolozka + dbo.hpf_UniImportHlasky('7FCD5ABF-212A-47E1-87A6-61F2AD719398', @JazykVerze, @KodUmisteni, DEFAULT, DEFAULT, DEFAULT)
END
ELSE
BEGIN
  SET @IdVStavUmisteni=(SELECT ID FROM TabVStavUmisteni WHERE IDUmisteni=@IdUmisteni AND IDStav=@IDZboSklad)
  IF @IdVStavUmisteni IS NULL
  BEGIN
    INSERT TabVStavUmisteni(IDStav, IDUmisteni) VALUES(@IDZboSklad, @IdUmisteni)
    SET @IdVStavUmisteni=SCOPE_IDENTITY()
  END
  UPDATE TabPohybyZbozi SET IdUmisteni=@IdVStavUmisteni WHERE ID=@IDPohyb
END
END
ELSE
  UPDATE TabPohybyZbozi SET IdUmisteni=(SELECT TOP 1 ID FROM TabVStavUmisteni WHERE IDStav=@IDZboSklad AND Prednastaveno=1)
  WHERE ID=@IDPohyb
END
/*Popis1-4 polozky*/
IF @ChybaPriImportu=0
BEGIN
  UPDATE TabPohybyZbozi SET
    NazevSozNa1=ISNULL(TabUniImportOZ.NazevSozNa1, ''),
    NazevSozNa2=ISNULL(TabUniImportOZ.NazevSozNa2, ''),
    NazevSozNa3=ISNULL(TabUniImportOZ.NazevSozNa3, ''),
    Popis4=ISNULL(TabUniImportOZ.Popis4, '')
  FROM TabUniImportOZ
  WHERE TabPohybyZbozi.ID=@IDPohyb AND TabUniImportOZ.ID=@IDPolozky
  IF @@ERROR<>0 SET @ChybaPriImportu=1
END
IF @ChybaPriImportu=0
BEGIN
  IF @Hmotnost IS NULL
    EXEC [dbo].[hp_OZPrepoctiHmotnost]
      @IDPohyb = @IDPohyb,
      @Selectem = 0,
      @Hmotnost = @Hmotnost OUT,
      @Mnozstvi = @Mnozstvi,
      @MJ = @MJ
  IF @Hmotnost IS NULL SET @Hmotnost = 0
  UPDATE TabPohybyZbozi SET
    Hmotnost = @Hmotnost
  WHERE ID=@IDPohyb
END
IF ISNULL(@ZemePuvodu, '')<>'' 
  UPDATE TabPohybyZbozi SET
    ZemePuvodu = @ZemePuvodu
  WHERE ID=@IDPohyb
IF ISNULL(@ZemePreference, '')<>'' 
  UPDATE TabPohybyZbozi SET
    ZemePreference = @ZemePreference
  WHERE ID=@IDPohyb
IF @ChybaPriImportu=0
BEGIN
  UPDATE TabPohybyZbozi SET
    PozadDatDod = @PozadDatDod,
    PotvrzDatDod = @PotvrzDatDod
  WHERE ID=@IDPohyb
END
IF @DruhPohybuZbo IN(1, 3)
  UPDATE TabPohybyZbozi SET
    CCevidPozadovana=@CCevidPozadovana
  WHERE ID=@IDPohyb
IF @JePDP=1
BEGIN
  IF @SazbaDPHPol IS NULL
  BEGIN
    IF @DruhPohybuZbo IN (0, 1, 6, 18, 19)
      SET @SazbaDPHPol = (SELECT SazbaDPHVstup FROM TabKmenZbozi WHERE ID=@IDKmen)
    IF @DruhPohybuZbo IN (2, 3, 9, 10, 13, 14)
      SET @SazbaDPHPol = (SELECT SazbaDPHVystup FROM TabKmenZbozi WHERE ID=@IDKmen)
  END
  SET @SazbaDPHproPDP=@SazbaDPHPol
  IF @DruhPohybuZbo IN (0, 1, 6, 18, 19)
    SET @SazbaDPHPol = NULL
  IF @DruhPohybuZbo IN (2, 3, 9, 10, 13, 14)
    SET @SazbaDPHPol = 0
  UPDATE TabPohybyZbozi SET
    SazbaDPHproPDP=@SazbaDPHproPDP,
    SazbaDPH=@SazbaDPHPol
  WHERE ID=@IDPohyb
END
IF @DruhPohybuZbo IN (2, 9, 10, 11, 13)
IF (@SlevaSozNa<>0) OR (@SlevaSkupZbo<>0) OR (@SlevaZboKmen<>0) OR (@SlevaZboSklad<>0) OR (@SlevaOrg<>0)
BEGIN
  SET @NastaveniSlev=0
  IF @SlevaSozNa=0
    SET @NastaveniSlev=@NastaveniSlev+4096
  ELSE
    SET @NastaveniSlev=@NastaveniSlev+8192
  IF @SlevaSkupZbo=0
    SET @NastaveniSlev=@NastaveniSlev+512
  ELSE
    SET @NastaveniSlev=@NastaveniSlev+1024
  IF @SlevaOrg=0
    SET @NastaveniSlev=@NastaveniSlev+64
  ELSE
    SET @NastaveniSlev=@NastaveniSlev+128
  IF @SlevaZboKmen=0
    SET @NastaveniSlev=@NastaveniSlev+8
  ELSE
    SET @NastaveniSlev=@NastaveniSlev+16
  IF @SlevaZboSklad=0
    SET @NastaveniSlev=@NastaveniSlev+1
  ELSE
    SET @NastaveniSlev=@NastaveniSlev+2
  UPDATE TabPohybyZbozi SET
    NastaveniSlev=@NastaveniSlev,
    SlevaSozNa=@SlevaSozNa,
    SlevaSkupZbo=@SlevaSkupZbo,
    SlevaOrg=@SlevaOrg,
    SlevaZboKmen=@SlevaZboKmen,
    SlevaZboSklad=@SlevaZboSklad
  WHERE ID=@IDPohyb
END
SET @ChybaExtAtr=''
EXEC dbo.hpx_UniImport_ZpracujExtAtr
  @ImportIdent=5,
  @IdImpTable=@IDPolozky,
  @IdTargetTable=@IDPohyb,
  @Chyba=@ChybaExtAtr OUT,
  @Polozky=1
IF @ChybaExtAtr<>''
BEGIN
  SET @ChybaPriImportu=1
  IF @TextChybyImportuPolozka<>'' SET @TextChybyImportuPolozka=@TextChybyImportuPolozka + ' | '
  SET @TextChybyImportuPolozka = @TextChybyImportuPolozka + dbo.hpf_UniImportHlasky('15364319-B20F-4D65-8900-391DE8D4C52F', @JazykVerze, @ChybaExtAtr, DEFAULT, DEFAULT, DEFAULT)
END
END
IF @TextChybyImportuPolozka<>''
INSERT @CHYBYPOLOZEK(ID, Chyba) VALUES(@IDPolozky, @TextChybyImportuPolozka)
SET @TextChybyImportuPolozka=''
END
CLOSE p
DEALLOCATE p
/*nakladove stredisko*/
SET @StredNaklad=(SELECT TOP 1 StredNaklad FROM dbo.TabUniImportOZ WHERE IDHlavicky=@IDHlavicky AND Chyba IS NULL AND Zaloha=0 AND ((@PouzeZaznamyDleLogin=1 AND Autor=SUSER_SNAME())OR(@PouzeZaznamyDleLogin=0)) )
IF @StredNaklad IS NOT NULL
BEGIN
/*existuje stredisko?*/
IF NOT EXISTS(SELECT * FROM TabStrom WHERE Cislo=@StredNaklad)
BEGIN
SET @ChybaPriImportu=1
IF @TextChybyImportu<>'' SET @TextChybyImportu=@TextChybyImportu + ' | '
SET @TextChybyImportu = @TextChybyImportu + dbo.hpf_UniImportHlasky('ED5CBFF2-E377-44A7-980C-2929F89AE8ED', @JazykVerze, @StredNaklad, DEFAULT, DEFAULT, DEFAULT)
END
ELSE
  IF @ChybaPriImportu=0
    UPDATE TabDokladyZbozi SET StredNaklad=@StredNaklad WHERE ID=@IDDoklad
END
/*DIC*/
SET @DIC=(SELECT TOP 1 DIC FROM dbo.TabUniImportOZ WHERE IDHlavicky=@IDHlavicky AND Chyba IS NULL AND Zaloha=0 AND ((@PouzeZaznamyDleLogin=1 AND Autor=SUSER_SNAME())OR(@PouzeZaznamyDleLogin=0)) )
IF @DIC IS NOT NULL
BEGIN
/*existuje DIC?*/
IF NOT EXISTS(SELECT * FROM TabDICOrg WHERE DIC=@DIC AND CisloOrg=@CisOrg)
BEGIN
SET @ChybaPriImportu=1
IF @TextChybyImportu<>'' SET @TextChybyImportu=@TextChybyImportu + ' | '
SET @TextChybyImportu = @TextChybyImportu + dbo.hpf_UniImportHlasky('B151D137-D762-474A-86B3-A051D8EDE3AD', @JazykVerze, @DIC, CAST(@CisOrg AS NVARCHAR(10)), DEFAULT, DEFAULT)
END
ELSE
  IF @ChybaPriImportu=0
    UPDATE TabDokladyZbozi SET DIC=@DIC WHERE ID=@IDDoklad
END
/*MistoUrceni*/
IF @DruhPohybuZbo NOT IN (18, 19)
BEGIN
SET @MU=(SELECT TOP 1 MistoUrceni FROM dbo.TabUniImportOZ WHERE IDHlavicky=@IDHlavicky AND Chyba IS NULL AND Zaloha=0 AND ((@PouzeZaznamyDleLogin=1 AND Autor=SUSER_SNAME())OR(@PouzeZaznamyDleLogin=0)) )
IF @MU IS NOT NULL
BEGIN
/*existuje MU?*/
IF NOT EXISTS(SELECT * FROM TabCisOrg WHERE CisloOrg=@MU)
BEGIN
SET @ChybaPriImportu=1
IF @TextChybyImportu<>'' SET @TextChybyImportu=@TextChybyImportu + ' | '
SET @TextChybyImportu = @TextChybyImportu + dbo.hpf_UniImportHlasky('49A578B9-B0F4-46A7-9C0A-DC46446E702D', @JazykVerze, CAST(@MU AS NVARCHAR(10)), DEFAULT, DEFAULT, DEFAULT)
END
ELSE
  IF @ChybaPriImportu=0
    UPDATE TabDokladyZbozi SET MistoUrceni=@MU WHERE ID=@IDDoklad
END
END
/*Prijemce*/
SET @Prijemce=(SELECT TOP 1 Prijemce FROM dbo.TabUniImportOZ WHERE IDHlavicky=@IDHlavicky AND Chyba IS NULL AND Zaloha=0 AND ((@PouzeZaznamyDleLogin=1 AND Autor=SUSER_SNAME())OR(@PouzeZaznamyDleLogin=0)) )
IF @Prijemce IS NOT NULL
BEGIN
/*existuje Prijemce?*/
IF NOT EXISTS(SELECT * FROM TabCisOrg WHERE CisloOrg=@Prijemce)
BEGIN
SET @ChybaPriImportu=1
IF @TextChybyImportu<>'' SET @TextChybyImportu=@TextChybyImportu + ' | '
SET @TextChybyImportu = @TextChybyImportu + dbo.hpf_UniImportHlasky('C64F39A3-1A49-4435-8F66-45F38017D9F6', @JazykVerze, CAST(@Prijemce AS NVARCHAR(10)), DEFAULT, DEFAULT, DEFAULT)
END
ELSE
  IF @ChybaPriImportu=0
    UPDATE TabDokladyZbozi SET Prijemce=@Prijemce WHERE ID=@IDDoklad
END
SET @Splatnost=(SELECT TOP 1 Splatnost FROM dbo.TabUniImportOZ WHERE IDHlavicky=@IDHlavicky AND Chyba IS NULL AND Zaloha=0 AND ((@PouzeZaznamyDleLogin=1 AND Autor=SUSER_SNAME())OR(@PouzeZaznamyDleLogin=0)) )
IF @Splatnost IS NOT NULL UPDATE TabDokladyZbozi SET Splatnost=@Splatnost WHERE ID=@IDDoklad
/*DUZP*/
IF (@ChybaPriImportu=0)AND(@DruhPohybuZbo IN(13, 14, 18, 19))
BEGIN
  SET @DUZP=(SELECT TOP 1 DUZP FROM dbo.TabUniImportOZ WHERE IDHlavicky=@IDHlavicky AND Chyba IS NULL AND Zaloha=0 AND ((@PouzeZaznamyDleLogin=1 AND Autor=SUSER_SNAME())OR(@PouzeZaznamyDleLogin=0)) )
  UPDATE TabDokladyZbozi SET DUZP=@DUZP WHERE ID=@IDDoklad
END
IF (@ChybaPriImportu=0)AND(@DruhPohybuZbo IN(18, 19))
BEGIN
  SET @DatumDoruceni=(SELECT TOP 1 DatumDoruceni FROM dbo.TabUniImportOZ WHERE IDHlavicky=@IDHlavicky AND Chyba IS NULL AND Zaloha=0 AND ((@PouzeZaznamyDleLogin=1 AND Autor=SUSER_SNAME())OR(@PouzeZaznamyDleLogin=0)) )
  IF @DatumDoruceni IS NOT NULL UPDATE TabDokladyZbozi SET DatumDoruceni=@DatumDoruceni WHERE ID=@IDDoklad
END
/*Datum vystaveni*/
IF (@ChybaPriImportu=0)
BEGIN
  SET @DatPovinnostiFa=(SELECT TOP 1 DatPovinnostiFa FROM dbo.TabUniImportOZ WHERE IDHlavicky=@IDHlavicky AND Chyba IS NULL AND Zaloha=0 AND ((@PouzeZaznamyDleLogin=1 AND Autor=SUSER_SNAME())OR(@PouzeZaznamyDleLogin=0)) )
  IF @DatPovinnostiFa IS NOT NULL UPDATE TabDokladyZbozi SET DatPovinnostiFa=@DatPovinnostiFa WHERE ID=@IDDoklad
END
/*UKod*/
IF (@DruhPohybuZbo NOT IN(6, 9, 10, 11))
BEGIN
SET @UKod=(SELECT TOP 1 UKod FROM dbo.TabUniImportOZ WHERE IDHlavicky=@IDHlavicky AND Chyba IS NULL AND Zaloha=0 AND ((@PouzeZaznamyDleLogin=1 AND Autor=SUSER_SNAME())OR(@PouzeZaznamyDleLogin=0)) )
IF @UKod IS NOT NULL
BEGIN
/*existuje UKod pro dany druh pohybu?*/
IF NOT EXISTS(SELECT * FROM TabUKod WHERE CisloKontace=@UKod AND DruhPohybu=@DruhPohybuZbo)
BEGIN
SET @ChybaPriImportu=1
IF @TextChybyImportu<>'' SET @TextChybyImportu=@TextChybyImportu + ' | '
SET @TextChybyImportu = @TextChybyImportu + dbo.hpf_UniImportHlasky('09024EB4-27E7-48A5-AB28-B6FC301E4D7E', @JazykVerze, CAST(@UKod AS NVARCHAR(10)), DEFAULT, DEFAULT, DEFAULT)
END
ELSE
  IF(@ChybaPriImportu=0)
    UPDATE TabDokladyZbozi SET UKod=@UKod WHERE ID=@IDDoklad
END
END
/*SazbaDPH*/
SET @SazbaDPH=(SELECT TOP 1 SazbaDPH FROM dbo.TabUniImportOZ WHERE IDHlavicky=@IDHlavicky AND Chyba IS NULL AND Zaloha=0 AND ((@PouzeZaznamyDleLogin=1 AND Autor=SUSER_SNAME())OR(@PouzeZaznamyDleLogin=0)) )
IF @SazbaDPH IS NOT NULL
BEGIN
/*existuje sazba?*/
IF dbo.hpf_UniImportExistujeSazbaDPH(@SazbaDPH, @DatPorizeni) = 0
BEGIN
SET @ChybaPriImportu=1
IF @TextChybyImportu<>'' SET @TextChybyImportu=@TextChybyImportu + ' | '
SET @TextChybyImportu = @TextChybyImportu + dbo.hpf_UniImportHlasky('593FB54F-C1E7-48E4-996E-C499F540EF4F', @JazykVerze, CAST(@SazbaDPH AS NVARCHAR(10)), DEFAULT, DEFAULT, DEFAULT)
END
ELSE
  IF @ChybaPriImportu=0
    UPDATE TabDokladyZbozi SET SazbaDPH=@SazbaDPH WHERE ID=@IDDoklad
END
ELSE 
  IF @ChybaPriImportu=0
    UPDATE TabDokladyZbozi SET SazbaDPH=NULL WHERE ID=@IDDoklad
/*SazbaSD*/
IF @ChybaPriImportu=0
BEGIN
  SET @SazbaSD=(SELECT TOP 1 SazbaSD FROM dbo.TabUniImportOZ WHERE IDHlavicky=@IDHlavicky AND Chyba IS NULL AND Zaloha=0 AND ((@PouzeZaznamyDleLogin=1 AND Autor=SUSER_SNAME())OR(@PouzeZaznamyDleLogin=0)) )
  IF @SazbaSD IS NOT NULL UPDATE TabDokladyZbozi SET SazbaSD=@SazbaSD WHERE ID=@IDDoklad
END
/*FormaUhrady*/
SET @FormaUhrady=(SELECT TOP 1 FormaUhrady FROM dbo.TabUniImportOZ WHERE IDHlavicky=@IDHlavicky AND Chyba IS NULL AND Zaloha=0 AND ((@PouzeZaznamyDleLogin=1 AND Autor=SUSER_SNAME())OR(@PouzeZaznamyDleLogin=0)) )
IF @FormaUhrady IS NOT NULL
BEGIN
/*existuje forma uhrady?*/
IF NOT EXISTS(SELECT * FROM TabFormaUhrady WHERE FormaUhrady=@FormaUhrady)
BEGIN
SET @ChybaPriImportu=1
IF @TextChybyImportu<>'' SET @TextChybyImportu=@TextChybyImportu + ' | '
SET @TextChybyImportu = @TextChybyImportu + dbo.hpf_UniImportHlasky('DF0B2893-2541-4A54-80DD-AC1B907D8648', @JazykVerze, @FormaUhrady, DEFAULT, DEFAULT, DEFAULT)
END
ELSE
  IF @ChybaPriImportu=0
    UPDATE TabDokladyZbozi SET FormaUhrady=@FormaUhrady WHERE ID=@IDDoklad
END
/*NakladovyOkruh*/
SET @NOkruhCislo=(SELECT TOP 1 NOkruhCislo FROM dbo.TabUniImportOZ WHERE IDHlavicky=@IDHlavicky AND Chyba IS NULL AND Zaloha=0 AND ((@PouzeZaznamyDleLogin=1 AND Autor=SUSER_SNAME())OR(@PouzeZaznamyDleLogin=0)) )
IF @NOkruhCislo IS NOT NULL
BEGIN
/*existuje nakladovy okruh?*/
IF NOT EXISTS(SELECT * FROM TabNakladovyOkruh WHERE Cislo=@NOkruhCislo)
BEGIN
SET @ChybaPriImportu=1
IF @TextChybyImportu<>'' SET @TextChybyImportu=@TextChybyImportu + ' | '
SET @TextChybyImportu = @TextChybyImportu + dbo.hpf_UniImportHlasky('C452A8EC-9169-4F93-9EC4-A27217E0FBA7', @JazykVerze, @NOkruhCislo, DEFAULT, DEFAULT, DEFAULT)
END
ELSE
  IF @ChybaPriImportu=0
    UPDATE TabDokladyZbozi SET NOkruhCislo=@NOkruhCislo WHERE ID=@IDDoklad
END
/*CisloZakazky*/
SET @CisloZakazky=(SELECT TOP 1 CisloZakazky FROM dbo.TabUniImportOZ WHERE IDHlavicky=@IDHlavicky AND Chyba IS NULL AND Zaloha=0 AND ((@PouzeZaznamyDleLogin=1 AND Autor=SUSER_SNAME())OR(@PouzeZaznamyDleLogin=0)) )
IF @CisloZakazky IS NOT NULL
BEGIN
/*existuje zakazka?*/
IF NOT EXISTS(SELECT * FROM TabZakazka WHERE CisloZakazky=@CisloZakazky)
BEGIN
SET @ChybaPriImportu=1
IF @TextChybyImportu<>'' SET @TextChybyImportu=@TextChybyImportu + ' | '
SET @TextChybyImportu = @TextChybyImportu + dbo.hpf_UniImportHlasky('F8F59726-1E74-4FC0-90BF-94425A2D5019', @JazykVerze, @CisloZakazky, DEFAULT, DEFAULT, DEFAULT)
END
ELSE
  IF @ChybaPriImportu=0
    UPDATE TabDokladyZbozi SET CisloZakazky=@CisloZakazky WHERE ID=@IDDoklad
END
/*CisloZam*/
SET @CisloZam=(SELECT TOP 1 CisloZam FROM dbo.TabUniImportOZ WHERE IDHlavicky=@IDHlavicky AND Chyba IS NULL AND Zaloha=0 AND ((@PouzeZaznamyDleLogin=1 AND Autor=SUSER_SNAME())OR(@PouzeZaznamyDleLogin=0)) )
IF @CisloZam IS NOT NULL
BEGIN
/*existuje zamestnanec?*/
IF NOT EXISTS(SELECT * FROM TabCisZam WHERE Cislo=@CisloZam)
BEGIN
SET @ChybaPriImportu=1
IF @TextChybyImportu<>'' SET @TextChybyImportu=@TextChybyImportu + ' | '
SET @TextChybyImportu = @TextChybyImportu + dbo.hpf_UniImportHlasky('F5003BED-6EAD-46D1-8C67-305A0EA61705', @JazykVerze, CAST(@CisloZam AS NVARCHAR(20)), DEFAULT, DEFAULT, DEFAULT)
END
ELSE
  IF @ChybaPriImportu=0
    UPDATE TabDokladyZbozi SET CisloZam=@CisloZam WHERE ID=@IDDoklad
END
/*FormaDopravy*/
IF @ChybaPriImportu=0
BEGIN
SET @FormaDopravy=(SELECT TOP 1 FormaDopravy FROM dbo.TabUniImportOZ WHERE IDHlavicky=@IDHlavicky AND Chyba IS NULL AND Zaloha=0 AND ((@PouzeZaznamyDleLogin=1 AND Autor=SUSER_SNAME())OR(@PouzeZaznamyDleLogin=0)) )
IF @FormaDopravy IS NOT NULL
BEGIN
/*existuje forma dopravy?*/
IF NOT EXISTS(SELECT * FROM TabFormaDopravy WHERE FormaDopravy=@FormaDopravy)
  INSERT TabFormaDopravy(FormaDopravy) VALUES(@FormaDopravy)
UPDATE TabDokladyZbozi SET FormaDopravy=@FormaDopravy WHERE ID=@IDDoklad
END
END
/*PopisDodavky*/
IF @ChybaPriImportu=0
BEGIN
SET @PopisDodavky=(SELECT TOP 1 PopisDodavky FROM dbo.TabUniImportOZ WHERE IDHlavicky=@IDHlavicky AND Chyba IS NULL AND Zaloha=0 AND ((@PouzeZaznamyDleLogin=1 AND Autor=SUSER_SNAME())OR(@PouzeZaznamyDleLogin=0)) )
IF @PopisDodavky IS NOT NULL
BEGIN
UPDATE TabDokladyZbozi SET PopisDodavky=@PopisDodavky WHERE ID=@IDDoklad
END
END
/*TerminDodavky*/
IF @ChybaPriImportu=0
BEGIN
SET @TerminDodavky=(SELECT TOP 1 TerminDodavky FROM dbo.TabUniImportOZ WHERE IDHlavicky=@IDHlavicky AND Chyba IS NULL AND Zaloha=0 AND ((@PouzeZaznamyDleLogin=1 AND Autor=SUSER_SNAME())OR(@PouzeZaznamyDleLogin=0)) )
IF @TerminDodavky IS NOT NULL
BEGIN
UPDATE TabDokladyZbozi SET TerminDodavky=@TerminDodavky WHERE ID=@IDDoklad
END
END
/*DodavatelskaFaktura*/
IF @ChybaPriImportu=0
BEGIN
  SET @DodFak=(SELECT TOP 1 DodFak FROM dbo.TabUniImportOZ WHERE IDHlavicky=@IDHlavicky AND Chyba IS NULL AND Zaloha=0 AND ((@PouzeZaznamyDleLogin=1 AND Autor=SUSER_SNAME())OR(@PouzeZaznamyDleLogin=0)) )
  IF @DodFak IS NOT NULL UPDATE TabDokladyZbozi SET DodFak=@DodFak WHERE ID=@IDDoklad
END
/*EvCislo vozidla*/
IF @ChybaPriImportu=0
BEGIN
SET @EvCislo=(SELECT TOP 1 EvCislo FROM dbo.TabUniImportOZ WHERE IDHlavicky=@IDHlavicky AND Chyba IS NULL AND Zaloha=0 AND ((@PouzeZaznamyDleLogin=1 AND Autor=SUSER_SNAME())OR(@PouzeZaznamyDleLogin=0)) )
IF @EvCislo IS NOT NULL
BEGIN
/*existuje vozidlo?*/
IF NOT EXISTS(SELECT * FROM TabIVozidlo WHERE EvCislo=@EvCislo)
BEGIN
SET @ChybaPriImportu=1
IF @TextChybyImportu<>'' SET @TextChybyImportu=@TextChybyImportu + ' | '
SET @TextChybyImportu = @TextChybyImportu + dbo.hpf_UniImportHlasky('432E30F9-89CE-4AFD-8960-FFCA1125F1A4', @JazykVerze, @EvCislo, DEFAULT, DEFAULT, DEFAULT)
END
ELSE
  IF @ChybaPriImportu=0
    UPDATE TabDokladyZbozi SET IdVozidlo=(SELECT ID FROM TabIVozidlo WHERE EvCislo=@EvCislo) WHERE ID=@IDDoklad
END
ELSE
BEGIN
SET @SPZZobraz=(SELECT TOP 1 SPZZobraz FROM dbo.TabUniImportOZ WHERE IDHlavicky=@IDHlavicky AND Chyba IS NULL AND Zaloha=0 AND ((@PouzeZaznamyDleLogin=1 AND Autor=SUSER_SNAME())OR(@PouzeZaznamyDleLogin=0)) )
IF @SPZZobraz IS NOT NULL
  SET @EvCislo=(SELECT TOP 1 EvCislo FROM TabIVozidlo WHERE SPZZobraz=@SPZZobraz)
IF @EvCislo IS NOT NULL
  UPDATE TabDokladyZbozi SET IdVozidlo=(SELECT ID FROM TabIVozidlo WHERE EvCislo=@EvCislo) WHERE ID=@IDDoklad
END
END
/*NavaznaObjednavka*/
IF (@ChybaPriImportu=0)
BEGIN
  SET @NavaznaObjednavka=(SELECT TOP 1 NavaznaObjednavka FROM dbo.TabUniImportOZ WHERE IDHlavicky=@IDHlavicky AND Chyba IS NULL AND Zaloha=0 AND ((@PouzeZaznamyDleLogin=1 AND Autor=SUSER_SNAME())OR(@PouzeZaznamyDleLogin=0)) )
  IF @NavaznaObjednavka IS NOT NULL  UPDATE TabDokladyZbozi SET NavaznaObjednavka=@NavaznaObjednavka WHERE ID=@IDDoklad
END
/*Zaokrouhleni*/
IF (@ChybaPriImportu=0)AND(@DruhPohybuZbo IN(18, 19))
BEGIN
  SET @KurzZaokr=(SELECT Kurz FROM TabDokladyZbozi WHERE ID=@IDDoklad)
  SET @MenaZaokr=(SELECT Mena FROM TabDokladyZbozi WHERE ID=@IDDoklad)
  SET @JednotkaZaokr=(SELECT JednotkaMeny FROM TabDokladyZbozi WHERE ID=@IDDoklad)
  SET @Zaokrouhleni=(SELECT TOP 1 Zaokrouhleni FROM dbo.TabUniImportOZ WHERE IDHlavicky=@IDHlavicky AND Chyba IS NULL AND Zaloha=0 AND ((@PouzeZaznamyDleLogin=1 AND Autor=SUSER_SNAME())OR(@PouzeZaznamyDleLogin=0)) )
  IF @Zaokrouhleni IS NOT NULL
  BEGIN
  IF @VstupniCena IN(0, 1, 2, 3, 8, 9)
    BEGIN
      UPDATE TabDokladyZbozi SET ZadanaCastkaZaoKc=@Zaokrouhleni WHERE ID=@IDDoklad
      EXEC dbo.hp_VypCenOZPolozek_Prepocet_Kc_Val_a_Val_Kc @Zaokrouhleni, @PrepocetZaokr OUTPUT, 0, @KurzZaokr, 0, @JednotkaZaokr, @MenaZaokr
      UPDATE TabDokladyZbozi SET ZadanaCastkaZaoKc=@Zaokrouhleni, ZadanaCastkaZaoVal=ISNULL(@PrepocetZaokr, 0) WHERE ID=@IDDoklad
    END
  ELSE
    BEGIN
      UPDATE TabDokladyZbozi SET ZadanaCastkaZaoVal=@Zaokrouhleni WHERE ID=@IDDoklad
      EXEC dbo.hp_VypCenOZPolozek_Prepocet_Kc_Val_a_Val_Kc @Zaokrouhleni, @PrepocetZaokr OUTPUT, 1, @KurzZaokr, 0, @JednotkaZaokr, @MenaZaokr
      UPDATE TabDokladyZbozi SET ZadanaCastkaZaoKc=ISNULL(@PrepocetZaokr, 0), ZadanaCastkaZaoVal=@Zaokrouhleni WHERE ID=@IDDoklad
    END
  END
END
/*Typ nabidky*/
IF (@ChybaPriImportu=0)AND(@DruhPohybuZbo=11)
BEGIN
  SET @NabidkaCenik=(SELECT TOP 1 NabidkaCenik FROM dbo.TabUniImportOZ WHERE IDHlavicky=@IDHlavicky AND Chyba IS NULL AND Zaloha=0 AND ((@PouzeZaznamyDleLogin=1 AND Autor=SUSER_SNAME())OR(@PouzeZaznamyDleLogin=0)) )
  IF (@NabidkaCenik IS NOT NULL)AND(@NabidkaCenik IN(0, 1))
  UPDATE TabDokladyZbozi SET NabidkaCenik=@NabidkaCenik WHERE ID=@IDDoklad
END
/*Poznamka*/
UPDATE TabDokladyZbozi SET
  Poznamka=ISNULL(TabUniImportOZ.Poznamka, ''),
  Text1=ISNULL(TabUniImportOZ.Text1, ''),
  Text2=ISNULL(TabUniImportOZ.Text2, ''),
  Text3=ISNULL(TabUniImportOZ.Text3, '')
FROM TabUniImportOZ
WHERE TabDokladyZbozi.ID=@IDDoklad AND TabUniImportOZ.ID=@IDImport
IF @@ERROR<>0 SET @ChybaPriImportu=1
/*Sleva*/
IF (@ChybaPriImportu=0)
BEGIN
  SET @Sleva=(SELECT TOP 1 ISNULL(Sleva, 0) FROM dbo.TabUniImportOZ WHERE IDHlavicky=@IDHlavicky AND Chyba IS NULL AND Zaloha=0 AND ((@PouzeZaznamyDleLogin=1 AND Autor=SUSER_SNAME())OR(@PouzeZaznamyDleLogin=0)) )
  IF @Sleva<>0
    UPDATE TabDokladyZbozi SET Sleva=@Sleva WHERE ID=@IDDoklad
END
IF @DUZP IS NOT NULL AND EXISTS(SELECT*FROM TabHGlob WHERE DoplneniObdobiStavuOZ = 1)
  EXEC dbo.hp_GetObdobiStavu @IdObdobi, 0, @DUZP, @IDObdobiStavu OUT
ELSE
  EXEC dbo.hp_GetObdobiStavu @IdObdobi, 0, @DatPorizeni, @IDObdobiStavu OUT
UPDATE TabDokladyZbozi SET IDObdobiStavu=@IDObdobiStavu WHERE ID=@IDDoklad
SET @DD = NULL
SET @DodaciPodminky=NULL
SET @ZemeUrceni=NULL
SELECT TOP 1 @DD=DD, @DodaciPodminky=DodaciPodminky, @ZemeUrceni=ZemeUrceni FROM dbo.TabUniImportOZ WHERE IDHlavicky=@IDHlavicky AND Chyba IS NULL AND Zaloha=0 AND ((@PouzeZaznamyDleLogin=1 AND Autor=SUSER_SNAME())OR(@PouzeZaznamyDleLogin=0)) 
SET @DD_ORG = NULL
SET @DodaciPodminky_ORG = NULL
SET @ZemeUrceni_ORG = NULL
SELECT @DD_ORG=DruhDopravy, @DodaciPodminky_ORG=DodaciPodminky, @ZemeUrceni_ORG=IdZeme FROM TabCisOrg WHERE CisloOrg=@CisOrg
SET @DD_RADA = NULL
SET @DodaciPodminky_RADA = NULL
SET @ZemeUrceni_RADA = NULL
SELECT @DD_RADA=DD, @DodaciPodminky_RADA=DodaciPodminky, @ZemeUrceni_RADA=ZemeUrceni FROM TabDruhDokZbo WHERE DruhPohybuZbo=@DruhPohybuZbo AND RadaDokladu=@Rada
IF LEN(@ZemeUrceni_ORG)<>2
  SET @ZemeUrceni_ORG=NULL
IF @DD IS NULL
  SET @DD=@DD_ORG
IF @DodaciPodminky IS NULL
  SET @DodaciPodminky=@DodaciPodminky_ORG
IF @ZemeUrceni IS NULL
  SET @ZemeUrceni=@ZemeUrceni_ORG
IF @DD IS NULL
  SET @DD=@DD_RADA
IF @DodaciPodminky IS NULL
  SET @DodaciPodminky=@DodaciPodminky_RADA
IF @ZemeUrceni IS NULL
  SET @ZemeUrceni=@ZemeUrceni_RADA
UPDATE TabDokZboDodatek SET
  DD=@DD,
  DodaciPodminky = ISNULL(@DodaciPodminky, ''),
  ZemeUrceni = ISNULL(@ZemeUrceni, '')
WHERE IdHlavicky=@IDDoklad
SELECT TOP 1 @DodFakKV = DodFakKV, @ZdrojCisKV = ZdrojCisKV FROM dbo.TabUniImportOZ WHERE IDHlavicky=@IDHlavicky AND Chyba IS NULL AND Zaloha=0 AND ((@PouzeZaznamyDleLogin=1 AND Autor=SUSER_SNAME())OR(@PouzeZaznamyDleLogin=0)) 
IF @ZdrojCisKV IS NULL
  SET @ZdrojCisKV=(SELECT DZ.ZdrojCisKV
FROM TabDokladyZbozi D
JOIN TabDruhDokZbo DZ ON DZ.DruhPohybuZbo=D.DruhPohybuZbo AND DZ.RadaDokladu=D.RadaDokladu
WHERE D.ID=@IDHlavicky)
UPDATE TabDokladyZbozi SET
  DodFakKV=ISNULL(@DodFakKV, ''),
  ZdrojCisKV = ISNULL(@ZdrojCisKV, 0)
WHERE ID=@IDDoklad
IF (@ChybaPriImportu=0)
IF @DruhPohybuZbo IN(11)
BEGIN
SET @DatUhrady=(SELECT TOP 1 DatUhrady FROM dbo.TabUniImportOZ WHERE IDHlavicky=@IDHlavicky AND Chyba IS NULL AND Zaloha=0 AND ((@PouzeZaznamyDleLogin=1 AND Autor=SUSER_SNAME())OR(@PouzeZaznamyDleLogin=0)) )
IF @DatUhrady IS NOT NULL
UPDATE TabDokladyZbozi SET DatUhrady=@DatUhrady
WHERE ID=@IDDoklad
END
IF @Mena IS NOT NULL
BEGIN
  SET @HlavniMena=(SELECT Kod FROM TabKodMen WHERE HlavniMena=1)
  IF @Mena<>@HlavniMena
  BEGIN
    SET @SamoVyZdrojKurzu=NULL
    SET @SamoVyDatumKurzuDPH=NULL
    SET @SamoVyKurzDPH=NULL
    SET @SamoVyMnoKurzDPH=NULL
    SELECT TOP 1 @SamoVyZdrojKurzu=SamoVyZdrojKurzu, @SamoVyDatumKurzuDPH=SamoVyDatumKurzuDPH, @SamoVyKurzDPH=SamoVyKurzDPH, @SamoVyMnoKurzDPH=SamoVyMnoKurzDPH FROM dbo.TabUniImportOZ WHERE IDHlavicky=@IDHlavicky AND Chyba IS NULL AND Zaloha=0 AND ((@PouzeZaznamyDleLogin=1 AND Autor=SUSER_SNAME())OR(@PouzeZaznamyDleLogin=0)) 
    IF @SamoVyZdrojKurzu IS NULL
      SET @SamoVyZdrojKurzu=(SELECT TOP 1 SamoVyZdrojKurzu FROM TabDruhDokZbo WHERE DruhPohybuZbo=@DruhPohybuZbo AND RadaDokladu=@Rada)
    IF @SamoVyZdrojKurzu<>2
    BEGIN
      SELECT @DUZP=DUZP, @SamoVyMenaDPH_HEO=SamoVyMenaDPH FROM TabDokladyZbozi WHERE ID=@IDDoklad
      EXEC dbo.hp_ObehZbozi_NajdiKurzSamoDan
        @ZdrojKurzu=@SamoVyZdrojKurzu,
        @MenaFak=@Mena,
        @MenaDPH=@SamoVyMenaDPH_HEO,
        @MenaHlavni=@HlavniMena,
        @DUZP=@DUZP,
        @DatumKurzu=@SamoVyDatumKurzuDPH_HEO OUT,
        @Kurz=@SamoVyKurzDPH_HEO OUT,
        @KurzEuro=@KurzEuro OUT,
        @JednotkaMeny=@SamoVyMnoKurzDPH_HEO OUT
    END
    ELSE
    BEGIN
      SELECT @SamoVyDatumKurzuDPH_HEO=DatumKurzu, @SamoVyKurzDPH_HEO=Kurz, @SamoVyMnoKurzDPH_HEO=JednotkaMeny
      FROM TabDokladyZbozi WHERE ID=@IDDoklad
     IF @SamoVyDatumKurzuDPH IS NOT NULL SET @SamoVyDatumKurzuDPH_HEO=@SamoVyDatumKurzuDPH
     IF @SamoVyKurzDPH IS NOT NULL SET @SamoVyKurzDPH_HEO=@SamoVyKurzDPH
     IF @SamoVyMnoKurzDPH IS NOT NULL SET @SamoVyMnoKurzDPH_HEO=@SamoVyMnoKurzDPH
    END
    UPDATE TabDokladyZbozi SET
      SamoVyZdrojKurzu=@SamoVyZdrojKurzu
    , SamoVyDatumKurzuDPH=@SamoVyDatumKurzuDPH_HEO
    , SamoVyKurzDPH=@SamoVyKurzDPH_HEO
    , SamoVyMnoKurzDPH=@SamoVyMnoKurzDPH_HEO
    WHERE ID=@IDDoklad
  END
END
IF (@ChybaPriImportu=0)
BEGIN
SET @KodDanovyRezim=(SELECT TOP 1 KodDanovyRezim FROM dbo.TabUniImportOZ WHERE IDHlavicky=@IDHlavicky AND Chyba IS NULL AND Zaloha=0 AND ((@PouzeZaznamyDleLogin=1 AND Autor=SUSER_SNAME())OR(@PouzeZaznamyDleLogin=0)) )
IF ISNULL(@KodDanovyRezim, '')<>''
BEGIN
SET @IdDanovyRezim=(SELECT Id FROM TabDanovyRezim WHERE Kod=@KodDanovyRezim)
IF @IdDanovyRezim IS NULL
BEGIN
  SET @ChybaPriImportu=1
  IF @TextChybyImportu<>'' SET @TextChybyImportu=@TextChybyImportu + ' | '
  SET @TextChybyImportu = @TextChybyImportu + dbo.hpf_UniImportHlasky('4073958C-AC87-4562-B9E8-74B3C5D1F7D2', @JazykVerze, @KodDanovyRezim, DEFAULT, DEFAULT, DEFAULT)
END
ELSE
  IF @ChybaPriImportu=0
    UPDATE TabDokladyZbozi SET IdDanovyRezim=@IdDanovyRezim WHERE ID=@IDDoklad
END
END
IF (@ChybaPriImportu=0)
BEGIN
  SET @DruhPohybuPrevod=NULL
  SET @TypPrevodky=NULL
  SET @IdSkladPrevodu=NULL
  SELECT TOP 1 @DruhPohybuPrevod=DruhPohybuPrevod, @TypPrevodky=TypPrevodky, @IdSkladPrevodu=IdSkladPrevodu FROM dbo.TabUniImportOZ WHERE IDHlavicky=@IDHlavicky AND Chyba IS NULL AND Zaloha=0 AND ((@PouzeZaznamyDleLogin=1 AND Autor=SUSER_SNAME())OR(@PouzeZaznamyDleLogin=0)) 
  IF @DruhPohybuPrevod IS NOT NULL
  BEGIN
IF NOT EXISTS(SELECT * FROM TabDruhDokZbo WHERE DruhPohybuZbo=@DruhPohybuPrevod AND RadaDokladu=@TypPrevodky)
BEGIN
SET @ChybaPriImportu=1
IF @TextChybyImportu<>'' SET @TextChybyImportu=@TextChybyImportu + ' | '
SET @TextChybyImportu = @TextChybyImportu + dbo.hpf_UniImportHlasky('4BD2A71C-633E-4F18-B07E-2180DA7A5CF4', @JazykVerze, ISNULL(@TypPrevodky, '<!!>'), DEFAULT, DEFAULT, DEFAULT)
END
IF (@ChybaPriImportu=0)
IF NOT EXISTS(SELECT * FROM TabStrom WHERE Cislo=@IdSkladPrevodu)
BEGIN
SET @ChybaPriImportu=1
IF @TextChybyImportu<>'' SET @TextChybyImportu=@TextChybyImportu + ' | '
SET @TextChybyImportu = @TextChybyImportu + dbo.hpf_UniImportHlasky('32E711C5-DB15-414F-BAD7-B513BB576585', @JazykVerze, ISNULL(@IdSkladPrevodu, '<!!>'), DEFAULT, DEFAULT, DEFAULT)
END
IF (@ChybaPriImportu=0)
  UPDATE TabDokladyZbozi SET DruhPohybuPrevod=@DruhPohybuPrevod, TypPrevodky=@TypPrevodky, IdSkladPrevodu=@IdSkladPrevodu WHERE ID=@IDDoklad
  END
END
SET @PZ2=(SELECT TOP 1 PZ2 FROM dbo.TabUniImportOZ WHERE IDHlavicky=@IDHlavicky AND Chyba IS NULL AND Zaloha=0 AND ((@PouzeZaznamyDleLogin=1 AND Autor=SUSER_SNAME())OR(@PouzeZaznamyDleLogin=0)) )
IF ISNULL(@PZ2, '')<>''
UPDATE TabDokladyZbozi SET PZ2=@PZ2 WHERE ID=@IDDoklad
IF (@ChybaPriImportu=0)AND(@DruhPohybuZbo IN(13, 14, 18, 19))
BEGIN
SELECT TOP 1 @CisloUctu=CisloUctu, @KodUstavu=KodUstavu, @IBANElektronicky=IBANElektronicky FROM dbo.TabUniImportOZ WHERE IDHlavicky=@IDHlavicky AND Chyba IS NULL AND Zaloha=0 AND ((@PouzeZaznamyDleLogin=1 AND Autor=SUSER_SNAME())OR(@PouzeZaznamyDleLogin=0)) 
IF ISNULL(@IBANElektronicky, '')<>''
BEGIN
IF @DruhPohybuZbo IN(14, 18)
BEGIN
SET @IdBankSpoj=(SELECT TOP 1 ID FROM TabBankSpojeni WHERE IBANElektronicky=@IBANElektronicky AND IdOrg=(SELECT ID FROM TabCisOrg WHERE CisloOrg=@CisOrg))
IF @IdBankSpoj IS NULL
BEGIN
SET @ChybaPriImportu=1
IF @TextChybyImportu<>'' SET @TextChybyImportu=@TextChybyImportu + ' | '
SET @TextChybyImportu = @TextChybyImportu + dbo.hpf_UniImportHlasky('49C36813-D3BE-4414-B431-CB8A3BF9E692', @JazykVerze, CAST(@CisOrg AS NVARCHAR), DEFAULT, DEFAULT, DEFAULT)
END
END
IF @DruhPohybuZbo IN(13, 19)
BEGIN
SET @IdBankSpoj=(SELECT TOP 1 ID FROM TabBankSpojeni WHERE IBANElektronicky=@IBANElektronicky AND IdOrg=(SELECT ID FROM TabCisOrg WHERE CisloOrg=0))
IF @IdBankSpoj IS NULL
BEGIN
SET @ChybaPriImportu=1
IF @TextChybyImportu<>'' SET @TextChybyImportu=@TextChybyImportu + ' | '
SET @TextChybyImportu = @TextChybyImportu + dbo.hpf_UniImportHlasky('49C36813-D3BE-4414-B431-CB8A3BF9E692', @JazykVerze, CAST(0 AS NVARCHAR), DEFAULT, DEFAULT, DEFAULT)
END
END
END
ELSE
IF ISNULL(@CisloUctu, '')<>''
BEGIN
IF @DruhPohybuZbo IN(14, 18)
BEGIN
SET @IdBankSpoj=(SELECT TOP 1 B.ID FROM TabBankSpojeni B LEFT OUTER JOIN TabPenezniUstavy U ON U.ID=B.IDUstavu WHERE B.CisloUctu=@CisloUctu AND U.KodUstavu=@KodUstavu AND B.IdOrg=(SELECT ID FROM TabCisOrg WHERE CisloOrg=@CisOrg))
IF @IdBankSpoj IS NULL
BEGIN
SET @ChybaPriImportu=1
IF @TextChybyImportu<>'' SET @TextChybyImportu=@TextChybyImportu + ' | '
SET @TextChybyImportu = @TextChybyImportu + dbo.hpf_UniImportHlasky('49C36813-D3BE-4414-B431-CB8A3BF9E692', @JazykVerze, CAST(@CisOrg AS NVARCHAR), DEFAULT, DEFAULT, DEFAULT)
END
END
IF @DruhPohybuZbo IN(13, 19)
BEGIN
SET @IdBankSpoj=(SELECT TOP 1 B.ID FROM TabBankSpojeni B LEFT OUTER JOIN TabPenezniUstavy U ON U.ID=B.IDUstavu WHERE B.CisloUctu=@CisloUctu AND U.KodUstavu=@KodUstavu AND B.IdOrg=(SELECT ID FROM TabCisOrg WHERE CisloOrg=0))
IF @IdBankSpoj IS NULL
BEGIN
SET @ChybaPriImportu=1
IF @TextChybyImportu<>'' SET @TextChybyImportu=@TextChybyImportu + ' | '
SET @TextChybyImportu = @TextChybyImportu + dbo.hpf_UniImportHlasky('49C36813-D3BE-4414-B431-CB8A3BF9E692', @JazykVerze, CAST(0 AS NVARCHAR), DEFAULT, DEFAULT, DEFAULT)
END
END
END
IF @IdBankSpoj IS NOT NULL
  UPDATE TabDokladyZbozi SET IDBankSpoj=@IdBankSpoj WHERE ID=@IDDoklad
END
/*finalni UPDATE dokladu*/
IF @ChybaPriImportu=0
BEGIN
EXEC hp_VypCenOZPolozek_IDDokladu @IDDoklad=@IDDoklad, @AktualizaceSlev=1
UPDATE TabDokladyZbozi SET BlokovaniEditoru=NULL
WHERE ID=@IDDoklad
END
/*externi atributy*/
/*--ex. atrb. 1 - typ NVARCHAR(30)*/
SET @ExtAtr1=(SELECT TOP 1 ExtAtr1 FROM dbo.TabUniImportOZ WHERE IDHlavicky=@IDHlavicky AND Chyba IS NULL AND ((@PouzeZaznamyDleLogin=1 AND Autor=SUSER_SNAME())OR(@PouzeZaznamyDleLogin=0)) )
SET @ExtAtr1Nazev=(SELECT TOP 1 ExtAtr1Nazev FROM dbo.TabUniImportOZ WHERE IDHlavicky=@IDHlavicky AND Chyba IS NULL AND ((@PouzeZaznamyDleLogin=1 AND Autor=SUSER_SNAME())OR(@PouzeZaznamyDleLogin=0)) )
IF (@ExtAtr1 IS NOT NULL)AND(@ExtAtr1Nazev IS NOT NULL)
BEGIN
IF (OBJECT_ID('TabDokladyZbozi_EXT','U')IS NOT NULL)AND(COLUMNPROPERTY(OBJECT_ID('TabDokladyZbozi_EXT','U'),'_'+@ExtAtr1Nazev,'AllowsNull')IS NOT NULL)
BEGIN
SET @ExtAtr1Nazev='_' + @ExtAtr1Nazev
IF EXISTS(SELECT ID FROM TabDokladyZbozi_EXT WHERE ID=@IDDoklad)
SET @SQLString='UPDATE TabDokladyZbozi_EXT SET ' + @ExtAtr1Nazev + '=N' + '''' + @ExtAtr1 + '''' + ' WHERE ID=' + CAST(@IDDoklad AS NVARCHAR(10))
ELSE
SET @SQLString='INSERT TabDokladyZbozi_EXT(ID, ' + @ExtAtr1Nazev + ') VALUES(' + CAST(@IDDoklad AS NVARCHAR(10)) + ', N' + '''' + @ExtAtr1 + '''' + ')'
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
SET @ExtAtr2=(SELECT TOP 1 ExtAtr2 FROM dbo.TabUniImportOZ WHERE IDHlavicky=@IDHlavicky AND Chyba IS NULL AND ((@PouzeZaznamyDleLogin=1 AND Autor=SUSER_SNAME())OR(@PouzeZaznamyDleLogin=0)) )
SET @ExtAtr2Nazev=(SELECT TOP 1 ExtAtr2Nazev FROM dbo.TabUniImportOZ WHERE IDHlavicky=@IDHlavicky AND Chyba IS NULL AND ((@PouzeZaznamyDleLogin=1 AND Autor=SUSER_SNAME())OR(@PouzeZaznamyDleLogin=0)) )
IF (@ExtAtr2 IS NOT NULL)AND(@ExtAtr2Nazev IS NOT NULL)
IF (OBJECT_ID('TabDokladyZbozi_EXT','U')IS NOT NULL)AND(COLUMNPROPERTY(OBJECT_ID('TabDokladyZbozi_EXT','U'),'_'+@ExtAtr2Nazev,'AllowsNull')IS NOT NULL)
BEGIN
SET @ExtAtr2Nazev='_' + @ExtAtr2Nazev
IF EXISTS(SELECT ID FROM TabDokladyZbozi_EXT WHERE ID=@IDDoklad)
SET @SQLString='UPDATE TabDokladyZbozi_EXT SET ' + @ExtAtr2Nazev + '=N' + '''' + @ExtAtr2 + '''' + ' WHERE ID=' + CAST(@IDDoklad AS NVARCHAR(10))
ELSE
SET @SQLString='INSERT TabDokladyZbozi_EXT(ID, ' + @ExtAtr2Nazev + ') VALUES(' + CAST(@IDDoklad AS NVARCHAR(10)) + ', N' + '''' + @ExtAtr2 + '''' + ')'
EXECUTE sp_executesql @SQLString
END
ELSE
BEGIN
SET @ChybaPriImportu=1
IF @TextChybyImportu<>'' SET @TextChybyImportu=@TextChybyImportu + ' | '
SET @TextChybyImportu = @TextChybyImportu + dbo.hpf_UniImportHlasky('15364319-B20F-4D65-8900-391DE8D4C52F', @JazykVerze, '_'+@ExtAtr2Nazev, DEFAULT, DEFAULT, DEFAULT)
END
/*--ex. atrb. 3 - typ DATETIME*/
SET @ExtAtr3=(SELECT TOP 1 ExtAtr3 FROM dbo.TabUniImportOZ WHERE IDHlavicky=@IDHlavicky AND Chyba IS NULL AND ((@PouzeZaznamyDleLogin=1 AND Autor=SUSER_SNAME())OR(@PouzeZaznamyDleLogin=0)) )
SET @ExtAtr3Nazev=(SELECT TOP 1 ExtAtr3Nazev FROM dbo.TabUniImportOZ WHERE IDHlavicky=@IDHlavicky AND Chyba IS NULL AND ((@PouzeZaznamyDleLogin=1 AND Autor=SUSER_SNAME())OR(@PouzeZaznamyDleLogin=0)) )
IF (@ExtAtr3 IS NOT NULL)AND(@ExtAtr3Nazev IS NOT NULL)
IF (OBJECT_ID('TabDokladyZbozi_EXT','U')IS NOT NULL)AND(COLUMNPROPERTY(OBJECT_ID('TabDokladyZbozi_EXT','U'),'_'+@ExtAtr3Nazev,'AllowsNull')IS NOT NULL)
BEGIN
SET @ExtAtr3Nazev='_' + @ExtAtr3Nazev
IF EXISTS(SELECT ID FROM TabDokladyZbozi_EXT WHERE ID=@IDDoklad)
SET @SQLString='UPDATE TabDokladyZbozi_EXT SET ' + @ExtAtr3Nazev + '=' + '''' + CONVERT(NVARCHAR(10),@ExtAtr3, 112) + '''' + ' WHERE ID=' + CAST(@IDDoklad AS NVARCHAR(10))
ELSE
SET @SQLString='INSERT TabDokladyZbozi_EXT(ID, ' + @ExtAtr3Nazev + ') VALUES(' + CAST(@IDDoklad AS NVARCHAR(10)) + ', ' + '''' + CONVERT(NVARCHAR(10),@ExtAtr3, 112) + '''' + ')'
EXECUTE sp_executesql @SQLString
END
ELSE
BEGIN
SET @ChybaPriImportu=1
IF @TextChybyImportu<>'' SET @TextChybyImportu=@TextChybyImportu + ' | '
SET @TextChybyImportu = @TextChybyImportu + dbo.hpf_UniImportHlasky('15364319-B20F-4D65-8900-391DE8D4C52F', @JazykVerze, '_'+@ExtAtr3Nazev, DEFAULT, DEFAULT, DEFAULT)
END
/*--ex. atrb. 4 - typ NUMERIC*/
SET @ExtAtr4=(SELECT TOP 1 ExtAtr4 FROM dbo.TabUniImportOZ WHERE IDHlavicky=@IDHlavicky AND Chyba IS NULL AND ((@PouzeZaznamyDleLogin=1 AND Autor=SUSER_SNAME())OR(@PouzeZaznamyDleLogin=0)) )
SET @ExtAtr4Nazev=(SELECT TOP 1 ExtAtr4Nazev FROM dbo.TabUniImportOZ WHERE IDHlavicky=@IDHlavicky AND Chyba IS NULL AND ((@PouzeZaznamyDleLogin=1 AND Autor=SUSER_SNAME())OR(@PouzeZaznamyDleLogin=0)) )
IF (@ExtAtr4 IS NOT NULL)AND(@ExtAtr4Nazev IS NOT NULL)
IF (OBJECT_ID('TabDokladyZbozi_EXT','U')IS NOT NULL)AND(COLUMNPROPERTY(OBJECT_ID('TabDokladyZbozi_EXT','U'),'_'+@ExtAtr4Nazev,'AllowsNull')IS NOT NULL)
BEGIN
SET @ExtAtr4Nazev='_' + @ExtAtr4Nazev
IF EXISTS(SELECT ID FROM TabDokladyZbozi_EXT WHERE ID=@IDDoklad)
SET @SQLString='UPDATE TabDokladyZbozi_EXT SET ' + @ExtAtr4Nazev + '=' + CAST(@ExtAtr4 AS NVARCHAR(26)) +  ' WHERE ID=' + CAST(@IDDoklad AS NVARCHAR(10))
ELSE
SET @SQLString='INSERT TabDokladyZbozi_EXT(ID, ' + @ExtAtr4Nazev + ') VALUES(' + CAST(@IDDoklad AS NVARCHAR(10)) + ', ' + CAST(@ExtAtr4 AS NVARCHAR(26)) + ')'
EXECUTE sp_executesql @SQLString
END
ELSE
BEGIN
SET @ChybaPriImportu=1
IF @TextChybyImportu<>'' SET @TextChybyImportu=@TextChybyImportu + ' | '
SET @TextChybyImportu = @TextChybyImportu + dbo.hpf_UniImportHlasky('15364319-B20F-4D65-8900-391DE8D4C52F', @JazykVerze, '_'+@ExtAtr4Nazev, DEFAULT, DEFAULT, DEFAULT)
END
SET @ChybaExtAtr=''
EXEC dbo.hpx_UniImport_ZpracujExtAtr
  @ImportIdent=5,
  @IdImpTable=@IdImport,
  @IdTargetTable=@IDDoklad,
  @Chyba=@ChybaExtAtr OUT
IF @ChybaExtAtr<>''
BEGIN
  SET @ChybaPriImportu=1
  IF @TextChybyImportu<>'' SET @TextChybyImportu=@TextChybyImportu + ' | '
  SET @TextChybyImportu = @TextChybyImportu + dbo.hpf_UniImportHlasky('15364319-B20F-4D65-8900-391DE8D4C52F', @JazykVerze, @ChybaExtAtr, DEFAULT, DEFAULT, DEFAULT)
END
IF EXISTS(SELECT 0 FROM TabUniImportOZ WHERE IDHlavicky=@IDHlavicky AND Chyba IS NULL AND Zaloha=0 AND VC=1 AND ISNULL(VyrobniCislo, '') = ''  AND ((@PouzeZaznamyDleLogin=1 AND Autor=SUSER_SNAME())OR(@PouzeZaznamyDleLogin=0))   )
BEGIN
  SET @ChybaPriImportu=1
  IF @TextChybyImportu<>'' SET @TextChybyImportu=@TextChybyImportu + ' | '
  SET @TextChybyImportu = @TextChybyImportu + dbo.hpf_UniImportHlasky('A8C6E221-D1EB-486E-8421-1B256A7A4CC4', @JazykVerze, DEFAULT, DEFAULT, DEFAULT, DEFAULT)
END
IF @ChybaPriImportu=0
BEGIN
SET @ChybaVC=''
EXEC dbo.hpx_UniImport_ZpracujVC_OZ
  @IDHlavicky=@IDHlavicky,
  @IdTargetTable=@IDDoklad,
  @Chyba=@ChybaVC OUT
IF @ChybaVC<>''
BEGIN
  SET @ChybaPriImportu=1
  IF @TextChybyImportu<>'' SET @TextChybyImportu=@TextChybyImportu + ' | '
  SET @TextChybyImportu = @TextChybyImportu + dbo.hpf_UniImportHlasky('FBEDEA05-97AB-49EB-9B06-0C78E7081038', @JazykVerze, @ChybaVC, DEFAULT, DEFAULT, DEFAULT)
END
END
IF (@ChybaPriImportu=0)AND(@DruhPohybuZbo IN(13, 14, 18, 19))
BEGIN
SET @ChybaZaloha=''
EXEC dbo.hpx_UniImport_ZpracujZalohy_OZ
  @IDHlavicky=@IDHlavicky,
  @IdTargetTable=@IDDoklad,
  @Chyba=@ChybaZaloha OUT
IF @ChybaZaloha<>''
BEGIN
  SET @ChybaPriImportu=1
  IF @TextChybyImportu<>'' SET @TextChybyImportu=@TextChybyImportu + ' | '
  SET @TextChybyImportu = @TextChybyImportu + dbo.hpf_UniImportHlasky('06B5F9D2-1ECE-4882-B5C4-E006D5B35BA6', @JazykVerze, @ChybaZaloha, DEFAULT, DEFAULT, DEFAULT)
END
END
IF OBJECT_ID('dbo.epx_UniImportOZ03', 'P') IS NOT NULL EXEC dbo.epx_UniImportOZ03 @IDDoklad
IF @ChybaPriImportu=0 DELETE FROM dbo.TabUniImportOZ WHERE IDHlavicky=@IDHlavicky AND ((@PouzeZaznamyDleLogin=1 AND Autor=SUSER_SNAME())OR(@PouzeZaznamyDleLogin=0)) 
IF @ChybaPriImportu=1
BEGIN
IF @@trancount>0 ROLLBACK TRAN T1
UPDATE dbo.TabUniImportOZ SET Chyba=@TextChybyImportu, DatumImportu=GETDATE() WHERE IDHlavicky=@IDHlavicky AND Chyba IS NULL AND ((@PouzeZaznamyDleLogin=1 AND Autor=SUSER_SNAME())OR(@PouzeZaznamyDleLogin=0)) 
UPDATE TabUniImportOZ SET
  TabUniImportOZ.Chyba=ISNULL(CH.Chyba, N'') + N' ## ' + CAST(ISNULL(TabUniImportOZ.Chyba, N'') AS NVARCHAR(MAX))
FROM @CHYBYPOLOZEK CH
WHERE TabUniImportOZ.ID=CH.ID AND ((@PouzeZaznamyDleLogin=1 AND Autor=SUSER_SNAME())OR(@PouzeZaznamyDleLogin=0)) 
END
ELSE IF @@trancount>0 COMMIT TRAN T1
END TRY
BEGIN CATCH
  UPDATE TabUniImportOZ SET Chyba=ISNULL(CAST(Chyba AS NVARCHAR(MAX)), N'') + N' !! ' + ISNULL(dbo.hf_TextInterniHlasky(ERROR_MESSAGE(), @JazykVerze), N'') + N' ## ' + ISNULL(ERROR_PROCEDURE(), N'') + N' (Ln ' + ISNULL(CAST(ERROR_LINE() AS NVARCHAR), N'') + N')'  WHERE IDHlavicky=@IDHlavicky
END CATCH
FETCH NEXT FROM c INTO @IDHlavicky
IF @@fetch_status<>0 BREAK
END
CLOSE c
DEALLOCATE c
/*KONEC-------------------------------------------------------------------------------------------------*/
GO

