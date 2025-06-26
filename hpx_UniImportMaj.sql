USE [RayService]
GO

/****** Object:  StoredProcedure [dbo].[hpx_UniImportMaj]    Script Date: 26.06.2025 10:19:00 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

/*rpObecneImporty.Import*/CREATE PROC [dbo].[hpx_UniImportMaj]
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
SET @PocetRadkuImpTabulky=(SELECT COUNT(*) FROM TabUniImportMaj WHERE Chyba IS NULL AND ((@PouzeZaznamyDleLogin=1 AND Autor=SUSER_SNAME())OR(@PouzeZaznamyDleLogin=0)) )
SET @InfoText = dbo.hpf_UniImportHlasky('959B5166-6EEF-44A5-B4AC-DA13F5642C08', @JazykVerze, 'TabUniImportMaj', CAST(@PocetRadkuImpTabulky AS NVARCHAR), DEFAULT, DEFAULT)
IF @InfoText IS NOT NULL
  EXEC dbo.hp_ZapisDoZurnalu 1, 77, @InfoText
IF OBJECT_ID('dbo.epx_UniImportMaj02', 'P') IS NOT NULL EXEC dbo.epx_UniImportMaj02
DECLARE @ChybaPriImportu BIT, @TextChybyImportu NVARCHAR(4000), @IDProtZaved INT, @ChybaCistic INT, @CisticNeznamy TINYINT, @ChybaExtAtr NVARCHAR(4000)
DECLARE @ID INT, @InterniVerze INT, @TypMaj NVARCHAR(3), @CisloMaj INT, @Nazev1 NVARCHAR(100),
@SKP NVARCHAR(50), @DatumPor DATETIME, @DatumZav DATETIME, @DatumPlatnostiDP DATETIME, @DatumPlatnostiUP DATETIME,
@DatumPlatnostiUM DATETIME, @ZpusobPorizeni TINYINT, @TypOzn NVARCHAR(20), @Vyrobeno DATETIME, @Vyrobce NVARCHAR(20),
@Zeme NVARCHAR(30), @VyrCislo NVARCHAR(100), @Doklad NVARCHAR(20), @DanovePohyby BIT, @UcetniPohyby BIT, @P30o12 BIT,
@P30o12Odpis NUMERIC(19,6), @OpisUcetnich TINYINT, @Trida NVARCHAR(2), @Polozka1 NVARCHAR(50), @Polozka2 NVARCHAR(50),
@UKodOdpis INT, @UKodOdpisAN BIT, @IdDrPoDP INT, @ZpusobDP TINYINT, @ZvyseniOdpisu TINYINT, @Zastaveni TINYINT,
@Skupina TINYINT, @TechnickyZhodnoceno BIT, @CastRocOdp NUMERIC(19,6), @NizsiSazbaAN BIT, @NizsiSazba NUMERIC(19,6),
@VstCenStav NUMERIC(19,6), @ZvyCenStav NUMERIC(19,6), @ZusCenStavDP NUMERIC(19,6), @RokyOdpisu SMALLINT,
@DP_HodnotaUzivatelska BIT, @DP_ParovaciZnak NVARCHAR(20), @DP_PlatnostMesicPoAN BIT,
@DP_UKod INT, @DP_UKodUzivAN BIT, @Hodnota NUMERIC(19,6), @IdDrPoUP INT, @CisloZpusobOdpisu INT, @CisloUS INT,
@Sazba NUMERIC(19,6), @SazbaRocni NUMERIC(19,6), @PocetObdobiOdpisAN BIT, @PocetObdobiOdpis SMALLINT, @UP_PlatnostMesicPoAN BIT,
@PosledniOdpis BIT, @UKod INT, @ParovaciZnak NVARCHAR(20), @CenaStav NUMERIC(19,6), @ZusCenStavUP NUMERIC(19,6),
@UP_UKodUzivAN BIT, @UP_ZusCenCilova NUMERIC(19,6), @IdDrPoUm INT, @CisZam INT, @Utvar NVARCHAR(30), @KodLok NVARCHAR(20),
@SPZZobraz NVARCHAR(12), @CarKod NVARCHAR(20), @CisloZakazky NVARCHAR(15), @CisloNakladovyOkruh NVARCHAR(15),
@Poradac NVARCHAR(10), @PocKusu INT,
@EvCislo NVARCHAR(20),
@P3_CenaStav NUMERIC(19,6), @P3_CisloUS INT,
@P3_CisloZpusobOdpisu INT, @P3_DatumPlatnosti DATETIME,
@P3_IdDrPo INT, @P3_PlatnostMesicPoAN BIT, @P3_ParovaciZnak NVARCHAR(20),
@P3_PocetObdobiOdpis SMALLINT, @P3_PocetObdobiOdpisAN BIT, @P3_PosledniOdpis BIT,
@P3_Sazba NUMERIC(19,6), @P3_SazbaRocni NUMERIC(19,6), @P3_UKod INT,
@P3_UKodOdpis INT, @P3_UKodOdpisAN BIT, @P3_UKodUzivAN BIT, @P3_ZusCenCilova NUMERIC(19,6), @P3_ZusCenStav NUMERIC(19,6),
@P3Pohyby BIT, @SPZID INT, @Um_NadKarta_CisloMaj INT, @Um_NadKarta_TypMaj NVARCHAR(3), @Um_NadKarta_Id INT,
@CZCPAKod NVARCHAR(8), @CZCPA_AN BIT, @CZCCKod NVARCHAR(6), @CZCC_AN BIT,
@OperativniEvidence BIT, @OE_CenaStav NUMERIC(19,6), @Um_CisloOrg INT, @Um_CisloOrg2 INT, @DatumZarukyDo DATETIME,
@UcetMajetku NVARCHAR(10), @UcetOdpisu NVARCHAR(10), @UcetNakladDoLimitu NVARCHAR(10),
@Ucetporizenimajetku NVARCHAR(10), @UcetOpravek NVARCHAR(10), @UcetZustatkoveCeny NVARCHAR(10)
DECLARE c CURSOR LOCAL FAST_FORWARD FOR
SELECT ID, InterniVerze, TypMaj, CisloMaj, Nazev1, SKP, DatumPor, DatumZav, DatumPlatnostiDP,
DatumPlatnostiUP, DatumPlatnostiUM, ZpusobPorizeni, TypOzn, Vyrobeno, Vyrobce, Zeme, VyrCislo, Doklad,
DanovePohyby, UcetniPohyby, P30o12, P30o12Odpis, OpisUcetnich, Trida, Polozka1, Polozka2, UKodOdpis,
UKodOdpisAN, IdDrPoDP, ZpusobDP, ZvyseniOdpisu, Zastaveni, Skupina, TechnickyZhodnoceno, CastRocOdp,
NizsiSazbaAN, NizsiSazba, VstCenStav, ZvyCenStav, ZusCenStavDP, RokyOdpisu, DP_HodnotaUzivatelska,
DP_ParovaciZnak, DP_PlatnostMesicPoAN, DP_UKod, DP_UKodUzivAN, Hodnota, IdDrPoUP,
CisloZpusobOdpisu, CisloUS, Sazba, SazbaRocni, PocetObdobiOdpisAN, PocetObdobiOdpis, UP_PlatnostMesicPoAN, PosledniOdpis,
UKod, ParovaciZnak, CenaStav, ZusCenStavUP, UP_UKodUzivAN, UP_ZusCenCilova, IdDrPoUm, CisZam, Utvar,
KodLok, SPZZobraz, CarKod, CisloZakazky, CisloNakladovyOkruh, Poradac, PocKusu,
EvCislo,
P3_CenaStav, P3_CisloUS, P3_CisloZpusobOdpisu, P3_DatumPlatnosti,
P3_IdDrPo, P3_PlatnostMesicPoAN, P3_ParovaciZnak, P3_PocetObdobiOdpis,
P3_PocetObdobiOdpisAN, P3_PosledniOdpis, P3_Sazba, P3_SazbaRocni,
P3_UKod, P3_UKodOdpis, P3_UKodOdpisAN, P3_UKodUzivAN, P3_ZusCenCilova, P3_ZusCenStav,
P3Pohyby,
Um_NadKarta_CisloMaj, Um_NadKarta_TypMaj,
CZCPAKod, CZCCKod,
OperativniEvidence, OE_CenaStav, Um_CisloOrg, Um_CisloOrg2, DatumZarukyDo, UcetMajetku, UcetOdpisu, UcetNakladDoLimitu,
Ucetporizenimajetku, UcetOpravek, UcetZustatkoveCeny
FROM dbo.TabUniImportMaj
WHERE Chyba IS NULL
 AND ((@PouzeZaznamyDleLogin=1 AND Autor=SUSER_SNAME())OR(@PouzeZaznamyDleLogin=0)) 
