USE [RayService]
GO

/****** Object:  StoredProcedure [dbo].[hpx_UniImportDenik]    Script Date: 26.06.2025 10:16:41 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

/*rpObecneImporty.Import*/CREATE PROC [dbo].[hpx_UniImportDenik]
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
SET @PocetRadkuImpTabulky=(SELECT COUNT(*) FROM TabUniImportDenik WHERE Chyba IS NULL AND ((@PouzeZaznamyDleLogin=1 AND Autor=SUSER_SNAME())OR(@PouzeZaznamyDleLogin=0)) )
SET @InfoText = dbo.hpf_UniImportHlasky('959B5166-6EEF-44A5-B4AC-DA13F5642C08', @JazykVerze, 'TabUniImportDenik', CAST(@PocetRadkuImpTabulky AS NVARCHAR), DEFAULT, DEFAULT)
IF @InfoText IS NOT NULL
  EXEC dbo.hp_ZapisDoZurnalu 1, 77, @InfoText
IF OBJECT_ID('dbo.epx_UniImportDenik02', 'P') IS NOT NULL EXEC dbo.epx_UniImportDenik02
DECLARE @ChybaPriImportu BIT, @TextChybyImportu NVARCHAR(4000), @TextChybyImportuRadek NVARCHAR(4000), @ChybaExtAtr NVARCHAR(4000),
@ID INT, @InterniVerze INT, @IdDenikImp INT, @SQLString NVARCHAR(4000),
@ExtDoklad NVARCHAR(30), @Sbornik NVARCHAR(3), @CisloDokladu INT, @IdObdobi_DatumOd DATETIME,
@DatumPripad DATETIME, @DatumPorizeno DATETIME, @DatumDUZP DATETIME, @DatumSplatno DATETIME,
@DruhData TINYINT, @IdObdobiStavu_Nazev NVARCHAR(30), @UcetMD NVARCHAR(30), @CastkaMD NUMERIC(19,6),
@CastkaMenaMD NUMERIC(19,6), @UtvarMD NVARCHAR(30), @UcetDAL NVARCHAR(30), @CastkaDAL NUMERIC(19,6),
@CastkaMenaDAL NUMERIC(19,6), @UtvarDAL NVARCHAR(30), @Strana TINYINT, @CisloUcet NVARCHAR(30),
@UcetDPH NVARCHAR(30), @Castka NUMERIC(19,6), @CastkaMena NUMERIC(19,6), @Mena NVARCHAR(3),
@Kurz NUMERIC(19,6), @JednotkaMeny INT, @DatumKurz DATETIME, @Popis NVARCHAR(255), @ParovaciZnak NVARCHAR(20),
@Zaknihovano TINYINT, @Stav TINYINT, @CisloOrg INT, @CisloOrgDOS NVARCHAR(20), @ICOrganizace NVARCHAR(20),
@DICOrg NVARCHAR(15), @Utvar NVARCHAR(30), @CisloZam INT, @CisloZakazky NVARCHAR(15),
@CisloNakladovyOkruh NVARCHAR(15), @IdVozidlo_SPZZobraz NVARCHAR(12), @ExtAtr1 NVARCHAR(30),
@ExtAtr1Nazev NVARCHAR(127), @ExtAtr2 NVARCHAR(255), @ExtAtr2Nazev NVARCHAR(127), @ExtAtr3 DATETIME,
@ExtAtr3Nazev NVARCHAR(127), @ExtAtr4 NUMERIC(19,6), @ExtAtr4Nazev NVARCHAR(127),
@RadekDokladu INT, @CisloDokladuTMP INT, @IDObdobi INT, @IDObdobi_DatumDo DATETIME,
@IdObdobiStavu INT, @IdObdobiStavu_DatumOd DATETIME, @IdObdobiStavu_DatumDo DATETIME,
@NazevOrganizace NVARCHAR(100),
@ParovaciZnakMD NVARCHAR(20), @CisloZamMD INT, @CisloZakazkyMD NVARCHAR(15), @CisloNakladovyOkruhMD NVARCHAR(15),
@ParovaciZnakDAL NVARCHAR(20), @CisloZamDAL INT, @CisloZakazkyDAL NVARCHAR(15), @CisloNakladovyOkruhDAL NVARCHAR(15),
@DatumDoruceni DATETIME,
@MJKV INT, @MnozstviKV NUMERIC(19,6), @KodKV NVARCHAR(4), @PorCisKV NVARCHAR(32), @PorCisPuvKV NVARCHAR(32), @DatumKV DATETIME,
@UcetDPHMD NVARCHAR(30), @UcetDPHDAL NVARCHAR(30), @KodDanoveKlice NVARCHAR(30), @IdDanovyKlic INT,
@KodZbozi NVARCHAR(20), @PlneniDoLimitu BIT, @KOs_Jmeno NVARCHAR(100), @KOs_Prijmeni NVARCHAR(100),
@TypZmeny INT, @OrganizaceTransakce INT, @IdVozidlo_EvCislo NVARCHAR(20),
@PZ2 NVARCHAR(20), @PZ2MD NVARCHAR(20), @PZ2DAL NVARCHAR(20),
@IdObdobiDPH_DatumOd DATETIME, @IdObdobiDPH_DatumDo DATETIME
IF EXISTS(SELECT * FROM TabUniImportDenik WHERE InterniVerze=1 AND Chyba IS NULL AND ((@PouzeZaznamyDleLogin=1 AND Autor=SUSER_SNAME())OR(@PouzeZaznamyDleLogin=0)) )
IF (SELECT COUNT(*) FROM TabDenikIMP)>0
BEGIN
UPDATE dbo.TabUniImportDenik SET Chyba=dbo.hpf_UniImportHlasky('931D605E-1963-4EFB-82B0-2AA700BFB2CE', @JazykVerze, DEFAULT, DEFAULT, DEFAULT, DEFAULT), DatumImportu=GETDATE() WHERE Chyba IS NULL AND InterniVerze=1
RETURN
END
DELETE FROM TabStrukturaImpDen
DECLARE c CURSOR LOCAL FAST_FORWARD FOR
SELECT DISTINCT ExtDoklad
FROM dbo.TabUniImportDenik
WHERE Chyba IS NULL
 AND ((@PouzeZaznamyDleLogin=1 AND Autor=SUSER_SNAME())OR(@PouzeZaznamyDleLogin=0)) 
ORDER BY ExtDoklad ASC
OPEN c
FETCH NEXT FROM c INTO @ExtDoklad
WHILE 1=1
BEGIN
IF (SELECT TOP 1 InterniVerze FROM dbo.TabUniImportDenik WHERE ExtDoklad=@ExtDoklad AND ((@PouzeZaznamyDleLogin=1 AND Autor=SUSER_SNAME())OR(@PouzeZaznamyDleLogin=0)) )=1
BEGIN  /*interni verze=1*/ --------------------------------------------------------------------------------------
IF @ExtDoklad=''
BEGIN
UPDATE dbo.TabUniImportDenik SET Chyba=dbo.hpf_UniImportHlasky('E43A1DAA-76AD-424F-A4A9-C2E4F436E948', @JazykVerze, DEFAULT, DEFAULT, DEFAULT, DEFAULT), DatumImportu=GETDATE() WHERE ExtDoklad=@ExtDoklad AND Chyba IS NULL AND ((@PouzeZaznamyDleLogin=1 AND Autor=SUSER_SNAME())OR(@PouzeZaznamyDleLogin=0)) 
END
ELSE
IF (SELECT COUNT(DISTINCT CisloDokladu)
FROM dbo.TabUniImportDenik
WHERE ISNULL(CisloDokladu, '')<>''
AND ExtDoklad=@ExtDoklad
AND Chyba IS NULL AND ((@PouzeZaznamyDleLogin=1 AND Autor=SUSER_SNAME())OR(@PouzeZaznamyDleLogin=0)) )>1
BEGIN /*nemuzeme importovat, cislo dokladu musi byt nevyplneno a nebo vsude stejne*/
UPDATE dbo.TabUniImportDenik SET Chyba=dbo.hpf_UniImportHlasky('679FFFD7-5C8E-45D1-A4C0-0B5577D28E0E', @JazykVerze, DEFAULT, DEFAULT, DEFAULT, DEFAULT), DatumImportu=GETDATE() WHERE ExtDoklad=@ExtDoklad AND Chyba IS NULL AND ((@PouzeZaznamyDleLogin=1 AND Autor=SUSER_SNAME())OR(@PouzeZaznamyDleLogin=0)) 
END   /*nemuzeme importovat, cislo dokladu musi byt nevyplneno a nebo vsude stejne*/
ELSE
BEGIN /*samotna importni cast*/
SET @TextChybyImportu=''
SET @ChybaPriImportu=0
BEGIN TRAN T1
SET @CisloDokladuTMP=(SELECT ISNULL(MAX(DISTINCT CisloDokladu), 0)+1 FROM TabDenikImp)
SET @RadekDokladu=0
DECLARE r CURSOR LOCAL FAST_FORWARD FOR
SELECT ID, Sbornik, CisloDokladu, IdObdobi_DatumOd, DatumPripad, DatumPorizeno,
DatumDUZP, DatumSplatno, DruhData, IdObdobiStavu_Nazev, UcetMD, CastkaMD, CastkaMenaMD, UtvarMD,
UcetDAL, CastkaDAL, CastkaMenaDAL, UtvarDAL, Strana, CisloUcet, UcetDPH, Castka, CastkaMena,
Mena, Kurz, JednotkaMeny, DatumKurz, Popis, ParovaciZnak, Zaknihovano, Stav, CisloOrg, CisloOrgDOS,
NazevOrganizace, ICOrganizace, DICOrg, Utvar, CisloZam, CisloZakazky, CisloNakladovyOkruh, IdVozidlo_SPZZobraz,
ExtAtr1, ExtAtr1Nazev, ExtAtr2, ExtAtr2Nazev, ExtAtr3, ExtAtr3Nazev, ExtAtr4, ExtAtr4Nazev,
ParovaciZnakMD, ParovaciZnakDAL, CisloZamMD, CisloZamDAL, CisloZakazkyMD, CisloZakazkyDAL, CisloNakladovyOkruhMD, CisloNakladovyOkruhDAL, DatumDoruceni,
MJKV, MnozstviKV, KodKV, PorCisKV, PorCisPuvKV, DatumKV, UcetDPHMD, UcetDPHDAL, KodDanoveKlice,
KodZbozi, PlneniDoLimitu, KOs_Jmeno, KOs_Prijmeni, TypZmeny, OrganizaceTransakce, IdVozidlo_EvCislo,
PZ2, PZ2MD, PZ2DAL, IdObdobiDPH_DatumOd, IdObdobiDPH_DatumDo
FROM dbo.TabUniImportDenik
WHERE ExtDoklad=@ExtDoklad AND Chyba IS NULL
 AND ((@PouzeZaznamyDleLogin=1 AND Autor=SUSER_SNAME())OR(@PouzeZaznamyDleLogin=0)) 
