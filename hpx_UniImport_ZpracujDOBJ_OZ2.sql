USE [RayService]
GO

/****** Object:  StoredProcedure [dbo].[hpx_UniImport_ZpracujDOBJ_OZ2]    Script Date: 26.06.2025 10:14:05 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

/*rpObecneImporty.Import*/CREATE PROC [dbo].[hpx_UniImport_ZpracujDOBJ_OZ2]
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

DECLARE @ChybaPriImportu BIT, @TextChybyImportu NVARCHAR(4000), @TextChybyImportuPolozka NVARCHAR(4000), @ErrorCode INT, @IDImport INT, @IDImportPol INT,
        @ChybaExtAtr NVARCHAR(4000)
DECLARE @IDHlavicky NVARCHAR(30), @IdDoklad INT, @RadaDokladu NVARCHAR(3), @Cislo NVARCHAR(17), @CisloOrg INT,
@DatPorizeni DATETIME, @IdSklad NVARCHAR(30), @IDzboSklad INT, @SkupZbo NVARCHAR(3), @RegCis NVARCHAR(30), @IdSkladPol NVARCHAR(30),
@IdPolozky INT, @VstupniCena TINYINT, @Cena NUMERIC(19,6), @Mnozstvi NUMERIC(19,6), @SkladSluzeb NVARCHAR(30), @BarCode NVARCHAR(50),
@IDKmenBarCode INT, @IDKmen INT, @Nuly NVARCHAR(30), @DelkaReg TINYINT, @Zarovnani TINYINT, @I TINYINT,
@StredNakladPol NVARCHAR(30), @CisloNOkruhPol NVARCHAR(15), @CisloZakazkyPol NVARCHAR(15), @EvCisloPol NVARCHAR(20), @CisloZamPol INT,
@Hmotnost NUMERIC(19,6), @PozadDatDod DATETIME, @PotvrzDatDod DATETIME, @StredNaklad NVARCHAR(30),
@CisloNOkruh NVARCHAR(15), @CisloZakazky NVARCHAR(15), @EvCislo NVARCHAR(20), @CisloZam INT, @DIC NVARCHAR(15),
@MU INT, @Prijemce INT, @FormaUhrady NVARCHAR(30), @FormaDopravy NVARCHAR(30), @TerminDodavky NVARCHAR(20),
@Mena NVARCHAR(3), @Kurz NUMERIC(19,6), @JednotkaMeny INT, @SazbaDPHPol NUMERIC(5,2), @PopisDodavky NVARCHAR(40),
@ExterniCislo NVARCHAR(30), @DatumDodavky DATETIME, @TextPolozka BIT, @MJ NVARCHAR(10),
@SlevaSozNa NUMERIC(5,2), @SlevaSkupZbo NUMERIC(5,2), @SlevaZboKmen NUMERIC(5,2), @SlevaZboSklad NUMERIC(5,2), @SlevaOrg NUMERIC(5,2), @NastaveniSlev SMALLINT,
@ICO NVARCHAR(20), @SPZZobraz NVARCHAR(12), @SPZZobrazPol NVARCHAR(12),
@KodPDP NVARCHAR(20), @IdKodPDP INT
DECLARE @ZmenaSozna BIT, @ZmenaSkupZbo BIT, @ZmenaZboKmen BIT, @ZmenaZboSklad BIT, @ZmenaOrg BIT
DECLARE @PopisTxtPol NVARCHAR(MAX)
DECLARE @DotahovatSazbuDPH BIT
DECLARE @DotahovatSazbyImp BIT
DECLARE @RezimMOSS TINYINT, @SamoVyDICDPH NVARCHAR(15), @ZemeDPH NVARCHAR(6)
DECLARE c CURSOR LOCAL FAST_FORWARD FOR
SELECT DISTINCT IDHlavicky FROM dbo.TabUniImportOZ
WHERE DruhPohybuZbo=53 AND Zaloha=0 AND ISNULL(TypDOBJ,0)=1 AND Chyba IS NULL AND ((@PouzeZaznamyDleLogin=1 AND Autor=SUSER_SNAME())OR(@PouzeZaznamyDleLogin=0)) 
OPEN c
WHILE 1=1
BEGIN
FETCH NEXT FROM c INTO @IDHlavicky
IF @@fetch_status<>0 BREAK
BEGIN TRY
BEGIN TRAN T1
SET @IDImport=(SELECT TOP 1 ID FROM dbo.TabUniImportOZ WHERE IDHlavicky=@IDHlavicky AND Chyba IS NULL AND ((@PouzeZaznamyDleLogin=1 AND Autor=SUSER_SNAME())OR(@PouzeZaznamyDleLogin=0)) )
SET @ChybaPriImportu=0
SET @TextChybyImportu = ''
SET @RadaDokladu = NULL
SET @DatPorizeni = NULL
SET @IdSklad = NULL
SET @ErrorCode = 0
SET @CisloOrg = NULL
SET @StredNaklad = NULL
SET @CisloNOkruh = NULL
SET @CisloZakazky = NULL
SET @EvCislo = NULL
SET @SPZZobraz = NULL
SET @CisloZam = NULL
SET @DIC = NULL
SET @MU = NULL
SET @Prijemce = NULL
SET @FormaUhrady = NULL
SET @FormaDopravy = NULL
SET @TerminDodavky = NULL
SET @VstupniCena = NULL
SET @Mena = NULL
SET @Kurz = NULL
SET @JednotkaMeny = NULL
SET @PopisDodavky = NULL
SET @ExterniCislo = NULL
SET @DatumDodavky = NULL
SET @ICO = NULL
SELECT TOP 1 @RadaDokladu = RadaDokladu,
             @DatPorizeni = DatPorizeni,
             @IdSklad = IDSklad,
             @CisloOrg = CisloOrg,
             @StredNaklad = StredNaklad,
             @CisloNOkruh = NOkruhCislo,
             @CisloZakazky = CisloZakazky,
             @EvCislo = EvCislo,
             @SPZZobraz = SPZZobraz,
             @CisloZam = CisloZam,
             @DIC = DIC,
             @MU = MistoUrceni,
             @Prijemce = Prijemce,
             @FormaUhrady = FormaUhrady,
             @FormaDopravy = FormaDopravy,
             @TerminDodavky = TerminDodavky,
             @VstupniCena = ISNULL(VstupniCena, 0),
             @Mena = Mena,
             @Kurz = Kurz,
             @JednotkaMeny = JednotkaMeny,
             @PopisDodavky = PopisDodavky,
             @ExterniCislo = ExterniCislo,
             @DatumDodavky = DatumDodavky,
             @ICO = ICO
