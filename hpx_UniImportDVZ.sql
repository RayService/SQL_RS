USE [RayService]
GO

/****** Object:  StoredProcedure [dbo].[hpx_UniImportDVZ]    Script Date: 26.06.2025 10:17:08 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

/*rpObecneImporty.Import*/CREATE PROC [dbo].[hpx_UniImportDVZ]
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
SET @PocetRadkuImpTabulky=(SELECT COUNT(*) FROM TabUniImportDVZ WHERE Chyba IS NULL AND ((@PouzeZaznamyDleLogin=1 AND Autor=SUSER_SNAME())OR(@PouzeZaznamyDleLogin=0)) )
SET @InfoText = dbo.hpf_UniImportHlasky('959B5166-6EEF-44A5-B4AC-DA13F5642C08', @JazykVerze, 'TabUniImportDVZ', CAST(@PocetRadkuImpTabulky AS NVARCHAR), DEFAULT, DEFAULT)
IF @InfoText IS NOT NULL
  EXEC dbo.hp_ZapisDoZurnalu 1, 77, @InfoText
IF OBJECT_ID('dbo.epx_UniImportDVZ02', 'P') IS NOT NULL EXEC dbo.epx_UniImportDVZ02
DECLARE @ChybaPriImportu BIT, @TextChybyImportu NVARCHAR(4000), @IDZam INT, @IDObdobi INT,
@ID INT, @InterniVerze INT, @Cislo INT, @RodneCislo NVARCHAR(11), @Rok SMALLINT, @Mesic SMALLINT,
@Koruny NUMERIC(19,2), @KalDny NUMERIC(9,2), @VyloucDoby NUMERIC(9,2), @IdDVZ INT
SET @IDObdobi=(SELECT IdObdobi FROM TabMzdObd WHERE Stav=1)
DECLARE c CURSOR LOCAL FAST_FORWARD FOR
SELECT ID, InterniVerze, Cislo, RodneCislo, Rok, Mesic, Koruny, KalDny, VyloucDoby
FROM dbo.TabUniImportDVZ
WHERE Chyba IS NULL
 AND ((@PouzeZaznamyDleLogin=1 AND Autor=SUSER_SNAME())OR(@PouzeZaznamyDleLogin=0)) 
OPEN c
FETCH NEXT FROM c INTO @ID, @InterniVerze, @Cislo, @RodneCislo, @Rok, @Mesic, @Koruny, @KalDny, @VyloucDoby
WHILE 1=1
BEGIN
SET @ChybaPriImportu=0
SET @TextChybyImportu=''
SET @IDZam=NULL
IF @InterniVerze=1
BEGIN
BEGIN TRAN T1
IF (@Cislo IS NULL)AND(@RodneCislo IS NULL)  /*--neni vyplneno ani osobni ani rodne cislo, nelze pokracovat*/
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
IF @ChybaPriImportu=0               /*--zamestnanec existuje a ma mzdovou kartu=> importujeme*/
BEGIN
IF EXISTS(SELECT * FROM TabMzDvzUdaje WHERE ZamestnanecId=@IDZam AND IdObdobi=-1 AND Mesic=@Mesic AND Rok=@Rok)
BEGIN
SET @ChybaPriImportu=1
IF @TextChybyImportu<>'' SET @TextChybyImportu=@TextChybyImportu + ' | '
SET @TextChybyImportu = @TextChybyImportu + dbo.hpf_UniImportHlasky('DBBC0721-5616-4173-9BA6-25A0F37E6D49', @JazykVerze, DEFAULT, DEFAULT, DEFAULT, DEFAULT)
END
ELSE
BEGIN
  INSERT TabMzDvzUdaje(ZamestnanecId, IdObdobi, Mesic, Rok, Koruny, KalDny, VyloucDoby)
  VALUES(@IDZam, -1, @Mesic, @Rok, @Koruny, @KalDny, @VyloucDoby)
  SET @IdDVZ = SCOPE_IDENTITY()
END
END
IF OBJECT_ID('dbo.epx_UniImportDVZ03', 'P') IS NOT NULL EXEC dbo.epx_UniImportDVZ03 @IDDVZ
IF @@ERROR<>0 SET @ChybaPriImportu=1
IF @ChybaPriImportu=0 DELETE FROM dbo.TabUniImportDVZ WHERE ID=@ID
IF @ChybaPriImportu=1
BEGIN
IF @@trancount>0 ROLLBACK TRAN T1
UPDATE dbo.TabUniImportDVZ SET Chyba=@TextChybyImportu, DatumImportu=GETDATE() WHERE ID=@ID
END
ELSE
IF @@trancount>0 COMMIT TRAN T1
END
FETCH NEXT FROM c INTO @ID, @InterniVerze, @Cislo, @RodneCislo, @Rok, @Mesic, @Koruny, @KalDny, @VyloucDoby
IF @@fetch_status<>0 BREAK
END
CLOSE c
DEALLOCATE c
GO

