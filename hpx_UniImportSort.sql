USE [RayService]
GO

/****** Object:  StoredProcedure [dbo].[hpx_UniImportSort]    Script Date: 26.06.2025 10:21:21 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

/*rpObecneImporty.Import*/CREATE PROC [dbo].[hpx_UniImportSort]
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
SET @PocetRadkuImpTabulky=(SELECT COUNT(*) FROM TabUniImportSort WHERE Chyba IS NULL AND ((@PouzeZaznamyDleLogin=1 AND Autor=SUSER_SNAME())OR(@PouzeZaznamyDleLogin=0)) )
SET @InfoText = dbo.hpf_UniImportHlasky('959B5166-6EEF-44A5-B4AC-DA13F5642C08', @JazykVerze, 'TabUniImportSort', CAST(@PocetRadkuImpTabulky AS NVARCHAR), DEFAULT, DEFAULT)
IF @InfoText IS NOT NULL
  EXEC dbo.hp_ZapisDoZurnalu 1, 77, @InfoText
IF OBJECT_ID('dbo.epx_UniImportSort02', 'P') IS NOT NULL EXEC dbo.epx_UniImportSort02
DECLARE @ChybaPriImportu BIT, @IDSort INT, @SQLString NVARCHAR(4000), @TextChybyImportu NVARCHAR(4000), @ChybaExtAtr NVARCHAR(4000),
@ID INT, @InterniVerze INT, @Nazev NVARCHAR(100), @K1 NVARCHAR(10), @K2 NVARCHAR(10), @K3 NVARCHAR(10),
@K4 NVARCHAR(10), @K5 NVARCHAR(10), @IDNadrazene INT,
@ExtAtr1 NVARCHAR(30), @ExtAtr1Nazev NVARCHAR(127), @ExtAtr2 NVARCHAR(255), @ExtAtr2Nazev NVARCHAR(127),
@ExtAtr3 DATETIME, @ExtAtr3Nazev NVARCHAR(127), @ExtAtr4 NUMERIC(19,6), @ExtAtr4Nazev NVARCHAR(127),
@TEMPNULL NVARCHAR(10)
SET @TEMPNULL=N'@@@@@LCS@@'
DECLARE c CURSOR LOCAL FAST_FORWARD FOR
SELECT ID, InterniVerze, ISNULL(Nazev, ''), ISNULL(K1, @TEMPNULL), ISNULL(K2, @TEMPNULL), ISNULL(K3, @TEMPNULL), ISNULL(K4, @TEMPNULL), ISNULL(K5, @TEMPNULL),
       ExtAtr1, ExtAtr1Nazev,
       ExtAtr2, ExtAtr2Nazev, ExtAtr3, ExtAtr3Nazev, ExtAtr4, ExtAtr4Nazev
FROM dbo.TabUniImportSort
WHERE Chyba IS NULL
 AND ((@PouzeZaznamyDleLogin=1 AND Autor=SUSER_SNAME())OR(@PouzeZaznamyDleLogin=0)) ORDER BY K1, K2, K3, K4, K5
