USE [RayService]
GO

/****** Object:  StoredProcedure [dbo].[hpx_UniImportZam]    Script Date: 26.06.2025 10:24:08 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

/*rpObecneImporty.Import*/CREATE PROC [dbo].[hpx_UniImportZam]
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
SET @PocetRadkuImpTabulky=(SELECT COUNT(*) FROM TabUniImportZam WHERE Chyba IS NULL AND ((@PouzeZaznamyDleLogin=1 AND Autor=SUSER_SNAME())OR(@PouzeZaznamyDleLogin=0)) )
SET @InfoText = dbo.hpf_UniImportHlasky('959B5166-6EEF-44A5-B4AC-DA13F5642C08', @JazykVerze, 'TabUniImportZam', CAST(@PocetRadkuImpTabulky AS NVARCHAR), DEFAULT, DEFAULT)
IF @InfoText IS NOT NULL
  EXEC dbo.hp_ZapisDoZurnalu 1, 77, @InfoText
IF OBJECT_ID('dbo.epx_UniImportZam02', 'P') IS NOT NULL EXEC dbo.epx_UniImportZam02
DECLARE @ChybaPriImportu BIT, @IDZam INT, @IDUstavu INT, @SQLString NVARCHAR(4000), @ChybaExtAtr NVARCHAR(4000),
@TextChybyImportu NVARCHAR(4000), @TEMP_DATE DATETIME,
/*PRI PRIDANI NOVE VERZE IMPORTU PRIDAT DEKLARACE NOVYCH PROMENNYCH I SEM*/
@ID INT, @InterniVerze INT, @Cislo INT, @TitulPred NVARCHAR(15), @TitulZa NVARCHAR(15), @Prijmeni NVARCHAR(100),
@Jmeno NVARCHAR(100), @LoginId NVARCHAR(128), @RodneCislo NVARCHAR(11), @DatumNarozeni DATETIME,
@StatniPrislus NVARCHAR(3), @Narodnost NVARCHAR(100), @Pohlavi SMALLINT, @RodinnyStav SMALLINT,
@RodnePrijmeni NVARCHAR(100), @MistoNarozeni NVARCHAR(100), @AdrTrvUlice NVARCHAR(100), @AdrTrvPopCislo NVARCHAR(15),
@AdrTrvOrCislo NVARCHAR(15), @AdrTrvPSC NVARCHAR(10), @AdrTrvMisto NVARCHAR(100), @AdrTrvZeme NVARCHAR(3),
@AdrPrechUlice NVARCHAR(100), @AdrPrechPopCislo NVARCHAR(15), @AdrPrechOrCislo NVARCHAR(15), @AdrPrechPSC NVARCHAR(10),
@AdrPrechMisto NVARCHAR(100), @AdrPrechZeme NVARCHAR(3), @Stredisko NVARCHAR(30), @NakladovyOkruh NVARCHAR(15),
@Zakazka NVARCHAR(15), @Alias NVARCHAR(15), @CisloOP NVARCHAR(15), @PlatnostOP DATETIME, @CisloPasu NVARCHAR(20),
@PlatnostPasu DATETIME, @CisloRP NVARCHAR(20), @SkupinaRP NVARCHAR(55), @SSN NVARCHAR(24), @PovoleniKPobytu NVARCHAR(30),
@Telefon NVARCHAR(255), @Mobil NVARCHAR(255), @Fax NVARCHAR(255), @Email NVARCHAR(255), @CisloUctu NVARCHAR(40),
@KodUstavu NVARCHAR(15), @IBANElektronicky NVARCHAR(40), @NazevBankSpoj NVARCHAR(100), @HesloPDF NVARCHAR(20),
@ExtAtr1 NVARCHAR(30), @ExtAtr1Nazev NVARCHAR(127), @ExtAtr2 NVARCHAR(255), @ExtAtr2Nazev NVARCHAR(127),
@ExtAtr3 DATETIME, @ExtAtr3Nazev NVARCHAR(127), @ExtAtr4 NUMERIC(19,6), @ExtAtr4Nazev NVARCHAR(127),
@VariabilniSymbol NVARCHAR(20), @KonstantniSymbol NVARCHAR(10), @SpecifickySymbol NVARCHAR(10), @MenaBankSpoj NVARCHAR(3), @PlatebniTitul NVARCHAR(10),
@CilovaZeme NVARCHAR(3), @HromadneProEmail NVARCHAR(255), @PasVydal NVARCHAR(40),
@AdrKontUlice NVARCHAR(100), @AdrKontPopCislo NVARCHAR(15), @AdrKontOrCislo NVARCHAR(15), @AdrKontPSC NVARCHAR(10), @AdrKontMisto NVARCHAR(100), @AdrKontZeme NVARCHAR(3),
@SWIFTUstavu NVARCHAR(15)
DECLARE c CURSOR LOCAL FAST_FORWARD FOR
/*PRI PRIDANI NOVE VERZE IMPORTU PRIDAT NOVE PROMENNE I SEM*/
SELECT ID, InterniVerze, Cislo, TitulPred, TitulZa, Prijmeni, Jmeno, LoginId, RodneCislo, DatumNarozeni,
StatniPrislus, Narodnost, Pohlavi, RodinnyStav, RodnePrijmeni, MistoNarozeni, AdrTrvUlice, AdrTrvPopCislo,
AdrTrvOrCislo, AdrTrvPSC, AdrTrvMisto, AdrTrvZeme, AdrPrechUlice, AdrPrechPopCislo, AdrPrechOrCislo, AdrPrechPSC,
AdrPrechMisto, AdrPrechZeme, Stredisko, NakladovyOkruh, Zakazka, Alias, CisloOP, PlatnostOP, CisloPasu,
PlatnostPasu, CisloRP, SkupinaRP, SSN, PovoleniKPobytu, Telefon, Mobil, Fax, Email, CisloUctu, KodUstavu, IBANElektronicky,
NazevBankSpoj, HesloPDF, ExtAtr1, ExtAtr1Nazev, ExtAtr2, ExtAtr2Nazev, ExtAtr3, ExtAtr3Nazev, ExtAtr4, ExtAtr4Nazev,
ISNULL(VariabilniSymbol, ''), ISNULL(KonstantniSymbol, ''), ISNULL(SpecifickySymbol, ''), MenaBankSpoj, PlatebniTitul, CilovaZeme, HromadneProEmail, PasVydal,
AdrKontUlice, AdrKontPopCislo, AdrKontOrCislo, AdrKontPSC, AdrKontMisto, AdrKontZeme, SWIFTUstavu
FROM dbo.TabUniImportZam
WHERE Chyba IS NULL
 AND ((@PouzeZaznamyDleLogin=1 AND Autor=SUSER_SNAME())OR(@PouzeZaznamyDleLogin=0)) 
