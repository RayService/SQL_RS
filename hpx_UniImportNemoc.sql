USE [RayService]
GO

/****** Object:  StoredProcedure [dbo].[hpx_UniImportNemoc]    Script Date: 26.06.2025 10:19:54 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

/*rpObecneImporty.Import*/CREATE PROC [dbo].[hpx_UniImportNemoc]
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
SET @PocetRadkuImpTabulky=(SELECT COUNT(*) FROM TabUniImportNemoc WHERE Chyba IS NULL AND ((@PouzeZaznamyDleLogin=1 AND Autor=SUSER_SNAME())OR(@PouzeZaznamyDleLogin=0)) )
SET @InfoText = dbo.hpf_UniImportHlasky('959B5166-6EEF-44A5-B4AC-DA13F5642C08', @JazykVerze, 'TabUniImportNemoc', CAST(@PocetRadkuImpTabulky AS NVARCHAR), DEFAULT, DEFAULT)
IF @InfoText IS NOT NULL
  EXEC dbo.hp_ZapisDoZurnalu 1, 77, @InfoText
IF OBJECT_ID('dbo.epx_UniImportNemoc02', 'P') IS NOT NULL EXEC dbo.epx_UniImportNemoc02
DECLARE @ChybaPriImportu BIT, @TextChybyImportu NVARCHAR(4000), @IDZam INT, @IDObdobi INT,
@ID INT, @InterniVerze INT, @Cislo INT, @RodneCislo NVARCHAR(11), @CisloMS INT, @ND_TypOperace TINYINT,
@DatumOd DATETIME, @DatumDo DATETIME, @DnyKal NUMERIC(9,2), @Castka NUMERIC(19,2), @Proplaceno BIT,
@JePrekryv BIT, @IdMS INT, @JeNavaznost INT, @ResultDate DATETIME, @PrvniDenOstreObdobi DATETIME,
@DatumNastupu DATETIME, @Rok INT, @Mesic INT, @IdTabNemocPredIQ INT
SET @IDObdobi=(SELECT IdObdobi FROM TabMzdObd WHERE Stav=1)
DECLARE c CURSOR LOCAL FAST_FORWARD FOR
SELECT ID, InterniVerze, Cislo, RodneCislo, CisloMS, ND_TypOperace, DatumOd, DatumDo, DnyKal, Castka, Proplaceno
FROM dbo.TabUniImportNemoc
WHERE Chyba IS NULL
 AND ((@PouzeZaznamyDleLogin=1 AND Autor=SUSER_SNAME())OR(@PouzeZaznamyDleLogin=0)) 
OPEN c
FETCH NEXT FROM c INTO @ID, @InterniVerze, @Cislo, @RodneCislo, @CisloMS, @ND_TypOperace, @DatumOd,
@DatumDo, @DnyKal, @Castka, @Proplaceno
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
IF @ChybaPriImportu=0
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
IF NOT EXISTS(SELECT * FROM TabCisMzSl
WHERE CisloMzSl=@CisloMS AND
SkupinaMS=3 AND
IdObdobi=@IdObdobi AND
Konstanty_SkupinaDochazky=6)
BEGIN
SET @ChybaPriImportu=1
IF @TextChybyImportu<>'' SET @TextChybyImportu=@TextChybyImportu + ' | '
SET @TextChybyImportu = @TextChybyImportu + dbo.hpf_UniImportHlasky('AFDD2500-497D-4B08-A841-8926312A1E2D', @JazykVerze, CAST(@CisloMS AS VARCHAR), DEFAULT, DEFAULT, DEFAULT)
END
IF @DatumOd IS NULL
SET @DatumOd=(SELECT  DATEADD(d, -1, CAST((CAST(Rok AS VARCHAR) + SUBSTRING(CAST(Mesic+100 AS VARCHAR), 2, 2) + '01') AS DATETIME))
FROM TabMzdObd
WHERE PrvniObdobi=1)
IF @DatumDo IS NULL
SET @DatumDo=(SELECT  DATEADD(d, -1, CAST((CAST(Rok AS VARCHAR) + SUBSTRING(CAST(Mesic+100 AS VARCHAR), 2, 2) + '01') AS DATETIME))
FROM TabMzdObd
WHERE PrvniObdobi=1)
IF (@DatumOd IS NULL)OR(@DatumDo IS NULL)
BEGIN
SET @ChybaPriImportu=1
IF @TextChybyImportu<>'' SET @TextChybyImportu=@TextChybyImportu + ' | '
SET @TextChybyImportu = @TextChybyImportu + dbo.hpf_UniImportHlasky('CCCE20BD-6411-4EA5-9BFF-66EBAE203955', @JazykVerze, DEFAULT, DEFAULT, DEFAULT, DEFAULT)
END
IF @DatumOd>@DatumDo
BEGIN
SET @ChybaPriImportu=1
IF @TextChybyImportu<>'' SET @TextChybyImportu=@TextChybyImportu + ' | '
SET @TextChybyImportu = @TextChybyImportu + dbo.hpf_UniImportHlasky('625223EE-0E15-4329-933E-0441D34890BC', @JazykVerze, DEFAULT, DEFAULT, DEFAULT, DEFAULT)
END
SET @JePrekryv=0
IF YEAR(@DatumOd)=YEAR(@DatumDo) AND MONTH(@DatumOd)=MONTH(@DatumDo) AND DAY(@DatumOd)=DAY(@DatumDo)
BEGIN
IF EXISTS(SELECT * FROM TabNemocPredIQ
WHERE ZamestnanecId=@IDZam AND
@DatumOd>DatumOd AND @DatumOd<DatumDo
)
SET @JePrekryv=1
END
ELSE
BEGIN
IF EXISTS(SELECT * FROM TabNemocPredIQ
WHERE ZamestnanecId=@IdZam AND
((@DatumOd>=DatumOd AND @DatumOd<=DatumDo OR @DatumDo>=DatumOd AND @DatumDo<=DatumDo) OR
(@DatumOd>=DatumOd AND @DatumDo>=DatumOd AND @DatumOd<=DatumDo AND @DatumDo<=DatumDo) OR
(@DatumOd<=DatumOd AND @DatumDo>=DatumOd AND @DatumOd<=DatumDo AND @DatumDo>=DatumDo)))
SET @JePrekryv=1
END
IF @JePrekryv=1
BEGIN
SET @ChybaPriImportu=1
IF @TextChybyImportu<>'' SET @TextChybyImportu=@TextChybyImportu + ' | '
SET @TextChybyImportu = @TextChybyImportu + dbo.hpf_UniImportHlasky('5EA0B875-987F-44CE-B9AA-3859B08617DD', @JazykVerze, DEFAULT, DEFAULT, DEFAULT, DEFAULT)
END
IF @ND_TypOperace=1
BEGIN
  SET @JeNavaznost=0
  IF EXISTS(SELECT * FROM TabNemocPredIQ
            WHERE ZamestnanecId=@IdZam AND
            CisloMS=@CisloMS AND @DatumOd-1=DatumDo)
  SET @JeNavaznost=1
