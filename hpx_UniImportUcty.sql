USE [RayService]
GO

/****** Object:  StoredProcedure [dbo].[hpx_UniImportUcty]    Script Date: 26.06.2025 10:23:01 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

/*rpObecneImporty.Import*/CREATE PROC [dbo].[hpx_UniImportUcty]
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
SET @PocetRadkuImpTabulky=(SELECT COUNT(*) FROM TabUniImportUcty WHERE Chyba IS NULL AND ((@PouzeZaznamyDleLogin=1 AND Autor=SUSER_SNAME())OR(@PouzeZaznamyDleLogin=0)) )
SET @InfoText = dbo.hpf_UniImportHlasky('959B5166-6EEF-44A5-B4AC-DA13F5642C08', @JazykVerze, 'TabUniImportUcty', CAST(@PocetRadkuImpTabulky AS NVARCHAR), DEFAULT, DEFAULT)
IF @InfoText IS NOT NULL
  EXEC dbo.hp_ZapisDoZurnalu 1, 77, @InfoText
IF OBJECT_ID('dbo.epx_UniImportUcty02', 'P') IS NOT NULL EXEC dbo.epx_UniImportUcty02
DECLARE @ChybaPriImportu BIT, @SQLString NVARCHAR(4000), @TextChybyImportu NVARCHAR(4000), @IDObdobi INT,
@ID INT, @InterniVerze INT, @CisloUcet NVARCHAR(30), @NazevUctu NVARCHAR(220), @DruhyUcet NVARCHAR(30),
@DruhyNazevUctu NVARCHAR(220), @PovahaUctu TINYINT, @Rozvaha TINYINT, @Vysledovka TINYINT,
@Mena NVARCHAR(3), @NazevUctuSyn NVARCHAR(220), @DruhyNazevUctuSyn NVARCHAR(220), @PovahaUctuSyn TINYINT,
@RozvahaSyn TINYINT, @VysledovkaSyn TINYINT, @CisloUcetSyn NVARCHAR(6), @SledovatCM NCHAR(1), @IdUcet INT,
@MistoPlneni  TINYINT, @ISOKodZeme NVARCHAR(3), @SmerPlneni TINYINT, @NastaveniOdecitat TINYINT, @SazbaDPH NUMERIC(5,2), @KodPlneni TINYINT,
@ZadavaniDIC TINYINT, @Splatnost TINYINT, @UctovaniBanka TINYINT, @ProGenerZapFA BIT
DECLARE c CURSOR LOCAL FAST_FORWARD FOR
SELECT ID, InterniVerze, CisloUcet, NazevUctu, DruhyUcet, DruhyNazevUctu, PovahaUctu, Rozvaha, Vysledovka, Mena,
       MistoPlneni, ISOKodZeme, SmerPlneni, NastaveniOdecitat, SazbaDPH, KodPlneni, ZadavaniDIC, ISNULL(Splatnost, 0), ISNULL(UctovaniBanka, 0), ISNULL(ProGenerZapFA, 0)
FROM dbo.TabUniImportUcty
WHERE Chyba IS NULL
 AND ((@PouzeZaznamyDleLogin=1 AND Autor=SUSER_SNAME())OR(@PouzeZaznamyDleLogin=0)) 
OPEN c
FETCH NEXT FROM c INTO @ID, @InterniVerze, @CisloUcet, @NazevUctu, @DruhyUcet, @DruhyNazevUctu, @PovahaUctu,
@Rozvaha, @Vysledovka, @Mena, @MistoPlneni, @ISOKodZeme, @SmerPlneni, @NastaveniOdecitat, @SazbaDPH, @KodPlneni, @ZadavaniDIC,
@Splatnost, @UctovaniBanka, @ProGenerZapFA
WHILE 1=1
BEGIN
SET @ChybaPriImportu=0
SET @TextChybyImportu=''
IF @InterniVerze=1
BEGIN
IF EXISTS(SELECT * FROM TabCisUct WHERE CisloUcet=@CisloUcet)
BEGIN
  UPDATE dbo.TabUniImportUcty SET Chyba = dbo.hpf_UniImportHlasky('0FC01BC3-B824-4942-9370-3137C5B1DF71', @JazykVerze, @CisloUcet, DEFAULT, DEFAULT, DEFAULT), DatumImportu=GETDATE() WHERE ID=@ID