ORDER BY ID ASC
OPEN r
FETCH NEXT FROM r INTO @ID, @Sbornik, @CisloDokladu, @IdObdobi_DatumOd, @DatumPripad,
@DatumPorizeno, @DatumDUZP, @DatumSplatno, @DruhData, @IdObdobiStavu_Nazev, @UcetMD,
@CastkaMD, @CastkaMenaMD, @UtvarMD, @UcetDAL, @CastkaDAL, @CastkaMenaDAL, @UtvarDAL,
@Strana, @CisloUcet, @UcetDPH, @Castka, @CastkaMena, @Mena, @Kurz, @JednotkaMeny,
@DatumKurz, @Popis, @ParovaciZnak, @Zaknihovano, @Stav, @CisloOrg, @CisloOrgDOS,
@NazevOrganizace, @ICOrganizace, @DICOrg, @Utvar, @CisloZam, @CisloZakazky, @CisloNakladovyOkruh,
@IdVozidlo_SPZZobraz, @ExtAtr1, @ExtAtr1Nazev, @ExtAtr2, @ExtAtr2Nazev, @ExtAtr3,
@ExtAtr3Nazev, @ExtAtr4, @ExtAtr4Nazev,
@ParovaciZnakMD, @ParovaciZnakDAL, @CisloZamMD, @CisloZamDAL, @CisloZakazkyMD, @CisloZakazkyDAL, @CisloNakladovyOkruhMD, @CisloNakladovyOkruhDAL, @DatumDoruceni,
@MJKV, @MnozstviKV, @KodKV, @PorCisKV, @PorCisPuvKV, @DatumKV, @UcetDPHMD, @UcetDPHDAL, @KodDanoveKlice, @KodZbozi, @PlneniDoLimitu, @KOs_Jmeno, @KOs_Prijmeni,
@TypZmeny, @OrganizaceTransakce, @IdVozidlo_EvCislo, @PZ2, @PZ2MD, @PZ2DAL, @IdObdobiDPH_DatumOd, @IdObdobiDPH_DatumDo
WHILE 1=1
BEGIN /*zacatek vnitrniho cyklu po radcich*/
SET @TextChybyImportuRadek=''
IF ISNULL(@Sbornik, '')='' SET @Sbornik='IMP'
IF ISNULL(@CisloDokladu, -1)=-1 SET @CisloDokladu=@CisloDokladuTMP
IF (@Stav>0)AND(@IdObdobi_DatumOd IS NULL)
BEGIN
SET @ChybaPriImportu=1
IF @TextChybyImportuRadek<>'' SET @TextChybyImportuRadek=@TextChybyImportuRadek + ' | '
SET @TextChybyImportuRadek = @TextChybyImportuRadek + dbo.hpf_UniImportHlasky('F84081AB-9720-4ED5-8DA1-169392A889A3', @JazykVerze, DEFAULT, DEFAULT, DEFAULT, DEFAULT)
END
ELSE
BEGIN
IF @Stav>0
BEGIN --stav "pocatecni" nebo "koncovy"
SET @IDObdobi=(SELECT ID FROM TabObdobi WHERE DatumOd=@IdObdobi_DatumOd)
SET @IDObdobi_DatumDo=(SELECT DatumDo FROM TabObdobi WHERE ID=@IdObdobi)
IF @IDObdobi IS NULL
BEGIN
SET @ChybaPriImportu=1
IF @TextChybyImportuRadek<>'' SET @TextChybyImportuRadek=@TextChybyImportuRadek + ' | '
SET @TextChybyImportuRadek = @TextChybyImportuRadek + dbo.hpf_UniImportHlasky('190D0742-1538-4EC8-92CB-E95B381EB637', @JazykVerze, DEFAULT, DEFAULT, DEFAULT, DEFAULT)
END
END
ELSE  --stav "bezny"
BEGIN
SET @IdObdobi=(SELECT ID FROM TabObdobi WHERE DatumOd<=@DatumPripad AND DatumDo>=@DatumPripad)
SET @IDObdobi_DatumOd=(SELECT DatumOd FROM TabObdobi WHERE ID=@IdObdobi)
SET @IDObdobi_DatumDo=(SELECT DatumDo FROM TabObdobi WHERE ID=@IdObdobi)
IF @IDObdobi IS NULL
BEGIN
SET @ChybaPriImportu=1
IF @TextChybyImportuRadek<>'' SET @TextChybyImportuRadek=@TextChybyImportuRadek + ' | '
SET @TextChybyImportuRadek = @TextChybyImportuRadek + dbo.hpf_UniImportHlasky('7A4581AF-808D-4148-AFDF-3DBF9F28A7E9', @JazykVerze, DEFAULT, DEFAULT, DEFAULT, DEFAULT)
END
END
END
IF (@DruhData=0)OR(@DruhData=3) SET @DatumSplatno=NULL
IF ((@DruhData=1)OR(@DruhData=2))AND(@DatumSplatno IS NULL)
BEGIN
SET @ChybaPriImportu=1
IF @TextChybyImportuRadek<>'' SET @TextChybyImportuRadek=@TextChybyImportuRadek + ' | '
SET @TextChybyImportuRadek = @TextChybyImportuRadek + dbo.hpf_UniImportHlasky('2E7B0BFD-78EB-404D-B851-41E849707C34', @JazykVerze, DEFAULT, DEFAULT, DEFAULT, DEFAULT)
END
SET @IdDanovyKlic=NULL
IF ISNULL(@KodDanoveKlice, '')<>''
BEGIN
  SET @IdDanovyKlic=(SELECT ID FROM TabDanoveKlice WHERE Kod=@KodDanoveKlice)
  IF @IdDanovyKlic IS NULL
  BEGIN
    SET @ChybaPriImportu=1
    IF @TextChybyImportuRadek<>'' SET @TextChybyImportuRadek=@TextChybyImportuRadek + ' | '
    SET @TextChybyImportuRadek = @TextChybyImportuRadek + dbo.hpf_UniImportHlasky('091A40F2-BE70-4191-86EB-941CD9D78603', @JazykVerze, @KodDanoveKlice, DEFAULT, DEFAULT, DEFAULT)
   END
