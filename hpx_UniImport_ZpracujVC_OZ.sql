USE [RayService]
GO

/****** Object:  StoredProcedure [dbo].[hpx_UniImport_ZpracujVC_OZ]    Script Date: 26.06.2025 10:15:51 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

/*rpObecneImporty.Import*/CREATE PROC [dbo].[hpx_UniImport_ZpracujVC_OZ]
@IDHlavicky NVARCHAR(30),
@IdTargetTable INT,
@Chyba NVARCHAR(4000) OUT
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

DECLARE @VyrobniCislo NVARCHAR(100), @VyrobniCisloMnozstvi NUMERIC(19,6), @VyrobniCisloExpirace DATETIME,
@SkupZbo NVARCHAR(3), @RegCis NVARCHAR(30), @BarCode NVARCHAR(50), @IdPohyb INT, @IDKmenBarCode INT,
@ChybaPriImportu BIT, @IdKmen INT, @Nuly NVARCHAR(30), @DelkaReg SMALLINT, @Zarovnani TINYINT, @I INT,
@IdSkladPol NVARCHAR(30), @IdSklad NVARCHAR(30), @IDVyrCis INT, @IdStavSkladu INT, @MnozstviPohyb NUMERIC(19,6),
@VyrobniCisloNazev NVARCHAR(100)
SET @Chyba = ''
DECLARE c CURSOR LOCAL FAST_FORWARD FOR
SELECT VyrobniCislo, VyrobniCisloMnozstvi, VyrobniCisloExpirace, SkupZbo, RegCis, BarCode, IDSklad, IDSkladPol, VyrobniCisloNazev
FROM TabUniImportOZ
WHERE Chyba IS NULL
AND DatumImportu IS NULL
AND VC = 1
AND TextPolozka = 0
AND Zaloha=0
AND IDHlavicky = @IDHlavicky
AND ISNULL(VyrobniCislo, '')<>''
 AND ((@PouzeZaznamyDleLogin=1 AND Autor=SUSER_SNAME())OR(@PouzeZaznamyDleLogin=0)) 
OPEN c
WHILE 1=1
BEGIN
FETCH NEXT FROM c INTO @VyrobniCislo, @VyrobniCisloMnozstvi, @VyrobniCisloExpirace, @SkupZbo, @RegCis, @BarCode, @IDSklad, @IDSkladPol, @VyrobniCisloNazev
IF @@fetch_status<>0 BREAK
IF (@BarCode IS NOT NULL)AND((@RegCis IS NULL)AND(@SkupZbo IS NULL))
BEGIN
SET @IDKmenBarCode=(SELECT IDKmenZbo FROM TabBarCodeZbo WHERE BarCode=@BarCode)
IF @IDKmenBarCode IS NULL
BEGIN
SET @ChybaPriImportu=1
IF @Chyba<>'' SET @Chyba = @Chyba + ', '
SET @Chyba = @Chyba + @VyrobniCislo
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
SET @I = @DelkaReg - LEN(@RegCis)
WHILE @I >= 1
BEGIN
SET @Nuly = @Nuly + '0'
SET @I = @I - 1
END
IF @Zarovnani=2 SET @RegCis = @Nuly + @RegCis
ELSE IF @Zarovnani=3 SET @RegCis = @RegCis + @Nuly
IF LEN(@SkupZbo)=1 SET @SkupZbo=N'00' + @SkupZbo
IF LEN(@SkupZbo)=2 SET @SkupZbo=N'0'  + @SkupZbo
SET @IDKmen=(SELECT ID FROM TabKmenZbozi WHERE RegCis=@RegCis AND SkupZbo=@SkupZbo)
IF @IDKmen IS NULL
BEGIN
SET @ChybaPriImportu=1
IF @Chyba <> '' SET @Chyba = @Chyba + ', '
SET @Chyba = @Chyba + @VyrobniCislo
END
END
IF @IdSkladPol IS NOT NULL
SET @IdSklad = @IdSkladPol
SET @IdPohyb = (SELECT TOP 1 P.ID
FROM TabPohybyZbozi P
LEFT OUTER JOIN TabStavSkladu S ON S.ID = P.IDZboSklad
WHERE S.IDKmenZbozi = @IDKmen AND S.IDSklad = @IdSklad AND P.IDDoklad = @IdTargetTable
ORDER BY ID DESC
)
SET @IdStavSkladu = (SELECT IDZboSklad FROM TabPohybyZbozi WHERE ID = @IdPohyb)
IF @IdStavSkladu IS NULL
BEGIN
SET @ChybaPriImportu=1
IF @Chyba <> '' SET @Chyba = @Chyba + ', '
SET @Chyba = @Chyba + @VyrobniCislo
END
ELSE
BEGIN
SET @IDVyrCis = (SELECT ID FROM TabVyrCS WHERE IDStavSkladu = @IdStavSkladu AND Nazev1 = @VyrobniCislo)
SET @MnozstviPohyb = (SELECT Mnozstvi FROM TabPohybyZbozi WHERE ID=@IdPohyb)
IF @IDVyrCis IS NULL
BEGIN
INSERT TabVyrCS(IDStavSkladu, Nazev1, Nazev2, DatExpirace) VALUES(@IdStavSkladu, @VyrobniCislo, '', @VyrobniCisloExpirace)
SET @IDVyrCis = SCOPE_IDENTITY()
END
IF NOT EXISTS(SELECT 0 FROM TabVyrCP WHERE IDPolozkaDokladu=@IdPohyb AND IDVyrCis=@IDVyrCis)
BEGIN
  IF (@VyrobniCisloMnozstvi+(SELECT SUM(Mnozstvi) FROM TabVyrCP WHERE IDPolozkaDokladu = @IdPohyb))>@MnozstviPohyb
  BEGIN
    SET @ChybaPriImportu=1
    IF @Chyba <> '' SET @Chyba = @Chyba + ', '
    SET @Chyba = @Chyba + @VyrobniCislo
  END
  ELSE
    INSERT TabVyrCP(IDPolozkaDokladu, IDVyrCis, Mnozstvi, Nazev, DatExpirace) VALUES (@IdPohyb, @IDVyrCis, @VyrobniCisloMnozstvi, ISNULL(@VyrobniCisloNazev, ''), @VyrobniCisloExpirace)
END
ELSE
BEGIN
  IF (@VyrobniCisloMnozstvi+(SELECT SUM(Mnozstvi) FROM TabVyrCP WHERE IDPolozkaDokladu = @IdPohyb))>@MnozstviPohyb
  BEGIN
    SET @ChybaPriImportu=1
    IF @Chyba <> '' SET @Chyba = @Chyba + ', '
    SET @Chyba = @Chyba + @VyrobniCislo
  END
  ELSE
    UPDATE TabVyrCP SET
      Mnozstvi = Mnozstvi + @VyrobniCisloMnozstvi
    WHERE IDPolozkaDokladu = @IdPohyb
    AND IDVyrCis=@IDVyrCis
END
END
END
DEALLOCATE c
GO