OPEN c
FETCH NEXT FROM c INTO @ID, @InterniVerze, @TypMaj, @CisloMaj, @Nazev1, @SKP, @DatumPor, @DatumZav,
@DatumPlatnostiDP, @DatumPlatnostiUP, @DatumPlatnostiUM, @ZpusobPorizeni, @TypOzn, @Vyrobeno, @Vyrobce, @Zeme,
@VyrCislo, @Doklad, @DanovePohyby, @UcetniPohyby, @P30o12, @P30o12Odpis, @OpisUcetnich, @Trida, @Polozka1,
@Polozka2, @UKodOdpis, @UKodOdpisAN, @IdDrPoDP, @ZpusobDP, @ZvyseniOdpisu, @Zastaveni, @Skupina, @TechnickyZhodnoceno,
@CastRocOdp, @NizsiSazbaAN, @NizsiSazba, @VstCenStav, @ZvyCenStav, @ZusCenStavDP, @RokyOdpisu, @DP_HodnotaUzivatelska,
@DP_ParovaciZnak, @DP_PlatnostMesicPoAN, @DP_UKod, @DP_UKodUzivAN, @Hodnota, @IdDrPoUP,
@CisloZpusobOdpisu, @CisloUS, @Sazba, @SazbaRocni, @PocetObdobiOdpisAN, @PocetObdobiOdpis, @UP_PlatnostMesicPoAN, @PosledniOdpis,
@UKod, @ParovaciZnak, @CenaStav, @ZusCenStavUP, @UP_UKodUzivAN, @UP_ZusCenCilova, @IdDrPoUm, @CisZam, @Utvar,
@KodLok, @SPZZobraz, @CarKod, @CisloZakazky, @CisloNakladovyOkruh, @Poradac, @PocKusu,
@EvCislo,
@P3_CenaStav, @P3_CisloUS, @P3_CisloZpusobOdpisu, @P3_DatumPlatnosti,
@P3_IdDrPo, @P3_PlatnostMesicPoAN, @P3_ParovaciZnak, @P3_PocetObdobiOdpis,
@P3_PocetObdobiOdpisAN, @P3_PosledniOdpis, @P3_Sazba, @P3_SazbaRocni,
@P3_UKod, @P3_UKodOdpis, @P3_UKodOdpisAN, @P3_UKodUzivAN, @P3_ZusCenCilova, @P3_ZusCenStav,
@P3Pohyby,
@Um_NadKarta_CisloMaj, @Um_NadKarta_TypMaj,
@CZCPAKod, @CZCCKod, @OperativniEvidence, @OE_CenaStav, @Um_CisloOrg, @Um_CisloOrg2, @DatumZarukyDo,
@UcetMajetku, @UcetOdpisu, @UcetNakladDoLimitu,
@Ucetporizenimajetku, @UcetOpravek, @UcetZustatkoveCeny
WHILE 1=1
BEGIN
SET @ChybaPriImportu=0
SET @TextChybyImportu=''
IF @InterniVerze=1
BEGIN
IF @TypMaj IS NOT NULL
IF NOT EXISTS(SELECT * FROM TabMaTyp WHERE TypMaj=@TypMaj)
BEGIN
SET @ChybaPriImportu=1
IF @TextChybyImportu<>'' SET @TextChybyImportu=@TextChybyImportu + ' | '
SET @TextChybyImportu = @TextChybyImportu + dbo.hpf_UniImportHlasky('248A0B61-B589-48B7-9392-AD25DFB3ADE8', @JazykVerze, @TypMaj, DEFAULT, DEFAULT, DEFAULT)
END
IF @CisloMaj IS NOT NULL
BEGIN
IF (@CisloMaj<1)or(@CisloMaj>99999999)
BEGIN
SET @ChybaPriImportu=1
IF @TextChybyImportu<>'' SET @TextChybyImportu=@TextChybyImportu + ' | '
SET @TextChybyImportu = @TextChybyImportu + dbo.hpf_UniImportHlasky('79699CCE-C9B7-443F-A8DB-720FEFFD6373', @JazykVerze, DEFAULT, DEFAULT, DEFAULT, DEFAULT)
END
END
ELSE
BEGIN
  IF @TypMaj IS NOT NULL
    EXEC hp_Ma_CisloMajetku @CisloMaj OUTPUT, @TypMaj, 0
  ELSE SET @CisloMaj=1
