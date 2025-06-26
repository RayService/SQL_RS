USE [RayService]
GO

/****** Object:  StoredProcedure [dbo].[hpx_UniImportKal]    Script Date: 26.06.2025 10:17:36 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

/*rpObecneImporty.Import*/CREATE PROC [dbo].[hpx_UniImportKal]
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
SET @PocetRadkuImpTabulky=(SELECT COUNT(*) FROM TabUniImportKal WHERE Chyba IS NULL AND ((@PouzeZaznamyDleLogin=1 AND Autor=SUSER_SNAME())OR(@PouzeZaznamyDleLogin=0)) )
SET @InfoText = dbo.hpf_UniImportHlasky('959B5166-6EEF-44A5-B4AC-DA13F5642C08', @JazykVerze, 'TabUniImportKal', CAST(@PocetRadkuImpTabulky AS NVARCHAR), DEFAULT, DEFAULT)
IF @InfoText IS NOT NULL
  EXEC dbo.hp_ZapisDoZurnalu 1, 77, @InfoText
IF OBJECT_ID('dbo.epx_UniImportKal02', 'P') IS NOT NULL EXEC dbo.epx_UniImportKal02
DECLARE @ChybaPriImportu BIT, @TextChybyImportu NVARCHAR(4000), @IDZam INT, @IDObdobi INT, @RokA INT, @MesicA INT, @CisloKalendare NVARCHAR(3),
        @IdKalendar INT, @IdOsobKal INT, @TypDne SMALLINT, @IdObdobiBezne INT, @TypKal SMALLINT,
        @SQLString NVARCHAR(4000), @OsCisloKontrola INT, @RodneCisloKontrola NVARCHAR(11),
        @DatumKontrola DATETIME, @PocetHodinKontrola NUMERIC(9,2), @RokB INT, @MesicB INT, 
@ID INT, @InterniVerze INT, @Cislo INT, @RodneCislo NVARCHAR(11), @Alias NVARCHAR(15), @Datum DATETIME, @PocetHodin NUMERIC(9,2),
@Svatek BIT
SET @IDObdobi=(SELECT IdObdobi FROM TabMzdObd WHERE Stav=1)
SET @IdObdobiBezne=(SELECT IdObdobi FROM TabMzdObd WHERE Stav=2)
SELECT @RokA=Rok, @MesicA=Mesic FROM TabMzdObd WHERE IdObdobi=@IdObdobi
SELECT @RokB=Rok, @MesicB=Mesic FROM TabMzdObd WHERE IdObdobi=@IdObdobiBezne
IF OBJECT_ID('tempdb..#LCSJAS_UNIIMPORT_KAL') IS NOT NULL
DROP TABLE #LCSJAS_UNIIMPORT_KAL
CREATE TABLE [#LCSJAS_UNIIMPORT_KAL] (
[id] INT IDENTITY(1,1) NOT NULL,
[PocetHodin] NUMERIC(19,6) NOT NULL,
[Datum] DATETIME NOT NULL
) ON [PRIMARY]
DECLARE c CURSOR LOCAL FAST_FORWARD FOR
SELECT ID, InterniVerze, Cislo, RodneCislo, Alias, Datum, PocetHodin, Svatek
FROM dbo.TabUniImportKal
WHERE Chyba IS NULL
 AND ((@PouzeZaznamyDleLogin=1 AND Autor=SUSER_SNAME())OR(@PouzeZaznamyDleLogin=0)) 