FROM TabUniImportOZ
WHERE IDHlavicky = @IDHlavicky AND Zaloha=0 AND Chyba IS NULL AND ((@PouzeZaznamyDleLogin=1 AND Autor=SUSER_SNAME())OR(@PouzeZaznamyDleLogin=0)) 
IF @DatPorizeni IS NULL SET @DatPorizeni=GETDATE()
IF NOT EXISTS(SELECT * FROM TabObdobi WHERE DatumOd<=@DatPorizeni AND DatumDo>=@DatPorizeni AND Uzavreno=0)
BEGIN
SET @ChybaPriImportu=1
IF @TextChybyImportu<>'' SET @TextChybyImportu=@TextChybyImportu + ' | '
SET @TextChybyImportu = @TextChybyImportu + dbo.hpf_UniImportHlasky('6095777A-AEB6-4CDB-A9F7-232286F0B460', @JazykVerze, DEFAULT, DEFAULT, DEFAULT, DEFAULT)
END
IF NOT EXISTS(SELECT * FROM TabDosleObjRada WHERE Rada = @RadaDokladu)
BEGIN
SET @ChybaPriImportu=1
IF @TextChybyImportu<>'' SET @TextChybyImportu=@TextChybyImportu + ' | '
SET @TextChybyImportu = @TextChybyImportu + dbo.hpf_UniImportHlasky('4BD2A71C-633E-4F18-B07E-2180DA7A5CF4', @JazykVerze, @RadaDokladu, DEFAULT, DEFAULT, DEFAULT)
END
SELECT DISTINCT Kurz, Mena, JednotkaMeny FROM dbo.TabUniImportOZ WHERE IDHlavicky=@IDHlavicky AND Chyba IS NULL AND ((@PouzeZaznamyDleLogin=1 AND Autor=SUSER_SNAME())OR(@PouzeZaznamyDleLogin=0)) 
IF @@rowcount>1
  BEGIN
  SET @ChybaPriImportu=1
  IF @TextChybyImportu<>'' SET @TextChybyImportu=@TextChybyImportu + ' | '
  SET @TextChybyImportu = @TextChybyImportu + dbo.hpf_UniImportHlasky('712620C5-2051-4ED1-80E3-BA0F4DE89E4E', @JazykVerze, DEFAULT, DEFAULT, DEFAULT, DEFAULT)
  END
SET @SkladSluzeb=(SELECT ISNULL(SkladSluzeb, 'D4B73E394670455489587358B43F09') FROM TabHGlob)
IF (SELECT RuznySkladNaPolAHla FROM TabHGlob)<>0
IF (SELECT COUNT(DISTINCT CASE WHEN IDSkladPol IS NOT NULL THEN IDSkladPol ELSE IDSklad END)
FROM TabUniImportOZ
WHERE IDHlavicky=@IdHlavicky AND (CASE WHEN IDSkladPol IS NOT NULL THEN IDSkladPol ELSE IDSklad END)<>@SkladSluzeb  AND ((@PouzeZaznamyDleLogin=1 AND Autor=SUSER_SNAME())OR(@PouzeZaznamyDleLogin=0)) )>1
BEGIN
  SET @ChybaPriImportu=1
  IF @TextChybyImportu<>'' SET @TextChybyImportu=@TextChybyImportu + ' | '
  SET @TextChybyImportu = @TextChybyImportu + dbo.hpf_UniImportHlasky('230B4AF1-16CB-4374-A0C1-6929BB8AD0B6', @JazykVerze, DEFAULT, DEFAULT, DEFAULT, DEFAULT)
END
IF @IDSklad IS NULL
  SET @IDSklad=(SELECT SkladSluzeb FROM TabHGlob)
IF @IDSklad IS NOT NULL
BEGIN
IF NOT EXISTS(SELECT * FROM TabStrom WHERE Cislo=@IDSklad)
BEGIN
SET @ChybaPriImportu=1
IF @TextChybyImportu<>'' SET @TextChybyImportu=@TextChybyImportu + ' | '
SET @TextChybyImportu = @TextChybyImportu + dbo.hpf_UniImportHlasky('32E711C5-DB15-414F-BAD7-B513BB576585', @JazykVerze, @IDSklad, DEFAULT, DEFAULT, DEFAULT)
END
END
ELSE
BEGIN
SET @ChybaPriImportu=1
IF @TextChybyImportu<>'' SET @TextChybyImportu=@TextChybyImportu + ' | '
SET @TextChybyImportu = @TextChybyImportu + dbo.hpf_UniImportHlasky('3CE7FAE2-A705-4BC9-8F70-18533C4EB0EE', @JazykVerze, DEFAULT, DEFAULT, DEFAULT, DEFAULT)
END
IF @CisloOrg IS NOT NULL
BEGIN
  IF NOT EXISTS(SELECT * FROM TabCisOrg WHERE CisloOrg=@CisloOrg)
  BEGIN
    SET @ChybaPriImportu=1
    IF @TextChybyImportu<>'' SET @TextChybyImportu=@TextChybyImportu + ' | '
    SET @TextChybyImportu = @TextChybyImportu + dbo.hpf_UniImportHlasky('3D736ACC-09C3-4BA8-A47E-218FD883826A', @JazykVerze, CAST(@CisloOrg AS NVARCHAR(10)), DEFAULT, DEFAULT, DEFAULT)
  END
END
IF @ChybaPriImportu=0
BEGIN
IF @CisloOrg IS NULL
SET @ICO=(SELECT TOP 1 ICO FROM dbo.TabUniImportOZ WHERE IDHlavicky=@IDHlavicky AND Chyba IS NULL AND ((@PouzeZaznamyDleLogin=1 AND Autor=SUSER_SNAME())OR(@PouzeZaznamyDleLogin=0)) )
IF (@CisloOrg IS NULL)AND(@ICO IS NOT NULL)
IF (SELECT COUNT(*) FROM TabCisOrg WHERE ICO=@ICO)=1
SET @CisloOrg=(SELECT CisloOrg FROM TabCisOrg WHERE ICO=@ICO)
END
IF @Mena IS NULL
  SET @Mena=(SELECT Mena FROM TabDosleObjRada WHERE Rada=@RadaDokladu)
IF @Mena IS NOT NULL
  IF @Kurz IS NULL