OPEN c
/*PRI PRIDANI NOVE VERZE IMPORTU PRIDAT NOVE PROMENNE I SEM*/
FETCH NEXT FROM c INTO @ID, @InterniVerze, @Cislo, @TitulPred, @TitulZa, @Prijmeni, @Jmeno, @LoginId, @RodneCislo,
@DatumNarozeni, @StatniPrislus, @Narodnost, @Pohlavi, @RodinnyStav, @RodnePrijmeni, @MistoNarozeni, @AdrTrvUlice,
@AdrTrvPopCislo, @AdrTrvOrCislo, @AdrTrvPSC, @AdrTrvMisto, @AdrTrvZeme, @AdrPrechUlice, @AdrPrechPopCislo,
@AdrPrechOrCislo, @AdrPrechPSC, @AdrPrechMisto, @AdrPrechZeme, @Stredisko, @NakladovyOkruh, @Zakazka, @Alias,
@CisloOP, @PlatnostOP, @CisloPasu, @PlatnostPasu, @CisloRP, @SkupinaRP, @SSN, @PovoleniKPobytu, @Telefon, @Mobil,
@Fax, @Email, @CisloUctu, @KodUstavu, @IBANElektronicky, @NazevBankSpoj, @HesloPDF, @ExtAtr1, @ExtAtr1Nazev, @ExtAtr2, @ExtAtr2Nazev,
@ExtAtr3, @ExtAtr3Nazev, @ExtAtr4, @ExtAtr4Nazev, @VariabilniSymbol, @KonstantniSymbol, @SpecifickySymbol, @MenaBankSpoj, @PlatebniTitul, @CilovaZeme, @HromadneProEmail, @PasVydal,
@AdrKontUlice, @AdrKontPopCislo, @AdrKontOrCislo, @AdrKontPSC, @AdrKontMisto, @AdrKontZeme, @SWIFTUstavu
WHILE 1=1
BEGIN
SET @ChybaPriImportu=0
SET @TextChybyImportu=''
SET @IDZam=NULL
/*VERZE IMPORTU C.1----------------------------------------------------------------------------------------------------------*/
IF @InterniVerze=1
BEGIN
/*--pokud je Cislo zamestance vyplneno, overim, jestli uz existuje a pokud ano, chyba a konec*/
IF ((@Cislo IS NOT NULL)AND(EXISTS(SELECT ID FROM TabCisZam WHERE Cislo=@Cislo)))
BEGIN
UPDATE dbo.TabUniImportZam SET Chyba = dbo.hpf_UniImportHlasky('9FD6818C-49E6-4C0B-B788-B662D5441F56', @JazykVerze, CAST(@Cislo AS NVARCHAR(10)), DEFAULT, DEFAULT, DEFAULT), DatumImportu=GETDATE() WHERE ID=@ID
END
ELSE
BEGIN
BEGIN TRAN T1
/*pokud Cislo zam neni vyplneno, tak vygeneruju*/
IF @Cislo IS NULL EXEC @Cislo=dbo.hp_NajdiPrvniVolny 'TabCisZam','Cislo',1,999999,'',1,1
IF @@ERROR<>0 SET @ChybaPriImportu=1
/*insertujeme zakladni udaje zamestnance*/
IF @Cislo>=0 AND @Cislo<=999999
BEGIN
INSERT TabCisZam(Cislo, TitulPred, TitulZa, Prijmeni, Jmeno, LoginId, RodneCislo,
Narodnost, Pohlavi, RodinnyStav, RodnePrijmeni, MistoNarozeni, AdrTrvUlice, AdrTrvPopCislo,
AdrTrvOrCislo, AdrTrvMisto, AdrPrechUlice, AdrPrechPopCislo, AdrPrechOrCislo, AdrPrechMisto,
Alias, CisloOP, CisloPasu, CisloRP, SkupinaRP, SSN, PovoleniKPobytu, HesloPDF, PasVydal,
AdrKontUlice, AdrKontPopCislo, AdrKontOrCislo, AdrKontMisto)
VALUES(@Cislo, ISNULL(@TitulPred, ''), ISNULL(@TitulZa, ''), ISNULL(@Prijmeni, ''), ISNULL(@Jmeno, ''),
ISNULL(@LoginId, ''), ISNULL(@RodneCislo, ''), ISNULL(@Narodnost, ''),
ISNULL(@Pohlavi, 0), ISNULL(@RodinnyStav, 0), ISNULL(@RodnePrijmeni, ''), ISNULL(@MistoNarozeni, ''),
ISNULL(@AdrTrvUlice, ''), ISNULL(@AdrTrvPopCislo, ''), ISNULL(@AdrTrvOrCislo, ''),
ISNULL(@AdrTrvMisto, ''), ISNULL(@AdrPrechUlice, ''), ISNULL(@AdrPrechPopCislo, ''),
ISNULL(@AdrPrechOrCislo, ''), ISNULL(@AdrPrechMisto, ''), ISNULL(@Alias, ''), ISNULL(@CisloOP, ''),
ISNULL(@CisloPasu, ''), ISNULL(@CisloRP, ''), ISNULL(@SkupinaRP, ''), ISNULL(@SSN, ''),
ISNULL(@PovoleniKPobytu, ''), ISNULL(@HesloPDF, ''), ISNULL(@PasVydal, ''),
ISNULL(@AdrKontUlice, ''), ISNULL(@AdrKontPopCislo, ''), ISNULL(@AdrKontOrCislo, ''), ISNULL(@AdrKontMisto, ''))
IF @@ERROR<>0 SET @ChybaPriImportu=1
/*dohledani ID zamestnance, hodi se v dalsi casti importu*/
SET @IDZam=SCOPE_IDENTITY()
/*poznamka*/
UPDATE TabCisZam SET TabCisZam.Poznamka=TabUniImportZam.Poznamka
FROM TabUniImportZam
WHERE TabUniImportZam.ID=@ID AND TabCisZam.Cislo=@Cislo
IF @@ERROR<>0 SET @ChybaPriImportu=1
/*PSC*/
IF @AdrTrvPSC IS NOT NULL
BEGIN
UPDATE TabCisZam SET AdrTrvPSC=@AdrTrvPSC WHERE Cislo=@Cislo
IF @@ERROR<>0 SET @ChybaPriImportu=1
IF NOT EXISTS(SELECT ID FROM TabPSC WHERE Cislo=@AdrTrvPSC) INSERT TabPSC(Cislo) VALUES(@AdrTrvPSC)
IF @@ERROR<>0 SET @ChybaPriImportu=1
END
IF @AdrPrechPSC IS NOT NULL
BEGIN
UPDATE TabCisZam SET AdrPrechPSC=@AdrPrechPSC WHERE Cislo=@Cislo
IF @@ERROR<>0 SET @ChybaPriImportu=1
IF NOT EXISTS(SELECT ID FROM TabPSC WHERE Cislo=@AdrPrechPSC) INSERT TabPSC(Cislo) VALUES(@AdrPrechPSC)
IF @@ERROR<>0 SET @ChybaPriImportu=1
END
IF @AdrKontPSC IS NOT NULL
BEGIN
UPDATE TabCisZam SET AdrKontPSC=@AdrKontPSC WHERE Cislo=@Cislo
IF @@ERROR<>0 SET @ChybaPriImportu=1
IF NOT EXISTS(SELECT ID FROM TabPSC WHERE Cislo=@AdrKontPSC) INSERT TabPSC(Cislo) VALUES(@AdrKontPSC)
IF @@ERROR<>0 SET @ChybaPriImportu=1
END
/*zeme*/
IF @AdrTrvZeme IS NOT NULL
BEGIN
IF NOT EXISTS(SELECT ID FROM TabZeme WHERE ISOKod=@AdrTrvZeme) INSERT TabZeme(ISOKod, SmeroveCislo, Nazev) VALUES(@AdrTrvZeme, '', '')
IF @@ERROR<>0 SET @ChybaPriImportu=1
UPDATE TabCisZam SET AdrTrvZeme=@AdrTrvZeme WHERE Cislo=@Cislo
IF @@ERROR<>0 SET @ChybaPriImportu=1
END
IF @AdrPrechZeme IS NOT NULL
BEGIN
IF NOT EXISTS(SELECT ID FROM TabZeme WHERE ISOKod=@AdrPrechZeme) INSERT TabZeme(ISOKod, SmeroveCislo, Nazev) VALUES(@AdrPrechZeme, '', '')
IF @@ERROR<>0 SET @ChybaPriImportu=1
UPDATE TabCisZam SET AdrPrechZeme=@AdrPrechZeme WHERE Cislo=@Cislo
IF @@ERROR<>0 SET @ChybaPriImportu=1
END
IF @AdrKontZeme IS NOT NULL
BEGIN
IF NOT EXISTS(SELECT ID FROM TabZeme WHERE ISOKod=@AdrKontZeme) INSERT TabZeme(ISOKod, SmeroveCislo, Nazev) VALUES(@AdrKontZeme, '', '')
IF @@ERROR<>0 SET @ChybaPriImportu=1
UPDATE TabCisZam SET AdrKontZeme=@AdrKontZeme WHERE Cislo=@Cislo
IF @@ERROR<>0 SET @ChybaPriImportu=1
END
/*statni prislusnost*/
IF @StatniPrislus IS NOT NULL
BEGIN
IF NOT EXISTS(SELECT ID FROM TabZeme WHERE ISOKod=@StatniPrislus) INSERT TabZeme(ISOKod, SmeroveCislo, Nazev) VALUES(@StatniPrislus, '', '')
IF @@ERROR<>0 SET @ChybaPriImportu=1
UPDATE TabCisZam SET StatniPrislus=@StatniPrislus WHERE Cislo=@Cislo
IF @@ERROR<>0 SET @ChybaPriImportu=1
END
/*stredisko*/
IF @Stredisko IS NOT NULL
BEGIN
IF EXISTS(SELECT ID FROM TabStrom WHERE Cislo=@Stredisko)
BEGIN
UPDATE TabCisZam SET Stredisko=@Stredisko WHERE Cislo=@Cislo
IF @@ERROR<>0 SET @ChybaPriImportu=1
END
ELSE
BEGIN
SET @ChybaPriImportu=1
IF @TextChybyImportu<>'' SET @TextChybyImportu=@TextChybyImportu + ' | '
SET @TextChybyImportu = @TextChybyImportu + dbo.hpf_UniImportHlasky('A5C75180-8F27-42D7-9B23-0632710E6EB5', @JazykVerze, @Stredisko, DEFAULT, DEFAULT, DEFAULT)
END
END
/*nakladovy okruh*/
IF @NakladovyOkruh IS NOT NULL
BEGIN
IF EXISTS(SELECT ID FROM TabNakladovyOkruh WHERE Cislo=@NakladovyOkruh)
BEGIN
UPDATE TabCisZam SET NakladovyOkruh=@NakladovyOkruh WHERE Cislo=@Cislo
IF @@ERROR<>0 SET @ChybaPriImportu=1
END
ELSE
BEGIN
SET @ChybaPriImportu=1
IF @TextChybyImportu<>'' SET @TextChybyImportu=@TextChybyImportu + ' | '
SET @TextChybyImportu = @TextChybyImportu + dbo.hpf_UniImportHlasky('C452A8EC-9169-4F93-9EC4-A27217E0FBA7', @JazykVerze, @NakladovyOkruh, DEFAULT, DEFAULT, DEFAULT)
END
END
/*zakazka*/
IF @Zakazka IS NOT NULL
BEGIN
IF EXISTS(SELECT ID FROM TabZakazka WHERE CisloZakazky=@Zakazka)
BEGIN
UPDATE TabCisZam SET Zakazka=@Zakazka WHERE Cislo=@Cislo
IF @@ERROR<>0 SET @ChybaPriImportu=1
END
ELSE
BEGIN
SET @ChybaPriImportu=1
IF @TextChybyImportu<>'' SET @TextChybyImportu=@TextChybyImportu + ' | '
SET @TextChybyImportu = @TextChybyImportu + dbo.hpf_UniImportHlasky('F8F59726-1E74-4FC0-90BF-94425A2D5019', @JazykVerze, @Zakazka, DEFAULT, DEFAULT, DEFAULT)
END
END
/*datum narozeni*/
IF @DatumNarozeni IS NOT NULL
BEGIN
UPDATE TabCisZam SET DatumNarozeni=@DatumNarozeni WHERE Cislo=@Cislo
IF @@ERROR<>0 SET @ChybaPriImportu=1
END
ELSE
IF @RodneCislo IS NOT NULL
BEGIN
  SET @RodneCislo=REPLACE(@RodneCislo, '/', '')
  IF ISNUMERIC(@RodneCislo)=1
  BEGIN
  SET @TEMP_DATE=(SELECT CASE WHEN CAST(SUBSTRING(@RodneCislo, 1, 2) AS INT)>35 THEN '19'+SUBSTRING(@RodneCislo, 1, 2) ELSE '20'+SUBSTRING(@RodneCislo, 1, 2) END
+
CASE WHEN CAST(SUBSTRING(@RodneCislo, 3, 2) AS INT)>50 THEN RIGHT('0' + CAST(CAST(SUBSTRING(@RodneCislo, 3, 2) AS INT) - 50 AS VARCHAR), 2)
ELSE SUBSTRING(@RodneCislo, 3, 2)
END
+
SUBSTRING(@RodneCislo, 5, 2))
  UPDATE TabCisZam SET DatumNarozeni=@TEMP_DATE
  WHERE Cislo=@Cislo
  IF @@ERROR<>0 SET @ChybaPriImportu=1
  END