END
IF ISNULL(@IdObdobiStavu_Nazev, '')<>''
SELECT @IdObdobiStavu=ID,
@IdObdobiStavu_DatumOd=DatumOd,
@IdObdobiStavu_DatumDo=DatumDo
FROM TabObdobiStavu
WHERE Nazev=@IdObdobiStavu_Nazev
IF (ISNULL(@Mena,'')='')
OR((SELECT TOP 1 Kod FROM TabKodMen WHERE HlavniMena=1)=@Mena)
BEGIN
SET @CastkaMenaMD=0
SET @CastkaMenaDAL=0
SET @CastkaMena=0
END
IF @Popis IS NULL SET @Popis=''
IF @ParovaciZnak IS NULL SET @ParovaciZnak=''
IF @ParovaciZnakMD IS NULL SET @ParovaciZnakMD=''
IF @ParovaciZnakDAL IS NULL SET @ParovaciZnakDAL=''
IF @PZ2 IS NULL SET @PZ2=''
IF @PZ2MD IS NULL SET @PZ2MD=''
IF @PZ2DAL IS NULL SET @PZ2DAL=''
IF @CisloOrg IS NULL  --hledame podle CisloOrgDOS
BEGIN
IF ISNULL(@CisloOrgDOS, '')<>''
BEGIN
IF (SELECT COUNT(*) FROM TabCisOrg WHERE CisloOrgDOS=@CisloOrgDOS)=1
SET @CisloOrg=(SELECT CisloOrg FROM TabCisOrg WHERE CisloOrgDOS=@CisloOrgDOS)
ELSE
BEGIN
IF (SELECT COUNT(*) FROM TabCisOrg WHERE CisloOrgDOS=@CisloOrgDOS)>1
BEGIN
SET @ChybaPriImportu=1
IF @TextChybyImportuRadek<>'' SET @TextChybyImportuRadek=@TextChybyImportuRadek + ' | '
SET @TextChybyImportuRadek = @TextChybyImportuRadek + dbo.hpf_UniImportHlasky('A70E1DBE-14E1-4F84-B1CB-F33929AD57EC', @JazykVerze, ISNULL(@CisloOrgDOS, N'<!!>'), DEFAULT, DEFAULT, DEFAULT)
END
END
END
ELSE
BEGIN  --hledame podle ICO
IF ISNULL(@ICOrganizace, '')<>''
BEGIN
IF (SELECT COUNT(*) FROM TabCisOrg WHERE ICO=@ICOrganizace)>0
BEGIN
IF (SELECT COUNT(*) FROM TabCisOrg WHERE ICO=@ICOrganizace)=1
SET @CisloOrg=(SELECT CisloOrg FROM TabCisOrg WHERE ICO=@ICOrganizace)
IF @CisloOrg IS NULL
IF (SELECT COUNT(*) FROM TabCisOrg WHERE ICO=@ICOrganizace AND Stav=0)=1
SET @CisloOrg=(SELECT CisloOrg FROM TabCisOrg WHERE ICO=@ICOrganizace AND Stav=0)
IF @CisloOrg IS NULL
IF (SELECT COUNT(*) FROM TabCisOrg WHERE ICO=@ICOrganizace AND Stav=0 AND Fakturacni=1)=1
SET @CisloOrg=(SELECT CisloOrg FROM TabCisOrg WHERE ICO=@ICOrganizace AND Stav=0 AND Fakturacni=1)
IF @CisloOrg IS NULL
BEGIN
SET @ChybaPriImportu=1
IF @TextChybyImportuRadek<>'' SET @TextChybyImportuRadek=@TextChybyImportuRadek + ' | '
SET @TextChybyImportuRadek = @TextChybyImportuRadek + dbo.hpf_UniImportHlasky('35084677-DDAC-4840-B3B1-94693ED9D29C', @JazykVerze, ISNULL(@ICOrganizace, N'<!!>'), DEFAULT, DEFAULT, DEFAULT)
END
END
END
END
END
SET @RadekDokladu=(SELECT ISNULL(MAX(CisloRadku), 0) + 1 FROM TabDenikImp WHERE CisloDokladu=@CisloDokladu AND Sbornik=@Sbornik AND IdObdobi=@IdObdobi)
IF (@Strana IS NULL)
BEGIN  --zpracovavame atributy Účet MD, Částka MD, CM MD, Útvar MD,Účet DAL, Částka DAL, CM DAL,Útvar DAL a dalsi MD/DAL atributy
IF @UcetMD IS NOT NULL --strana MD
BEGIN
IF ((ISNULL(@CastkaMD, 0)=0)AND(ISNULL(@CastkaMenaMD, 0)=0))
AND
((ISNULL(@CastkaDAL, 0)=0)AND(ISNULL(@CastkaMenaDAL, 0)=0))
BEGIN  --nulovy nesmyslny zaznam, vypiseme chybu
SET @ChybaPriImportu=1
IF @TextChybyImportuRadek<>'' SET @TextChybyImportuRadek=@TextChybyImportuRadek + ' | '
SET @TextChybyImportuRadek = @TextChybyImportuRadek + dbo.hpf_UniImportHlasky('2B20F045-5E11-411B-8F99-6F0295C49140', @JazykVerze, DEFAULT, DEFAULT, DEFAULT, DEFAULT)
END
ELSE
BEGIN  --zapiseme do TabDenikImp
  IF @ChybaPriImportu=0
  BEGIN
INSERT TabDenikImp(ExtDoklad,
Sbornik,
CisloDokladu,
CisloRadku,
DatumPripad,
DatumPorizeno,
DatumDUZP,
DatumSplatno,
DruhData,
IdObdobiStavu_Nazev,
Strana,
CisloUcet,
UcetDPH,
Castka,
CastkaMena,
Mena,
Kurz,
JednotkaMeny,
DatumKurz,
Popis,
ParovaciZnak,
PZ2,
Zaknihovano,
Stav,
CisloOrg,
NazevOrganizace,
ICOrganizace,
DICOrg,
Utvar,
CisloZam,
CisloZakazky,
CisloNakladovyOkruh,
IdVozidlo_SPZZobraz,
IdVozidlo_EvCislo,
IdObdobi,
IdObdobi_DatumOd,
IdObdobi_DatumDo,
IdObdobiStavu,
IdObdobiStavu_DatumOd,
IdObdobiStavu_DatumDo,
DatumDoruceni,
MJKV,
MnozstviKV,
KodKV,
PorCisKV,
PorCisPuvKV,
DatumKV,
DanovyKlic_Kod,
KodZbozi,
PlneniDoLimitu,
KOs_Jmeno,
KOs_Prijmeni,
TypZmeny,
OrganizaceTransakce,
IdObdobiDPH_DatumOd,
IdObdobiDPH_DatumDo
)
VALUES(            @ExtDoklad,
@Sbornik,
@CisloDokladu,
@RadekDokladu,
ISNULL(@DatumPripad, GETDATE()),
ISNULL(@DatumPorizeno, GETDATE()),
@DatumDUZP,
@DatumSplatno,
ISNULL(@DruhData, 0),
@IdObdobiStavu_Nazev,
0,
@UcetMD,
@UcetDPHMD,
ISNULL(@CastkaMD, 0),
ISNULL(@CastkaMenaMD, 0),
@Mena,
ISNULL(@Kurz, 1),
ISNULL(@JednotkaMeny, 1),
@DatumKurz,
ISNULL(@Popis, ''),
ISNULL(@ParovaciZnakMD, ''),
ISNULL(@PZ2MD, ''),
ISNULL(@Zaknihovano, 0),
ISNULL(@Stav, 0),
@CisloOrg,
ISNULL(@NazevOrganizace, ''),
@ICOrganizace,
@DICOrg,
@UtvarMD,
@CisloZamMD,
@CisloZakazkyMD,
@CisloNakladovyOkruhMD,
@IdVozidlo_SPZZobraz,
@IdVozidlo_EvCislo,
@IdObdobi,
@IdObdobi_DatumOd,
@IdObdobi_DatumDo,
@IdObdobiStavu,
@IdObdobiStavu_DatumOd,
@IdObdobiStavu_DatumDo,
@DatumDoruceni,
@MJKV,
ISNULL(@MnozstviKV, 0),
ISNULL(@KodKV, ''),
ISNULL(@PorCisKV, ''),
ISNULL(@PorCisPuvKV, ''),
@DatumKV,
@KodDanoveKlice,
@KodZbozi,
@PlneniDoLimitu,
@KOs_Jmeno,
@KOs_Prijmeni,
@TypZmeny,
@OrganizaceTransakce,
@IdObdobiDPH_DatumOd,
@IdObdobiDPH_DatumDo
)
SET @IdDenikImp=SCOPE_IDENTITY()
IF OBJECT_ID('dbo.epx_UniImportDenik03', 'P') IS NOT NULL EXEC dbo.epx_UniImportDenik03 @IdDenikImp
IF (@ExtAtr1 IS NOT NULL)AND(@ExtAtr1Nazev IS NOT NULL)
BEGIN
IF SUBSTRING(@ExtAtr1Nazev, 1, 1)<>'_'
  SET @ExtAtr1Nazev='_' + @ExtAtr1Nazev