OPEN c
FETCH NEXT FROM c INTO @ID, @InterniVerze, @Nazev, @K1, @K2, @K3, @K4, @K5, @ExtAtr1, @ExtAtr1Nazev, @ExtAtr2,
@ExtAtr2Nazev, @ExtAtr3, @ExtAtr3Nazev, @ExtAtr4, @ExtAtr4Nazev
WHILE 1=1
BEGIN
SET @ChybaPriImportu=0
SET @TextChybyImportu=''
SET @IDSort=NULL
IF @InterniVerze=1
BEGIN
IF EXISTS(SELECT ID FROM TabSortiment WHERE ISNULL(K1, @TEMPNULL)=@K1 AND ISNULL(K2, @TEMPNULL)=@K2 AND ISNULL(K3, @TEMPNULL)=@K3 AND ISNULL(K4, @TEMPNULL)=@K4 AND ISNULL(K5, @TEMPNULL)=@K5)
BEGIN
SET @ChybaPriImportu=1
UPDATE dbo.TabUniImportSort SET Chyba=dbo.hpf_UniImportHlasky('7A360CAF-59E8-4444-8920-1BDDB38E4B7C', @JazykVerze, DEFAULT, DEFAULT, DEFAULT, DEFAULT), DatumImportu=GETDATE() WHERE ID=@ID
END
ELSE
BEGIN
BEGIN TRAN T1
IF (@K1 <>@TEMPNULL)AND(@K2 = @TEMPNULL)AND(@K3 = @TEMPNULL)AND(@K4 = @TEMPNULL)AND(@K5 = @TEMPNULL)
BEGIN
IF EXISTS(SELECT * FROM TabSortiment WHERE K1=@K1)
BEGIN
SET @ChybaPriImportu=1
IF @TextChybyImportu<>'' SET @TextChybyImportu=@TextChybyImportu + ' | '
SET @TextChybyImportu = @TextChybyImportu + dbo.hpf_UniImportHlasky('7A360CAF-59E8-4444-8920-1BDDB38E4B7C', @JazykVerze, DEFAULT, DEFAULT, DEFAULT, DEFAULT)
END
ELSE BEGIN
INSERT TabSortiment(K1, Nazev) VALUES(@K1, @Nazev)
SET @IDSort= SCOPE_IDENTITY()
END
END
ELSE
IF (@K1 <> @TEMPNULL)AND(@K2 <> @TEMPNULL)AND(@K3 = @TEMPNULL)AND(@K4 = @TEMPNULL)AND(@K5 = @TEMPNULL)
BEGIN
SET @IDNadrazene=(SELECT ID FROM TabSortiment WHERE K1=@K1 AND K2 IS NULL AND K3 IS NULL AND K4 IS NULL AND K5 IS NULL)
IF @IDNadrazene IS NULL
BEGIN
SET @ChybaPriImportu=1
IF @TextChybyImportu<>'' SET @TextChybyImportu=@TextChybyImportu + ' | '
SET @TextChybyImportu = @TextChybyImportu + dbo.hpf_UniImportHlasky('EC5C5BB6-672E-422F-8980-23D8ABE01ED0', @JazykVerze, N'2.', @K2, DEFAULT, DEFAULT)
END
ELSE BEGIN
INSERT TabSortiment(IDNadrazene, Nazev, K1, K2) VALUES(@IDNadrazene, @Nazev, @K1, @K2)
SET @IDSort=SCOPE_IDENTITY()
END
END
ELSE
IF (@K1 <> @TEMPNULL)AND(@K2 <> @TEMPNULL)AND(@K3 <> @TEMPNULL)AND(@K4 = @TEMPNULL)AND(@K5 = @TEMPNULL)
BEGIN
SET @IDNadrazene=(SELECT ID FROM TabSortiment WHERE K1=@K1 AND K2=@K2 AND K3 IS NULL AND K4 IS NULL AND K5 IS NULL)
IF @IDNadrazene IS NULL
BEGIN
SET @ChybaPriImportu=1
IF @TextChybyImportu<>'' SET @TextChybyImportu=@TextChybyImportu + ' | '
SET @TextChybyImportu = @TextChybyImportu + dbo.hpf_UniImportHlasky('EC5C5BB6-672E-422F-8980-23D8ABE01ED0', @JazykVerze, N'3.', @K3, DEFAULT, DEFAULT)
END
ELSE BEGIN
INSERT TabSortiment(IDNadrazene, Nazev, K1, K2, K3) VALUES(@IDNadrazene, @Nazev, @K1, @K2, @K3)
SET @IDSort=SCOPE_IDENTITY()
END
END
ELSE
IF (@K1 <> @TEMPNULL)AND(@K2 <> @TEMPNULL)AND(@K3 <> @TEMPNULL)AND(@K4 <> @TEMPNULL)AND(@K5 = @TEMPNULL)
BEGIN
SET @IDNadrazene=(SELECT ID FROM TabSortiment WHERE K1=@K1 AND K2=@K2 AND K3=@K3 AND K4 IS NULL AND K5 IS NULL)
IF @IDNadrazene IS NULL
BEGIN
SET @ChybaPriImportu=1
IF @TextChybyImportu<>'' SET @TextChybyImportu=@TextChybyImportu + ' | '
SET @TextChybyImportu = @TextChybyImportu + dbo.hpf_UniImportHlasky('EC5C5BB6-672E-422F-8980-23D8ABE01ED0', @JazykVerze, N'4.', @K4, DEFAULT, DEFAULT)
END
ELSE BEGIN
INSERT TabSortiment(IDNadrazene, Nazev, K1, K2, K3, K4) VALUES(@IDNadrazene, @Nazev, @K1, @K2, @K3, @K4)
SET @IDSort=SCOPE_IDENTITY()
END
END
ELSE
IF (@K1 <> @TEMPNULL)AND(@K2 <> @TEMPNULL)AND(@K3 <> @TEMPNULL)AND(@K4 <> @TEMPNULL)AND(@K5 <> @TEMPNULL)
BEGIN
SET @IDNadrazene=(SELECT ID FROM TabSortiment WHERE K1=@K1 AND K2=@K2 AND K3=@K3 AND K4=@K4 AND K5 IS NULL)
IF @IDNadrazene IS NULL
BEGIN
SET @ChybaPriImportu=1
IF @TextChybyImportu<>'' SET @TextChybyImportu=@TextChybyImportu + ' | '
SET @TextChybyImportu = @TextChybyImportu + dbo.hpf_UniImportHlasky('EC5C5BB6-672E-422F-8980-23D8ABE01ED0', @JazykVerze, N'5.', @K5, DEFAULT, DEFAULT)
END
ELSE BEGIN
INSERT TabSortiment(IDNadrazene, Nazev, K1, K2, K3, K4, K5) VALUES(@IDNadrazene, @Nazev, @K1, @K2, @K3, @K4, @K5)
SET @IDSort=SCOPE_IDENTITY()
END
END
ELSE
BEGIN
SET @ChybaPriImportu=1
IF @TextChybyImportu<>'' SET @TextChybyImportu=@TextChybyImportu + ' | '
SET @TextChybyImportu = @TextChybyImportu + dbo.hpf_UniImportHlasky('01E2FD25-5D24-4517-AD60-FA005D41AF6E', @JazykVerze, DEFAULT, DEFAULT, DEFAULT, DEFAULT)
END
IF @ChybaPriImportu=0
BEGIN
IF (@ExtAtr1 IS NOT NULL)AND(@ExtAtr1Nazev IS NOT NULL)
BEGIN
IF (OBJECT_ID('TabSortiment_EXT','U')IS NOT NULL)AND(COLUMNPROPERTY(OBJECT_ID('TabSortiment_EXT','U'),'_'+@ExtAtr1Nazev,'AllowsNull')IS NOT NULL)
BEGIN
SET @ExtAtr1Nazev='_' + @ExtAtr1Nazev
IF EXISTS(SELECT ID FROM TabSortiment_EXT WHERE ID=@IDSort)
SET @SQLString='UPDATE TabSortiment_EXT SET ' + @ExtAtr1Nazev + '=N' + '''' + @ExtAtr1 + '''' + ' WHERE ID=' + CAST(@IDSort AS NVARCHAR(10))
ELSE
SET @SQLString='INSERT TabSortiment_EXT(ID, ' + @ExtAtr1Nazev + ') VALUES(' + CAST(@IDSort AS NVARCHAR(10)) + ', N' + '''' + @ExtAtr1 + '''' + ')'
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
IF (OBJECT_ID('TabSortiment_EXT','U')IS NOT NULL)AND(COLUMNPROPERTY(OBJECT_ID('TabSortiment_EXT','U'),'_'+@ExtAtr2Nazev,'AllowsNull')IS NOT NULL)
BEGIN
SET @ExtAtr2Nazev='_' + @ExtAtr2Nazev
IF EXISTS(SELECT ID FROM TabSortiment_EXT WHERE ID=@IDSort)
SET @SQLString='UPDATE TabSortiment_EXT SET ' + @ExtAtr2Nazev + '=N' + '''' + @ExtAtr2 + '''' + ' WHERE ID=' + CAST(@IDSort AS NVARCHAR(10))
ELSE
SET @SQLString='INSERT TabSortiment_EXT(ID, ' + @ExtAtr2Nazev + ') VALUES(' + CAST(@IDSort AS NVARCHAR(10)) + ', N' + '''' + @ExtAtr2 + '''' + ')'
EXECUTE sp_executesql @SQLString
END
ELSE
BEGIN
SET @ChybaPriImportu=1
IF @TextChybyImportu<>'' SET @TextChybyImportu=@TextChybyImportu + ' | '
SET @TextChybyImportu = @TextChybyImportu + dbo.hpf_UniImportHlasky('15364319-B20F-4D65-8900-391DE8D4C52F', @JazykVerze, '_'+@ExtAtr2Nazev, DEFAULT, DEFAULT, DEFAULT)
END
IF (@ExtAtr3 IS NOT NULL)AND(@ExtAtr3Nazev IS NOT NULL)
IF (OBJECT_ID('TabSortiment_EXT','U')IS NOT NULL)AND(COLUMNPROPERTY(OBJECT_ID('TabSortiment_EXT','U'),'_'+@ExtAtr3Nazev,'AllowsNull')IS NOT NULL)
BEGIN
SET @ExtAtr3Nazev='_' + @ExtAtr3Nazev
IF EXISTS(SELECT ID FROM TabSortiment_EXT WHERE ID=@IDSort)
SET @SQLString='UPDATE TabSortiment_EXT SET ' + @ExtAtr3Nazev + '=' + '''' + CONVERT(NVARCHAR(10),@ExtAtr3, 112) + '''' + ' WHERE ID=' + CAST(@IDSort AS NVARCHAR(10))
ELSE
SET @SQLString='INSERT TabSortiment_EXT(ID, ' + @ExtAtr3Nazev + ') VALUES(' + CAST(@IDSort AS NVARCHAR(10)) + ', ' + '''' + CONVERT(NVARCHAR(10),@ExtAtr3, 112) + '''' + ')'
EXECUTE sp_executesql @SQLString
END
ELSE
BEGIN
SET @ChybaPriImportu=1
IF @TextChybyImportu<>'' SET @TextChybyImportu=@TextChybyImportu + ' | '
SET @TextChybyImportu = @TextChybyImportu + dbo.hpf_UniImportHlasky('15364319-B20F-4D65-8900-391DE8D4C52F', @JazykVerze, '_'+@ExtAtr3Nazev, DEFAULT, DEFAULT, DEFAULT)
END
IF (@ExtAtr4 IS NOT NULL)AND(@ExtAtr4Nazev IS NOT NULL)
IF (OBJECT_ID('TabSortiment_EXT','U')IS NOT NULL)AND(COLUMNPROPERTY(OBJECT_ID('TabSortiment_EXT','U'),'_'+@ExtAtr4Nazev,'AllowsNull')IS NOT NULL)
BEGIN
SET @ExtAtr4Nazev='_' + @ExtAtr4Nazev
IF EXISTS(SELECT ID FROM TabSortiment_EXT WHERE ID=@IDSort)
SET @SQLString='UPDATE TabSortiment_EXT SET ' + @ExtAtr4Nazev + '=' + CAST(@ExtAtr4 AS NVARCHAR(26)) +  ' WHERE ID=' + CAST(@IDSort AS NVARCHAR(10))
ELSE
SET @SQLString='INSERT TabSortiment_EXT(ID, ' + @ExtAtr4Nazev + ') VALUES(' + CAST(@IDSort AS NVARCHAR(10)) + ', ' + CAST(@ExtAtr4 AS NVARCHAR(26)) + ')'
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
  @ImportIdent=6,
  @IdImpTable=@ID,
  @IdTargetTable=@IDSort,
  @Chyba=@ChybaExtAtr OUT
