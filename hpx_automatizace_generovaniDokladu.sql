USE [RayService]
GO

/****** Object:  StoredProcedure [dbo].[hpx_automatizace_generovaniDokladu]    Script Date: 30.06.2025 8:13:37 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

CREATE PROCEDURE [dbo].[hpx_automatizace_generovaniDokladu] @ID INT, @IDKrok INT, @Vyhodnoceni INT, @IDDokladNew INT OUT, @ErrorCode INT OUT, @ErrorMsg NVARCHAR(MAX) OUT
AS
DECLARE @ErrStr NVARCHAR(2047)
DECLARE @IDParamAno1 INT
DECLARE @Rada NVARCHAR(3)
DECLARE @RealizovatFak BIT
DECLARE @DatumReal DATETIME

SET @ErrorCode=0
IF @ID IS NULL OR @IDKrok IS NULL
BEGIN
  SET @ErrStr = dbo.hf_FormatError(59585, '')
  RAISERROR(@ErrStr, 16, 1)
  RETURN
END
SELECT @IDParamAno1=(CASE WHEN Posun=1 THEN IDParamMan1 ELSE CASE WHEN @Vyhodnoceni=1 THEN IDParamAno1 ELSE IDParamNe1 END END),
@RealizovatFak=(CASE WHEN Posun=1 THEN RealizovatFakMan ELSE CASE WHEN @Vyhodnoceni=1 THEN RealizovatFak1 ELSE RealizovatFak0 END END)
FROM TabAutomatizace WHERE ID=@IDKrok
IF @IDParamAno1 IS NULL
BEGIN
  SET @ErrStr = dbo.hf_FormatError(68674, '')
  RAISERROR(@ErrStr, 16, 1)
  RETURN
END
SELECT @Rada=RadaDokladu FROM TabDosleObjGenProfil WHERE ID=@IDParamAno1

IF OBJECT_ID(N'tempdb..#tmpDOBJ_OznaceneProNavazGen')IS NULL
CREATE TABLE #tmpDOBJ_OznaceneProNavazGen(ID INT NOT NULL PRIMARY KEY)
ELSE
TRUNCATE TABLE #tmpDOBJ_OznaceneProNavazGen

INSERT #tmpDOBJ_OznaceneProNavazGen(ID)VALUES(@ID)

CREATE TABLE dbo.#TabDosleObjGenDoklad(
ID INT NOT NULL,
IDZboSklad INT NOT NULL,
Zarazeno BIT NOT NULL CONSTRAINT DF__#TabDosleObjGenDoklad__Zarazeno__57 DEFAULT 1,
Skupina1 INT NOT NULL CONSTRAINT DF__#TabDosleObjGenDoklad__Skupina1__57 DEFAULT 1,
Skupina2 INT NOT NULL CONSTRAINT DF__#TabDosleObjGenDoklad__Skupina2__57 DEFAULT 1,
MnozstviChtene NUMERIC(19,6) NOT NULL CONSTRAINT DF__#TabDosleObjGenDoklad__MnozstviChtene__57 DEFAULT (0.0),
MnozstviJizGenCelkem NUMERIC(19,6) NOT NULL CONSTRAINT DF__#TabDosleObjGenDoklad__MnozstviJizGenCelkem__57 DEFAULT (0.0),
MnozstviJizGen NUMERIC(19,6) NOT NULL CONSTRAINT DF__#TabDosleObjGenDoklad__MnozstviJizGen__57 DEFAULT (0.0),
MnozstviMax NUMERIC(19,6) NOT NULL CONSTRAINT DF__#TabDosleObjGenDoklad__MnozstviMax__57 DEFAULT (0.0),
MnozstviRealVydej NUMERIC(19,6) NOT NULL CONSTRAINT DF__#TabDosleObjGenDoklad__MnozstviRealVydej__57 DEFAULT (0.0),
Upozorneni TINYINT NOT NULL CONSTRAINT DF__#TabDosleObjGenDoklad__Upozorneni__57 DEFAULT 0,
Zpusob TINYINT NOT NULL CONSTRAINT DF__#TabDosleObjGenDoklad__Zpusob__57 DEFAULT 0,
RetValue TINYINT NOT NULL CONSTRAINT DF__#TabDosleObjGenDoklad__RetValue__57 DEFAULT 0,
IDDoklad INT NOT NULL CONSTRAINT DF__#TabDosleObjGenDoklad__IDDoklad__57 DEFAULT 0,
Grupovat BIT NOT NULL CONSTRAINT DF__#TabDosleObjGenDoklad__Grupovat__57 DEFAULT 1,
Blokovano TINYINT NOT NULL CONSTRAINT DF__#TabDosleObjGenDoklad__Blokovano__57 DEFAULT 0,
DalsiZprava INT NOT NULL CONSTRAINT DF__#TabDosleObjGenDoklad__DalsiZprava__57 DEFAULT 0,
JeVC BIT NOT NULL CONSTRAINT DF__#TabDosleObjGenDoklad__JeVC__57 DEFAULT 0,
CONSTRAINT PK__#TabDosleObjGenDoklad__ID__IDZboSklad__57 PRIMARY KEY(ID,IDZboSklad))

CREATE TABLE dbo.#TabDosleObjGenTxtDoklad(
ID INT NOT NULL,
Zarazeno BIT NOT NULL CONSTRAINT DF__#TabDosleObjGenTxtDoklad__Zarazeno__57 DEFAULT 1,
Skupina1 INT NOT NULL CONSTRAINT DF__#TabDosleObjGenTxtDoklad__Skupina1__57 DEFAULT 1,
Skupina2 INT NOT NULL CONSTRAINT DF__#TabDosleObjGenTxtDoklad__Skupina2__57 DEFAULT 1,
MnozstviChtene NUMERIC(19,6) NOT NULL CONSTRAINT DF__#TabDosleObjGenTxtDoklad__MnozstviChtene__57 DEFAULT (0.0),
MnozstviJizGen NUMERIC(19,6) NOT NULL CONSTRAINT DF__#TabDosleObjGenTxtDoklad__MnozstviJizGen__57 DEFAULT (0.0),
CONSTRAINT PK__#TabDosleObjGenTxtDoklad__ID__57 PRIMARY KEY(ID))

CREATE TABLE dbo.#TabDosleObjGenDokladVC(
ID INT NOT NULL,
Nazev1 NVARCHAR(100) COLLATE database_default NOT NULL CONSTRAINT DF__#TabDosleObjGenDokladVC__Nazev1__57 DEFAULT '',
IDZboSklad INT NOT NULL,
Zarazeno BIT NOT NULL CONSTRAINT DF__#TabDosleObjGenDokladVC__Zarazeno__57 DEFAULT 1,
MnozstviMax NUMERIC(19,6) NOT NULL CONSTRAINT DF__#TabDosleObjGenDokladVC__MnozstviMax__57 DEFAULT (0.0),
MnozstviChtene NUMERIC(19,6) NOT NULL CONSTRAINT DF__#TabDosleObjGenDokladVC__MnozstviChtene__57 DEFAULT (0.0),
IDPohyb INT NOT NULL CONSTRAINT DF__#TabDosleObjGenDokladVC__IDPohyb__57 DEFAULT 0,
Vyber BIT NOT NULL CONSTRAINT DF__#TabDosleObjGenDokladVC__Vyber__57 DEFAULT 0,
IDPuv INT NOT NULL,
ZdrojovaTab TINYINT NULL)

CREATE TABLE dbo.#TabDosleObjGenVazbyMeziProfily ( Profil INT, NavaznyProfil INT)
CREATE TABLE dbo.#TabDosleObjGenDokladHRID( HID INT, RID INT )

EXEC dbo.hp_DosleObj_PripravPolozkyProGenerovani02 @IDParamAno1,0,0,NULL,1,0,0,0

IF OBJECT_ID(N'tempdb..#TabDOdoOZ_hp_DosleObj_PripravPolozkyProGenerovani02') IS NOT NULL
DROP TABLE #TabDOdoOZ_hp_DosleObj_PripravPolozkyProGenerovani02


EXEC dbo.hp_DosleObj_GenNavaznyDoklad02
@ID, 1, @IDParamAno1, @Rada, NULL, NULL, 0, 2, @IDDokladNew OUT, @ErrorCode OUT, 0

IF @IDDokladNew IS NULL
  SET @ErrorCode=68559

IF @IDDokladNew IS NOT NULL AND @RealizovatFak=1
BEGIN
  IF OBJECT_ID(N'tempdb..#TabSeznamID') IS NULL 
    CREATE TABLE dbo.#TabSeznamID(ID INT NOT NULL,ID2 INT NULL,IDPom INT NULL,IDPom2 INT NULL,IDPom3 INT NULL,
        Info NVARCHAR(50) COLLATE database_default NULL CONSTRAINT DF__#TabSeznamID__Info__57 DEFAULT '',
        OK AS (convert(bit,case when ([IDPom] is null) then 0 else 1 end)),
        OK2 AS (convert(bit,case when ([IDPom2] is null) then 0 else 1 end)))
  TRUNCATE TABLE #TabSeznamID

  EXEC dbo.hp_realizuj_fak @IDDokladNew,@DatumReal,999
  SET @ErrorCode=@@ERROR
END
GO