END
IF (@Pohlavi IS NULL) AND (@RodneCislo IS NOT NULL)
BEGIN
  IF (CAST(SUBSTRING(@RodneCislo, 3, 2) AS INT))>50
    UPDATE TabCisZam SET Pohlavi=1
    WHERE Cislo=@Cislo
  ELSE
    UPDATE TabCisZam SET Pohlavi=0
    WHERE Cislo=@Cislo
END
/*platnost OP*/
IF @PlatnostOP IS NOT NULL
BEGIN
UPDATE TabCisZam SET PlatnostOP=@PlatnostOP WHERE Cislo=@Cislo
IF @@ERROR<>0 SET @ChybaPriImportu=1
END
/*platnost pasu*/
IF @PlatnostPasu IS NOT NULL
BEGIN
UPDATE TabCisZam SET PlatnostPasu=@PlatnostPasu WHERE Cislo=@Cislo
IF @@ERROR<>0 SET @ChybaPriImportu=1
END
/*kontakty*/
IF @Telefon IS NOT NULL
IF NOT EXISTS(SELECT ID FROM TabKontakty WHERE IDCisZam=@IDZam AND Spojeni=@Telefon AND Druh=1)
INSERT TabKontakty(IDCisZam, Spojeni, Druh) VALUES(@IDZam, @Telefon, 1)
IF @@ERROR<>0 SET @ChybaPriImportu=1
IF @Mobil IS NOT NULL
IF NOT EXISTS(SELECT ID FROM TabKontakty WHERE IDCisZam=@IDZam AND Spojeni=@Mobil AND Druh=2)
INSERT TabKontakty(IDCisZam, Spojeni, Druh) VALUES(@IDZam, @Mobil, 2)
IF @@ERROR<>0 SET @ChybaPriImportu=1
IF @Fax IS NOT NULL
IF NOT EXISTS(SELECT ID FROM TabKontakty WHERE IDCisZam=@IDZam AND Spojeni=@Fax AND Druh=3)
INSERT TabKontakty(IDCisZam, Spojeni, Druh) VALUES(@IDZam, @Fax, 3)
IF @@ERROR<>0 SET @ChybaPriImportu=1
IF @Email IS NOT NULL
IF NOT EXISTS(SELECT ID FROM TabKontakty WHERE IDCisZam=@IDZam AND Spojeni=@Email AND Druh=6)
INSERT TabKontakty(IDCisZam, Spojeni, Druh) VALUES(@IDZam, @Email, 6)
IF @@ERROR<>0 SET @ChybaPriImportu=1
IF @HromadneProEmail IS NOT NULL
IF NOT EXISTS(SELECT ID FROM TabKontakty WHERE IDCisZam=@IDZam AND Spojeni=@HromadneProEmail AND Druh=10)
INSERT TabKontakty(IDCisZam, Spojeni, Druh) VALUES(@IDZam, @HromadneProEmail, 10)
IF @@ERROR<>0 SET @ChybaPriImportu=1
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
IF @CilovaZeme IS NOT NULL
  IF NOT EXISTS(SELECT ID FROM TabZeme WHERE ISOKod=@CilovaZeme) INSERT TabZeme(ISOKod, SmeroveCislo, Nazev) VALUES(@CilovaZeme, '', '')