BEGIN
    SELECT TOP 1 @Kurz=Kurz, @JednotkaMeny=JednotkaMeny FROM TabKurzList WHERE Mena=@Mena AND Datum = (CONVERT([datetime],CONVERT([int],CONVERT([float],@DatPorizeni,0),0),0))
    IF @Kurz IS NULL
      SELECT TOP 1 @Kurz=Kurz, @JednotkaMeny=JednotkaMeny FROM TabKurzList WHERE Mena=@Mena AND Datum<=(CONVERT([datetime],CONVERT([int],CONVERT([float],@DatPorizeni,0),0),0)) ORDER BY Datum DESC
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
IF @ChybaPriImportu = 0
BEGIN
EXEC dbo.hp_DosleObj_PoradoveCislo @RadaDokladu, @DatPorizeni OUT, @Cislo OUT, NULL
EXEC @IdDoklad = [dbo].[hp_DosleObj_NovaHlavicka02]
@Rada=@RadaDokladu,
@DatumPripadu=@DatPorizeni,
@Cislo = @Cislo,
@Sklad = @IDsklad,
@ErrorCode=@ErrorCode OUT,
@ZpusobRET = 0,
@CisloOrg = @CisloOrg
UPDATE TabDosleObjH02 SET
  VstupniCena = @VstupniCena,
  Mena = @Mena,
  Kurz = @Kurz,
  JednotkaMeny = @JednotkaMeny
WHERE ID = @IdDoklad
IF @ErrorCode<>0
BEGIN
SET @ChybaPriImportu=1
IF @TextChybyImportu<>'' SET @TextChybyImportu=@TextChybyImportu + ' | '
SET @TextChybyImportu = @TextChybyImportu + dbo.hpf_UniImportHlasky('8D9B4F78-D3D7-47B7-8B88-8F561CE504AB', @JazykVerze, CAST(@ErrorCode AS NVARCHAR(10)), DEFAULT, DEFAULT, DEFAULT)
END
END
IF @ChybaPriImportu=0
BEGIN
SELECT TOP 1 @RezimMOSS=RezimMOSS, @SamoVyDICDPH=SamoVyDICDPH, @ZemeDPH=ZemeDPH FROM TabUniImportOZ WHERE IDHlavicky=@IDHlavicky AND Chyba IS NULL AND Zaloha=0 AND ((@PouzeZaznamyDleLogin=1 AND Autor=SUSER_SNAME())OR(@PouzeZaznamyDleLogin=0)) 
IF @RezimMOSS IS NULL
  SET @RezimMOSS=(SELECT PrednastaveniRezimuOSS FROM TabDosleObjRada WHERE Rada=@RadaDokladu)
IF @SamoVyDICDPH IS NOT NULL
  IF NOT EXISTS(SELECT * FROM TabDICOrg WHERE CisloOrg=0 AND DIC=@SamoVyDICDPH)
  BEGIN
SET @ChybaPriImportu=1
IF @TextChybyImportu<>'' SET @TextChybyImportu=@TextChybyImportu + ' | '
SET @TextChybyImportu = @TextChybyImportu + dbo.hpf_UniImportHlasky('7929A253-28BB-41B9-B1E7-70A16D6A7E62', @JazykVerze, @SamoVyDICDPH, DEFAULT, DEFAULT, DEFAULT)
  END
  ELSE
    UPDATE TabDosleObjH02 SET
      RezimMOSS=@RezimMOSS
    , SamoVyDICDPH=@SamoVyDICDPH
    , ZemeDPH=@ZemeDPH
    WHERE ID=@IDDoklad
END
DECLARE pol CURSOR LOCAL FAST_FORWARD FOR
SELECT ID, SkupZbo, RegCis, IDSkladPol, Cena, Mnozstvi, BarCode, StredNakladPol, CisloNOkruhPol, CisloZakazkyPol, EvCisloPol, CisloZamPol, Hmotnost,
       PozadDatDod, PotvrzDatDod, SazbaDPHPol, TextPolozka, MJ,
       ISNULL(SlevaSozNa, 0), ISNULL(SlevaSkupZbo, 0), ISNULL(SlevaZboKmen, 0), ISNULL(SlevaZboSklad, 0), ISNULL(SlevaOrg, 0), SPZZobrazPol,
       DotahovatSazby, KodPDP
FROM TabUniImportOZ
WHERE IDHlavicky = @IDHlavicky AND Chyba IS NULL AND VC=0 AND Zaloha=0 AND DruhPohybuZbo = 53 AND ((@PouzeZaznamyDleLogin=1 AND Autor=SUSER_SNAME())OR(@PouzeZaznamyDleLogin=0)) 
OPEN pol
WHILE 1=1
BEGIN
FETCH NEXT FROM pol INTO @IDImportPol, @SkupZbo, @RegCis, @IdSkladPol, @Cena, @Mnozstvi, @BarCode, @StredNakladPol, @CisloNOkruhPol, @CisloZakazkyPol,
                         @EvCisloPol, @CisloZamPol, @Hmotnost, @PozadDatDod, @PotvrzDatDod, @SazbaDPHPol, @TextPolozka, @MJ,
                         @SlevaSozNa, @SlevaSkupZbo, @SlevaZboKmen, @SlevaZboSklad, @SlevaOrg, @SPZZobrazPol, @DotahovatSazbyImp, @KodPDP
IF @@fetch_status<>0 BREAK
IF @MJ IS NOT NULL
  IF NOT EXISTS(SELECT * FROM TabMJ WHERE Kod=@MJ)
    INSERT TabMJ(Kod) VALUES(@MJ)
IF @TextPolozka = 1
BEGIN
IF dbo.hpf_UniImportExistujeSazbaDPH(@SazbaDPHPol, @DatPorizeni) = 0
BEGIN
SET @ChybaPriImportu=1
IF @TextChybyImportu<>'' SET @TextChybyImportu=@TextChybyImportu + ' | '
SET @TextChybyImportu = @TextChybyImportu + dbo.hpf_UniImportHlasky('593FB54F-C1E7-48E4-996E-C499F540EF4F', @JazykVerze, CAST(@SazbaDPHPol AS NVARCHAR(20)), DEFAULT, DEFAULT, DEFAULT)
END
IF @ChybaPriImportu = 0
BEGIN
SET @ErrorCode = 0
EXEC [dbo].[hp_DosleObj_NovaTxtPolozka02]
  @IDDoklad=@IdDoklad,
  @IDPolozky=@IdPolozky OUT,
  @ErrorCode = @ErrorCode OUT,
  @VstupniCena = @VstupniCena,
  @Cena=@Cena,
  @Popis=NULL,
  @SazbaDPH=@SazbaDPHPol,
  @Mnozstvi=@Mnozstvi,
  @MJ=@MJ,
  @TypSlevy = 0,
  @Sleva=0