IF (OBJECT_ID('TabDenikImp')IS NOT NULL)AND(COLUMNPROPERTY(OBJECT_ID('TabDenikImp'),@ExtAtr1Nazev,'AllowsNull')IS NULL)
BEGIN
SET @SQLString='ALTER TABLE TabDenikImp ADD ' + @ExtAtr1Nazev + ' NVARCHAR(30) NULL'
EXEC sp_executesql @SQLString
END
IF NOT EXISTS(SELECT * FROM TabUzivAtr WHERE Externi=1 AND NazevTabulkySys='TabDenik' AND NazevAtrSys=@ExtAtr1Nazev)
BEGIN
EXEC dbo.hp_ExterniTabulka 'TabDenik', @ExtAtr1Nazev, 'NVARCHAR(30)'
INSERT INTO TabUzivAtr (Externi, NazevTabulkySys, NazevAtrSys, NazevAtrVer, TypAtr, SirkaSloupceAtr)
VALUES (1, 'TabDenik', @ExtAtr1Nazev, @ExtAtr1Nazev,'VARCHAR',0)
END
IF EXISTS(SELECT * FROM TabStrukturaImpDen)
BEGIN
IF NOT EXISTS(SELECT * FROM TabStrukturaImpDen WHERE PATINDEX('%'+@ExtAtr1Nazev+'%', Nazvy)>0)
UPDATE TabStrukturaImpDen SET Nazvy=Nazvy+','+@ExtAtr1Nazev, NazvyProDEL=NazvyProDEL+',COLUMN ' + @ExtAtr1Nazev
END
ELSE
INSERT INTO TabStrukturaImpDen(Nazvy, NazvyProDEL) VALUES (@ExtAtr1Nazev,'COLUMN ' + @ExtAtr1Nazev)
SET @SQLString='UPDATE TabDenikImp SET ' + @ExtAtr1Nazev + '=N' + '''' + @ExtAtr1 + '''' + ' WHERE ID=' + CAST(@IdDenikImp AS NVARCHAR(10))
EXEC sp_executesql @SQLString
END
IF (@ExtAtr2 IS NOT NULL)AND(@ExtAtr2Nazev IS NOT NULL)
BEGIN
IF SUBSTRING(@ExtAtr2Nazev, 1, 1)<>'_'
  SET @ExtAtr2Nazev='_' + @ExtAtr2Nazev
IF (OBJECT_ID('TabDenikImp')IS NOT NULL)AND(COLUMNPROPERTY(OBJECT_ID('TabDenikImp'),@ExtAtr2Nazev,'AllowsNull')IS NULL)
BEGIN
SET @SQLString='ALTER TABLE TabDenikImp ADD ' + @ExtAtr2Nazev + ' NVARCHAR(255) NULL'
EXEC sp_executesql @SQLString
END
IF NOT EXISTS(SELECT * FROM TabUzivAtr WHERE Externi=1 AND NazevTabulkySys='TabDenik' AND NazevAtrSys=@ExtAtr2Nazev)
BEGIN
EXEC dbo.hp_ExterniTabulka 'TabDenik', @ExtAtr2Nazev, 'NVARCHAR(255)'
INSERT INTO TabUzivAtr (Externi, NazevTabulkySys, NazevAtrSys, NazevAtrVer, TypAtr, SirkaSloupceAtr)
VALUES (1, 'TabDenik', @ExtAtr2Nazev, @ExtAtr2Nazev,'VARCHAR',0)
END
IF EXISTS(SELECT * FROM TabStrukturaImpDen)
BEGIN
IF NOT EXISTS(SELECT * FROM TabStrukturaImpDen WHERE PATINDEX('%'+@ExtAtr2Nazev+'%', Nazvy)>0)
UPDATE TabStrukturaImpDen SET Nazvy=Nazvy+','+@ExtAtr2Nazev, NazvyProDEL=NazvyProDEL+',COLUMN ' + @ExtAtr2Nazev
END
ELSE
INSERT INTO TabStrukturaImpDen(Nazvy, NazvyProDEL) VALUES (@ExtAtr2Nazev,'COLUMN ' + @ExtAtr2Nazev)
SET @SQLString='UPDATE TabDenikImp SET ' + @ExtAtr2Nazev + '=N' + '''' + @ExtAtr2 + '''' + ' WHERE ID=' + CAST(@IdDenikImp AS NVARCHAR(10))
EXEC sp_executesql @SQLString
END
IF (@ExtAtr3 IS NOT NULL)AND(@ExtAtr3Nazev IS NOT NULL)
BEGIN
IF SUBSTRING(@ExtAtr3Nazev, 1, 1)<>'_'
  SET @ExtAtr3Nazev='_' + @ExtAtr3Nazev
IF (OBJECT_ID('TabDenikImp')IS NOT NULL)AND(COLUMNPROPERTY(OBJECT_ID('TabDenikImp'),@ExtAtr3Nazev,'AllowsNull')IS NULL)
BEGIN
SET @SQLString='ALTER TABLE TabDenikImp ADD ' + @ExtAtr3Nazev + ' DATETIME NULL'
EXEC sp_executesql @SQLString
END
IF NOT EXISTS(SELECT * FROM TabUzivAtr WHERE Externi=1 AND NazevTabulkySys='TabDenik' AND NazevAtrSys=@ExtAtr3Nazev)
BEGIN
EXEC dbo.hp_ExterniTabulka 'TabDenik', @ExtAtr3Nazev, 'DATETIME'
INSERT INTO TabUzivAtr (Externi, NazevTabulkySys, NazevAtrSys, NazevAtrVer, TypAtr, SirkaSloupceAtr)
VALUES (1, 'TabDenik', @ExtAtr3Nazev, @ExtAtr3Nazev,'DATETIME',0)
END
IF EXISTS(SELECT * FROM TabStrukturaImpDen)
BEGIN
IF NOT EXISTS(SELECT * FROM TabStrukturaImpDen WHERE PATINDEX('%'+@ExtAtr3Nazev+'%', Nazvy)>0)
UPDATE TabStrukturaImpDen SET Nazvy=Nazvy+','+@ExtAtr3Nazev, NazvyProDEL=NazvyProDEL+',COLUMN ' + @ExtAtr3Nazev
END
ELSE
INSERT INTO TabStrukturaImpDen(Nazvy, NazvyProDEL) VALUES (@ExtAtr3Nazev,'COLUMN ' + @ExtAtr3Nazev)
SET @SQLString='UPDATE TabDenikImp SET ' + @ExtAtr3Nazev + '=' + '''' + CONVERT(NVARCHAR, @ExtAtr3, 112) + '''' + ' WHERE ID=' + CAST(@IdDenikImp AS NVARCHAR(10))
EXEC sp_executesql @SQLString
END
IF (@ExtAtr4 IS NOT NULL)AND(@ExtAtr4Nazev IS NOT NULL)
BEGIN
IF SUBSTRING(@ExtAtr4Nazev, 1, 1)<>'_'
  SET @ExtAtr4Nazev='_' + @ExtAtr4Nazev
IF (OBJECT_ID('TabDenikImp')IS NOT NULL)AND(COLUMNPROPERTY(OBJECT_ID('TabDenikImp'),@ExtAtr4Nazev,'AllowsNull')IS NULL)
BEGIN
SET @SQLString='ALTER TABLE TabDenikImp ADD ' + @ExtAtr4Nazev + ' NUMERIC(19,6) NULL'
EXEC sp_executesql @SQLString
END
IF NOT EXISTS(SELECT * FROM TabUzivAtr WHERE Externi=1 AND NazevTabulkySys='TabDenik' AND NazevAtrSys=@ExtAtr4Nazev)
BEGIN
EXEC dbo.hp_ExterniTabulka 'TabDenik', @ExtAtr4Nazev, 'NUMERIC'
INSERT INTO TabUzivAtr (Externi, NazevTabulkySys, NazevAtrSys, NazevAtrVer, TypAtr, SirkaSloupceAtr)
VALUES (1, 'TabDenik', @ExtAtr4Nazev, @ExtAtr4Nazev,'NUMERIC',0)
END
IF EXISTS(SELECT * FROM TabStrukturaImpDen)
BEGIN
IF NOT EXISTS(SELECT * FROM TabStrukturaImpDen WHERE PATINDEX('%'+@ExtAtr4Nazev+'%', Nazvy)>0)
UPDATE TabStrukturaImpDen SET Nazvy=Nazvy+','+@ExtAtr4Nazev, NazvyProDEL=NazvyProDEL+',COLUMN ' + @ExtAtr4Nazev
END
ELSE
INSERT INTO TabStrukturaImpDen(Nazvy, NazvyProDEL) VALUES (@ExtAtr4Nazev,'COLUMN ' + @ExtAtr4Nazev)
SET @SQLString='UPDATE TabDenikImp SET ' + @ExtAtr4Nazev + '=' + CONVERT(NVARCHAR, @ExtAtr4) + ' WHERE ID=' + CAST(@IdDenikImp AS NVARCHAR(10))
EXEC sp_executesql @SQLString
END
SET @ChybaExtAtr=''
EXEC dbo.hpx_UniImport_ZpracujExtAtr
  @ImportIdent=11,
  @IdImpTable=@ID,
  @IdTargetTable=@IdDenikImp,
  @Chyba=@ChybaExtAtr OUT