IF @KodUstavu IS NOT NULL SET @IDUstavu=(SELECT TOP 1 ID FROM TabPenezniUstavy WHERE KodUstavu=@KodUstavu)
IF (@KodUstavu IS NULL)AND(@SWIFTUstavu IS NOT NULL) SET @IDUstavu=(SELECT TOP 1 ID FROM TabPenezniUstavy WHERE SWIFTUstavu=@SWIFTUstavu)
INSERT TabBankSpojeni(IDZam, IDUstavu, NazevBankSpoj, CisloUctu, VariabilniSymbol, KonstantniSymbol, SpecifickySymbol, IBANElektronicky, Prednastaveno, Mena, PlatebniTitul, CilovaZeme)
VALUES(@IDZam, @IDUstavu, ISNULL(@NazevBankSpoj, ''), ISNULL(@CisloUctu, ''), @VariabilniSymbol, @KonstantniSymbol, @SpecifickySymbol, ISNULL(@IBANElektronicky, ''), 1, @MenaBankSpoj, ISNULL(@PlatebniTitul, ''), @CilovaZeme)
IF @@ERROR<>0 SET @ChybaPriImportu=1
END
/*externi atributy*/
/*--ex. atrb. 1 - typ NVARCHAR(30)*/
IF (@ExtAtr1 IS NOT NULL)AND(@ExtAtr1Nazev IS NOT NULL)
BEGIN
IF (OBJECT_ID('TabCisZam_EXT','U')IS NOT NULL)AND(COLUMNPROPERTY(OBJECT_ID('TabCisZam_EXT','U'),'_'+@ExtAtr1Nazev,'AllowsNull')IS NOT NULL)
BEGIN
SET @ExtAtr1Nazev='_' + @ExtAtr1Nazev
IF EXISTS(SELECT ID FROM TabCisZam_EXT WHERE ID=@IDZam)
SET @SQLString='UPDATE TabCisZam_EXT SET ' + @ExtAtr1Nazev + '=N' + '''' + @ExtAtr1 + '''' + ' WHERE ID=' + CAST(@IDZam AS NVARCHAR(10))
ELSE
SET @SQLString='INSERT TabCisZam_EXT(ID, ' + @ExtAtr1Nazev + ') VALUES(' + CAST(@IDZam AS NVARCHAR(10)) + ', N' + '''' + @ExtAtr1 + '''' + ')'
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
IF (OBJECT_ID('TabCisZam_EXT','U')IS NOT NULL)AND(COLUMNPROPERTY(OBJECT_ID('TabCisZam_EXT','U'),'_'+@ExtAtr2Nazev,'AllowsNull')IS NOT NULL)
BEGIN
SET @ExtAtr2Nazev='_' + @ExtAtr2Nazev
IF EXISTS(SELECT ID FROM TabCisZam_EXT WHERE ID=@IDZam)
SET @SQLString='UPDATE TabCisZam_EXT SET ' + @ExtAtr2Nazev + '=N' + '''' + @ExtAtr2 + '''' + ' WHERE ID=' + CAST(@IDZam AS NVARCHAR(10))
ELSE
SET @SQLString='INSERT TabCisZam_EXT(ID, ' + @ExtAtr2Nazev + ') VALUES(' + CAST(@IDZam AS NVARCHAR(10)) + ', N' + '''' + @ExtAtr2 + '''' + ')'
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
IF (OBJECT_ID('TabCisZam_EXT','U')IS NOT NULL)AND(COLUMNPROPERTY(OBJECT_ID('TabCisZam_EXT','U'),'_'+@ExtAtr3Nazev,'AllowsNull')IS NOT NULL)
BEGIN
SET @ExtAtr3Nazev='_' + @ExtAtr3Nazev
IF EXISTS(SELECT ID FROM TabCisZam_EXT WHERE ID=@IDZam)
SET @SQLString='UPDATE TabCisZam_EXT SET ' + @ExtAtr3Nazev + '=' + '''' + CONVERT(NVARCHAR(10),@ExtAtr3, 112) + '''' + ' WHERE ID=' + CAST(@IDZam AS NVARCHAR(10))
ELSE
SET @SQLString='INSERT TabCisZam_EXT(ID, ' + @ExtAtr3Nazev + ') VALUES(' + CAST(@IDZam AS NVARCHAR(10)) + ', ' + '''' + CONVERT(NVARCHAR(10),@ExtAtr3, 112) + '''' + ')'
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
IF (OBJECT_ID('TabCisZam_EXT','U')IS NOT NULL)AND(COLUMNPROPERTY(OBJECT_ID('TabCisZam_EXT','U'),'_'+@ExtAtr4Nazev,'AllowsNull')IS NOT NULL)
BEGIN
SET @ExtAtr4Nazev='_' + @ExtAtr4Nazev
IF EXISTS(SELECT ID FROM TabCisZam_EXT WHERE ID=@IDZam)
SET @SQLString='UPDATE TabCisZam_EXT SET ' + @ExtAtr4Nazev + '=' + CAST(@ExtAtr4 AS NVARCHAR(26)) +  ' WHERE ID=' + CAST(@IDZam AS NVARCHAR(10))
ELSE
SET @SQLString='INSERT TabCisZam_EXT(ID, ' + @ExtAtr4Nazev + ') VALUES(' + CAST(@IDZam AS NVARCHAR(10)) + ', ' + CAST(@ExtAtr4 AS NVARCHAR(26)) + ')'
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
  @ImportIdent=1,
  @IdImpTable=@ID,
  @IdTargetTable=@IDZam,
  @Chyba=@ChybaExtAtr OUT