IF @ErrorCode <> 0
BEGIN
SET @ChybaPriImportu=1
IF @TextChybyImportu<>'' SET @TextChybyImportu=@TextChybyImportu + ' | '
SET @TextChybyImportu = @TextChybyImportu + dbo.hpf_UniImportHlasky('CBB260E6-98CE-439E-BCEB-A2FAD7C025EA', @JazykVerze, CAST(@ErrorCode AS NVARCHAR(10)), DEFAULT, DEFAULT, DEFAULT)
END
IF @ChybaPriImportu = 0
UPDATE TabDosleObjTxtPol02 SET Poznamka=ISNULL(TabUniImportOZ.PoznamkaPol, '')
FROM TabUniImportOZ
WHERE TabDosleObjTxtPol02.ID=@IdPolozky AND TabUniImportOZ.ID=@IDImportPol
SET @PopisTxtPol=(SELECT PopisTxtPol FROM TabUniImportOZ WHERE ID=@IDImportPol)
IF @PopisTxtPol IS NOT NULL
  UPDATE TabDosleObjTxtPol02 SET Popis=@PopisTxtPol WHERE ID=@IdPolozky
IF @StredNakladPol IS NOT NULL
BEGIN
IF NOT EXISTS(SELECT * FROM TabStrom WHERE Cislo=@StredNakladPol)
BEGIN
  SET @ChybaPriImportu=1
  IF @TextChybyImportuPolozka<>'' SET @TextChybyImportuPolozka=@TextChybyImportuPolozka + ' | '
  SET @TextChybyImportuPolozka = @TextChybyImportuPolozka + dbo.hpf_UniImportHlasky('ED5CBFF2-E377-44A7-980C-2929F89AE8ED', @JazykVerze, @StredNakladPol, DEFAULT, DEFAULT, DEFAULT)
END
ELSE
  IF @ChybaPriImportu=0
    UPDATE TabDosleObjTxtPol02 SET IDStredNaklad=(SELECT ID FROM TabStrom WHERE Cislo=@StredNakladPol) WHERE ID=@IdPolozky
END
IF @CisloNOkruhPol IS NOT NULL
BEGIN
IF NOT EXISTS(SELECT * FROM TabNakladovyOkruh WHERE Cislo=@CisloNOkruhPol)
BEGIN
  SET @ChybaPriImportu=1
  IF @TextChybyImportuPolozka<>'' SET @TextChybyImportuPolozka=@TextChybyImportuPolozka + ' | '
  SET @TextChybyImportuPolozka = @TextChybyImportuPolozka + dbo.hpf_UniImportHlasky('0502CA86-715E-479E-AE3E-D197E78E37D7', @JazykVerze, @CisloNOkruhPol, DEFAULT, DEFAULT, DEFAULT)
END
ELSE
  IF @ChybaPriImportu=0
    UPDATE TabDosleObjTxtPol02 SET IDNOkruh=(SELECT ID FROM TabNakladovyOkruh WHERE Cislo=@CisloNOkruhPol) WHERE ID=@IdPolozky
END
IF @CisloZakazkyPol IS NOT NULL
BEGIN
IF NOT EXISTS(SELECT * FROM TabZakazka WHERE CisloZakazky=@CisloZakazkyPol)
BEGIN
SET @ChybaPriImportu=1
IF @TextChybyImportuPolozka<>'' SET @TextChybyImportuPolozka=@TextChybyImportuPolozka + ' | '
SET @TextChybyImportuPolozka = @TextChybyImportuPolozka + dbo.hpf_UniImportHlasky('F8F59726-1E74-4FC0-90BF-94425A2D5019', @JazykVerze, @CisloZakazkyPol, DEFAULT, DEFAULT, DEFAULT)
END
ELSE
  IF @ChybaPriImportu=0
    UPDATE TabDosleObjTxtPol02 SET IDZakazka=(SELECT ID FROM TabZakazka WHERE CisloZakazky=@CisloZakazkyPol) WHERE ID=@IdPolozky
END
IF @EvCisloPol IS NOT NULL
BEGIN
IF NOT EXISTS(SELECT * FROM TabIVozidlo WHERE EvCislo=@EvCisloPol)
BEGIN
  SET @ChybaPriImportu=1
  IF @TextChybyImportuPolozka<>'' SET @TextChybyImportuPolozka=@TextChybyImportuPolozka + ' | '
  SET @TextChybyImportuPolozka = @TextChybyImportuPolozka + dbo.hpf_UniImportHlasky('432E30F9-89CE-4AFD-8960-FFCA1125F1A4', @JazykVerze, @EvCisloPol, DEFAULT, DEFAULT, DEFAULT)
END
ELSE
  IF @ChybaPriImportu=0
    UPDATE TabDosleObjTxtPol02 SET IDVozidlo=(SELECT ID FROM TabIVozidlo WHERE EvCislo=@EvCisloPol) WHERE ID=@IdPolozky
END
ELSE
BEGIN
IF @SPZZobrazPol IS NOT NULL
BEGIN
  SET @EvCisloPol=(SELECT TOP 1 EvCislo FROM TabIVozidlo WHERE SPZZobraz=@SPZZobrazPol)
  IF (@EvCisloPol IS NOT NULL)AND(@ChybaPriImportu=0)
    UPDATE TabDosleObjTxtPol02 SET IDVozidlo=(SELECT ID FROM TabIVozidlo WHERE EvCislo=@EvCisloPol) WHERE ID=@IdPolozky
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
ELSE
  IF @ChybaPriImportu=0
    UPDATE TabDosleObjTxtPol02 SET IDZam=(SELECT ID FROM TabCisZam WHERE Cislo=@CisloZamPol) WHERE ID=@IdPolozky