OPEN c
FETCH NEXT FROM c INTO @ID, @InterniVerze, @Cislo, @RodneCislo, @Alias, @Datum, @PocetHodin, @Svatek
WHILE 1=1
BEGIN
SET @ChybaPriImportu=0
SET @TextChybyImportu=''
SET @IDZam=NULL
IF @InterniVerze=1
BEGIN
BEGIN TRAN T1
IF ISNULL(@Alias, '')<>''
IF (SELECT MzAlias FROM TabHGlob)=1
SET @IDZam=(SELECT TOP 1 ID FROM TabCisZam WHERE Alias=@Alias)
IF (@Cislo IS NULL)AND(@RodneCislo IS NULL)AND(@IDZam IS NULL)  /*--neni vyplneno ani osobni ani rodne cislo, nelze pokracovat*/
BEGIN
SET @ChybaPriImportu=1
IF @TextChybyImportu<>'' SET @TextChybyImportu=@TextChybyImportu + ' | '
SET @TextChybyImportu = @TextChybyImportu + dbo.hpf_UniImportHlasky('47FE31D6-7E03-48B6-A644-5693A293BAA4', @JazykVerze, DEFAULT, DEFAULT, DEFAULT, DEFAULT)
END
IF (@ChybaPriImportu=0)AND(@IDZam IS NULL)               /*--dohledani ID zamestnance bud podle OsCisla nebo RC*/
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
END
IF @ChybaPriImportu=0               /*--povedlo se ID dohledat? pokud ano, otestuj mzdovou kartu*/
BEGIN
IF @IDZam IS NULL /*--zamestnanec nenalezen*/
BEGIN
SET @ChybaPriImportu=1
IF @TextChybyImportu<>'' SET @TextChybyImportu=@TextChybyImportu + ' | '
SET @TextChybyImportu = @TextChybyImportu + dbo.hpf_UniImportHlasky('A774CDE5-6416-4D37-8370-BE07671162F5', @JazykVerze, DEFAULT, DEFAULT, DEFAULT, DEFAULT)
END
ELSE
BEGIN
IF NOT EXISTS(SELECT * FROM TabZamMzd WHERE ZamestnanecID=@IDZam AND IdObdobi=@IdObdobi)
BEGIN
SET @ChybaPriImportu=1
IF @TextChybyImportu<>'' SET @TextChybyImportu=@TextChybyImportu + ' | '
SET @TextChybyImportu = @TextChybyImportu + dbo.hpf_UniImportHlasky('778B1335-FCBE-4600-93E0-DB43CE1C186B', @JazykVerze, DEFAULT, DEFAULT, DEFAULT, DEFAULT)
END
END
END
IF @ChybaPriImportu=0
BEGIN
IF (DATEPART(year, @Datum)=@RokA)AND(DATEPART(month, @Datum)=@MesicA)
BEGIN
IF EXISTS(SELECT * FROM TabZamVyp WHERE IdObdobi=@IdObdobi AND ZamestnanecId=@IDZam)
OR EXISTS(SELECT * FROM TabPredZp WHERE IdObdobi=@IdObdobi AND ZamestnanecId=@IdZam)
BEGIN
SET @ChybaPriImportu=1
IF @TextChybyImportu<>'' SET @TextChybyImportu=@TextChybyImportu + ' | '
SET @TextChybyImportu = @TextChybyImportu + dbo.hpf_UniImportHlasky('45AA4244-BAB5-4172-90E3-FF818C856B85', @JazykVerze, DEFAULT, DEFAULT, DEFAULT, DEFAULT)
END
END
IF (DATEPART(year, @Datum)=@RokB)AND(DATEPART(month, @Datum)=@MesicB)
BEGIN
IF EXISTS(SELECT * FROM TabPredZp WHERE IdObdobi=@IdObdobiBezne AND ZamestnanecId=@IdZam)
BEGIN
SET @ChybaPriImportu=1
IF @TextChybyImportu<>'' SET @TextChybyImportu=@TextChybyImportu + ' | '
SET @TextChybyImportu = @TextChybyImportu + dbo.hpf_UniImportHlasky('BA9C0E5F-1A28-4A92-A632-09C26D5AA68B', @JazykVerze, DEFAULT, DEFAULT, DEFAULT, DEFAULT)
END
END
END
IF @ChybaPriImportu=0
BEGIN
IF (DATEPART(year, @Datum)<>@RokA)OR(DATEPART(month, @Datum)<@MesicA)
BEGIN
SET @ChybaPriImportu=1
IF @TextChybyImportu<>'' SET @TextChybyImportu=@TextChybyImportu + ' | '
SET @TextChybyImportu = @TextChybyImportu + dbo.hpf_UniImportHlasky('D78ECC0B-3D35-4AA7-B36D-6C24560562F3', @JazykVerze, DEFAULT, DEFAULT, DEFAULT, DEFAULT)
END
IF @ChybaPriImportu=0
BEGIN
  SET @CisloKalendare=(SELECT DruhKalendare FROM TabZamMzd WHERE IdObdobi=@IdObdobi AND ZamestnanecId=@IdZam)
  IF @CisloKalendare IS NULL
  BEGIN
SET @ChybaPriImportu=1
IF @TextChybyImportu<>'' SET @TextChybyImportu=@TextChybyImportu + ' | '
SET @TextChybyImportu = @TextChybyImportu + dbo.hpf_UniImportHlasky('0E4F2F81-E814-4870-AA48-D68D938C1CA0', @JazykVerze, DEFAULT, DEFAULT, DEFAULT, DEFAULT)
  END
END
IF @ChybaPriImportu=0
BEGIN
  SET @IdKalendar=(SELECT ID FROM TabMzKalendarZam WHERE ZamestnanecId=@IdZam AND Cislo=@CisloKalendare AND Rok=@RokA)
END
IF @ChybaPriImportu=0
BEGIN
  SET @TypKal=(SELECT TypKal FROM TabMzKalendarZam WHERE ZamestnanecId=@IdZam AND Cislo=@CisloKalendare AND Rok=@RokA)
  IF @TypKal IS NULL SET @TypKal=0