IF @ChybaExtAtr<>''
BEGIN
  SET @ChybaPriImportu=1
  IF @TextChybyImportu<>'' SET @TextChybyImportu=@TextChybyImportu + ' | '
  SET @TextChybyImportu = @TextChybyImportu + dbo.hpf_UniImportHlasky('15364319-B20F-4D65-8900-391DE8D4C52F', @JazykVerze, @ChybaExtAtr, DEFAULT, DEFAULT, DEFAULT)
END
END
IF OBJECT_ID('dbo.epx_UniImportSort03', 'P') IS NOT NULL EXEC dbo.epx_UniImportSort03 @IDSort
IF @@ERROR<>0 SET @ChybaPriImportu=1
IF @ChybaPriImportu=0 DELETE FROM dbo.TabUniImportSort WHERE ID=@ID
IF @ChybaPriImportu=1
BEGIN
IF @@trancount>0 ROLLBACK TRAN T1
UPDATE dbo.TabUniImportSort SET Chyba=@TextChybyImportu, DatumImportu=GETDATE() WHERE ID=@ID
END
ELSE IF @@trancount>0 COMMIT TRAN T1
END
END
FETCH NEXT FROM c INTO @ID, @InterniVerze, @Nazev, @K1, @K2, @K3, @K4, @K5, @ExtAtr1, @ExtAtr1Nazev, @ExtAtr2,
@ExtAtr2Nazev, @ExtAtr3, @ExtAtr3Nazev, @ExtAtr4, @ExtAtr4Nazev
IF @@fetch_status<>0 BREAK
END
CLOSE c
DEALLOCATE c
GO