END
END
END
ELSE
BEGIN
SET @TextChybyImportuPolozka = ''
IF @IdSkladPol IS NULL SET @IdSkladPol = @IdSklad
IF @IdSkladPol IS NOT NULL
IF NOT EXISTS(SELECT * FROM TabStrom WHERE Cislo=@IdSkladPol)
BEGIN
SET @ChybaPriImportu=1
IF @TextChybyImportuPolozka<>'' SET @TextChybyImportuPolozka=@TextChybyImportuPolozka + ' | '
SET @TextChybyImportuPolozka = @TextChybyImportuPolozka + dbo.hpf_UniImportHlasky('32E711C5-DB15-414F-BAD7-B513BB576585', @JazykVerze, @IdSkladPol, DEFAULT, DEFAULT, DEFAULT)
END
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
IF LEN(@SkupZbo)=1 SET @SkupZbo=N'00' + @SkupZbo
IF LEN(@SkupZbo)=2 SET @SkupZbo=N'0'  + @SkupZbo
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
IF NOT EXISTS(SELECT * FROM TabStavSkladu
              LEFT OUTER JOIN TabKmenZbozi ON TabStavSkladu.IDKmenZbozi=TabKmenZbozi.ID
              WHERE TabStavSkladu.IDSklad = @IdSkladPol
              AND TabKmenZbozi.RegCis = @RegCis AND TabKmenZbozi.SkupZbo=@SkupZbo)
  IF @ChybaPriImportu=0
    INSERT TabStavSkladu(IDSklad, IDKmenZbozi) VALUES (@IdSkladPol, @IDKmen)
IF (SELECT Blokovano FROM TabStavSkladu WHERE IDKmenZbozi=@IDKmen AND IDSklad=@IdSkladPol)=1
BEGIN
  SET @ChybaPriImportu=1
  IF @TextChybyImportuPolozka<>'' SET @TextChybyImportuPolozka=@TextChybyImportuPolozka + ' | '
  SET @TextChybyImportuPolozka = @TextChybyImportuPolozka + dbo.hpf_UniImportHlasky('418528D0-4D6E-413D-9F55-EA894243F674', @JazykVerze, ISNULL(CAST(@SkupZbo AS NVARCHAR(20)),'<!!>'), ISNULL(@RegCis, '<!!>'), DEFAULT, DEFAULT)
END
IF dbo.hpf_UniImportExistujeSazbaDPH(@SazbaDPHPol, @DatPorizeni) = 0
BEGIN
SET @ChybaPriImportu=1
IF @TextChybyImportu<>'' SET @TextChybyImportu=@TextChybyImportu + ' | '
SET @TextChybyImportu = @TextChybyImportu + dbo.hpf_UniImportHlasky('593FB54F-C1E7-48E4-996E-C499F540EF4F', @JazykVerze, CAST(@SazbaDPHPol AS NVARCHAR(20)), DEFAULT, DEFAULT, DEFAULT)
END
IF @ChybaPriImportu = 0
BEGIN
SET @ErrorCode = 0
SET @IDzboSklad = (SELECT S.ID FROM TabStavSkladu S JOIN TabKmenZbozi K ON S.IDKmenZBozi=K.ID WHERE K.SkupZbo = @SkupZbo AND K.RegCis=@RegCis AND S.IDSklad=@IdSkladPol)
IF @SazbaDPHPol IS NOT NULL
  SET @DotahovatSazbuDPH=0
ELSE
  SET @DotahovatSazbuDPH=1
IF @DotahovatSazbyImp IS NOT NULL
SET @DotahovatSazbuDPH=@DotahovatSazbyImp
EXEC [dbo].[hp_DosleObj_NovaPolozka02]
@IdDoklad=@IdDoklad,
@IdZboSklad=@IDZboSklad,
@BarCode=@BarCode,
@NewID = @IdPolozky OUT,
@ErrorCode = @ErrorCode OUT,
@ZpusobRET = 2,
@PovolitDuplicitu = 1,
@PovolitBlokovane = 0,
@TypMnozstvi = NULL,
@Mnozstvi = @Mnozstvi,
@IDVyrobek = NULL,
@StinJeVyrobek = NULL,
@PomerDV = 1,
@Cena = @Cena,
@VstupniCena = @VstupniCena,
@DotahovatSazbuDPH=@DotahovatSazbuDPH,
@VnucenaSazbaDPH=@SazbaDPHPol,
@VnucenaMJ=@MJ
IF @ErrorCode <> 0
BEGIN
SET @ChybaPriImportu=1
IF @TextChybyImportu<>'' SET @TextChybyImportu=@TextChybyImportu + ' | '
SET @TextChybyImportu = @TextChybyImportu + dbo.hpf_UniImportHlasky('CBB260E6-98CE-439E-BCEB-A2FAD7C025EA', @JazykVerze, CAST(@ErrorCode AS NVARCHAR(10)), DEFAULT, DEFAULT, DEFAULT)
END
IF (@SlevaSozNa<>0) OR (@SlevaSkupZbo<>0) OR (@SlevaZboKmen<>0) OR (@SlevaZboSklad<>0) OR (@SlevaOrg<>0)
BEGIN
SET @ZmenaSozna=0
SET @ZmenaSkupZbo=0
SET @ZmenaZboKmen=0
SET @ZmenaZboSklad=0
SET @ZmenaOrg=0
IF @SlevaSozNa<>0 SET @ZmenaSozna=1
IF @SlevaSkupZbo<>0 SET @ZmenaSkupZbo=1
IF @SlevaZboKmen<>0 SET @ZmenaZboKmen=1
IF @SlevaZboSklad<>0 SET @ZmenaZboSklad=1
IF @SlevaOrg<>0 SET @ZmenaOrg=1
EXEC dbo.hp_DosleObj_NastavSlevuMnozstviDPHPolozky02
@IDPolozka = @IdPolozky
, @ErrorCode = @ErrorCode OUT
, @ZmenaMnozstvi = 0
, @NewMnozstvi = NULL
, @ZmenaSozna = @ZmenaSozna
, @NewSlevaSozna = @SlevaSozNa
, @ZmenaSkupZbo = @ZmenaSkupZbo
, @NewSlevaSkupZbo = @SlevaSkupZbo
, @ZmenaZboKmen = @ZmenaZboKmen
, @NewSlevaZboKmen = @SlevaZboKmen
, @ZmenaZboSklad = @ZmenaZboSklad
, @NewSlevaZboSklad = @SlevaZboSklad
, @ZmenaOrg = @ZmenaOrg
, @NewSlevaOrg = @SlevaOrg
, @ZmenaTermin = 0
, @NewSlevaTermin = NULL
, @ZmenaCastka = 0
, @NewSlevaCastka = NULL
, @ZmenaDPH = 0
, @NewSazbaDPH = NULL
END
END
IF @ChybaPriImportu = 0
UPDATE TabDosleObjR02 SET Poznamka=ISNULL(TabUniImportOZ.PoznamkaPol, '')
FROM TabUniImportOZ
WHERE TabDosleObjR02.ID=@IdPolozky AND TabUniImportOZ.ID=@IDImportPol
IF @StredNakladPol IS NOT NULL
BEGIN
IF NOT EXISTS(SELECT * FROM TabStrom WHERE Cislo=@StredNakladPol)
BEGIN
  SET @ChybaPriImportu=1
  IF @TextChybyImportuPolozka<>'' SET @TextChybyImportuPolozka=@TextChybyImportuPolozka + ' | '
  SET @TextChybyImportuPolozka = @TextChybyImportuPolozka + dbo.hpf_UniImportHlasky('ED5CBFF2-E377-44A7-980C-2929F89AE8ED', @JazykVerze, @StredNakladPol, DEFAULT, DEFAULT, DEFAULT)
