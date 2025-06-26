USE [RayService]
GO

/****** Object:  StoredProcedure [dbo].[hpx_UniImport_ZpracujZalohy_OZ]    Script Date: 26.06.2025 10:16:16 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

/*rpObecneImporty.Import*/CREATE PROC [dbo].[hpx_UniImport_ZpracujZalohy_OZ]
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

DECLARE @ZalohaPopis NVARCHAR(20), @ZalohaDatum DATETIME, @ZalohaCastkaZaoKc NUMERIC(19,6),
@ZalohaCastkaZaoVal NUMERIC(19,6), @IdZal INT, @Poradi INT, @IdPolZal INT, @JeHlavniMena BIT, @Mena NVARCHAR(3)
DECLARE @ZalohaPolSazbaDPH NUMERIC(5,2), @ZalohaPolCsDPH NUMERIC(19,6), @ZalohaPolCbezDPH NUMERIC(19,6), @ZalohaPolCastkaDPH NUMERIC(19,6),
@ZalohaPolCsDPHVal NUMERIC(19,6), @ZalohaPolCbezDPHVal NUMERIC(19,6), @ZalohaPolCastkaDPHVal NUMERIC(19,6)
DECLARE SAZBA CURSOR LOCAL FAST_FORWARD FOR
SELECT DISTINCT ZalohaPolSazbaDPH
FROM TabUniImportOZ
WHERE ZalohaPolSazbaDPH IS NOT NULL
AND ISNULL(Zaloha, 0)=1
AND IDHlavicky=@IDHlavicky
AND ISNULL(ZalohaPopis, '')<>''
 AND ((@PouzeZaznamyDleLogin=1 AND Autor=SUSER_SNAME())OR(@PouzeZaznamyDleLogin=0)) 
OPEN SAZBA
WHILE 1=1
BEGIN
FETCH NEXT FROM SAZBA INTO @ZalohaPolSazbaDPH
IF @@fetch_status<>0 BREAK
IF NOT EXISTS(SELECT * FROM TabDPH WHERE Sazba=@ZalohaPolSazbaDPH)
BEGIN
SET @Chyba=CAST(@ZalohaPolSazbaDPH AS NVARCHAR)
RETURN
END
END
DEALLOCATE SAZBA
DECLARE ZAL CURSOR LOCAL FAST_FORWARD FOR
SELECT DISTINCT ZalohaPopis
FROM TabUniImportOZ
WHERE ISNULL(Zaloha, 0)=1
AND IDHlavicky=@IDHlavicky
AND ISNULL(ZalohaPopis, '')<>''
 AND ((@PouzeZaznamyDleLogin=1 AND Autor=SUSER_SNAME())OR(@PouzeZaznamyDleLogin=0)) 
