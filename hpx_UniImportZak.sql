USE [RayService]
GO

/****** Object:  StoredProcedure [dbo].[hpx_UniImportZak]    Script Date: 26.06.2025 10:23:31 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

/*rpObecneImporty.Import*/CREATE PROC [dbo].[hpx_UniImportZak]
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
SET @PocetRadkuImpTabulky=(SELECT COUNT(*) FROM TabUniImportZak WHERE Chyba IS NULL AND ((@PouzeZaznamyDleLogin=1 AND Autor=SUSER_SNAME())OR(@PouzeZaznamyDleLogin=0)) )
SET @InfoText = dbo.hpf_UniImportHlasky('959B5166-6EEF-44A5-B4AC-DA13F5642C08', @JazykVerze, 'TabUniImportZak', CAST(@PocetRadkuImpTabulky AS NVARCHAR), DEFAULT, DEFAULT)
IF @InfoText IS NOT NULL
  EXEC dbo.hp_ZapisDoZurnalu 1, 77, @InfoText
IF OBJECT_ID('dbo.epx_UniImportZak02', 'P') IS NOT NULL EXEC dbo.epx_UniImportZak02
DECLARE @ChybaPriImportu BIT, @IDZak INT, @SQLString NVARCHAR(4000), @TextChybyImportu NVARCHAR(4000), @ChybaExtAtr NVARCHAR(4000),
/*PRI PRIDANI NOVE VERZE IMPORTU PRIDAT DEKLARACE NOVYCH PROMENNYCH I SEM*/
@ID INT, @InterniVerze INT, @CisloZakazky NVARCHAR(15), @Nazev NVARCHAR(100), @DruhyNazev NVARCHAR(100),
@Prijemce INT, @PrijemceMU INT, @Zadavatel INT, @KontaktOsoba INT, @Zodpovida INT, @Stredisko NVARCHAR(30),
@DatumStartPlan DATETIME, @DatumStartReal DATETIME, @DatumKonecPlan DATETIME, @DatumKonecReal DATETIME,
@Ukonceno TINYINT, @Stav NVARCHAR(15), @Priorita NVARCHAR(10), @Identifikator NVARCHAR(15), @NadrizenaZak NVARCHAR(15),
@NavaznaZak NVARCHAR(15), @CisloObjednavky NVARCHAR(30), @CisloNabidky NVARCHAR(30), @CisloSmlouvy NVARCHAR(30),
@ExtAtr1 NVARCHAR(30), @ExtAtr1Nazev NVARCHAR(127), @ExtAtr2 NVARCHAR(255), @ExtAtr2Nazev NVARCHAR(127),
@ExtAtr3 DATETIME, @ExtAtr3Nazev NVARCHAR(127), @ExtAtr4 NUMERIC(19,6), @ExtAtr4Nazev NVARCHAR(127),
@VynosPlan NUMERIC(19,6), @Rada NVARCHAR(3)
DECLARE c CURSOR LOCAL FAST_FORWARD FOR
/*PRI PRIDANI NOVE VERZE IMPORTU PRIDAT NOVE PROMENNE I SEM*/
SELECT ID, InterniVerze, CisloZakazky, Nazev, DruhyNazev, Prijemce, PrijemceMU, Zadavatel, KontaktOsoba, Zodpovida,
Stredisko, DatumStartPlan, DatumStartReal, DatumKonecPlan, DatumKonecReal, Ukonceno, Stav, Priorita,
Identifikator, NadrizenaZak, NavaznaZak, CisloObjednavky, CisloNabidky, CisloSmlouvy, ExtAtr1, ExtAtr1Nazev,
ExtAtr2, ExtAtr2Nazev, ExtAtr3, ExtAtr3Nazev, ExtAtr4, ExtAtr4Nazev, VynosPlan, Rada
FROM dbo.TabUniImportZak
WHERE Chyba IS NULL
 AND ((@PouzeZaznamyDleLogin=1 AND Autor=SUSER_SNAME())OR(@PouzeZaznamyDleLogin=0)) 