END
IF @UKodOdpis IS NOT NULL
IF NOT EXISTS(SELECT * FROM TabUKod WHERE CisloKontace=@UKodOdpis)
BEGIN
SET @ChybaPriImportu=1
IF @TextChybyImportu<>'' SET @TextChybyImportu=@TextChybyImportu + ' | '
SET @TextChybyImportu = @TextChybyImportu + dbo.hpf_UniImportHlasky('CA294443-4A0B-47F2-822F-FE8EBF43DC7C', @JazykVerze, CAST(@UKodOdpis AS NVARCHAR), DEFAULT, DEFAULT, DEFAULT)
END
IF @IdDrPoDP IS NOT NULL
IF NOT EXISTS(SELECT * FROM TabMaDrPo WHERE ID=@IdDrPoDP)
BEGIN
SET @ChybaPriImportu=1
IF @TextChybyImportu<>'' SET @TextChybyImportu=@TextChybyImportu + ' | '
SET @TextChybyImportu = @TextChybyImportu + dbo.hpf_UniImportHlasky('E2684EDE-CA85-41E5-9F78-8CCDFE907C64', @JazykVerze, CAST(@IdDrPoDP AS NVARCHAR), DEFAULT, DEFAULT, DEFAULT)
END
IF @Skupina IS NOT NULL
IF NOT (@Skupina >= 0 and @Skupina <= 8 or @Skupina >= 10 and @Skupina <= 11 or @Skupina >= 20 and @Skupina <= 23 or @Skupina >= 28 and @Skupina <= 29)
BEGIN
SET @ChybaPriImportu=1
IF @TextChybyImportu<>'' SET @TextChybyImportu=@TextChybyImportu + ' | '
SET @TextChybyImportu = @TextChybyImportu + dbo.hpf_UniImportHlasky('18DB0037-3C2B-4ED9-B787-59D635AE8433', @JazykVerze, DEFAULT, DEFAULT, DEFAULT, DEFAULT)
END
IF @CastRocOdp IS NOT NULL
IF (@CastRocOdp<0)or(@CastRocOdp>100)
BEGIN
SET @ChybaPriImportu=1
IF @TextChybyImportu<>'' SET @TextChybyImportu=@TextChybyImportu + ' | '
SET @TextChybyImportu = @TextChybyImportu + dbo.hpf_UniImportHlasky('C940A38F-9CCB-4545-9947-30D1D33CE5AE', @JazykVerze, DEFAULT, DEFAULT, DEFAULT, DEFAULT)
END
IF @NizsiSazba IS NOT NULL
IF @NizsiSazba<=-0.0000001
BEGIN
SET @ChybaPriImportu=1
IF @TextChybyImportu<>'' SET @TextChybyImportu=@TextChybyImportu + ' | '
SET @TextChybyImportu = @TextChybyImportu + dbo.hpf_UniImportHlasky('E2362982-4CB3-4CF2-9FA5-56B947A1014F', @JazykVerze, DEFAULT, DEFAULT, DEFAULT, DEFAULT)
END
IF @DP_UKod IS NOT NULL
IF NOT EXISTS(SELECT * FROM TabUKod WHERE CisloKontace=@DP_UKod)
BEGIN
SET @ChybaPriImportu=1
IF @TextChybyImportu<>'' SET @TextChybyImportu=@TextChybyImportu + ' | '
SET @TextChybyImportu = @TextChybyImportu + dbo.hpf_UniImportHlasky('B5FD7BC1-F3F6-4BC7-9743-742AD009CC7C', @JazykVerze, CAST(@DP_UKod AS NVARCHAR), DEFAULT, DEFAULT, DEFAULT)
END
IF @IdDrPoUP IS NOT NULL
IF NOT EXISTS(SELECT * FROM TabMaDrPo WHERE ID=@IdDrPoUP)
BEGIN
SET @ChybaPriImportu=1
IF @TextChybyImportu<>'' SET @TextChybyImportu=@TextChybyImportu + ' | '
SET @TextChybyImportu = @TextChybyImportu + dbo.hpf_UniImportHlasky('CCA6C4B2-2097-4024-83A9-7A35BAA8BDE6', @JazykVerze, CAST(@IdDrPoUP AS NVARCHAR), DEFAULT, DEFAULT, DEFAULT)
END
IF @CisloZpusobOdpisu IS NOT NULL
IF NOT EXISTS(SELECT * FROM TabMaZpusobyOdpisu WHERE Cislo=@CisloZpusobOdpisu)
BEGIN
SET @ChybaPriImportu=1
IF @TextChybyImportu<>'' SET @TextChybyImportu=@TextChybyImportu + ' | '
SET @TextChybyImportu = @TextChybyImportu + dbo.hpf_UniImportHlasky('2C2A484F-223B-46E7-BEB6-61198EFCF649', @JazykVerze, CAST(@CisloZpusobOdpisu AS NVARCHAR), DEFAULT, DEFAULT, DEFAULT)
END
IF @CisloUS IS NOT NULL
IF NOT EXISTS(SELECT * FROM TabMaUS WHERE CisloUS=@CisloUS)
BEGIN
SET @ChybaPriImportu=1
IF @TextChybyImportu<>'' SET @TextChybyImportu=@TextChybyImportu + ' | '
SET @TextChybyImportu = @TextChybyImportu + dbo.hpf_UniImportHlasky('0D632515-7BBD-4054-9333-EE2FDFABBD8C', @JazykVerze, CAST(@CisloUS AS NVARCHAR), DEFAULT, DEFAULT, DEFAULT)
END
IF @PocetObdobiOdpis IS NOT NULL
IF @PocetObdobiOdpis<0
BEGIN
SET @ChybaPriImportu=1
IF @TextChybyImportu<>'' SET @TextChybyImportu=@TextChybyImportu + ' | '
SET @TextChybyImportu = @TextChybyImportu + dbo.hpf_UniImportHlasky('4A3B9E43-29B7-483F-AB76-4FDA6A15BF1B', @JazykVerze, DEFAULT, DEFAULT, DEFAULT, DEFAULT)
END
IF @UKod IS NOT NULL
IF NOT EXISTS(SELECT * FROM TabUKod WHERE CisloKontace=@UKod)
BEGIN
SET @ChybaPriImportu=1
IF @TextChybyImportu<>'' SET @TextChybyImportu=@TextChybyImportu + ' | '
SET @TextChybyImportu = @TextChybyImportu + dbo.hpf_UniImportHlasky('85BC5F6A-F60B-42CA-8AC6-1CAF93A24167', @JazykVerze, CAST(@UKod AS NVARCHAR), DEFAULT, DEFAULT, DEFAULT)
END
IF @UP_ZusCenCilova IS NOT NULL
IF @UP_ZusCenCilova<0
BEGIN
SET @ChybaPriImportu=1
IF @TextChybyImportu<>'' SET @TextChybyImportu=@TextChybyImportu + ' | '
SET @TextChybyImportu = @TextChybyImportu + dbo.hpf_UniImportHlasky('F1188661-0527-4A79-8884-91B39561F121', @JazykVerze, DEFAULT, DEFAULT, DEFAULT, DEFAULT)
END
IF @IdDrPoUm IS NOT NULL
IF NOT EXISTS(SELECT * FROM TabMaDrPo WHERE ID=@IdDrPoUm)
BEGIN
SET @ChybaPriImportu=1
IF @TextChybyImportu<>'' SET @TextChybyImportu=@TextChybyImportu + ' | '
SET @TextChybyImportu = @TextChybyImportu + dbo.hpf_UniImportHlasky('163D0B38-F7E4-4A10-A360-608A72C9462F', @JazykVerze, CAST(@IdDrPoUm AS NVARCHAR), DEFAULT, DEFAULT, DEFAULT)
END
IF @CisZam IS NOT NULL
IF NOT EXISTS(SELECT * FROM TabCisZam WHERE Cislo=@CisZam)
BEGIN
SET @ChybaPriImportu=1
IF @TextChybyImportu<>'' SET @TextChybyImportu=@TextChybyImportu + ' | '
SET @TextChybyImportu = @TextChybyImportu + dbo.hpf_UniImportHlasky('F5003BED-6EAD-46D1-8C67-305A0EA61705', @JazykVerze, CAST(@CisZam AS NVARCHAR), DEFAULT, DEFAULT, DEFAULT)
END
IF @Utvar IS NOT NULL
IF NOT EXISTS(SELECT * FROM TabStrom WHERE Cislo=@Utvar)
BEGIN
SET @ChybaPriImportu=1
IF @TextChybyImportu<>'' SET @TextChybyImportu=@TextChybyImportu + ' | '
SET @TextChybyImportu = @TextChybyImportu + dbo.hpf_UniImportHlasky('A5C75180-8F27-42D7-9B23-0632710E6EB5', @JazykVerze, CAST(@Utvar AS NVARCHAR), DEFAULT, DEFAULT, DEFAULT)
END
IF @KodLok IS NOT NULL
IF NOT EXISTS(SELECT * FROM TabMaLok WHERE KodLok=@KodLok)
BEGIN
SET @ChybaPriImportu=1
IF @TextChybyImportu<>'' SET @TextChybyImportu=@TextChybyImportu + ' | '
SET @TextChybyImportu = @TextChybyImportu + dbo.hpf_UniImportHlasky('03C26D07-5314-4122-8D93-AFCC9109A3A8', @JazykVerze, CAST(@KodLok AS NVARCHAR), DEFAULT, DEFAULT, DEFAULT)
END
IF @CisloZakazky IS NOT NULL
IF NOT EXISTS(SELECT * FROM TabZakazka WHERE CisloZakazky=@CisloZakazky)
BEGIN
SET @ChybaPriImportu=1
IF @TextChybyImportu<>'' SET @TextChybyImportu=@TextChybyImportu + ' | '
SET @TextChybyImportu = @TextChybyImportu + dbo.hpf_UniImportHlasky('F8F59726-1E74-4FC0-90BF-94425A2D5019', @JazykVerze, CAST(@CisloZakazky AS NVARCHAR), DEFAULT, DEFAULT, DEFAULT)
END
IF @CisloNakladovyOkruh IS NOT NULL
IF NOT EXISTS(SELECT * FROM TabNakladovyOkruh WHERE Cislo=@CisloNakladovyOkruh)
BEGIN
SET @ChybaPriImportu=1
IF @TextChybyImportu<>'' SET @TextChybyImportu=@TextChybyImportu + ' | '
SET @TextChybyImportu = @TextChybyImportu + dbo.hpf_UniImportHlasky('C452A8EC-9169-4F93-9EC4-A27217E0FBA7', @JazykVerze, CAST(@CisloNakladovyOkruh AS NVARCHAR), DEFAULT, DEFAULT, DEFAULT)
END
IF @PocKusu IS NOT NULL
IF @PocKusu<=0
BEGIN
SET @ChybaPriImportu=1
IF @TextChybyImportu<>'' SET @TextChybyImportu=@TextChybyImportu + ' | '
SET @TextChybyImportu = @TextChybyImportu + dbo.hpf_UniImportHlasky('D97EC2B6-2AFD-423A-B9B7-8FE61A269652', @JazykVerze, DEFAULT, DEFAULT, DEFAULT, DEFAULT)
END
IF @P3_CisloUS IS NOT NULL
IF NOT EXISTS(SELECT * FROM TabMaUS WHERE CisloUS=@P3_CisloUS)
BEGIN
SET @ChybaPriImportu=1
IF @TextChybyImportu<>'' SET @TextChybyImportu=@TextChybyImportu + ' | '
SET @TextChybyImportu = @TextChybyImportu + dbo.hpf_UniImportHlasky('68A3D3FA-D3F7-4C9F-A901-98ACDC731670', @JazykVerze, CAST(@P3_CisloUS AS NVARCHAR), DEFAULT, DEFAULT, DEFAULT)
END
IF @P3_CisloZpusobOdpisu IS NOT NULL
IF NOT EXISTS(SELECT * FROM TabMaZpusobyOdpisu WHERE Cislo=@P3_CisloZpusobOdpisu)
BEGIN
SET @ChybaPriImportu=1
IF @TextChybyImportu<>'' SET @TextChybyImportu=@TextChybyImportu + ' | '
SET @TextChybyImportu = @TextChybyImportu + dbo.hpf_UniImportHlasky('B66D2D92-AB7B-410B-A4C6-7C681543B196', @JazykVerze, CAST(@P3_CisloZpusobOdpisu AS NVARCHAR), DEFAULT, DEFAULT, DEFAULT)
END
IF @P3_IdDrPo IS NOT NULL
IF NOT EXISTS(SELECT * FROM TabMaDrPo WHERE ID=@P3_IdDrPo)
BEGIN
SET @ChybaPriImportu=1
IF @TextChybyImportu<>'' SET @TextChybyImportu=@TextChybyImportu + ' | '
SET @TextChybyImportu = @TextChybyImportu + dbo.hpf_UniImportHlasky('97751CB2-AC0D-4FC1-9272-61E088CB75B1', @JazykVerze, CAST(@P3_IdDrPo AS NVARCHAR), DEFAULT, DEFAULT, DEFAULT)
END
IF @P3_PocetObdobiOdpis IS NOT NULL
IF @P3_PocetObdobiOdpis<0
BEGIN
SET @ChybaPriImportu=1
IF @TextChybyImportu<>'' SET @TextChybyImportu=@TextChybyImportu + ' | '
SET @TextChybyImportu = @TextChybyImportu + dbo.hpf_UniImportHlasky('81CA020E-DD05-461B-8B79-7B9DDCAF0804', @JazykVerze, DEFAULT, DEFAULT, DEFAULT, DEFAULT)
END
IF @P3_UKod IS NOT NULL
IF NOT EXISTS(SELECT * FROM TabUKod WHERE CisloKontace=@P3_UKod)
BEGIN
SET @ChybaPriImportu=1
IF @TextChybyImportu<>'' SET @TextChybyImportu=@TextChybyImportu + ' | '
SET @TextChybyImportu = @TextChybyImportu + dbo.hpf_UniImportHlasky('D16C5E70-662E-4E00-9438-5F5BCD7D71E2', @JazykVerze, CAST(@P3_UKod AS NVARCHAR), DEFAULT, DEFAULT, DEFAULT)
END
IF @P3_UKodOdpis IS NOT NULL
IF NOT EXISTS(SELECT * FROM TabUKod WHERE CisloKontace=@P3_UKodOdpis)
BEGIN
SET @ChybaPriImportu=1
IF @TextChybyImportu<>'' SET @TextChybyImportu=@TextChybyImportu + ' | '
SET @TextChybyImportu = @TextChybyImportu + dbo.hpf_UniImportHlasky('5001812B-5303-4F8A-85DD-68A0B8217149', @JazykVerze, CAST(@P3_UKodOdpis AS NVARCHAR), DEFAULT, DEFAULT, DEFAULT)
END
IF @P3_ZusCenCilova IS NOT NULL
IF @P3_ZusCenCilova<0
BEGIN
SET @ChybaPriImportu=1
IF @TextChybyImportu<>'' SET @TextChybyImportu=@TextChybyImportu + ' | '
SET @TextChybyImportu = @TextChybyImportu + dbo.hpf_UniImportHlasky('175DC471-3AA6-4663-8721-54D0D44777C0', @JazykVerze, DEFAULT, DEFAULT, DEFAULT, DEFAULT)
END
SET @SPZID = NULL
IF @SPZZobraz IS NOT NULL
BEGIN
SET @SPZID=(SELECT TOP 1 ID FROM TabIVozidlo WHERE SPZZobraz=@SPZZobraz)
IF @SPZID IS NULL
BEGIN
SET @ChybaPriImportu=1
IF @TextChybyImportu<>'' SET @TextChybyImportu=@TextChybyImportu + ' | '
SET @TextChybyImportu = @TextChybyImportu + dbo.hpf_UniImportHlasky('A4018275-D13C-4399-9709-D22AD35FA06B', @JazykVerze, DEFAULT, DEFAULT, DEFAULT, DEFAULT)
END
END
IF (@EvCislo IS NOT NULL)AND(@SPZID IS NULL)
BEGIN
SET @SPZID=(SELECT TOP 1 ID FROM TabIVozidlo WHERE EvCislo=@EvCislo)
IF @SPZID IS NULL
BEGIN
SET @ChybaPriImportu=1
IF @TextChybyImportu<>'' SET @TextChybyImportu=@TextChybyImportu + ' | '
SET @TextChybyImportu = @TextChybyImportu + dbo.hpf_UniImportHlasky('52BCC6F5-A481-4863-8BCD-76E2463C8072', @JazykVerze, DEFAULT, DEFAULT, DEFAULT, DEFAULT)
END
END
IF @Um_CisloOrg IS NOT NULL
IF NOT EXISTS(SELECT * FROM TabCisOrg WHERE CisloOrg=@Um_CisloOrg)
BEGIN
SET @ChybaPriImportu=1
IF @TextChybyImportu<>'' SET @TextChybyImportu=@TextChybyImportu + ' | '
SET @TextChybyImportu = @TextChybyImportu + dbo.hpf_UniImportHlasky('3D736ACC-09C3-4BA8-A47E-218FD883826A', @JazykVerze, CAST(@Um_CisloOrg AS NVARCHAR), DEFAULT, DEFAULT, DEFAULT)
END
IF @Um_CisloOrg2 IS NOT NULL
IF NOT EXISTS(SELECT * FROM TabCisOrg WHERE CisloOrg=@Um_CisloOrg2)
BEGIN
SET @ChybaPriImportu=1
IF @TextChybyImportu<>'' SET @TextChybyImportu=@TextChybyImportu + ' | '
SET @TextChybyImportu = @TextChybyImportu + dbo.hpf_UniImportHlasky('3D736ACC-09C3-4BA8-A47E-218FD883826A', @JazykVerze, CAST(@Um_CisloOrg2 AS NVARCHAR), DEFAULT, DEFAULT, DEFAULT)
END
SET @Um_NadKarta_Id = NULL
IF (SELECT COUNT(*) FROM TabMaKar WHERE CisloMaj = @Um_NadKarta_CisloMaj AND TypMaj=@Um_NadKarta_TypMaj AND Prislusenstvi=0)=1
  SET @Um_NadKarta_Id = (SELECT ID FROM TabMaKar WHERE CisloMaj = @Um_NadKarta_CisloMaj AND TypMaj=@Um_NadKarta_TypMaj AND Prislusenstvi=0)
