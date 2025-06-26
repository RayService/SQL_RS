USE [RayService]
GO

/****** Object:  StoredProcedure [dbo].[hpx_RS_NavrhPosunuVOBDleDispozic]    Script Date: 26.06.2025 13:55:44 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

CREATE PROCEDURE [dbo].[hpx_RS_NavrhPosunuVOBDleDispozic]
AS
--USE HCvicna
--ID označeného řádku ve Stavu skladu


--označené ID řádků
--SELECT ID FROM #TabExtKomID

--dočasná tabule pro označená ID
IF OBJECT_ID(N'tempdb..#TabOznacIDSS_GenBudPoh')IS NULL
CREATE TABLE #TabOznacIDSS_GenBudPoh(ID INT NOT NULL PRIMARY KEY)
ELSE
TRUNCATE TABLE #TabOznacIDSS_GenBudPoh
--ID kmenových karet z označených řádků do dočasné tabule


INSERT INTO #TabOznacIDSS_GenBudPoh(ID)
SELECT ID 
FROM #TabExtKomID

--INSERT #TabOznacIDSS_GenBudPoh(ID)VALUES(@IDKmenZbozi)

IF OBJECT_ID(N'tempdb..#TabBudPohyby')IS NOT NULL DROP TABLE #TabBudPohyby
--tabule pro výpočet dočasných výsledků
CREATE TABLE dbo.#TabBudPohyby(
ID INT IDENTITY NOT NULL,
Generuj BIT NOT NULL /*CONSTRAINT DF__#TabBudPohyby__Generuj*/ DEFAULT 1,
IDPohyb INT NULL,
GUIDDosObjR BINARY(16) NULL,
IDPolKontraktu INT NULL,
IDTermOdvolavky INT NULL,
IDOdvolavky INT NULL,
IDPlan INT NULL,
IDPredPlan INT NULL,
PrKVDoklad INT NULL,
PrVPVDoklad INT NULL,
IDPlanPrikaz INT NULL,
IDPrikaz INT NULL,
IDGprUlohyMatZdroje INT NULL,
Oblast TINYINT NOT NULL,
Sklad NVARCHAR(30) COLLATE database_default NULL,
IDKmeneZbozi INT NOT NULL,
IDZakazModif INT NULL,
DatumPohybu_Pl DATETIME NULL,
DatumPohybu DATETIME NOT NULL,
PoradiPohybu INT NOT NULL/* CONSTRAINT DF__#TabBudPohyby__PoradiPohybu*/ DEFAULT 1,
MnozstviNaSklade NUMERIC(19,6) NOT NULL/* CONSTRAINT DF__#TabBudPohyby__MnozstviNaSklade*/ DEFAULT 0,
Mnozstvi_Pl NUMERIC(19,6) NOT NULL,
Mnozstvi NUMERIC(19,6) NOT NULL,
IDPolDodavKontraktu INT NULL,
Dodavatel INT NULL,
Objednat NUMERIC(19,6) NOT NULL /*CONSTRAINT DF__#TabBudPohyby__Objednat*/ DEFAULT 0,
generovano NUMERIC(19,6) NOT NULL/* CONSTRAINT DF__#TabBudPohyby__generovano */DEFAULT 0,
IDZakazka INT NULL,
DodaciLhuta INT NOT NULL /*CONSTRAINT DF__#TabBudPohyby__DodaciLhuta*/ DEFAULT 0,
TypDodaciLhuty TINYINT NOT NULL /*CONSTRAINT DF__#TabBudPohyby__TypDodaciLhuty*/ DEFAULT 0,
LhutaNaskladneni INT NOT NULL /*CONSTRAINT DF__#TabBudPohyby__LhutaNaskladneni*/ DEFAULT 0,
KumulovatObjKeDni INT NULL,
ZmenaDatumuPohybu AS (CONVERT(bit,CASE WHEN (ISNULL([DatumPohybu],0) = ISNULL([DatumPohybu_Pl],0)) THEN 0 ELSE 1 END)),
ZmenaMnozstvi AS (CONVERT(bit,CASE WHEN ([Mnozstvi] = [Mnozstvi_Pl]) THEN 0 ELSE 1 END)),
DatumObjednani AS (CASE [TypDodaciLhuty] WHEN 0 THEN DATEADD(day  , -1 * [DodaciLhuta], ([DatumPohybu] - [LhutaNaskladneni] - CASE WHEN [KumulovatObjKeDni] IS NULL THEN 0 ELSE (DATEPART(weekday, [DatumPohybu] - [LhutaNaskladneni]) + 7 - [KumulovatObjKeDni]) % 7 END))  WHEN 1 THEN DATEADD(month, -1 * [DodaciLhuta], ([DatumPohybu] - [LhutaNaskladneni] - CASE WHEN [KumulovatObjKeDni] IS NULL THEN 0 ELSE (DATEPART(weekday, [DatumPohybu] - [LhutaNaskladneni]) + 7 - [KumulovatObjKeDni]) % 7 END))  WHEN 2 THEN DATEADD(year , -1 * [DodaciLhuta], ([DatumPohybu] - [LhutaNaskladneni] - CASE WHEN [KumulovatObjKeDni] IS NULL THEN 0 ELSE (DATEPART(weekday, [DatumPohybu] - [LhutaNaskladneni]) + 7 - [KumulovatObjKeDni]) % 7 END)) END),
PozadDatDod AS ([DatumPohybu] - [LhutaNaskladneni] - CASE WHEN [KumulovatObjKeDni] IS NULL THEN 0 ELSE (DATEPART(weekday, [DatumPohybu] - [LhutaNaskladneni]) + 7 - [KumulovatObjKeDni]) % 7 END),
--CONSTRAINT PK__#TabBudPohyby__ID PRIMARY KEY(ID),
--CONSTRAINT CK__#TabBudPohyby__Objednat CHECK(Objednat >=0)
)