OPEN c
/*PRI PRIDANI NOVE VERZE IMPORTU PRIDAT NOVE PROMENNE I SEM*/
FETCH NEXT FROM c INTO @ID, @InterniVerze, @CisloZakazky, @Nazev, @DruhyNazev, @Prijemce, @PrijemceMU, @Zadavatel,
@KontaktOsoba, @Zodpovida, @Stredisko, @DatumStartPlan, @DatumStartReal, @DatumKonecPlan,
@DatumKonecReal, @Ukonceno, @Stav, @Priorita, @Identifikator, @NadrizenaZak, @NavaznaZak,
@CisloObjednavky, @CisloNabidky, @CisloSmlouvy, @ExtAtr1, @ExtAtr1Nazev, @ExtAtr2,
@ExtAtr2Nazev, @ExtAtr3, @ExtAtr3Nazev, @ExtAtr4, @ExtAtr4Nazev, @VynosPlan, @Rada
WHILE 1=1
BEGIN
SET @ChybaPriImportu=0
SET @TextChybyImportu=''
SET @IDZak=NULL
/*VERZE IMPORTU C.1----------------------------------------------------------------------------------------------------------*/
IF @InterniVerze=1
BEGIN
/*--existuje uz zakazka? pokud ano, chyba a konec*/
IF EXISTS(SELECT ID FROM TabZakazka WHERE CisloZakazky=@CisloZakazky)
BEGIN
 UPDATE dbo.TabUniImportZak SET Chyba= dbo.hpf_UniImportHlasky('FD335D81-01FD-4FBA-BB9C-C714B22CA7A3', @JazykVerze, @CisloZakazky, DEFAULT, DEFAULT, DEFAULT), DatumImportu=GETDATE() WHERE ID=@ID
END
ELSE
BEGIN
BEGIN TRAN T1
/*insertujeme zakladni udaje zakazky bez navaznych udaju*/
INSERT TabZakazka(CisloZakazky, Nazev, DruhyNazev, DatumStartPlan, DatumStartReal, DatumKonecPlan, DatumKonecReal,
Ukonceno, CisloObjednavky, CisloNabidky, CisloSmlouvy, VynosPlan)
VALUES(@CisloZakazky, ISNULL(@Nazev, ''), ISNULL(@DruhyNazev, ''), @DatumStartPlan, @DatumStartReal,
@DatumKonecPlan, @DatumKonecReal, ISNULL(@Ukonceno, 0), ISNULL(@CisloObjednavky, ''),
ISNULL(@CisloNabidky, ''), ISNULL(@CisloSmlouvy, ''), @VynosPlan)
/*dohledani ID zakazky, hodi se v dalsi casti importu*/
SET @IDZak=SCOPE_IDENTITY()
IF @@ERROR<>0 SET @ChybaPriImportu=1
/*poznamka*/
UPDATE TabZakazka SET TabZakazka.Poznamka=TabUniImportZak.Poznamka
FROM TabUniImportZak
WHERE TabUniImportZak.ID=@ID AND TabZakazka.CisloZakazky=@CisloZakazky
IF @@ERROR<>0 SET @ChybaPriImportu=1
IF @Rada='' SET @Rada=NULL
IF @Rada IS NOT NULL
BEGIN
  IF NOT EXISTS(SELECT * FROM TabZakazkaRada WHERE Rada=@Rada)
    INSERT TabZakazkaRada(Rada, Systemova, Nazev) VALUES(@Rada, 0, @Rada)
  UPDATE TabZakazka SET Rada=@Rada WHERE ID=@IDZak