IF @ChybaExtAtr<>''
BEGIN
  SET @ChybaPriImportu=1
  IF @TextChybyImportu<>'' SET @TextChybyImportu=@TextChybyImportu + ' | '
  SET @TextChybyImportu = @TextChybyImportu + dbo.hpf_UniImportHlasky('15364319-B20F-4D65-8900-391DE8D4C52F', @JazykVerze, @ChybaExtAtr, DEFAULT, DEFAULT, DEFAULT)
END
END
END
END --*strana MD
IF @UcetDAL IS NOT NULL --strana DAL
BEGIN
IF ((ISNULL(@CastkaMD, 0)=0)AND(ISNULL(@CastkaMenaMD, 0)=0))
AND
((ISNULL(@CastkaDAL, 0)=0)AND(ISNULL(@CastkaMenaDAL, 0)=0))
BEGIN  --nulovy nesmyslny zaznam, vypiseme chybu
SET @ChybaPriImportu=1
IF @TextChybyImportuRadek<>'' SET @TextChybyImportuRadek=@TextChybyImportuRadek + ' | '
SET @TextChybyImportuRadek = @TextChybyImportuRadek + dbo.hpf_UniImportHlasky('2B20F045-5E11-411B-8F99-6F0295C49140', @JazykVerze, DEFAULT, DEFAULT, DEFAULT, DEFAULT)
END
ELSE
BEGIN  --zapiseme do TabDenikImp
  IF @ChybaPriImportu=0
  BEGIN
SET @RadekDokladu=(SELECT ISNULL(MAX(CisloRadku), 0) + 1 FROM TabDenikImp WHERE CisloDokladu=@CisloDokladu AND Sbornik=@Sbornik AND IdObdobi=@IdObdobi)
INSERT TabDenikImp(ExtDoklad,
Sbornik,
CisloDokladu,
CisloRadku,
DatumPripad,
DatumPorizeno,
DatumDUZP,
DatumSplatno,
DruhData,
IdObdobiStavu_Nazev,
Strana,
CisloUcet,
UcetDPH,
Castka,
CastkaMena,
Mena,
Kurz,
JednotkaMeny,
DatumKurz,
Popis,
ParovaciZnak,
PZ2,
Zaknihovano,
Stav,
CisloOrg,
NazevOrganizace,
ICOrganizace,
DICOrg,
Utvar,
CisloZam,
CisloZakazky,
CisloNakladovyOkruh,
IdVozidlo_SPZZobraz,
IdVozidlo_EvCislo,
IdObdobi,
IdObdobi_DatumOd,
IdObdobi_DatumDo,
IdObdobiStavu,
IdObdobiStavu_DatumOd,
IdObdobiStavu_DatumDo,
DatumDoruceni,
MJKV,
MnozstviKV,
KodKV,
PorCisKV,
PorCisPuvKV,
DatumKV,
DanovyKlic_Kod,
KodZbozi,
PlneniDoLimitu,
KOs_Jmeno,
KOs_Prijmeni,
TypZmeny,
OrganizaceTransakce,
IdObdobiDPH_DatumOd,
IdObdobiDPH_DatumDo
)
VALUES(            @ExtDoklad,
@Sbornik,
@CisloDokladu,
@RadekDokladu,
ISNULL(@DatumPripad, GETDATE()),
ISNULL(@DatumPorizeno, GETDATE()),
@DatumDUZP,
@DatumSplatno,
ISNULL(@DruhData, 0),
@IdObdobiStavu_Nazev,
1,
@UcetDAL,
@UcetDPHDAL,
ISNULL(@CastkaDAL, 0),
ISNULL(@CastkaMenaDAL, 0),
@Mena,
ISNULL(@Kurz, 1),
ISNULL(@JednotkaMeny, 1),
@DatumKurz,
ISNULL(@Popis, ''),
ISNULL(@ParovaciZnakDAL, ''),
ISNULL(@PZ2DAL, ''),
ISNULL(@Zaknihovano, 0),
ISNULL(@Stav, 0),
@CisloOrg,
ISNULL(@NazevOrganizace, ''),
@ICOrganizace,
@DICOrg,
@UtvarDAL,
@CisloZamDAL,
@CisloZakazkyDAL,
@CisloNakladovyOkruhDAL,
@IdVozidlo_SPZZobraz,
@IdVozidlo_EvCislo,
@IdObdobi,
@IdObdobi_DatumOd,
@IdObdobi_DatumDo,
@IdObdobiStavu,
@IdObdobiStavu_DatumOd,
@IdObdobiStavu_DatumDo,
@DatumDoruceni,
@MJKV,
ISNULL(@MnozstviKV, 0),
ISNULL(@KodKV, ''),
ISNULL(@PorCisKV, ''),
ISNULL(@PorCisPuvKV, ''),
@DatumKV,
@KodDanoveKlice,
@KodZbozi,
@PlneniDoLimitu,
@KOs_Jmeno,
@KOs_Prijmeni,
@TypZmeny,
@OrganizaceTransakce,
@IdObdobiDPH_DatumOd,
@IdObdobiDPH_DatumDo
)
SET @IdDenikImp=SCOPE_IDENTITY()
IF OBJECT_ID('dbo.epx_UniImportDenik03', 'P') IS NOT NULL EXEC dbo.epx_UniImportDenik03 @IdDenikImp
IF (@ExtAtr1 IS NOT NULL)AND(@ExtAtr1Nazev IS NOT NULL)
BEGIN
IF SUBSTRING(@ExtAtr1Nazev, 1, 1)<>'_'
  SET @ExtAtr1Nazev='_' + @ExtAtr1Nazev
IF (OBJECT_ID('TabDenikImp')IS NOT NULL)AND(COLUMNPROPERTY(OBJECT_ID('TabDenikImp'),@ExtAtr1Nazev,'AllowsNull')IS NULL)
BEGIN
SET @SQLString='ALTER TABLE TabDenikImp ADD ' + @ExtAtr1Nazev + ' NVARCHAR(30) NULL'
EXEC sp_executesql @SQLString
END
IF NOT EXISTS(SELECT * FROM TabUzivAtr WHERE Externi=1 AND NazevTabulkySys='TabDenik' AND NazevAtrSys=@ExtAtr1Nazev)
BEGIN
EXEC dbo.hp_ExterniTabulka 'TabDenik', @ExtAtr1Nazev, 'NVARCHAR(30)'
INSERT INTO TabUzivAtr (Externi, NazevTabulkySys, NazevAtrSys, NazevAtrVer, TypAtr, SirkaSloupceAtr)
VALUES (1, 'TabDenik', @ExtAtr1Nazev, @ExtAtr1Nazev,'VARCHAR',0)
END
IF EXISTS(SELECT * FROM TabStrukturaImpDen)
BEGIN
IF NOT EXISTS(SELECT * FROM TabStrukturaImpDen WHERE PATINDEX('%'+@ExtAtr1Nazev+'%', Nazvy)>0)
UPDATE TabStrukturaImpDen SET Nazvy=Nazvy+','+@ExtAtr1Nazev, NazvyProDEL=NazvyProDEL+',COLUMN ' + @ExtAtr1Nazev
END
ELSE
INSERT INTO TabStrukturaImpDen(Nazvy, NazvyProDEL) VALUES (@ExtAtr1Nazev,'COLUMN ' + @ExtAtr1Nazev)
SET @SQLString='UPDATE TabDenikImp SET ' + @ExtAtr1Nazev + '=N' + '''' + @ExtAtr1 + '''' + ' WHERE ID=' + CAST(@IdDenikImp AS NVARCHAR(10))
EXEC sp_executesql @SQLString
END
IF (@ExtAtr2 IS NOT NULL)AND(@ExtAtr2Nazev IS NOT NULL)
BEGIN
IF SUBSTRING(@ExtAtr2Nazev, 1, 1)<>'_'
  SET @ExtAtr2Nazev='_' + @ExtAtr2Nazev