IF @JeNavaznost=0
BEGIN
SET @ChybaPriImportu=1
IF @TextChybyImportu<>'' SET @TextChybyImportu=@TextChybyImportu + ' | '
SET @TextChybyImportu = @TextChybyImportu + dbo.hpf_UniImportHlasky('6AFC13EA-04C7-43E5-A980-D80D1969B726', @JazykVerze, DEFAULT, DEFAULT, DEFAULT, DEFAULT)
END
END
IF @DatumDo IS NOT NULL
SET @ResultDate=GetDate()
SELECT @Rok=Rok, @Mesic=Mesic FROM TabMzdObd WHERE PrvniObdobi=2
IF @Rok IS NULL OR @Mesic IS NULL
  SELECT @Rok=Rok, @Mesic=Mesic FROM TabMzdObd WHERE PrvniObdobi=1
EXEC hp_EncodeDate @PrvniDenOstreObdobi OUT, @Rok, @Mesic,1
IF @PrvniDenOstreObdobi IS NOT NULL
BEGIN
SELECT @DatumNastupu=DatumVznikuPP FROM TabZamMZd WHERE ZamestnanecId=@IdZam AND IdObdobi=@IdObdobi
IF @DatumNastupu IS NULL
  SET @DatumNastupu=@PrvniDenOstreObdobi
IF @DatumNastupu>=@PrvniDenOstreObdobi
  SET @ResultDate=@DatumNastupu
ELSE
  SET @ResultDate=@PrvniDenOstreObdobi
END
IF @DatumDo>=@ResultDate
BEGIN
SET @ChybaPriImportu=1
IF @TextChybyImportu<>'' SET @TextChybyImportu=@TextChybyImportu + ' | '
SET @TextChybyImportu = @TextChybyImportu + dbo.hpf_UniImportHlasky('1FA3452A-6E52-4FC4-BED5-1C52317993C4', @JazykVerze, DEFAULT, DEFAULT, DEFAULT, DEFAULT)
END
IF @ChybaPriImportu=0
BEGIN
INSERT TabNemocPredIQ(ZamestnanecId, IdObdobi, CisloMS, ND_TypOperace, DatumOd, DatumDo, DnyKal, Castka, Proplaceno)
VALUES(@IdZam, @IdObdobi, @CisloMS, @ND_TypOperace, @DatumOd, @DatumDo, @DnyKal, @Castka, @Proplaceno)
SET @IdTabNemocPredIQ = SCOPE_IDENTITY()
IF OBJECT_ID('dbo.epx_UniImportNemoc03', 'P') IS NOT NULL EXEC dbo.epx_UniImportNemoc03 @IdTabNemocPredIQ
END
END  /*--*zamestnanec existuje a ma mzdovou kartu=> importujeme*/
IF @@ERROR<>0 SET @ChybaPriImportu=1
IF @ChybaPriImportu=0 DELETE FROM dbo.TabUniImportNemoc WHERE ID=@ID
IF @ChybaPriImportu=1
BEGIN
IF @@trancount>0 ROLLBACK TRAN T1
UPDATE dbo.TabUniImportNemoc SET Chyba=@TextChybyImportu, DatumImportu=GETDATE() WHERE ID=@ID
END
ELSE
IF @@trancount>0 COMMIT TRAN T1
END /*Interni verze 1*/
FETCH NEXT FROM c INTO @ID, @InterniVerze, @Cislo, @RodneCislo, @CisloMS, @ND_TypOperace, @DatumOd,
@DatumDo, @DnyKal, @Castka, @Proplaceno
IF @@fetch_status<>0 BREAK
END
CLOSE c
DEALLOCATE c
GO