END
/*Prijemce*/
IF @Prijemce IS NOT NULL
IF EXISTS(SELECT ID FROM TabCisOrg WHERE CisloOrg=@Prijemce)
BEGIN
UPDATE TabZakazka SET Prijemce=@Prijemce WHERE ID=@IDZak
IF @@ERROR<>0 SET @ChybaPriImportu=1
END
ELSE
BEGIN
SET @ChybaPriImportu=1
IF @TextChybyImportu<>'' SET @TextChybyImportu=@TextChybyImportu + ' | '
SET @TextChybyImportu = @TextChybyImportu + dbo.hpf_UniImportHlasky('C761C86D-9AF8-42CC-AA86-E59FA6149517', @JazykVerze, CAST(@Prijemce AS NVARCHAR(10)), DEFAULT, DEFAULT, DEFAULT)
END
/*PrijemceMU*/
IF @PrijemceMU IS NOT NULL
IF EXISTS(SELECT ID FROM TabCisOrg WHERE CisloOrg=@PrijemceMU)
BEGIN
UPDATE TabZakazka SET PrijemceMU=@PrijemceMU WHERE ID=@IDZak
IF @@ERROR<>0 SET @ChybaPriImportu=1
END
ELSE
BEGIN
SET @ChybaPriImportu=1
IF @TextChybyImportu<>'' SET @TextChybyImportu=@TextChybyImportu + ' | '
SET @TextChybyImportu = @TextChybyImportu + dbo.hpf_UniImportHlasky('0B822CB6-DC73-4E6F-98EB-DF9904226982', @JazykVerze, CAST(@PrijemceMU AS NVARCHAR(10)), DEFAULT, DEFAULT, DEFAULT)
END
/*Zadavatel*/
IF @Zadavatel IS NOT NULL
IF EXISTS(SELECT ID FROM TabCisOrg WHERE CisloOrg=@Zadavatel)
BEGIN
UPDATE TabZakazka SET Zadavatel=@Zadavatel WHERE ID=@IDZak
IF @@ERROR<>0 SET @ChybaPriImportu=1
END
ELSE
BEGIN
SET @ChybaPriImportu=1
IF @TextChybyImportu<>'' SET @TextChybyImportu=@TextChybyImportu + ' | '
SET @TextChybyImportu = @TextChybyImportu + dbo.hpf_UniImportHlasky('F9C0308F-C199-4B53-8098-0154918CA226', @JazykVerze, CAST(@Zadavatel AS NVARCHAR(10)), DEFAULT, DEFAULT, DEFAULT)
END
/*KontaktOsoba*/
IF @KontaktOsoba IS NOT NULL
IF EXISTS(SELECT ID FROM TabCisKOs WHERE Cislo=@KontaktOsoba)
BEGIN
UPDATE TabZakazka SET KontaktOsoba=@KontaktOsoba WHERE ID=@IDZak
IF @@ERROR<>0 SET @ChybaPriImportu=1
END
ELSE
BEGIN
SET @ChybaPriImportu=1
IF @TextChybyImportu<>'' SET @TextChybyImportu=@TextChybyImportu + ' | '
SET @TextChybyImportu = @TextChybyImportu + dbo.hpf_UniImportHlasky('C616168A-116E-4888-B2BD-B105E13287B4', @JazykVerze, CAST(@KontaktOsoba AS NVARCHAR(10)), DEFAULT, DEFAULT, DEFAULT)
END
/*Zodpovida*/
IF @Zodpovida IS NOT NULL
IF EXISTS(SELECT ID FROM TabCisZam WHERE Cislo=@Zodpovida)
BEGIN
UPDATE TabZakazka SET Zodpovida=@Zodpovida WHERE ID=@IDZak
IF @@ERROR<>0 SET @ChybaPriImportu=1
END
ELSE
BEGIN
SET @ChybaPriImportu=1
IF @TextChybyImportu<>'' SET @TextChybyImportu=@TextChybyImportu + ' | '
SET @TextChybyImportu = @TextChybyImportu + dbo.hpf_UniImportHlasky('19E18C3B-E08A-4045-B385-A2FA4EBE7450', @JazykVerze, CAST(@Zodpovida AS NVARCHAR(10)), DEFAULT, DEFAULT, DEFAULT)
END
/*Stredisko*/
IF @Stredisko IS NOT NULL
BEGIN
IF EXISTS(SELECT ID FROM TabStrom WHERE Cislo=@Stredisko)
BEGIN
UPDATE TabZakazka SET Stredisko=@Stredisko WHERE ID=@IDZak
IF @@ERROR<>0 SET @ChybaPriImportu=1
END
ELSE
BEGIN
SET @ChybaPriImportu=1
IF @TextChybyImportu<>'' SET @TextChybyImportu=@TextChybyImportu + ' | '
SET @TextChybyImportu = @TextChybyImportu + dbo.hpf_UniImportHlasky('A5C75180-8F27-42D7-9B23-0632710E6EB5', @JazykVerze, @Stredisko, DEFAULT, DEFAULT, DEFAULT)
END
END
/*Stav*/
IF @Stav IS NOT NULL
BEGIN
IF NOT EXISTS(SELECT Cislo FROM TabZakStavy WHERE Cislo=@Stav) INSERT TabZakStavy(Cislo, Popis) VALUES(@Stav, '')
UPDATE TabZakazka SET Stav=@Stav WHERE ID=@IDZak
IF @@ERROR<>0 SET @ChybaPriImportu=1
END
/*Priorita*/
IF @Priorita IS NOT NULL
BEGIN
IF NOT EXISTS(SELECT Cislo FROM TabZakPriorita WHERE Cislo=@Priorita) INSERT TabZakPriorita(Cislo, Popis) VALUES(@Priorita, '')
UPDATE TabZakazka SET Priorita=@Priorita WHERE ID=@IDZak
IF @@ERROR<>0 SET @ChybaPriImportu=1
END
/*Identifikator*/
IF @Identifikator IS NOT NULL
BEGIN
IF NOT EXISTS(SELECT Cislo FROM TabZakIdent WHERE Cislo=@Identifikator) INSERT TabZakIdent(Cislo, Popis) VALUES(@Identifikator, '')
UPDATE TabZakazka SET Identifikator=@Identifikator WHERE ID=@IDZak
IF @@ERROR<>0 SET @ChybaPriImportu=1
END
/*NadrizenaZakazka*/
IF @NadrizenaZak IS NOT NULL
BEGIN
IF EXISTS(SELECT ID FROM TabZakazka WHERE CisloZakazky=@NadrizenaZak)
BEGIN
UPDATE TabZakazka SET NadrizenaZak=@NadrizenaZak WHERE ID=@IDZak
IF @@ERROR<>0 SET @ChybaPriImportu=1
END
ELSE
BEGIN
SET @ChybaPriImportu=1
IF @TextChybyImportu<>'' SET @TextChybyImportu=@TextChybyImportu + ' | '
SET @TextChybyImportu = @TextChybyImportu + dbo.hpf_UniImportHlasky('5168F871-A0BD-41A7-8DA8-85CBF3F3B3C9', @JazykVerze, @NadrizenaZak, DEFAULT, DEFAULT, DEFAULT)
END
END
/*NavaznaZakazka*/
IF @NavaznaZak IS NOT NULL
BEGIN
IF EXISTS(SELECT ID FROM TabZakazka WHERE CisloZakazky=@NavaznaZak)
BEGIN
UPDATE TabZakazka SET NavaznaZak=@NavaznaZak WHERE ID=@IDZak
IF @@ERROR<>0 SET @ChybaPriImportu=1
END
ELSE
BEGIN
SET @ChybaPriImportu=1
IF @TextChybyImportu<>'' SET @TextChybyImportu=@TextChybyImportu + ' | '
SET @TextChybyImportu = @TextChybyImportu + dbo.hpf_UniImportHlasky('D90822CF-049E-4D27-9490-FF7DF062A23F', @JazykVerze, @NavaznaZak, DEFAULT, DEFAULT, DEFAULT)
END
END
/*externi atributy*/
/*--ex. atrb. 1 - typ NVARCHAR(30)*/
IF (@ExtAtr1 IS NOT NULL)AND(@ExtAtr1Nazev IS NOT NULL)
BEGIN
IF (OBJECT_ID('TabZakazka_EXT','U')IS NOT NULL)AND(COLUMNPROPERTY(OBJECT_ID('TabZakazka_EXT','U'),'_'+@ExtAtr1Nazev,'AllowsNull')IS NOT NULL)
BEGIN
SET @ExtAtr1Nazev='_' + @ExtAtr1Nazev
IF EXISTS(SELECT ID FROM TabZakazka_EXT WHERE ID=@IDZak)
SET @SQLString='UPDATE TabZakazka_EXT SET ' + @ExtAtr1Nazev + '=N' + '''' + @ExtAtr1 + '''' + ' WHERE ID=' + CAST(@IDZak AS NVARCHAR(10))
ELSE
SET @SQLString='INSERT TabZakazka_EXT(ID, ' + @ExtAtr1Nazev + ') VALUES(' + CAST(@IDZak AS NVARCHAR(10)) + ', N' + '''' + @ExtAtr1 + '''' + ')'
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
IF (OBJECT_ID('TabZakazka_EXT','U')IS NOT NULL)AND(COLUMNPROPERTY(OBJECT_ID('TabZakazka_EXT','U'),'_'+@ExtAtr2Nazev,'AllowsNull')IS NOT NULL)
BEGIN
SET @ExtAtr2Nazev='_' + @ExtAtr2Nazev
IF EXISTS(SELECT ID FROM TabZakazka_EXT WHERE ID=@IDZak)
SET @SQLString='UPDATE TabZakazka_EXT SET ' + @ExtAtr2Nazev + '=N' + '''' + @ExtAtr2 + '''' + ' WHERE ID=' + CAST(@IDZak AS NVARCHAR(10))
ELSE
SET @SQLString='INSERT TabZakazka_EXT(ID, ' + @ExtAtr2Nazev + ') VALUES(' + CAST(@IDZak AS NVARCHAR(10)) + ', N' + '''' + @ExtAtr2 + '''' + ')'
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
IF (OBJECT_ID('TabZakazka_EXT','U')IS NOT NULL)AND(COLUMNPROPERTY(OBJECT_ID('TabZakazka_EXT','U'),'_'+@ExtAtr3Nazev,'AllowsNull')IS NOT NULL)
BEGIN
SET @ExtAtr3Nazev='_' + @ExtAtr3Nazev
IF EXISTS(SELECT ID FROM TabZakazka_EXT WHERE ID=@IDZak)
SET @SQLString='UPDATE TabZakazka_EXT SET ' + @ExtAtr3Nazev + '=' + '''' + CONVERT(NVARCHAR(10),@ExtAtr3, 112) + '''' + ' WHERE ID=' + CAST(@IDZak AS NVARCHAR(10))
ELSE
SET @SQLString='INSERT TabZakazka_EXT(ID, ' + @ExtAtr3Nazev + ') VALUES(' + CAST(@IDZak AS NVARCHAR(10)) + ', ' + '''' + CONVERT(NVARCHAR(10),@ExtAtr3, 112) + '''' + ')'
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
IF (OBJECT_ID('TabZakazka_EXT','U')IS NOT NULL)AND(COLUMNPROPERTY(OBJECT_ID('TabZakazka_EXT','U'),'_'+@ExtAtr4Nazev,'AllowsNull')IS NOT NULL)
BEGIN
SET @ExtAtr4Nazev='_' + @ExtAtr4Nazev
IF EXISTS(SELECT ID FROM TabZakazka_EXT WHERE ID=@IDZak)
SET @SQLString='UPDATE TabZakazka_EXT SET ' + @ExtAtr4Nazev + '=' + CAST(@ExtAtr4 AS NVARCHAR(26)) +  ' WHERE ID=' + CAST(@IDZak AS NVARCHAR(10))
ELSE
SET @SQLString='INSERT TabZakazka_EXT(ID, ' + @ExtAtr4Nazev + ') VALUES(' + CAST(@IDZak AS NVARCHAR(10)) + ', ' + CAST(@ExtAtr4 AS NVARCHAR(26)) + ')'
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
  @ImportIdent=2,
  @IdImpTable=@ID,
  @IdTargetTable=@IDZak,
  @Chyba=@ChybaExtAtr OUT