IF (OBJECT_ID('TabDenikImp')IS NOT NULL)AND(COLUMNPROPERTY(OBJECT_ID('TabDenikImp'),@ExtAtr2Nazev,'AllowsNull')IS NULL)
BEGIN
SET @SQLString='ALTER TABLE TabDenikImp ADD ' + @ExtAtr2Nazev + ' NVARCHAR(255) NULL'
EXEC sp_executesql @SQLString
END
IF NOT EXISTS(SELECT * FROM TabUzivAtr WHERE Externi=1 AND NazevTabulkySys='TabDenik' AND NazevAtrSys=@ExtAtr2Nazev)
BEGIN
EXEC dbo.hp_ExterniTabulka 'TabDenik', @ExtAtr2Nazev, 'NVARCHAR(255)'
INSERT INTO TabUzivAtr (Externi, NazevTabulkySys, NazevAtrSys, NazevAtrVer, TypAtr, SirkaSloupceAtr)
VALUES (1, 'TabDenik', @ExtAtr2Nazev, @ExtAtr2Nazev,'VARCHAR',0)
END
IF EXISTS(SELECT * FROM TabStrukturaImpDen)
BEGIN
IF NOT EXISTS(SELECT * FROM TabStrukturaImpDen WHERE PATINDEX('%'+@ExtAtr2Nazev+'%', Nazvy)>0)
UPDATE TabStrukturaImpDen SET Nazvy=Nazvy+','+@ExtAtr2Nazev, NazvyProDEL=NazvyProDEL+',COLUMN ' + @ExtAtr2Nazev
END
ELSE
INSERT INTO TabStrukturaImpDen(Nazvy, NazvyProDEL) VALUES (@ExtAtr2Nazev,'COLUMN ' + @ExtAtr2Nazev)
SET @SQLString='UPDATE TabDenikImp SET ' + @ExtAtr2Nazev + '=N' + '''' + @ExtAtr2 + '''' + ' WHERE ID=' + CAST(@IdDenikImp AS NVARCHAR(10))
EXEC sp_executesql @SQLString
END
IF (@ExtAtr3 IS NOT NULL)AND(@ExtAtr3Nazev IS NOT NULL)
BEGIN
IF SUBSTRING(@ExtAtr3Nazev, 1, 1)<>'_'
  SET @ExtAtr3Nazev='_' + @ExtAtr3Nazev
IF (OBJECT_ID('TabDenikImp')IS NOT NULL)AND(COLUMNPROPERTY(OBJECT_ID('TabDenikImp'),@ExtAtr3Nazev,'AllowsNull')IS NULL)
BEGIN
SET @SQLString='ALTER TABLE TabDenikImp ADD ' + @ExtAtr3Nazev + ' DATETIME NULL'
EXEC sp_executesql @SQLString
END
IF NOT EXISTS(SELECT * FROM TabUzivAtr WHERE Externi=1 AND NazevTabulkySys='TabDenik' AND NazevAtrSys=@ExtAtr3Nazev)
BEGIN
EXEC dbo.hp_ExterniTabulka 'TabDenik', @ExtAtr3Nazev, 'DATETIME'
INSERT INTO TabUzivAtr (Externi, NazevTabulkySys, NazevAtrSys, NazevAtrVer, TypAtr, SirkaSloupceAtr)
VALUES (1, 'TabDenik', @ExtAtr3Nazev, @ExtAtr3Nazev,'DATETIME',0)
END
IF EXISTS(SELECT * FROM TabStrukturaImpDen)
BEGIN
IF NOT EXISTS(SELECT * FROM TabStrukturaImpDen WHERE PATINDEX('%'+@ExtAtr3Nazev+'%', Nazvy)>0)
UPDATE TabStrukturaImpDen SET Nazvy=Nazvy+','+@ExtAtr3Nazev, NazvyProDEL=NazvyProDEL+',COLUMN ' + @ExtAtr3Nazev
END
ELSE
INSERT INTO TabStrukturaImpDen(Nazvy, NazvyProDEL) VALUES (@ExtAtr3Nazev,'COLUMN ' + @ExtAtr3Nazev)
SET @SQLString='UPDATE TabDenikImp SET ' + @ExtAtr3Nazev + '=' + '''' + CONVERT(NVARCHAR, @ExtAtr3, 112) + '''' + ' WHERE ID=' + CAST(@IdDenikImp AS NVARCHAR(10))
EXEC sp_executesql @SQLString
END
IF (@ExtAtr4 IS NOT NULL)AND(@ExtAtr4Nazev IS NOT NULL)
BEGIN
IF SUBSTRING(@ExtAtr4Nazev, 1, 1)<>'_'
  SET @ExtAtr4Nazev='_' + @ExtAtr4Nazev
IF (OBJECT_ID('TabDenikImp')IS NOT NULL)AND(COLUMNPROPERTY(OBJECT_ID('TabDenikImp'),@ExtAtr4Nazev,'AllowsNull')IS NULL)
BEGIN
SET @SQLString='ALTER TABLE TabDenikImp ADD ' + @ExtAtr4Nazev + ' NUMERIC(19,6) NULL'
EXEC sp_executesql @SQLString
END
IF NOT EXISTS(SELECT * FROM TabUzivAtr WHERE Externi=1 AND NazevTabulkySys='TabDenik' AND NazevAtrSys=@ExtAtr4Nazev)
BEGIN
EXEC dbo.hp_ExterniTabulka 'TabDenik', @ExtAtr4Nazev, 'NUMERIC'
INSERT INTO TabUzivAtr (Externi, NazevTabulkySys, NazevAtrSys, NazevAtrVer, TypAtr, SirkaSloupceAtr)
VALUES (1, 'TabDenik', @ExtAtr4Nazev, @ExtAtr4Nazev,'NUMERIC',0)
END
IF EXISTS(SELECT * FROM TabStrukturaImpDen)
BEGIN
IF NOT EXISTS(SELECT * FROM TabStrukturaImpDen WHERE PATINDEX('%'+@ExtAtr4Nazev+'%', Nazvy)>0)
UPDATE TabStrukturaImpDen SET Nazvy=Nazvy+','+@ExtAtr4Nazev, NazvyProDEL=NazvyProDEL+',COLUMN ' + @ExtAtr4Nazev
END
ELSE
INSERT INTO TabStrukturaImpDen(Nazvy, NazvyProDEL) VALUES (@ExtAtr4Nazev,'COLUMN ' + @ExtAtr4Nazev)
SET @SQLString='UPDATE TabDenikImp SET ' + @ExtAtr4Nazev + '=' + CONVERT(NVARCHAR, @ExtAtr4) + ' WHERE ID=' + CAST(@IdDenikImp AS NVARCHAR(10))
EXEC sp_executesql @SQLString
END
SET @ChybaExtAtr=''
EXEC dbo.hpx_UniImport_ZpracujExtAtr
  @ImportIdent=11,
  @IdImpTable=@ID,
  @IdTargetTable=@IdDenikImp,
  @Chyba=@ChybaExtAtr OUT
IF @ChybaExtAtr<>''
BEGIN
  SET @ChybaPriImportu=1
  IF @TextChybyImportu<>'' SET @TextChybyImportu=@TextChybyImportu + ' | '
  SET @TextChybyImportu = @TextChybyImportu + dbo.hpf_UniImportHlasky('15364319-B20F-4D65-8900-391DE8D4C52F', @JazykVerze, @ChybaExtAtr, DEFAULT, DEFAULT, DEFAULT)
END
END
END
END --*strana DAL
IF (@UcetMD IS NULL)AND(@UcetDAL IS NULL)
BEGIN
SET @ChybaPriImportu=1
IF @TextChybyImportuRadek<>'' SET @TextChybyImportuRadek=@TextChybyImportuRadek + ' | '
SET @TextChybyImportuRadek = @TextChybyImportuRadek + dbo.hpf_UniImportHlasky('7AE2D8FD-F66D-475B-8A07-3A44979D7C19', @JazykVerze, DEFAULT, DEFAULT, DEFAULT, DEFAULT)
END
END
ELSE --atribut Strana je vyplnen
BEGIN  --zpracovavame atributy Účet, Účet DPH, Částka, Částka CM
IF @CisloUcet IS NOT NULL
BEGIN
IF (ISNULL(@Castka, 0)=0) AND (ISNULL(@CastkaMena, 0)=0)
BEGIN
SET @ChybaPriImportu=1
IF @TextChybyImportuRadek<>'' SET @TextChybyImportuRadek=@TextChybyImportuRadek + ' | '
SET @TextChybyImportuRadek = @TextChybyImportuRadek + dbo.hpf_UniImportHlasky('9CF76C55-5336-4A39-8931-A73086FCD0A5', @JazykVerze, DEFAULT, DEFAULT, DEFAULT, DEFAULT)
END
ELSE
BEGIN
  IF @ChybaPriImportu=0
  BEGIN