END
ELSE
BEGIN
BEGIN TRAN T1
EXEC dbo.hp_DotahniCisloUcetZeSyntet @CisloUcet, @CisloUcetSyn OUTPUT
SELECT TOP 1 @NazevUctuSyn=NazevUctu, @DruhyNazevUctuSyn=DruhyNazevUctu,
@PovahaUctuSyn=PovahaUctu, @RozvahaSyn=Rozvaha, @VysledovkaSyn=Vysledovka
FROM TabSyntetik WHERE CisloUcet=@CisloUcetSyn
IF NOT EXISTS(SELECT * FROM TabCisUct WHERE CisloUcet = @CisloUcet) AND EXISTS(SELECT * FROM TabObdobi) INSERT TabCisUct(CisloUcet) VALUES(@CisloUcet)
IF @@ERROR<>0 SET @ChybaPriImportu=1
IF @NazevUctu IS NULL SET @NazevUctu=@NazevUctuSyn
IF @DruhyNazevUctu IS NULL SET @DruhyNazevUctu=@DruhyNazevUctuSyn
IF @PovahaUctu IS NULL SET @PovahaUctu=@PovahaUctuSyn
IF @Rozvaha IS NULL SET @Rozvaha=@RozvahaSyn
IF @Vysledovka IS NULL SET @Vysledovka=@VysledovkaSyn
IF @PovahaUctu=0
BEGIN
SET @Rozvaha=0
SET @Vysledovka=0
END
IF @PovahaUctu=1 SET @Rozvaha=0
IF @PovahaUctu=2 SET @Vysledovka=0
IF @Mena IS NOT NULL
IF NOT EXISTS(SELECT * FROM TabKodMen WHERE Kod=@Mena) INSERT TabKodMen(Kod, Nazev) VALUES(@Mena, '')
IF @@ERROR<>0 SET @ChybaPriImportu=1
SET @SledovatCM=N'N'
IF @Mena IS NOT NULL
  IF @Mena<>(SELECT Kod FROM TabKodMen WHERE HlavniMena=1)
SET @SledovatCM=N'A'
IF @MistoPlneni = 0
BEGIN
  SET @ISOKodZeme = NULL
  SET @SmerPlneni = NULL
  SET @NastaveniOdecitat = NULL
END
IF @ISOKodZeme IS NOT NULL
  IF NOT EXISTS(SELECT ID FROM TabZeme WHERE ISOKod=@ISOKodZeme) INSERT TabZeme(ISOKod, SmeroveCislo, Nazev) VALUES(@ISOKodZeme, '', '')
IF @SazbaDPH IS NOT NULL
IF dbo.hpf_UniImportExistujeSazbaDPH(@SazbaDPH, NULL) = 0
BEGIN
SET @ChybaPriImportu=1
IF @TextChybyImportu<>'' SET @TextChybyImportu=@TextChybyImportu + ' | '
SET @TextChybyImportu = @TextChybyImportu + dbo.hpf_UniImportHlasky('593FB54F-C1E7-48E4-996E-C499F540EF4F', @JazykVerze, CAST(@SazbaDPH AS NVARCHAR(20)), DEFAULT, DEFAULT, DEFAULT)
END
IF @ChybaPriImportu=0
BEGIN
SET @IDObdobi=(SELECT TOP 1 ID FROM TabObdobi)
IF @IDObdobi IS NOT NULL
BEGIN
INSERT INTO TabCisUctDef(IdObdobi, CisloUcet, NazevUctu, DruhyUcet, DruhyNazevUctu, PovahaUctu, Rozvaha, Vysledovka, Mena, SledovatCM, MistoPlneni, ISOKodZeme, SmerPlneni, NastaveniOdecitat, SazbaDPH, KodPlneni, ZadavaniDIC,
Splatnost, UctovaniBanka, ProGenerZapFA)
VALUES(@IDObdobi, @CisloUcet, ISNULL(@NazevUctu, ''), @DruhyUcet, ISNULL(@DruhyNazevUctu, ''), ISNULL(@PovahaUctu, 0), ISNULL(@Rozvaha, 0), ISNULL(@Vysledovka, 0), @Mena, @SledovatCM,
       @MistoPlneni, @ISOKodZeme, @SmerPlneni, @NastaveniOdecitat, @SazbaDPH, @KodPlneni, ISNULL(@ZadavaniDIC, 0), @Splatnost, @UctovaniBanka, @ProGenerZapFA)
IF @@ERROR<>0 SET @ChybaPriImportu=1
SET @IdUcet = SCOPE_IDENTITY()
IF OBJECT_ID('dbo.epx_UniImportUcty03', 'P') IS NOT NULL EXEC dbo.epx_UniImportUcty03 @IDUcet
END
END
IF @@ERROR<>0 SET @ChybaPriImportu=1
IF @ChybaPriImportu=0 DELETE FROM dbo.TabUniImportUcty WHERE ID=@ID
IF @ChybaPriImportu=1
BEGIN
IF @@trancount>0 ROLLBACK TRAN T1
UPDATE dbo.TabUniImportUcty SET Chyba=@TextChybyImportu, DatumImportu=GETDATE() WHERE ID=@ID
END
ELSE IF @@trancount>0 COMMIT TRAN T1
END
END
FETCH NEXT FROM c INTO @ID, @InterniVerze, @CisloUcet, @NazevUctu, @DruhyUcet, @DruhyNazevUctu, @PovahaUctu,
@Rozvaha, @Vysledovka, @Mena, @MistoPlneni, @ISOKodZeme, @SmerPlneni, @NastaveniOdecitat, @SazbaDPH, @KodPlneni, @ZadavaniDIC,
@Splatnost, @UctovaniBanka, @ProGenerZapFA
IF @@fetch_status<>0 BREAK
END
CLOSE c
DEALLOCATE c
GO