IF @ChybaExtAtr<>''
BEGIN
  SET @ChybaPriImportu=1
  IF @TextChybyImportu<>'' SET @TextChybyImportu=@TextChybyImportu + ' | '
  SET @TextChybyImportu = @TextChybyImportu + dbo.hpf_UniImportHlasky('15364319-B20F-4D65-8900-391DE8D4C52F', @JazykVerze, @ChybaExtAtr, DEFAULT, DEFAULT, DEFAULT)
END
IF OBJECT_ID('dbo.epx_UniImportZak03', 'P') IS NOT NULL EXEC dbo.epx_UniImportZak03 @IDZak
/*--pokud nedoslo k chybe, smazeme zaznam z importni tabulky*/
IF @@ERROR<>0 SET @ChybaPriImportu=1
IF @ChybaPriImportu=0 DELETE FROM dbo.TabUniImportZak WHERE ID=@ID
/*--pokud probehlo vsechno OK, pustime transakci, jinak vse vratime zpet*/
IF @ChybaPriImportu=1
BEGIN
IF @@trancount>0 ROLLBACK TRAN T1
UPDATE dbo.TabUniImportZak SET Chyba=@TextChybyImportu, DatumImportu=GETDATE() WHERE ID=@ID
END
ELSE IF @@trancount>0 COMMIT TRAN T1
END
END
/*--VERZE IMPORTU C.1------------------------------------------------------------------------------------------------------------*/
SET @CisloZakazky=NULL
/*--PRI PRIDANI NOVE VERZE IMPORTU PRIDAT NOVE PROMENNE I SEM*/
FETCH NEXT FROM c INTO @ID, @InterniVerze, @CisloZakazky, @Nazev, @DruhyNazev, @Prijemce, @PrijemceMU, @Zadavatel,
@KontaktOsoba, @Zodpovida, @Stredisko, @DatumStartPlan, @DatumStartReal, @DatumKonecPlan,
@DatumKonecReal, @Ukonceno, @Stav, @Priorita, @Identifikator, @NadrizenaZak, @NavaznaZak,
@CisloObjednavky, @CisloNabidky, @CisloSmlouvy, @ExtAtr1, @ExtAtr1Nazev, @ExtAtr2,
@ExtAtr2Nazev, @ExtAtr3, @ExtAtr3Nazev, @ExtAtr4, @ExtAtr4Nazev, @VynosPlan, @Rada
IF @@fetch_status<>0 BREAK
END
CLOSE c
DEALLOCATE c
GO