INSERT TabDenikImp(ExtDoklad,
Sbornik,
CisloDokladu,
CisloRadku,
DatumPripad,
DatumPorizeno,
DatumDUZP,
DatumSplatno,
DruhData,
IdObdobiStavu_Nazev,
Strana,
CisloUcet,
UcetDPH,
Castka,
CastkaMena,
Mena,
Kurz,
JednotkaMeny,
DatumKurz,
Popis,
ParovaciZnak,
PZ2,
Zaknihovano,
Stav,
CisloOrg,
NazevOrganizace,
ICOrganizace,
DICOrg,
Utvar,
CisloZam,
CisloZakazky,
CisloNakladovyOkruh,
IdVozidlo_SPZZobraz,
IdVozidlo_EvCislo,
IdObdobi,
IdObdobi_DatumOd,
IdObdobi_DatumDo,
IdObdobiStavu,
IdObdobiStavu_DatumOd,
IdObdobiStavu_DatumDo,
DatumDoruceni,
MJKV,
MnozstviKV,
KodKV,
PorCisKV,
PorCisPuvKV,
DatumKV,
DanovyKlic_Kod,
KodZbozi,
PlneniDoLimitu,
KOs_Jmeno,
KOs_Prijmeni,
TypZmeny,
OrganizaceTransakce,
IdObdobiDPH_DatumOd,
IdObdobiDPH_DatumDo
)
VALUES(        @ExtDoklad,
@Sbornik,
@CisloDokladu,
@RadekDokladu,
ISNULL(@DatumPripad, GETDATE()),
ISNULL(@DatumPorizeno, GETDATE()),
@DatumDUZP,
@DatumSplatno,
ISNULL(@DruhData, 0),
@IdObdobiStavu_Nazev,
@Strana,
@CisloUcet,
@UcetDPH,
ISNULL(@Castka, 0),
ISNULL(@CastkaMena, 0),
@Mena,
ISNULL(@Kurz, 1),
ISNULL(@JednotkaMeny, 1),
@DatumKurz,
ISNULL(@Popis, ''),
ISNULL(@ParovaciZnak, ''),
ISNULL(@PZ2, ''),
ISNULL(@Zaknihovano, 0),
ISNULL(@Stav, 0),
@CisloOrg,
ISNULL(@NazevOrganizace, ''),
@ICOrganizace,
@DICOrg,
@Utvar,
@CisloZam,
@CisloZakazky,
@CisloNakladovyOkruh,
@IdVozidlo_SPZZobraz,
@IdVozidlo_EvCislo,
@IdObdobi,
@IdObdobi_DatumOd,
@IdObdobi_DatumDo,
@IdObdobiStavu,
@IdObdobiStavu_DatumOd,
@IdObdobiStavu_DatumDo,
@DatumDoruceni,
@MJKV,
ISNULL(@MnozstviKV, 0),
ISNULL(@KodKV, ''),
ISNULL(@PorCisKV, ''),
ISNULL(@PorCisPuvKV, ''),
@DatumKV,
@KodDanoveKlice,
@KodZbozi,
@PlneniDoLimitu,
@KOs_Jmeno,
@KOs_Prijmeni,
@TypZmeny,
@OrganizaceTransakce,
@IdObdobiDPH_DatumOd,
@IdObdobiDPH_DatumDo
)
SET @IdDenikImp=SCOPE_IDENTITY()
IF OBJECT_ID('dbo.epx_UniImportDenik03', 'P') IS NOT NULL EXEC dbo.epx_UniImportDenik03 @IdDenikImp
IF (@ExtAtr1 IS NOT NULL)AND(@ExtAtr1Nazev IS NOT NULL)
BEGIN
SET @ExtAtr1Nazev='_' + @ExtAtr1Nazev
IF (OBJECT_ID('TabDenikImp')IS NOT NULL)AND(COLUMNPROPERTY(OBJECT_ID('TabDenikImp'),@ExtAtr1Nazev,'AllowsNull')IS NULL)
BEGIN
SET @SQLString='ALTER TABLE TabDenikImp ADD ' + @ExtAtr1Nazev + ' NVARCHAR(30) NULL'
EXEC sp_executesql @SQLString
END
IF NOT EXISTS(SELECT * FROM TabUzivAtr WHERE Externi=1 AND NazevTabulkySys='TabDenik' AND NazevAtrSys=@ExtAtr1Nazev)
BEGIN
EXEC dbo.hp_ExterniTabulka 'TabDenik', @ExtAtr1Nazev, 'NVARCHAR(30)'
INSERT INTO TabUzivAtr (Externi, NazevTabulkySys, NazevAtrSys, NazevAtrVer, TypAtr, SirkaSloupceAtr)
VALUES (1, 'TabDenik', @ExtAtr1Nazev, @ExtAtr1Nazev,'VARCHAR',0)
END
IF EXISTS(SELECT * FROM TabStrukturaImpDen)
BEGIN
IF NOT EXISTS(SELECT * FROM TabStrukturaImpDen WHERE PATINDEX('%'+@ExtAtr1Nazev+'%', Nazvy)>0)
UPDATE TabStrukturaImpDen SET Nazvy=Nazvy+','+@ExtAtr1Nazev, NazvyProDEL=NazvyProDEL+',COLUMN ' + @ExtAtr1Nazev
END
ELSE
INSERT INTO TabStrukturaImpDen(Nazvy, NazvyProDEL) VALUES (@ExtAtr1Nazev,'COLUMN ' + @ExtAtr1Nazev)
SET @SQLString='UPDATE TabDenikImp SET ' + @ExtAtr1Nazev + '=N' + '''' + @ExtAtr1 + '''' + ' WHERE ID=' + CAST(@IdDenikImp AS NVARCHAR(10))
EXEC sp_executesql @SQLString
END
IF (@ExtAtr2 IS NOT NULL)AND(@ExtAtr2Nazev IS NOT NULL)
BEGIN
SET @ExtAtr2Nazev='_' + @ExtAtr2Nazev
IF (OBJECT_ID('TabDenikImp')IS NOT NULL)AND(COLUMNPROPERTY(OBJECT_ID('TabDenikImp'),@ExtAtr2Nazev,'AllowsNull')IS NULL)
BEGIN
SET @SQLString='ALTER TABLE TabDenikImp ADD ' + @ExtAtr2Nazev + ' NVARCHAR(255) NULL'
EXEC sp_executesql @SQLString
END
IF NOT EXISTS(SELECT * FROM TabUzivAtr WHERE Externi=1 AND NazevTabulkySys='TabDenik' AND NazevAtrSys=@ExtAtr2Nazev)
BEGIN
EXEC dbo.hp_ExterniTabulka 'TabDenik', @ExtAtr2Nazev, 'NVARCHAR(255)'
INSERT INTO TabUzivAtr (Externi, NazevTabulkySys, NazevAtrSys, NazevAtrVer, TypAtr, SirkaSloupceAtr)
VALUES (1, 'TabDenik', @ExtAtr2Nazev, @ExtAtr2Nazev,'VARCHAR',0)
END
IF EXISTS(SELECT * FROM TabStrukturaImpDen)
BEGIN
IF NOT EXISTS(SELECT * FROM TabStrukturaImpDen WHERE PATINDEX('%'+@ExtAtr2Nazev+'%', Nazvy)>0)
UPDATE TabStrukturaImpDen SET Nazvy=Nazvy+','+@ExtAtr2Nazev, NazvyProDEL=NazvyProDEL+',COLUMN ' + @ExtAtr2Nazev
END
ELSE
INSERT INTO TabStrukturaImpDen(Nazvy, NazvyProDEL) VALUES (@ExtAtr2Nazev,'COLUMN ' + @ExtAtr2Nazev)
SET @SQLString='UPDATE TabDenikImp SET ' + @ExtAtr2Nazev + '=N' + '''' + @ExtAtr2 + '''' + ' WHERE ID=' + CAST(@IdDenikImp AS NVARCHAR(10))
EXEC sp_executesql @SQLString
END
IF (@ExtAtr3 IS NOT NULL)AND(@ExtAtr3Nazev IS NOT NULL)
BEGIN
SET @ExtAtr3Nazev='_' + @ExtAtr3Nazev
IF (OBJECT_ID('TabDenikImp')IS NOT NULL)AND(COLUMNPROPERTY(OBJECT_ID('TabDenikImp'),@ExtAtr3Nazev,'AllowsNull')IS NULL)
BEGIN
SET @SQLString='ALTER TABLE TabDenikImp ADD ' + @ExtAtr3Nazev + ' DATETIME NULL'
EXEC sp_executesql @SQLString
END
IF NOT EXISTS(SELECT * FROM TabUzivAtr WHERE Externi=1 AND NazevTabulkySys='TabDenik' AND NazevAtrSys=@ExtAtr3Nazev)
BEGIN
EXEC dbo.hp_ExterniTabulka 'TabDenik', @ExtAtr3Nazev, 'DATETIME'
INSERT INTO TabUzivAtr (Externi, NazevTabulkySys, NazevAtrSys, NazevAtrVer, TypAtr, SirkaSloupceAtr)
VALUES (1, 'TabDenik', @ExtAtr3Nazev, @ExtAtr3Nazev,'DATETIME',0)
END
IF EXISTS(SELECT * FROM TabStrukturaImpDen)
BEGIN
IF NOT EXISTS(SELECT * FROM TabStrukturaImpDen WHERE PATINDEX('%'+@ExtAtr3Nazev+'%', Nazvy)>0)
UPDATE TabStrukturaImpDen SET Nazvy=Nazvy+','+@ExtAtr3Nazev, NazvyProDEL=NazvyProDEL+',COLUMN ' + @ExtAtr3Nazev
END
ELSE
INSERT INTO TabStrukturaImpDen(Nazvy, NazvyProDEL) VALUES (@ExtAtr3Nazev,'COLUMN ' + @ExtAtr3Nazev)
SET @SQLString='UPDATE TabDenikImp SET ' + @ExtAtr3Nazev + '=' + '''' + CONVERT(NVARCHAR, @ExtAtr3, 112) + '''' + ' WHERE ID=' + CAST(@IdDenikImp AS NVARCHAR(10))
EXEC sp_executesql @SQLString
END
IF (@ExtAtr4 IS NOT NULL)AND(@ExtAtr4Nazev IS NOT NULL)
BEGIN
SET @ExtAtr4Nazev='_' + @ExtAtr4Nazev
IF (OBJECT_ID('TabDenikImp')IS NOT NULL)AND(COLUMNPROPERTY(OBJECT_ID('TabDenikImp'),@ExtAtr4Nazev,'AllowsNull')IS NULL)
BEGIN
SET @SQLString='ALTER TABLE TabDenikImp ADD ' + @ExtAtr4Nazev + ' NUMERIC(19,6) NULL'
EXEC sp_executesql @SQLString
END
IF NOT EXISTS(SELECT * FROM TabUzivAtr WHERE Externi=1 AND NazevTabulkySys='TabDenik' AND NazevAtrSys=@ExtAtr4Nazev)
BEGIN
EXEC dbo.hp_ExterniTabulka 'TabDenik', @ExtAtr4Nazev, 'NUMERIC'
INSERT INTO TabUzivAtr (Externi, NazevTabulkySys, NazevAtrSys, NazevAtrVer, TypAtr, SirkaSloupceAtr)
VALUES (1, 'TabDenik', @ExtAtr4Nazev, @ExtAtr4Nazev,'NUMERIC',0)
END
IF EXISTS(SELECT * FROM TabStrukturaImpDen)
BEGIN
IF NOT EXISTS(SELECT * FROM TabStrukturaImpDen WHERE PATINDEX('%'+@ExtAtr4Nazev+'%', Nazvy)>0)
UPDATE TabStrukturaImpDen SET Nazvy=Nazvy+','+@ExtAtr4Nazev, NazvyProDEL=NazvyProDEL+',COLUMN ' + @ExtAtr4Nazev
END
ELSE
INSERT INTO TabStrukturaImpDen(Nazvy, NazvyProDEL) VALUES (@ExtAtr4Nazev,'COLUMN ' + @ExtAtr4Nazev)
SET @SQLString='UPDATE TabDenikImp SET ' + @ExtAtr4Nazev + '=' + CONVERT(NVARCHAR, @ExtAtr4) + ' WHERE ID=' + CAST(@IdDenikImp AS NVARCHAR(10))
EXEC sp_executesql @SQLString
END
SET @ChybaExtAtr=''
EXEC dbo.hpx_UniImport_ZpracujExtAtr
  @ImportIdent=11,
  @IdImpTable=@ID,
  @IdTargetTable=@IdDenikImp,
  @Chyba=@ChybaExtAtr OUT