IF @ChybaPriImportu=0
BEGIN
IF @CZCPAKod IS NOT NULL
  SET @CZCPA_AN=1
ELSE
  SET @CZCPA_AN=0
IF @CZCCKod IS NOT NULL
  SET @CZCC_AN=1
ELSE
  SET @CZCC_AN=0
INSERT TabMaPrZa(TypMaj, CisloMaj, Nazev1, SKP, DatumPor, DatumZav, DatumPlatnostiDP,
DatumPlatnostiUP, DatumPlatnostiUM, ZpusobPorizeni, TypOzn, Vyrobeno, Vyrobce, Zeme, VyrCislo, Doklad,
DanovePohyby, UcetniPohyby, P30o12, P30o12Odpis, OpisUcetnich, Trida, Polozka1, Polozka2, UKodOdpis,
UKodOdpisAN, IdDrPoDP, ZpusobDP, ZvyseniOdpisu, Zastaveni, Skupina, TechnickyZhodnoceno, CastRocOdp,
NizsiSazbaAN, NizsiSazba, VstCenStav, ZvyCenStav, ZusCenStavDP, RokyOdpisu, DP_HodnotaUzivatelska,
DP_ParovaciZnak, DP_PlatnostMesicPoAN, DP_UKod, DP_UKodUzivAN, Hodnota, IdDrPoUP,
CisloZpusobOdpisu, CisloUS, Sazba, SazbaRocni, PocetObdobiOdpisAN, PocetObdobiOdpis, UP_PlatnostMesicPoAN, PosledniOdpis,
UKod, ParovaciZnak, CenaStav, ZusCenStavUP, UP_UKodUzivAN, UP_ZusCenCilova, IdDrPoUm, CisZam, Utvar,
KodLok, IDVozidlo, CarKod, CisloZakazky, CisloNakladovyOkruh, Poradac, PocKusu,
P3_CenaStav, P3_CisloUS, P3_CisloZpusobOdpisu, P3_DatumPlatnosti,
P3_IdDrPo, P3_PlatnostMesicPoAN, P3_ParovaciZnak, P3_PocetObdobiOdpis,
P3_PocetObdobiOdpisAN, P3_PosledniOdpis, P3_Sazba, P3_SazbaRocni,
P3_UKod, P3_UKodOdpis, P3_UKodOdpisAN, P3_UKodUzivAN, P3_ZusCenCilova, P3_ZusCenStav,
P3Pohyby, Prislusenstvi, Um_NadKarta_Id, CZCPAKod, CZCPA_AN, CZCCKod, CZCC_AN, OperativniEvidence, OE_CenaStav, Um_CisloOrg, Um_CisloOrg2, DatumZarukyDo,
UcetMajetku, UcetOdpisu, UcetNakladDoLimitu, Ucetporizenimajetku, UcetOpravek, UcetZustatkoveCeny)
VALUES(@TypMaj, @CisloMaj, ISNULL(@Nazev1, ''), ISNULL(@SKP, ''), @DatumPor, @DatumZav, @DatumPlatnostiDP, @DatumPlatnostiUP,
@DatumPlatnostiUM, @ZpusobPorizeni, ISNULL(@TypOzn, ''), @Vyrobeno, ISNULL(@Vyrobce, ''), ISNULL(@Zeme, ''),
ISNULL(@VyrCislo, ''), ISNULL(@Doklad, ''), @DanovePohyby, @UcetniPohyby, @P30o12, ISNULL(@P30o12Odpis, 0),
@OpisUcetnich, ISNULL(@Trida, ''), ISNULL(@Polozka1, ''), ISNULL(@Polozka2, ''), @UKodOdpis, @UKodOdpisAN, @IdDrPoDP,
@ZpusobDP, @ZvyseniOdpisu, @Zastaveni, @Skupina, @TechnickyZhodnoceno,
@CastRocOdp, @NizsiSazbaAN, @NizsiSazba, @VstCenStav, @ZvyCenStav, @ZusCenStavDP, @RokyOdpisu, @DP_HodnotaUzivatelska,
@DP_ParovaciZnak, @DP_PlatnostMesicPoAN, @DP_UKod, @DP_UKodUzivAN, @Hodnota, @IdDrPoUP,
@CisloZpusobOdpisu, @CisloUS, @Sazba, @SazbaRocni, @PocetObdobiOdpisAN, @PocetObdobiOdpis, @UP_PlatnostMesicPoAN, @PosledniOdpis,
@UKod, @ParovaciZnak, @CenaStav, @ZusCenStavUP, @UP_UKodUzivAN, @UP_ZusCenCilova, @IdDrPoUm, @CisZam, @Utvar,
@KodLok, @SPZID, ISNULL(@CarKod, ''), @CisloZakazky, @CisloNakladovyOkruh, ISNULL(@Poradac, ''),
ISNULL(@PocKusu, 1),
@P3_CenaStav, @P3_CisloUS, @P3_CisloZpusobOdpisu, @P3_DatumPlatnosti,
@P3_IdDrPo, @P3_PlatnostMesicPoAN, @P3_ParovaciZnak, @P3_PocetObdobiOdpis,
@P3_PocetObdobiOdpisAN, @P3_PosledniOdpis, @P3_Sazba, @P3_SazbaRocni,
@P3_UKod, @P3_UKodOdpis, @P3_UKodOdpisAN, @P3_UKodUzivAN, @P3_ZusCenCilova, @P3_ZusCenStav,
@P3Pohyby, 0, @Um_NadKarta_Id, @CZCPAKod, @CZCPA_AN, @CZCCKod, @CZCC_AN, @OperativniEvidence, @OE_CenaStav, @Um_CisloOrg, @Um_CisloOrg2, @DatumZarukyDo,
@UcetMajetku, @UcetOdpisu, @UcetNakladDoLimitu, @Ucetporizenimajetku, @UcetOpravek, @UcetZustatkoveCeny)
SET @IDProtZaved=SCOPE_IDENTITY()
UPDATE TabMaPrZa SET
Poznamka=ISNULL(TabUniImportMaj.Poznamka, ''),
TechnickyPopis=ISNULL(TabUniImportMaj.TechnickyPopis, ''),
PoznamkaDP=ISNULL(TabUniImportMaj.PoznamkaDP, ''),
PoznamkaUP=ISNULL(TabUniImportMaj.PoznamkaUP, ''),
PoznamkaUm=ISNULL(TabUniImportMaj.PoznamkaUm, ''),
P3_Poznamka=ISNULL(TabUniImportMaj.P3_Poznamka, '')
FROM TabUniImportMaj
WHERE TabMaPrZa.ID=@IDProtZaved AND TabUniImportMaj.ID=@ID
IF @@ERROR<>0 SET @ChybaPriImportu=1
IF OBJECT_ID('dbo.epx_UniImportMaj03', 'P') IS NOT NULL EXEC dbo.epx_UniImportMaj03 @IDProtZaved
SET @ChybaCistic=0
EXEC @ChybaCistic=hp_Ma_PrZaCistic @IDProtZaved
IF @ChybaCistic<>0
BEGIN
SET @CisticNeznamy=1
IF @ChybaCistic=91001
BEGIN
SET @ChybaPriImportu=1
SET @CisticNeznamy=0
IF @TextChybyImportu<>'' SET @TextChybyImportu=@TextChybyImportu + ' | '
SET @TextChybyImportu = @TextChybyImportu + dbo.hpf_UniImportHlasky('B4262082-8D64-44CA-87D5-8B1F359F8BD0', @JazykVerze, DEFAULT, DEFAULT, DEFAULT, DEFAULT)
END
IF @ChybaCistic=91002
BEGIN
SET @ChybaPriImportu=1
SET @CisticNeznamy=0
IF @TextChybyImportu<>'' SET @TextChybyImportu=@TextChybyImportu + ' | '
SET @TextChybyImportu = @TextChybyImportu + dbo.hpf_UniImportHlasky('88062520-DABC-41DC-B957-FC1A692622E6', @JazykVerze, DEFAULT, DEFAULT, DEFAULT, DEFAULT)
END
IF @ChybaCistic=91003
BEGIN
SET @ChybaPriImportu=1
SET @CisticNeznamy=0
IF @TextChybyImportu<>'' SET @TextChybyImportu=@TextChybyImportu + ' | '
SET @TextChybyImportu = @TextChybyImportu + dbo.hpf_UniImportHlasky('7B095840-CA62-4E74-8779-87117D11A638', @JazykVerze, DEFAULT, DEFAULT, DEFAULT, DEFAULT)
END
IF @ChybaCistic=91004
BEGIN
SET @ChybaPriImportu=1
SET @CisticNeznamy=0
IF @TextChybyImportu<>'' SET @TextChybyImportu=@TextChybyImportu + ' | '
SET @TextChybyImportu = @TextChybyImportu + dbo.hpf_UniImportHlasky('1BA02C61-01CF-4B78-9210-F51F8FD63BAB', @JazykVerze, DEFAULT, DEFAULT, DEFAULT, DEFAULT)
END
IF @ChybaCistic=91005
BEGIN
SET @ChybaPriImportu=1
SET @CisticNeznamy=0
IF @TextChybyImportu<>'' SET @TextChybyImportu=@TextChybyImportu + ' | '
SET @TextChybyImportu = @TextChybyImportu + dbo.hpf_UniImportHlasky('162E7468-F078-4541-906C-080FD2B20881', @JazykVerze, DEFAULT, DEFAULT, DEFAULT, DEFAULT)
END
IF @ChybaCistic=91008
BEGIN
SET @ChybaPriImportu=1
SET @CisticNeznamy=0
IF @TextChybyImportu<>'' SET @TextChybyImportu=@TextChybyImportu + ' | '
SET @TextChybyImportu = @TextChybyImportu + dbo.hpf_UniImportHlasky('0C723683-0B0A-4169-BAEE-56320634F4C6', @JazykVerze, DEFAULT, DEFAULT, DEFAULT, DEFAULT)
END
IF @ChybaCistic=91046
BEGIN
SET @ChybaPriImportu=1
SET @CisticNeznamy=0
IF @TextChybyImportu<>'' SET @TextChybyImportu=@TextChybyImportu + ' | '
SET @TextChybyImportu = @TextChybyImportu + dbo.hpf_UniImportHlasky('B615ACCB-9BDE-43CB-82F2-06B2D48023CB', @JazykVerze, DEFAULT, DEFAULT, DEFAULT, DEFAULT)
END
IF @ChybaCistic=91047
BEGIN
SET @ChybaPriImportu=1
SET @CisticNeznamy=0
IF @TextChybyImportu<>'' SET @TextChybyImportu=@TextChybyImportu + ' | '
SET @TextChybyImportu = @TextChybyImportu + dbo.hpf_UniImportHlasky('FC116A64-E9EA-4531-80E8-807660B26AAC', @JazykVerze, DEFAULT, DEFAULT, DEFAULT, DEFAULT)
END
IF @ChybaCistic=91101
BEGIN
SET @ChybaPriImportu=1
SET @CisticNeznamy=0
IF @TextChybyImportu<>'' SET @TextChybyImportu=@TextChybyImportu + ' | '
SET @TextChybyImportu = @TextChybyImportu + dbo.hpf_UniImportHlasky('FADB5ABC-6183-4A32-81E6-99DDBE83BA38', @JazykVerze, DEFAULT, DEFAULT, DEFAULT, DEFAULT)
END
IF @ChybaCistic=91102
BEGIN
SET @ChybaPriImportu=1
SET @CisticNeznamy=0
IF @TextChybyImportu<>'' SET @TextChybyImportu=@TextChybyImportu + ' | '
SET @TextChybyImportu = @TextChybyImportu + dbo.hpf_UniImportHlasky('C95A5DF6-BFDF-4D57-A492-EC0EFDE86D1A', @JazykVerze, DEFAULT, DEFAULT, DEFAULT, DEFAULT)
END
IF @ChybaCistic=91103
BEGIN
SET @ChybaPriImportu=1
SET @CisticNeznamy=0
IF @TextChybyImportu<>'' SET @TextChybyImportu=@TextChybyImportu + ' | '
SET @TextChybyImportu = @TextChybyImportu + dbo.hpf_UniImportHlasky('C1395368-2252-4D77-B5CF-90DA66261D68', @JazykVerze, DEFAULT, DEFAULT, DEFAULT, DEFAULT)
END
IF @ChybaCistic=91104
BEGIN
SET @ChybaPriImportu=1
SET @CisticNeznamy=0
IF @TextChybyImportu<>'' SET @TextChybyImportu=@TextChybyImportu + ' | '
SET @TextChybyImportu = @TextChybyImportu + dbo.hpf_UniImportHlasky('F89F0C1D-66ED-41F3-A29C-CE4F4EC8C2D7', @JazykVerze, DEFAULT, DEFAULT, DEFAULT, DEFAULT)
END
IF @ChybaCistic=91105
BEGIN
SET @ChybaPriImportu=1
SET @CisticNeznamy=0
IF @TextChybyImportu<>'' SET @TextChybyImportu=@TextChybyImportu + ' | '
SET @TextChybyImportu = @TextChybyImportu + dbo.hpf_UniImportHlasky('2B020F4A-183D-4478-B46C-F8F075238776', @JazykVerze, DEFAULT, DEFAULT, DEFAULT, DEFAULT)
END
IF @ChybaCistic=91108
BEGIN
SET @ChybaPriImportu=1
SET @CisticNeznamy=0
IF @TextChybyImportu<>'' SET @TextChybyImportu=@TextChybyImportu + ' | '
SET @TextChybyImportu = @TextChybyImportu + dbo.hpf_UniImportHlasky('E000B5F9-C3B6-4DA6-BDDB-3C8C6C4D151F', @JazykVerze, DEFAULT, DEFAULT, DEFAULT, DEFAULT)
END
IF @ChybaCistic=91146
BEGIN
SET @ChybaPriImportu=1
SET @CisticNeznamy=0
IF @TextChybyImportu<>'' SET @TextChybyImportu=@TextChybyImportu + ' | '
SET @TextChybyImportu = @TextChybyImportu + dbo.hpf_UniImportHlasky('0D238AE8-56D7-4CA9-A430-298566ADCE2F', @JazykVerze, DEFAULT, DEFAULT, DEFAULT, DEFAULT)
END
IF @ChybaCistic=91147
BEGIN
SET @ChybaPriImportu=1
SET @CisticNeznamy=0
IF @TextChybyImportu<>'' SET @TextChybyImportu=@TextChybyImportu + ' | '
SET @TextChybyImportu = @TextChybyImportu + dbo.hpf_UniImportHlasky('260FC4B3-E1BB-471C-89E3-0FC4DA2268A1', @JazykVerze, DEFAULT, DEFAULT, DEFAULT, DEFAULT)
END
IF @ChybaCistic=91148
BEGIN
SET @ChybaPriImportu=1
SET @CisticNeznamy=0
IF @TextChybyImportu<>'' SET @TextChybyImportu=@TextChybyImportu + ' | '
SET @TextChybyImportu = @TextChybyImportu + dbo.hpf_UniImportHlasky('75379D67-A606-4B21-B37B-EFD737B22DC4', @JazykVerze, DEFAULT, DEFAULT, DEFAULT, DEFAULT)
END
IF @ChybaCistic=91149
BEGIN
SET @ChybaPriImportu=1
SET @CisticNeznamy=0
IF @TextChybyImportu<>'' SET @TextChybyImportu=@TextChybyImportu + ' | '
SET @TextChybyImportu = @TextChybyImportu + dbo.hpf_UniImportHlasky('F5EDF131-F8C4-40F1-99F7-FAACAB87F37E', @JazykVerze, DEFAULT, DEFAULT, DEFAULT, DEFAULT)
END
IF @ChybaCistic=91201
BEGIN
SET @ChybaPriImportu=1
SET @CisticNeznamy=0
IF @TextChybyImportu<>'' SET @TextChybyImportu=@TextChybyImportu + ' | '
SET @TextChybyImportu = @TextChybyImportu + dbo.hpf_UniImportHlasky('D3D706A3-7F62-489D-B8A9-964A8190F96D', @JazykVerze, DEFAULT, DEFAULT, DEFAULT, DEFAULT)
END
IF @ChybaCistic=91202
BEGIN
SET @ChybaPriImportu=1
SET @CisticNeznamy=0
IF @TextChybyImportu<>'' SET @TextChybyImportu=@TextChybyImportu + ' | '
SET @TextChybyImportu = @TextChybyImportu + dbo.hpf_UniImportHlasky('2F42D864-2070-429A-ADC2-4947A5F431B0', @JazykVerze, DEFAULT, DEFAULT, DEFAULT, DEFAULT)
END
IF @ChybaCistic=91203
BEGIN
SET @ChybaPriImportu=1
SET @CisticNeznamy=0
IF @TextChybyImportu<>'' SET @TextChybyImportu=@TextChybyImportu + ' | '
SET @TextChybyImportu = @TextChybyImportu + dbo.hpf_UniImportHlasky('79856C7E-53C9-4C7E-875E-312AE29886A5', @JazykVerze, DEFAULT, DEFAULT, DEFAULT, DEFAULT)
END
IF @ChybaCistic=91204
BEGIN
SET @ChybaPriImportu=1
SET @CisticNeznamy=0
IF @TextChybyImportu<>'' SET @TextChybyImportu=@TextChybyImportu + ' | '
SET @TextChybyImportu = @TextChybyImportu + dbo.hpf_UniImportHlasky('8574ACEF-894F-4B4E-A479-90F331A388F0', @JazykVerze, DEFAULT, DEFAULT, DEFAULT, DEFAULT)
END
IF @ChybaCistic=91205
BEGIN
SET @ChybaPriImportu=1
SET @CisticNeznamy=0
IF @TextChybyImportu<>'' SET @TextChybyImportu=@TextChybyImportu + ' | '
SET @TextChybyImportu = @TextChybyImportu + dbo.hpf_UniImportHlasky('6AF51723-E4BA-4D40-B315-F35932FE86BE', @JazykVerze, DEFAULT, DEFAULT, DEFAULT, DEFAULT)
END
IF @ChybaCistic=91208
BEGIN
SET @ChybaPriImportu=1
SET @CisticNeznamy=0
IF @TextChybyImportu<>'' SET @TextChybyImportu=@TextChybyImportu + ' | '
SET @TextChybyImportu = @TextChybyImportu + dbo.hpf_UniImportHlasky('BBDE277D-38BD-4514-9C7E-D6DA64508A56', @JazykVerze, DEFAULT, DEFAULT, DEFAULT, DEFAULT)
END
IF @ChybaCistic=91301
BEGIN
SET @ChybaPriImportu=1
SET @CisticNeznamy=0
IF @TextChybyImportu<>'' SET @TextChybyImportu=@TextChybyImportu + ' | '
SET @TextChybyImportu = @TextChybyImportu + dbo.hpf_UniImportHlasky('E05106DF-947C-4062-841C-0AC9F400C851', @JazykVerze, DEFAULT, DEFAULT, DEFAULT, DEFAULT)
END
IF @ChybaCistic=91302
BEGIN
SET @ChybaPriImportu=1
SET @CisticNeznamy=0
IF @TextChybyImportu<>'' SET @TextChybyImportu=@TextChybyImportu + ' | '
SET @TextChybyImportu = @TextChybyImportu + dbo.hpf_UniImportHlasky('D14B8A89-570B-4628-A718-FCC5912DFA9C', @JazykVerze, DEFAULT, DEFAULT, DEFAULT, DEFAULT)
END
IF @ChybaCistic=91303
BEGIN
SET @ChybaPriImportu=1
SET @CisticNeznamy=0
IF @TextChybyImportu<>'' SET @TextChybyImportu=@TextChybyImportu + ' | '
SET @TextChybyImportu = @TextChybyImportu + dbo.hpf_UniImportHlasky('3B09A730-4CD4-4EE6-ADC9-40E2EDE67E51', @JazykVerze, DEFAULT, DEFAULT, DEFAULT, DEFAULT)
END
IF @ChybaCistic=91304
BEGIN
SET @ChybaPriImportu=1
SET @CisticNeznamy=0
IF @TextChybyImportu<>'' SET @TextChybyImportu=@TextChybyImportu + ' | '
SET @TextChybyImportu = @TextChybyImportu + dbo.hpf_UniImportHlasky('66130EAC-7C4C-4757-A7F2-B01582AFB74B', @JazykVerze, DEFAULT, DEFAULT, DEFAULT, DEFAULT)
END
IF @ChybaCistic=91305
BEGIN
SET @ChybaPriImportu=1
SET @CisticNeznamy=0
IF @TextChybyImportu<>'' SET @TextChybyImportu=@TextChybyImportu + ' | '
SET @TextChybyImportu = @TextChybyImportu + dbo.hpf_UniImportHlasky('4FB6AEA1-6F4E-4EDD-AAC2-684D6B8C6421', @JazykVerze, DEFAULT, DEFAULT, DEFAULT, DEFAULT)
END
IF @ChybaCistic=91308
BEGIN
SET @ChybaPriImportu=1
SET @CisticNeznamy=0
IF @TextChybyImportu<>'' SET @TextChybyImportu=@TextChybyImportu + ' | '
SET @TextChybyImportu = @TextChybyImportu + dbo.hpf_UniImportHlasky('D1A87754-68AF-402D-8DB1-F22C611D7A42', @JazykVerze, DEFAULT, DEFAULT, DEFAULT, DEFAULT)
END
IF @ChybaCistic=91346
BEGIN
SET @ChybaPriImportu=1
SET @CisticNeznamy=0
IF @TextChybyImportu<>'' SET @TextChybyImportu=@TextChybyImportu + ' | '
SET @TextChybyImportu = @TextChybyImportu + dbo.hpf_UniImportHlasky('7AF7E744-D2D8-41C5-BBDE-93AF01428208', @JazykVerze, DEFAULT, DEFAULT, DEFAULT, DEFAULT)
END
IF @ChybaCistic=91347
BEGIN
SET @ChybaPriImportu=1
SET @CisticNeznamy=0
IF @TextChybyImportu<>'' SET @TextChybyImportu=@TextChybyImportu + ' | '
SET @TextChybyImportu = @TextChybyImportu + dbo.hpf_UniImportHlasky('ED9FE259-6053-4963-A5C5-21706F260F9B', @JazykVerze, DEFAULT, DEFAULT, DEFAULT, DEFAULT)
END
IF @ChybaCistic=99999
BEGIN
SET @ChybaPriImportu=1
SET @CisticNeznamy=0
IF @TextChybyImportu<>'' SET @TextChybyImportu=@TextChybyImportu + ' | '
SET @TextChybyImportu = @TextChybyImportu + dbo.hpf_UniImportHlasky('B94309C7-CDD6-48E9-B24D-D994E049003D', @JazykVerze, DEFAULT, DEFAULT, DEFAULT, DEFAULT)
END
IF @ChybaCistic=90009
BEGIN
SET @ChybaPriImportu=1
SET @CisticNeznamy=0
IF @TextChybyImportu<>'' SET @TextChybyImportu=@TextChybyImportu + ' | '
SET @TextChybyImportu = @TextChybyImportu + dbo.hpf_UniImportHlasky('A1915225-057E-42AB-9619-59C70CC10DE6', @JazykVerze, DEFAULT, DEFAULT, DEFAULT, DEFAULT)
END
IF @ChybaCistic=90130
BEGIN
SET @ChybaPriImportu=1
SET @CisticNeznamy=0
IF @TextChybyImportu<>'' SET @TextChybyImportu=@TextChybyImportu + ' | '
SET @TextChybyImportu = @TextChybyImportu + dbo.hpf_UniImportHlasky('43586AC2-28F7-489F-B8C5-BE0EE12957B2', @JazykVerze, DEFAULT, DEFAULT, DEFAULT, DEFAULT)
END
IF @ChybaCistic=90154
BEGIN
SET @ChybaPriImportu=1
SET @CisticNeznamy=0
IF @TextChybyImportu<>'' SET @TextChybyImportu=@TextChybyImportu + ' | '
SET @TextChybyImportu = @TextChybyImportu + dbo.hpf_UniImportHlasky('8E02B28E-980E-4AFB-83E3-36D89F4600D4', @JazykVerze, DEFAULT, DEFAULT, DEFAULT, DEFAULT)
END
IF @ChybaCistic=90478
BEGIN
SET @ChybaPriImportu=1
SET @CisticNeznamy=0
IF @TextChybyImportu<>'' SET @TextChybyImportu=@TextChybyImportu + ' | '
SET @TextChybyImportu = @TextChybyImportu + dbo.hpf_UniImportHlasky('970680BF-128C-4670-8D4E-2731F7FE5B6B', @JazykVerze, DEFAULT, DEFAULT, DEFAULT, DEFAULT)
END
IF @CisticNeznamy=1
BEGIN
SET @ChybaPriImportu=1
IF @TextChybyImportu<>'' SET @TextChybyImportu=@TextChybyImportu + ' | '
SET @TextChybyImportu = @TextChybyImportu + dbo.hpf_UniImportHlasky('72DEBE4F-FF2D-4F3F-84AB-9BA7D9884EE3', @JazykVerze, CAST(@ChybaCistic AS NVARCHAR), DEFAULT, DEFAULT, DEFAULT)
END
END
END
IF @ChybaPriImportu=0
BEGIN
SET @ChybaExtAtr=''
EXEC dbo.hpx_UniImport_ZpracujExtAtr
  @ImportIdent=10,
  @IdImpTable=@ID,
  @IdTargetTable=@IDProtZaved,
  @Chyba=@ChybaExtAtr OUT