IF @ChybaExtAtr<>''
BEGIN
  SET @ChybaPriImportu=1
  IF @TextChybyImportu<>'' SET @TextChybyImportu=@TextChybyImportu + ' | '
  SET @TextChybyImportu = @TextChybyImportu + dbo.hpf_UniImportHlasky('15364319-B20F-4D65-8900-391DE8D4C52F', @JazykVerze, @ChybaExtAtr, DEFAULT, DEFAULT, DEFAULT)
END
END
ELSE
BEGIN
SET @ChybaPriImportu=1
IF @TextChybyImportu<>'' SET @TextChybyImportu=@TextChybyImportu + ' | '
SET @TextChybyImportu = @TextChybyImportu + dbo.hpf_UniImportHlasky('8982B8E6-E28A-4BB5-90CD-8E98ACBE5723', @JazykVerze, DEFAULT, DEFAULT, DEFAULT, DEFAULT)
END
IF OBJECT_ID('dbo.epx_UniImportZam03', 'P') IS NOT NULL EXEC dbo.epx_UniImportZam03 @IDZam
/*--pokud nedoslo k chybe, smazeme zaznam z importni tabulky*/
IF @@ERROR<>0 SET @ChybaPriImportu=1
IF @ChybaPriImportu=0 DELETE FROM dbo.TabUniImportZam WHERE ID=@ID
/*--pokud probehlo vsechno OK, pustime transakci, jinak vse vratime zpet*/
IF @ChybaPriImportu=1
BEGIN
IF @@trancount>0 ROLLBACK TRAN T1
UPDATE dbo.TabUniImportZam SET Chyba=@TextChybyImportu, DatumImportu=GETDATE() WHERE ID=@ID
END
ELSE IF @@trancount>0 COMMIT TRAN T1
END
END
/*--VERZE IMPORTU C.1------------------------------------------------------------------------------------------------------------*/
SET @Cislo=NULL
/*--PRI PRIDANI NOVE VERZE IMPORTU PRIDAT NOVE PROMENNE I SEM*/
FETCH NEXT FROM c INTO @ID, @InterniVerze, @Cislo, @TitulPred, @TitulZa, @Prijmeni, @Jmeno, @LoginId, @RodneCislo,
@DatumNarozeni, @StatniPrislus, @Narodnost, @Pohlavi, @RodinnyStav, @RodnePrijmeni, @MistoNarozeni, @AdrTrvUlice,
@AdrTrvPopCislo, @AdrTrvOrCislo, @AdrTrvPSC, @AdrTrvMisto, @AdrTrvZeme, @AdrPrechUlice, @AdrPrechPopCislo,
@AdrPrechOrCislo, @AdrPrechPSC, @AdrPrechMisto, @AdrPrechZeme, @Stredisko, @NakladovyOkruh, @Zakazka, @Alias,
@CisloOP, @PlatnostOP, @CisloPasu, @PlatnostPasu, @CisloRP, @SkupinaRP, @SSN, @PovoleniKPobytu, @Telefon, @Mobil,
@Fax, @Email, @CisloUctu, @KodUstavu, @IBANElektronicky, @NazevBankSpoj, @HesloPDF, @ExtAtr1, @ExtAtr1Nazev, @ExtAtr2, @ExtAtr2Nazev,
@ExtAtr3, @ExtAtr3Nazev, @ExtAtr4, @ExtAtr4Nazev, @VariabilniSymbol, @KonstantniSymbol, @SpecifickySymbol, @MenaBankSpoj, @PlatebniTitul, @CilovaZeme, @HromadneProEmail, @PasVydal,
@AdrKontUlice, @AdrKontPopCislo, @AdrKontOrCislo, @AdrKontPSC, @AdrKontMisto, @AdrKontZeme, @SWIFTUstavu
IF @@fetch_status<>0 BREAK
END
CLOSE c
DEALLOCATE c
GO