TRUNCATE TABLE #TabBudPohyby

EXEC hp_GenerovaniBudPohybu N'100', 1, 0, 0, 3, 1, 0, 1, 0, 1, 0, 0, 1, 1, 0, 0, 0, 1, 0, 0, 0, 0, 0, 6, 0, 0, N'100,10000140144'
EXEC hp_BudPohyby_NastavPoradiPohybu @RespekMnozNaOstatSkladech=1, @RespekZakazky=0, @UprednostnitPlusy=0
EXEC hp_BudPohyby_AktVirtMnoz @RespekMnozNaOstatSkladech=1, @TypStrediska=3, @VybraneSklady=N'100,10000140144'

--SELECT *
--FROM #TabBudPohyby
--ORDER BY PoradiPohybu ASC


DECLARE @IDKmenZbozi INT

DECLARE CurPolozka CURSOR FAST_FORWARD LOCAL FOR 
SELECT DISTINCT IDKmeneZbozi
FROM #TabBudPohyby

OPEN CurPolozka 
    FETCH NEXT FROM CurPolozka INTO @IDKmenZbozi
    WHILE @@fetch_status=0 
      BEGIN 

--SET @IDKmenZbozi=(SELECT IDKmenZbozi FROM TabStavSkladu WHERE ID=@ID)




		--tabule pro uložení hodnot a určení posunu: Tabx_RS_TabBudPohybyZobraz
		--vymažeme data
		DELETE FROM Tabx_RS_TabBudPohybyZobraz WHERE IDKmeneZbozi=@IDKmenZbozi
		--vložíme vypočtená data
		INSERT INTO Tabx_RS_TabBudPohybyZobraz ([Generuj],[IDPohyb],[IDPlan],[IDPredPlan],[PrKVDoklad],[PrVPVDoklad],[IDPlanPrikaz],[IDPrikaz],[IDGprUlohyMatZdroje],[Oblast],[Sklad],[IDKmeneZbozi],[DatumPohybu_Pl],[DatumPohybu],[PoradiPohybu],[MnozstviNaSklade]
		,[Mnozstvi_Pl],[Mnozstvi],[Dodavatel],[Objednat],[generovano],[IDZakazka],[DodaciLhuta],[TypDodaciLhuty],[LhutaNaskladneni],[KumulovatObjKeDni])
		SELECT Generuj,IDPohyb,IDPlan,IDPredPlan,PrKVDoklad,PrVPVDoklad,IDPlanPrikaz,IDPrikaz,IDGprUlohyMatZdroje,Oblast,Sklad,IDKmeneZbozi,DatumPohybu_Pl,DatumPohybu,PoradiPohybu,MnozstviNaSklade,Mnozstvi_Pl,Mnozstvi,Dodavatel,Objednat,generovano,IDZakazka
		,DodaciLhuta,TypDodaciLhuty,LhutaNaskladneni,KumulovatObjKeDni
		FROM #TabBudPohyby
		WHERE IDKmeneZbozi=@IDKmenZbozi

		--DECLARE @ID INT=93140
		DECLARE @DatumPrvniMinus DATETIME, @IDPrvniMinus INT, @DatumPrvniVOB DATETIME, @IDPrvniVOB INT
		--ID a datum prvního mínusového pohybu	
		SET @IDPrvniMinus=(SELECT TOP 1 bp.ID FROM Tabx_RS_TabBudPohybyZobraz bp WHERE bp.MnozstviNaSklade<0 AND bp.IDKmeneZbozi=@IDKmenZbozi ORDER BY bp.DatumPohybu ASC)
		SET @DatumPrvniMinus=(SELECT TOP 1 bp.DatumPohybu AS IDPohybu FROM Tabx_RS_TabBudPohybyZobraz bp WHERE bp.MnozstviNaSklade<0 AND bp.IDKmeneZbozi=@IDKmenZbozi ORDER BY bp.DatumPohybu ASC)
		--ID a datum první VOB
		SET @IDPrvniVOB=(SELECT TOP 1 bp.ID FROM Tabx_RS_TabBudPohybyZobraz bp WHERE bp.Oblast=0 AND bp.IDKmeneZbozi=@IDKmenZbozi ORDER BY bp.DatumPohybu ASC)
		SET @DatumPrvniVOB=(SELECT TOP 1 bp.DatumPohybu AS IDPohybu FROM Tabx_RS_TabBudPohybyZobraz bp WHERE bp.Oblast=0 AND bp.IDKmeneZbozi=@IDKmenZbozi ORDER BY bp.DatumPohybu ASC)

		--SELECT @DatumPrvniMinus AS DatumPrvniMinus, @IDPrvniMinus AS IDPrvniMinus
		--SELECT @DatumPrvniVOB AS DatumPrvniVOB, @IDPrvniVOB AS IDPrvniVOB
		--návhr posunu zpět
		IF @DatumPrvniVOB > @DatumPrvniMinus
		BEGIN
		--SELECT 'Existuje objednávka s vyšším datem než je první mínusový požadavek'
		UPDATE bp SET bp.DatumPohybuNew=@DatumPrvniMinus,bp.NavrhPosunu=1
		FROM Tabx_RS_TabBudPohybyZobraz bp
		WHERE bp.ID=@IDPrvniVOB AND bp.IDKmeneZbozi=@IDKmenZbozi
		END;

		DECLARE @DatumPrvniPlus DATETIME, @IDPrvniPlus INT, @DatumPrvniVOBPlus DATETIME, @IDPrvniVOBPlus INT, @MnozstviVOB NUMERIC(19,6)
		--ID a datum první plusové VOB
		SET @IDPrvniVOBPlus=(SELECT TOP 1 bp.ID FROM Tabx_RS_TabBudPohybyZobraz bp WHERE bp.Oblast=0 AND bp.MnozstviNaSklade>0 AND bp.IDKmeneZbozi=@IDKmenZbozi ORDER BY bp.DatumPohybu ASC)
		SET @DatumPrvniVOBPlus=(SELECT TOP 1 bp.DatumPohybu FROM Tabx_RS_TabBudPohybyZobraz bp WHERE bp.Oblast=0 AND bp.MnozstviNaSklade>0 AND bp.IDKmeneZbozi=@IDKmenZbozi ORDER BY bp.DatumPohybu ASC)
		SET @MnozstviVOB=(SELECT TOP 1 bp.Mnozstvi AS IDPohybu FROM Tabx_RS_TabBudPohybyZobraz bp WHERE bp.Oblast=0 AND bp.MnozstviNaSklade>0 AND bp.IDKmeneZbozi=@IDKmenZbozi ORDER BY bp.DatumPohybu ASC)
		--ID a datum prvního plusového pohybu po odečtení plusové VOB
		SET @IDPrvniPlus=(SELECT TOP 1 bp.ID FROM Tabx_RS_TabBudPohybyZobraz bp WHERE bp.MnozstviNaSklade-@MnozstviVOB<0 AND bp.IDKmeneZbozi=@IDKmenZbozi ORDER BY bp.DatumPohybu ASC)
		SET @DatumPrvniPlus=(SELECT TOP 1 bp.DatumPohybu FROM Tabx_RS_TabBudPohybyZobraz bp WHERE bp.MnozstviNaSklade-@MnozstviVOB<0 AND bp.IDKmeneZbozi=@IDKmenZbozi ORDER BY bp.DatumPohybu ASC)

		--SELECT @DatumPrvniVOBPlus AS DatumPrvniVOBPlus, @IDPrvniVOBPlus AS IDPrvniVOBPlus, @MnozstviVOB AS MnoVOB
		--SELECT @DatumPrvniPlus AS DatumPrvniPlus, @IDPrvniPlus AS IDPrvniPlus
		--návhr posunu dopředu
		IF @DatumPrvniVOBPlus < @DatumPrvniPlus
		BEGIN
		--SELECT 'Existuje objednávka s nižším datem než je první přebytkový požadavek'
		UPDATE bp SET bp.DatumPohybuNew=@DatumPrvniPlus,bp.NavrhPosunu=2
		FROM Tabx_RS_TabBudPohybyZobraz bp
		WHERE bp.ID=@IDPrvniVOBPlus AND bp.IDKmeneZbozi=@IDKmenZbozi
		END;

		--SELECT bpz.ID,bpz.IDPohyb,bpz.IDPlan,bpz.PrKVDoklad,bpz.IDPlanPrikaz,bpz.Oblast,bpz.Sklad,bpz.DatumPohybu,bpz.DatumPohybuNew,bpz.PoradiPohybu,bpz.MnozstviNaSklade,tdz.ID,tdz.RadaDokladu,tdz.PoradoveCislo,tdz.IDSklad
		--FROM Tabx_RS_TabBudPohybyZobraz bpz
		--LEFT OUTER JOIN TabDokladyZbozi tdz ON tdz.ID=(SELECT tpz.IDDoklad FROM TabPohybyZbozi tpz WHERE tpz.ID=bpz.IDPohyb)
		--ORDER BY bpz.PoradiPohybu ASC

		--IF OBJECT_ID(N'tempdb..#TabBudPohyby')IS NOT NULL DROP TABLE #TabBudPohyby

        FETCH NEXT FROM CurPolozka INTO @IDKmenZbozi
      END 
    CLOSE CurPolozka 
    DEALLOCATE CurPolozka 


GO