END
ELSE
  IF @ChybaPriImportu=0
    UPDATE TabDosleObjR02 SET IDStredNaklad=(SELECT ID FROM TabStrom WHERE Cislo=@StredNakladPol) WHERE ID=@IdPolozky
END
IF @CisloNOkruhPol IS NOT NULL
BEGIN
IF NOT EXISTS(SELECT * FROM TabNakladovyOkruh WHERE Cislo=@CisloNOkruhPol)
BEGIN
  SET @ChybaPriImportu=1
  IF @TextChybyImportuPolozka<>'' SET @TextChybyImportuPolozka=@TextChybyImportuPolozka + ' | '
  SET @TextChybyImportuPolozka = @TextChybyImportuPolozka + dbo.hpf_UniImportHlasky('0502CA86-715E-479E-AE3E-D197E78E37D7', @JazykVerze, @CisloNOkruhPol, DEFAULT, DEFAULT, DEFAULT)
END
ELSE
  IF @ChybaPriImportu=0
    UPDATE TabDosleObjR02 SET IDNOkruh=(SELECT ID FROM TabNakladovyOkruh WHERE Cislo=@CisloNOkruhPol) WHERE ID=@IdPolozky
END
IF @CisloZakazkyPol IS NOT NULL
BEGIN
IF NOT EXISTS(SELECT * FROM TabZakazka WHERE CisloZakazky=@CisloZakazkyPol)
BEGIN
SET @ChybaPriImportu=1
IF @TextChybyImportuPolozka<>'' SET @TextChybyImportuPolozka=@TextChybyImportuPolozka + ' | '
SET @TextChybyImportuPolozka = @TextChybyImportuPolozka + dbo.hpf_UniImportHlasky('F8F59726-1E74-4FC0-90BF-94425A2D5019', @JazykVerze, @CisloZakazkyPol, DEFAULT, DEFAULT, DEFAULT)
END
ELSE
  IF @ChybaPriImportu=0
    UPDATE TabDosleObjR02 SET IDZakazka=(SELECT ID FROM TabZakazka WHERE CisloZakazky=@CisloZakazkyPol) WHERE ID=@IdPolozky
END
IF @EvCisloPol IS NOT NULL
BEGIN
IF NOT EXISTS(SELECT * FROM TabIVozidlo WHERE EvCislo=@EvCisloPol)
BEGIN
  SET @ChybaPriImportu=1
  IF @TextChybyImportuPolozka<>'' SET @TextChybyImportuPolozka=@TextChybyImportuPolozka + ' | '
  SET @TextChybyImportuPolozka = @TextChybyImportuPolozka + dbo.hpf_UniImportHlasky('432E30F9-89CE-4AFD-8960-FFCA1125F1A4', @JazykVerze, @EvCisloPol, DEFAULT, DEFAULT, DEFAULT)
END
ELSE
  IF @ChybaPriImportu=0
    UPDATE TabDosleObjR02 SET IDVozidlo=(SELECT ID FROM TabIVozidlo WHERE EvCislo=@EvCisloPol) WHERE ID=@IdPolozky
END
ELSE
BEGIN
IF @SPZZobrazPol IS NOT NULL
BEGIN
  SET @EvCisloPol=(SELECT TOP 1 EvCislo FROM TabIVozidlo WHERE SPZZobraz=@SPZZobrazPol)
  IF (@EvCisloPol IS NOT NULL)AND(@ChybaPriImportu=0)
    UPDATE TabDosleObjR02 SET IDVozidlo=(SELECT ID FROM TabIVozidlo WHERE EvCislo=@EvCisloPol) WHERE ID=@IdPolozky
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
ELSE
  IF @ChybaPriImportu=0
    UPDATE TabDosleObjR02 SET IDZam=(SELECT ID FROM TabCisZam WHERE Cislo=@CisloZamPol) WHERE ID=@IdPolozky
END
IF @BarCode IS NOT NULL
BEGIN
  IF EXISTS(SELECT * FROM TabBarCodeZbo WHERE BarCode=@BarCode AND IDKmenZbo=@IDKmen)
    UPDATE TabDosleObjR02 SET BarCode=@BarCode WHERE ID=@IdPolozky
END
ELSE
BEGIN
  UPDATE TabDosleObjR02 SET BarCode=(SELECT TOP 1 BarCode FROM TabBarCodeZbo WHERE IDKmenZbo=@IDKmen AND Prednastaveno=1 ORDER BY Porizeno DESC)
  WHERE ID=@IdPolozky
END
IF @ChybaPriImportu=0
BEGIN
  UPDATE TabDosleObjR02 SET
    NazevSozNa1=ISNULL(TabUniImportOZ.NazevSozNa1, ''),
    NazevSozNa2=ISNULL(TabUniImportOZ.NazevSozNa2, ''),
    NazevSozNa3=ISNULL(TabUniImportOZ.NazevSozNa3, '')
  FROM TabUniImportOZ
  WHERE TabDosleObjR02.ID=@IdPolozky AND TabUniImportOZ.ID=@IDImportPol
END
IF @ChybaPriImportu=0
BEGIN
  IF @Hmotnost IS NULL
  BEGIN
    SET @Hmotnost = (SELECT Hmotnost FROM TabKmenZbozi WHERE ID = @IDKmen)
    IF @Hmotnost <> 0 SET @Hmotnost = @Hmotnost * @Mnozstvi
  END
  IF @Hmotnost IS NULL SET @Hmotnost = 0
  UPDATE TabDosleObjR02 SET
    Hmotnost = @Hmotnost
  WHERE ID=@IdPolozky