IF @ChybaExtAtr<>''
BEGIN
  SET @ChybaPriImportu=1
  IF @TextChybyImportu<>'' SET @TextChybyImportu=@TextChybyImportu + ' | '
  SET @TextChybyImportu = @TextChybyImportu + dbo.hpf_UniImportHlasky('15364319-B20F-4D65-8900-391DE8D4C52F', @JazykVerze, @ChybaExtAtr, DEFAULT, DEFAULT, DEFAULT)
END
END
END
END
IF (@CisloUcet IS NULL)
BEGIN
SET @ChybaPriImportu=1
IF @TextChybyImportuRadek<>'' SET @TextChybyImportuRadek=@TextChybyImportuRadek + ' | '
SET @TextChybyImportuRadek = @TextChybyImportuRadek + dbo.hpf_UniImportHlasky('FA9FBEA6-BEAF-483A-8BE0-D8BAAE78E7D8', @JazykVerze, DEFAULT, DEFAULT, DEFAULT, DEFAULT)
END
END    --*zpracovavame atributy Účet, Účet DPH, Částka, Částka CM
IF @TextChybyImportuRadek<>''
BEGIN
IF @TextChybyImportu<>'' SET @TextChybyImportu=@TextChybyImportu + ' | '
SET @TextChybyImportu=@TextChybyImportu + ISNULL(@TextChybyImportuRadek, '')
SET @ChybaPriImportu=1
END
FETCH NEXT FROM r INTO @ID, @Sbornik, @CisloDokladu, @IdObdobi_DatumOd, @DatumPripad,
@DatumPorizeno, @DatumDUZP, @DatumSplatno, @DruhData, @IdObdobiStavu_Nazev, @UcetMD,
@CastkaMD, @CastkaMenaMD, @UtvarMD, @UcetDAL, @CastkaDAL, @CastkaMenaDAL, @UtvarDAL,
@Strana, @CisloUcet, @UcetDPH, @Castka, @CastkaMena, @Mena, @Kurz, @JednotkaMeny,
@DatumKurz, @Popis, @ParovaciZnak, @Zaknihovano, @Stav, @CisloOrg, @CisloOrgDOS,
@NazevOrganizace, @ICOrganizace, @DICOrg, @Utvar, @CisloZam, @CisloZakazky, @CisloNakladovyOkruh,
@IdVozidlo_SPZZobraz, @ExtAtr1, @ExtAtr1Nazev, @ExtAtr2, @ExtAtr2Nazev, @ExtAtr3,
@ExtAtr3Nazev, @ExtAtr4, @ExtAtr4Nazev,
@ParovaciZnakMD, @ParovaciZnakDAL, @CisloZamMD, @CisloZamDAL, @CisloZakazkyMD, @CisloZakazkyDAL, @CisloNakladovyOkruhMD, @CisloNakladovyOkruhDAL,@DatumDoruceni,
@MJKV, @MnozstviKV, @KodKV, @PorCisKV, @PorCisPuvKV, @DatumKV, @UcetDPHMD, @UcetDPHDAL, @KodDanoveKlice, @KodZbozi, @PlneniDoLimitu, @KOs_Jmeno, @KOs_Prijmeni,
@TypZmeny, @OrganizaceTransakce, @IdVozidlo_EvCislo, @PZ2, @PZ2MD, @PZ2DAL, @IdObdobiDPH_DatumOd, @IdObdobiDPH_DatumDo
IF @@fetch_status<>0 BREAK
END /*konec vnitrniho cyklu po radcich*/
CLOSE r
DEALLOCATE r
IF @ChybaPriImportu=0 DELETE FROM dbo.TabUniImportDenik WHERE ExtDoklad=@ExtDoklad AND Chyba IS NULL AND ((@PouzeZaznamyDleLogin=1 AND Autor=SUSER_SNAME())OR(@PouzeZaznamyDleLogin=0)) 
IF @ChybaPriImportu=1
BEGIN
IF @@trancount>0 ROLLBACK TRAN T1
UPDATE dbo.TabUniImportDenik SET Chyba=@TextChybyImportu, DatumImportu=GETDATE() WHERE ExtDoklad=@ExtDoklad AND Chyba IS NULL AND ((@PouzeZaznamyDleLogin=1 AND Autor=SUSER_SNAME())OR(@PouzeZaznamyDleLogin=0)) 
END
ELSE
IF @@trancount>0 COMMIT TRAN T1
END   /*samotna importni cast*/
END /*interni verze=1*/ -----------------------------------------------------------------------------------------
FETCH NEXT FROM c INTO @ExtDoklad
IF @@fetch_status<>0 BREAK
END
CLOSE c
DEALLOCATE c   --konec vnejsiho cyklu
GO