END
IF @ChybaPriImportu=0
BEGIN
  SET @IdOsobKal=(SELECT ID FROM TabMzKalendarDnyZam WHERE IDKalendar=@IdKalendar AND CONVERT(VARCHAR(8), Datum, 112)=CONVERT(VARCHAR(8), @Datum, 112))
END
IF @TypKal=0
BEGIN
  TRUNCATE TABLE #LCSJAS_UNIIMPORT_KAL
  SET @OsCisloKontrola=(SELECT Cislo FROM TabCisZam WHERE ID=@IdZam)
  SET @RodneCisloKontrola=(SELECT RodneCislo FROM TabCisZam WHERE ID=@IdZam)
DECLARE e CURSOR LOCAL FAST_FORWARD FOR
SELECT PocetHodin, Datum FROM TabUniImportKal
WHERE InterniVerze=@InterniVerze
AND Chyba IS NULL
AND DatumImportu IS NULL
AND ISNULL(Cislo, -1)=@OsCisloKontrola
AND PocetHodin IS NOT NULL
 AND ((@PouzeZaznamyDleLogin=1 AND Autor=SUSER_SNAME())OR(@PouzeZaznamyDleLogin=0)) 
OPEN e
WHILE 1=1
BEGIN
FETCH NEXT FROM e INTO @PocetHodinKontrola, @DatumKontrola
IF @@fetch_status<>0 BREAK
INSERT #LCSJAS_UNIIMPORT_KAL(PocetHodin, Datum) VALUES(@PocetHodinKontrola, @DatumKontrola)
END
DEALLOCATE e
DECLARE e CURSOR LOCAL FAST_FORWARD FOR
SELECT PocetHodin, Datum FROM TabUniImportKal
WHERE InterniVerze=@InterniVerze
AND Chyba IS NULL
AND DatumImportu IS NULL
AND ISNULL(RodneCislo, '')=@RodneCisloKontrola
AND PocetHodin IS NOT NULL
 AND ((@PouzeZaznamyDleLogin=1 AND Autor=SUSER_SNAME())OR(@PouzeZaznamyDleLogin=0)) 
OPEN e
WHILE 1=1
BEGIN
FETCH NEXT FROM e INTO @PocetHodinKontrola, @DatumKontrola
IF @@fetch_status<>0 BREAK
INSERT #LCSJAS_UNIIMPORT_KAL(PocetHodin, Datum) VALUES(@PocetHodinKontrola, @DatumKontrola)
END
DEALLOCATE e
INSERT INTO #LCSJAS_UNIIMPORT_KAL(PocetHodin, Datum)
SELECT PocetHodin, Datum FROM TabMzKalendarDnyZam WHERE IDKalendar=@IdKalendar
AND Datum NOT IN(SELECT Datum FROM #LCSJAS_UNIIMPORT_KAL)
IF (SELECT COUNT(DISTINCT PocetHodin) FROM #LCSJAS_UNIIMPORT_KAL)>1
  BEGIN
SET @ChybaPriImportu=1
IF @TextChybyImportu<>'' SET @TextChybyImportu=@TextChybyImportu + ' | '
SET @TextChybyImportu = @TextChybyImportu + dbo.hpf_UniImportHlasky('7E362A3C-6393-43B4-ACFF-B95ADB38624F', @JazykVerze, DEFAULT, DEFAULT, DEFAULT, DEFAULT)
  END
END
IF @PocetHodin IS NOT NULL
BEGIN
  IF @PocetHodin>0
   SET @TypDne=0
  ELSE
   SET @TypDne=1
  IF @Svatek IS NULL SET @Svatek=(SELECT Svatek FROM TabMzKalendarDnyZam WHERE ID=@IdOsobKal)
END
IF @ChybaPriImportu=0
BEGIN
IF @PocetHodin IS NOT NULL
UPDATE TabMzKalendarDnyZam SET
  PocetHodin=@PocetHodin,
  Svatek=@Svatek,
  TypDne=@TypDne
WHERE ID=@IdOsobKal
IF OBJECT_ID('dbo.epx_UniImportKal03', 'P') IS NOT NULL EXEC dbo.epx_UniImportKal03 @IdOsobKal
END
END
IF @@ERROR<>0 SET @ChybaPriImportu=1
IF @ChybaPriImportu=0 DELETE FROM dbo.TabUniImportKal WHERE ID=@ID
IF @ChybaPriImportu=1
BEGIN
IF @@trancount>0 ROLLBACK TRAN T1
UPDATE dbo.TabUniImportKal SET Chyba=@TextChybyImportu, DatumImportu=GETDATE() WHERE ID=@ID
END
ELSE
IF @@trancount>0 COMMIT TRAN T1
END
FETCH NEXT FROM c INTO @ID, @InterniVerze, @Cislo, @RodneCislo, @Alias, @Datum, @PocetHodin, @Svatek
IF @@fetch_status<>0 BREAK
END
CLOSE c
DEALLOCATE c
GO