END
IF @ChybaPriImportu=0
BEGIN
  UPDATE TabDosleObjR02 SET
    PozadDatDod = @PozadDatDod,
    PotvrzDatDod = @PotvrzDatDod
  WHERE ID=@IdPolozky
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
    UPDATE TabDosleObjR02 SET IDKodPDP=@IdKodPDP WHERE ID=@IdPolozky
END
SET @ChybaExtAtr=''
EXEC dbo.hpx_UniImport_ZpracujExtAtr
  @ImportIdent=5,
  @IdImpTable=@IDImportPol,
  @IdTargetTable=@IDPolozky,
  @Chyba=@ChybaExtAtr OUT,
  @Polozky=1
IF @ChybaExtAtr<>''
BEGIN
  SET @ChybaPriImportu=1
  IF @TextChybyImportu<>'' SET @TextChybyImportu=@TextChybyImportu + ' | '
  SET @TextChybyImportu = @TextChybyImportu + dbo.hpf_UniImportHlasky('15364319-B20F-4D65-8900-391DE8D4C52F', @JazykVerze, @ChybaExtAtr, DEFAULT, DEFAULT, DEFAULT)
END
END
IF @TextChybyImportuPolozka<>''
BEGIN
  IF @TextChybyImportu<>'' SET @TextChybyImportu=@TextChybyImportu + ' | '
  SET @TextChybyImportu=@TextChybyImportu + @TextChybyImportuPolozka
END
END
DEALLOCATE pol
UPDATE TabDosleObjH02 SET
  VerejnaPoznamka =ISNULL(TabUniImportOZ.Poznamka, '')
 ,VerejnaPoznamka2=ISNULL(TabUniImportOZ.Text1, '')
 ,VerejnaPoznamka3=ISNULL(TabUniImportOZ.Text2, '')
 ,VerejnaPoznamka4=ISNULL(TabUniImportOZ.Text3, '')
FROM TabUniImportOZ
WHERE TabDosleObjH02.ID=@IDDoklad AND TabUniImportOZ.ID=@IDImport
IF @PopisDodavky IS NOT NULL
  UPDATE TabDosleObjH02 SET PopisDodavky = @PopisDodavky WHERE ID=@IDDoklad
IF @ExterniCislo IS NOT NULL
  UPDATE TabDosleObjH02 SET ExterniCislo = @ExterniCislo WHERE ID=@IDDoklad
IF @DatumDodavky IS NOT NULL
  UPDATE TabDosleObjH02 SET DatumDodavky = @DatumDodavky WHERE ID=@IDDoklad
IF @StredNaklad IS NOT NULL
BEGIN
IF NOT EXISTS(SELECT * FROM TabStrom WHERE Cislo=@StredNaklad)
BEGIN
  SET @ChybaPriImportu=1
  IF @TextChybyImportu<>'' SET @TextChybyImportu=@TextChybyImportu + ' | '
  SET @TextChybyImportu = @TextChybyImportu + dbo.hpf_UniImportHlasky('ED5CBFF2-E377-44A7-980C-2929F89AE8ED', @JazykVerze, @StredNaklad, DEFAULT, DEFAULT, DEFAULT)
END
ELSE
  IF @ChybaPriImportu=0
    UPDATE TabDosleObjH02 SET IDStredNaklad=(SELECT ID FROM TabStrom WHERE Cislo=@StredNaklad) WHERE ID=@IDDoklad
END
IF @CisloNOkruh IS NOT NULL
BEGIN
IF NOT EXISTS(SELECT * FROM TabNakladovyOkruh WHERE Cislo=@CisloNOkruh)
BEGIN
  SET @ChybaPriImportu=1
  IF @TextChybyImportu<>'' SET @TextChybyImportu=@TextChybyImportu + ' | '
  SET @TextChybyImportu = @TextChybyImportu + dbo.hpf_UniImportHlasky('0502CA86-715E-479E-AE3E-D197E78E37D7', @JazykVerze, @CisloNOkruh, DEFAULT, DEFAULT, DEFAULT)
END
ELSE
  IF @ChybaPriImportu=0
    UPDATE TabDosleObjH02 SET IDNOkruh=(SELECT ID FROM TabNakladovyOkruh WHERE Cislo=@CisloNOkruh) WHERE ID=@IDDoklad
END
IF @CisloZakazky IS NOT NULL
BEGIN
IF NOT EXISTS(SELECT * FROM TabZakazka WHERE CisloZakazky=@CisloZakazky)
BEGIN
SET @ChybaPriImportu=1
IF @TextChybyImportu<>'' SET @TextChybyImportu=@TextChybyImportu + ' | '
SET @TextChybyImportu = @TextChybyImportu + dbo.hpf_UniImportHlasky('F8F59726-1E74-4FC0-90BF-94425A2D5019', @JazykVerze, @CisloZakazky, DEFAULT, DEFAULT, DEFAULT)
END
ELSE
  IF @ChybaPriImportu=0
    UPDATE TabDosleObjH02 SET IDZakazka=(SELECT ID FROM TabZakazka WHERE CisloZakazky=@CisloZakazky) WHERE ID=@IDDoklad
END
IF @EvCislo IS NOT NULL
BEGIN
IF NOT EXISTS(SELECT * FROM TabIVozidlo WHERE EvCislo=@EvCislo)
BEGIN
  SET @ChybaPriImportu=1
  IF @TextChybyImportu<>'' SET @TextChybyImportu=@TextChybyImportu + ' | '
  SET @TextChybyImportu = @TextChybyImportu + dbo.hpf_UniImportHlasky('432E30F9-89CE-4AFD-8960-FFCA1125F1A4', @JazykVerze, @EvCislo, DEFAULT, DEFAULT, DEFAULT)
END
ELSE
  IF @ChybaPriImportu=0
    UPDATE TabDosleObjH02 SET IDVozidlo=(SELECT ID FROM TabIVozidlo WHERE EvCislo=@EvCislo) WHERE ID=@IDDoklad
END
ELSE
BEGIN
IF @SPZZobraz IS NOT NULL
  SET @EvCislo=(SELECT TOP 1 EvCislo FROM TabIVozidlo WHERE SPZZobraz=@SPZZobraz)
IF @EvCislo IS NOT NULL
  UPDATE TabDosleObjH02 SET IDVozidlo=(SELECT ID FROM TabIVozidlo WHERE EvCislo=@EvCislo) WHERE ID=@IDDoklad