OPEN ZAL
WHILE 1=1
BEGIN
FETCH NEXT FROM ZAL INTO @ZalohaPopis
IF @@fetch_status<>0 BREAK
SET @ZalohaDatum=NULL
SET @ZalohaCastkaZaoKc=NULL
SET @ZalohaCastkaZaoVal=NULL
SET @Poradi=0
SELECT TOP 1 @ZalohaDatum=ZalohaDatum, @ZalohaCastkaZaoKc=ZalohaCastkaZaoKc, @ZalohaCastkaZaoVal=ZalohaCastkaZaoVal
FROM TabUniImportOZ
WHERE ZalohaPopis=@ZalohaPopis AND IDHlavicky=@IDHlavicky AND ((@PouzeZaznamyDleLogin=1 AND Autor=SUSER_SNAME())OR(@PouzeZaznamyDleLogin=0)) 
SET @Mena=(SELECT Mena FROM TabDokladyZbozi WHERE ID=@IdTargetTable)
IF @Mena IS NULL
SET @JeHlavniMena=1
ELSE
BEGIN
IF (SELECT Kod FROM TabKodMen WHERE HlavniMena=1) <> @Mena
SET @JeHlavniMena=0
ELSE
SET @JeHlavniMena=1
END
INSERT TabZalFak(IdReal, Popis) VALUES(@IdTargetTable, @ZalohaPopis)
SET @IdZal=SCOPE_IDENTITY()
DECLARE POL CURSOR LOCAL FAST_FORWARD FOR
SELECT ZalohaPolSazbaDPH, ZalohaPolCsDPH, ZalohaPolCbezDPH, ZalohaPolCastkaDPH, ZalohaPolCsDPHVal, ZalohaPolCbezDPHVal, ZalohaPolCastkaDPHVal
FROM TabUniImportOZ
WHERE ZalohaPopis=@ZalohaPopis AND IDHlavicky=@IDHlavicky AND ((@PouzeZaznamyDleLogin=1 AND Autor=SUSER_SNAME())OR(@PouzeZaznamyDleLogin=0)) 
OPEN POL
WHILE 1=1
BEGIN
FETCH NEXT FROM POL INTO @ZalohaPolSazbaDPH, @ZalohaPolCsDPH, @ZalohaPolCbezDPH, @ZalohaPolCastkaDPH, @ZalohaPolCsDPHVal, @ZalohaPolCbezDPHVal, @ZalohaPolCastkaDPHVal
IF @@fetch_status<>0 BREAK
SET @Poradi=@Poradi + 1
INSERT TabZalFakPol(IDZalFak, Poradi, SazbaDPH, CsDPH, CbezDPH, CastkaDPH, CsDPHVal, CbezDPHVal, CastkaDPHVal)
VALUES(@IdZal, @Poradi, @ZalohaPolSazbaDPH, ISNULL(@ZalohaPolCsDPH, 0), ISNULL(@ZalohaPolCbezDPH, 0), ISNULL(@ZalohaPolCastkaDPH, 0), ISNULL(@ZalohaPolCsDPHVal, 0), ISNULL(@ZalohaPolCbezDPHVal, 0), ISNULL(@ZalohaPolCastkaDPHVal, 0))
SET @IdPolZal=SCOPE_IDENTITY()
IF ISNULL(@ZalohaPolCsDPH, 0)=0
SET @ZalohaPolCsDPH = ISNULL(@ZalohaPolCbezDPH, 0) * ((ISNULL(@ZalohaPolSazbaDPH, 0)/100)+1)
IF ISNULL(@ZalohaPolCbezDPH, 0)=0
SET @ZalohaPolCbezDPH = ISNULL(@ZalohaPolCsDPH, 0) / ((ISNULL(@ZalohaPolSazbaDPH, 0)/100)+1)
IF ISNULL(@ZalohaPolCastkaDPH, 0)=0
SET @ZalohaPolCastkaDPH = @ZalohaPolCsDPH - @ZalohaPolCbezDPH
IF ISNULL(@ZalohaPolCsDPHVal, 0)=0
SET @ZalohaPolCsDPHVal = ISNULL(@ZalohaPolCbezDPHVal, 0) * ((ISNULL(@ZalohaPolSazbaDPH, 0)/100)+1)
IF ISNULL(@ZalohaPolCbezDPHVal, 0)=0
SET @ZalohaPolCbezDPHVal = ISNULL(@ZalohaPolCsDPHVal, 0) / ((ISNULL(@ZalohaPolSazbaDPH, 0)/100)+1)
IF ISNULL(@ZalohaPolCastkaDPHVal, 0)=0
SET @ZalohaPolCastkaDPHVal = @ZalohaPolCsDPHVal - @ZalohaPolCbezDPHVal
IF @JeHlavniMena=1
BEGIN
SET @ZalohaPolCsDPHVal=@ZalohaPolCsDPH
SET @ZalohaPolCbezDPHVal=@ZalohaPolCbezDPH
SET @ZalohaPolCastkaDPHVal=@ZalohaPolCastkaDPH
END
UPDATE TabZalFakPol SET
CsDPH=@ZalohaPolCsDPH,
CbezDPH=@ZalohaPolCbezDPH,
CastkaDPH=@ZalohaPolCastkaDPH,
CsDPHVal=@ZalohaPolCsDPHVal,
CbezDPHVal=@ZalohaPolCbezDPHVal,
CastkaDPHVal=@ZalohaPolCastkaDPHVal
WHERE ID=@IdPolZal
END
DEALLOCATE POL
IF @JeHlavniMena=1
SET @ZalohaCastkaZaoVal=@ZalohaCastkaZaoKc
UPDATE TabZalFak SET
CastkaZaoKc=ISNULL(@ZalohaCastkaZaoKc, 0),
CastkaZaoVal=ISNULL(@ZalohaCastkaZaoVal, 0),
Datum=@ZalohaDatum,
Castka=ISNULL((SELECT SUM(CsDPH) FROM TabZalFakPol WHERE IDZalFak=@IdZal), 0) + ISNULL(@ZalohaCastkaZaoKc, 0),
CastkaVal=ISNULL((SELECT SUM(CsDPHVal) FROM TabZalFakPol WHERE IDZalFak=@IdZal), 0) + ISNULL(@ZalohaCastkaZaoVal, 0)
WHERE ID=@IdZal
END
DEALLOCATE ZAL
GO