IF @ChybaExtAtr<>''
BEGIN
  SET @ChybaPriImportu=1
  IF @TextChybyImportu<>'' SET @TextChybyImportu=@TextChybyImportu + ' | '
  SET @TextChybyImportu = @TextChybyImportu + dbo.hpf_UniImportHlasky('15364319-B20F-4D65-8900-391DE8D4C52F', @JazykVerze, @ChybaExtAtr, DEFAULT, DEFAULT, DEFAULT)
END
END
IF @ChybaPriImportu=0
IF OBJECT_ID('dbo.epx_UniImportMaj03', 'P') IS NOT NULL EXEC dbo.epx_UniImportMaj03 @IDProtZaved
IF @@ERROR<>0 SET @ChybaPriImportu=1
IF @ChybaPriImportu=0 DELETE FROM dbo.TabUniImportMaj WHERE ID=@ID
IF @ChybaPriImportu=1
BEGIN
UPDATE dbo.TabUniImportMaj SET Chyba=@TextChybyImportu, DatumImportu=GETDATE() WHERE ID=@ID
DELETE FROM TabMaPrZa WHERE ID=@IDProtZaved
END
END
FETCH NEXT FROM c INTO @ID, @InterniVerze, @TypMaj, @CisloMaj, @Nazev1, @SKP, @DatumPor, @DatumZav,
@DatumPlatnostiDP, @DatumPlatnostiUP, @DatumPlatnostiUM, @ZpusobPorizeni, @TypOzn, @Vyrobeno, @Vyrobce, @Zeme,
@VyrCislo, @Doklad, @DanovePohyby, @UcetniPohyby, @P30o12, @P30o12Odpis, @OpisUcetnich, @Trida, @Polozka1,
@Polozka2, @UKodOdpis, @UKodOdpisAN, @IdDrPoDP, @ZpusobDP, @ZvyseniOdpisu, @Zastaveni, @Skupina, @TechnickyZhodnoceno,
@CastRocOdp, @NizsiSazbaAN, @NizsiSazba, @VstCenStav, @ZvyCenStav, @ZusCenStavDP, @RokyOdpisu, @DP_HodnotaUzivatelska,
@DP_ParovaciZnak, @DP_PlatnostMesicPoAN, @DP_UKod, @DP_UKodUzivAN, @Hodnota, @IdDrPoUP,
@CisloZpusobOdpisu, @CisloUS, @Sazba, @SazbaRocni, @PocetObdobiOdpisAN, @PocetObdobiOdpis, @UP_PlatnostMesicPoAN, @PosledniOdpis,
@UKod, @ParovaciZnak, @CenaStav, @ZusCenStavUP, @UP_UKodUzivAN, @UP_ZusCenCilova, @IdDrPoUm, @CisZam, @Utvar,
@KodLok, @SPZZobraz, @CarKod, @CisloZakazky, @CisloNakladovyOkruh, @Poradac, @PocKusu,
@EvCislo,
@P3_CenaStav, @P3_CisloUS, @P3_CisloZpusobOdpisu, @P3_DatumPlatnosti,
@P3_IdDrPo, @P3_PlatnostMesicPoAN, @P3_ParovaciZnak, @P3_PocetObdobiOdpis,
@P3_PocetObdobiOdpisAN, @P3_PosledniOdpis, @P3_Sazba, @P3_SazbaRocni,
@P3_UKod, @P3_UKodOdpis, @P3_UKodOdpisAN, @P3_UKodUzivAN, @P3_ZusCenCilova, @P3_ZusCenStav,
@P3Pohyby,
@Um_NadKarta_CisloMaj, @Um_NadKarta_TypMaj,
@CZCPAKod, @CZCCKod, @OperativniEvidence, @OE_CenaStav, @Um_CisloOrg, @Um_CisloOrg2, @DatumZarukyDo,
@UcetMajetku, @UcetOdpisu, @UcetNakladDoLimitu,
@Ucetporizenimajetku, @UcetOpravek, @UcetZustatkoveCeny
IF @@fetch_status<>0 BREAK
END
CLOSE c
DEALLOCATE c
GO