END
IF @CisloZam IS NOT NULL
BEGIN
IF NOT EXISTS(SELECT * FROM TabCisZam WHERE Cislo=@CisloZam)
BEGIN
  SET @ChybaPriImportu=1
  IF @TextChybyImportu<>'' SET @TextChybyImportu=@TextChybyImportu + ' | '
  SET @TextChybyImportu = @TextChybyImportu + dbo.hpf_UniImportHlasky('F5003BED-6EAD-46D1-8C67-305A0EA61705', @JazykVerze, CAST(@CisloZam AS NVARCHAR(20)), DEFAULT, DEFAULT, DEFAULT)
END
ELSE
  IF @ChybaPriImportu=0
    UPDATE TabDosleObjH02 SET IDZam=(SELECT ID FROM TabCisZam WHERE Cislo=@CisloZam) WHERE ID=@IDDoklad
END
IF @DIC IS NOT NULL
BEGIN
IF NOT EXISTS(SELECT * FROM TabDICOrg WHERE DIC=@DIC AND CisloOrg=@CisloOrg)
BEGIN
  SET @ChybaPriImportu=1
  IF @TextChybyImportu<>'' SET @TextChybyImportu=@TextChybyImportu + ' | '
  SET @TextChybyImportu = @TextChybyImportu + dbo.hpf_UniImportHlasky('B151D137-D762-474A-86B3-A051D8EDE3AD', @JazykVerze, @DIC, CAST(@CisloOrg AS NVARCHAR(10)), DEFAULT, DEFAULT)
END
ELSE
  IF @ChybaPriImportu=0
    UPDATE TabDosleObjH02 SET DIC=@DIC WHERE ID=@IDDoklad
END
IF @MU IS NOT NULL
BEGIN
IF NOT EXISTS(SELECT * FROM TabCisOrg WHERE CisloOrg=@MU)
BEGIN
  SET @ChybaPriImportu=1
  IF @TextChybyImportu<>'' SET @TextChybyImportu=@TextChybyImportu + ' | '
  SET @TextChybyImportu = @TextChybyImportu + dbo.hpf_UniImportHlasky('49A578B9-B0F4-46A7-9C0A-DC46446E702D', @JazykVerze, CAST(@MU AS NVARCHAR(10)), DEFAULT, DEFAULT, DEFAULT)
END
ELSE
  IF @ChybaPriImportu=0
    UPDATE TabDosleObjH02 SET MistoUrceni=@MU WHERE ID=@IDDoklad
END
IF @Prijemce IS NOT NULL
BEGIN
IF NOT EXISTS(SELECT * FROM TabCisOrg WHERE CisloOrg=@Prijemce)
BEGIN
SET @ChybaPriImportu=1
IF @TextChybyImportu<>'' SET @TextChybyImportu=@TextChybyImportu + ' | '
SET @TextChybyImportu = @TextChybyImportu + dbo.hpf_UniImportHlasky('C64F39A3-1A49-4435-8F66-45F38017D9F6', @JazykVerze, CAST(@Prijemce AS NVARCHAR(10)), DEFAULT, DEFAULT, DEFAULT)
END
ELSE
  IF @ChybaPriImportu=0
    UPDATE TabDosleObjH02 SET Prijemce=@Prijemce WHERE ID=@IDDoklad
END
IF @FormaUhrady IS NOT NULL
BEGIN
IF NOT EXISTS(SELECT * FROM TabFormaUhrady WHERE FormaUhrady=@FormaUhrady)
BEGIN
  SET @ChybaPriImportu=1
  IF @TextChybyImportu<>'' SET @TextChybyImportu=@TextChybyImportu + ' | '
  SET @TextChybyImportu = @TextChybyImportu + dbo.hpf_UniImportHlasky('DF0B2893-2541-4A54-80DD-AC1B907D8648', @JazykVerze, @FormaUhrady, DEFAULT, DEFAULT, DEFAULT)
END
ELSE
  IF @ChybaPriImportu=0
    UPDATE TabDosleObjH02 SET IDFormaUhrady=(SELECT ID FROM TabFormaUhrady WHERE FormaUhrady=@FormaUhrady) WHERE ID=@IDDoklad
END
IF @FormaDopravy IS NOT NULL
BEGIN
IF NOT EXISTS(SELECT * FROM TabFormaDopravy WHERE FormaDopravy=@FormaDopravy)
  INSERT TabFormaDopravy(FormaDopravy) VALUES(@FormaDopravy)
UPDATE TabDosleObjH02 SET IDFormaDopravy=(SELECT ID FROM TabFormaDopravy WHERE FormaDopravy=@FormaDopravy) WHERE ID=@IDDoklad
END
IF @TerminDodavky IS NOT NULL
UPDATE TabDosleObjH02 SET TerminDodavky=@TerminDodavky WHERE ID=@IDDoklad
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
IF OBJECT_ID('dbo.epx_UniImportOZ03', 'P') IS NOT NULL EXEC dbo.epx_UniImportOZ03 @IDDoklad
IF @ChybaPriImportu=0
DELETE FROM dbo.TabUniImportOZ WHERE IDHlavicky=@IDHlavicky AND Chyba IS NULL AND DruhPohybuZbo = 53 AND ((@PouzeZaznamyDleLogin=1 AND Autor=SUSER_SNAME())OR(@PouzeZaznamyDleLogin=0)) 
IF @ChybaPriImportu=1
BEGIN
IF @@trancount>0 ROLLBACK TRAN T1
UPDATE dbo.TabUniImportOZ SET Chyba=@TextChybyImportu, DatumImportu=GETDATE() WHERE IDHlavicky=@IDHlavicky AND Chyba IS NULL AND ((@PouzeZaznamyDleLogin=1 AND Autor=SUSER_SNAME())OR(@PouzeZaznamyDleLogin=0)) 
END
ELSE
IF @@trancount>0 COMMIT TRAN T1
END TRY
BEGIN CATCH
  UPDATE TabUniImportOZ SET Chyba=ISNULL(CAST(Chyba AS NVARCHAR(MAX)), N'') + N' !! ' + ISNULL(dbo.hf_TextInterniHlasky(ERROR_MESSAGE(), @JazykVerze), N'') + N' ## ' + ISNULL(ERROR_PROCEDURE(), N'') + N' (Ln ' + ISNULL(CAST(ERROR_LINE() AS NVARCHAR), N'') + N')'  WHERE IDHlavicky=@IDHlavicky
END CATCH
END
CLOSE C
DEALLOCATE C
GO

