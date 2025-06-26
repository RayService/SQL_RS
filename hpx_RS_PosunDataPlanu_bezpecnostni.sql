USE [RayService]
GO

/****** Object:  StoredProcedure [dbo].[hpx_RS_PosunDataPlanu_bezpecnostni]    Script Date: 26.06.2025 13:32:33 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

ALTER PROCEDURE [dbo].[hpx_RS_PosunDataPlanu_bezpecnostni]
AS
/*posunout datum plánu o 21 dní před první následující mínusový odpočet*/
--USE HCvicna

DECLARE @ID INT
DECLARE @IDSklad NVARCHAR(50)
IF OBJECT_ID(N'tempdb..#TabOznacIDSS_GenBudPoh')IS NULL
CREATE TABLE #TabOznacIDSS_GenBudPoh(ID INT NOT NULL PRIMARY KEY)
ELSE
TRUNCATE TABLE #TabOznacIDSS_GenBudPoh

IF OBJECT_ID(N'tempdb..#TabBudPohyby')IS NOT NULL DROP TABLE #TabBudPohyby
CREATE TABLE dbo.#TabBudPohyby(
ID INT IDENTITY NOT NULL,
Generuj BIT NOT NULL CONSTRAINT DF__#TabBudPohyby__Generuj DEFAULT 1,
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
PoradiPohybu INT NOT NULL CONSTRAINT DF__#TabBudPohyby__PoradiPohybu DEFAULT 1,
MnozstviNaSklade NUMERIC(19,6) NOT NULL CONSTRAINT DF__#TabBudPohyby__MnozstviNaSklade DEFAULT 0,
Mnozstvi_Pl NUMERIC(19,6) NOT NULL,
Mnozstvi NUMERIC(19,6) NOT NULL,
IDPolDodavKontraktu INT NULL,
Dodavatel INT NULL,
Objednat NUMERIC(19,6) NOT NULL CONSTRAINT DF__#TabBudPohyby__Objednat DEFAULT 0,
generovano NUMERIC(19,6) NOT NULL CONSTRAINT DF__#TabBudPohyby__generovano DEFAULT 0,
IDZakazka INT NULL,
DodaciLhuta INT NOT NULL CONSTRAINT DF__#TabBudPohyby__DodaciLhuta DEFAULT 0,
TypDodaciLhuty TINYINT NOT NULL CONSTRAINT DF__#TabBudPohyby__TypDodaciLhuty DEFAULT 0,
LhutaNaskladneni INT NOT NULL CONSTRAINT DF__#TabBudPohyby__LhutaNaskladneni DEFAULT 0,
KumulovatObjKeDni INT NULL,
DatumPohybu_Pl_D AS (DATEPART(DAY,[DatumPohybu_Pl])),
DatumPohybu_Pl_M AS (DATEPART(MONTH,[DatumPohybu_Pl])),
DatumPohybu_Pl_Y AS (DATEPART(YEAR,[DatumPohybu_Pl])),
DatumPohybu_Pl_Q AS (DATEPART(QUARTER,[DatumPohybu_Pl])),
DatumPohybu_Pl_W AS (DATEPART(WEEK,[DatumPohybu_Pl])),
DatumPohybu_Pl_X AS (CONVERT(DATETIME,CONVERT(INT,CONVERT(FLOAT,[DatumPohybu_Pl])))),
DatumPohybu_D AS (DATEPART(DAY,[DatumPohybu])),
DatumPohybu_M AS (DATEPART(MONTH,[DatumPohybu])),
DatumPohybu_Y AS (DATEPART(YEAR,[DatumPohybu])),
DatumPohybu_Q AS (DATEPART(QUARTER,[DatumPohybu])),
DatumPohybu_W AS (DATEPART(WEEK,[DatumPohybu])),
DatumPohybu_X AS (CONVERT(DATETIME,CONVERT(INT,CONVERT(FLOAT,[DatumPohybu])))),
ZmenaDatumuPohybu AS (CONVERT(bit,CASE WHEN (ISNULL([DatumPohybu],0) = ISNULL([DatumPohybu_Pl],0)) THEN 0 ELSE 1 END)),
ZmenaMnozstvi AS (CONVERT(bit,CASE WHEN ([Mnozstvi] = [Mnozstvi_Pl]) THEN 0 ELSE 1 END)),
DatumObjednani AS (CASE [TypDodaciLhuty] WHEN 0 THEN DATEADD(day  , -1 * [DodaciLhuta], ([DatumPohybu] - [LhutaNaskladneni] - CASE WHEN [KumulovatObjKeDni] IS NULL THEN 0 ELSE (DATEPART(weekday, [DatumPohybu] - [LhutaNaskladneni]) + 7 - [KumulovatObjKeDni]) % 7 END))  WHEN 1 THEN DATEADD(month, -1 * [DodaciLhuta], ([DatumPohybu] - [LhutaNaskladneni] - CASE WHEN [KumulovatObjKeDni] IS NULL THEN 0 ELSE (DATEPART(weekday, [DatumPohybu] - [LhutaNaskladneni]) + 7 - [KumulovatObjKeDni]) % 7 END))  WHEN 2 THEN DATEADD(year , -1 * [DodaciLhuta], ([DatumPohybu] - [LhutaNaskladneni] - CASE WHEN [KumulovatObjKeDni] IS NULL THEN 0 ELSE (DATEPART(weekday, [DatumPohybu] - [LhutaNaskladneni]) + 7 - [KumulovatObjKeDni]) % 7 END)) END),
PozadDatDod AS ([DatumPohybu] - [LhutaNaskladneni] - CASE WHEN [KumulovatObjKeDni] IS NULL THEN 0 ELSE (DATEPART(weekday, [DatumPohybu] - [LhutaNaskladneni]) + 7 - [KumulovatObjKeDni]) % 7 END),
Posunuto BIT,
DatumPohybuRozdil INT,
CONSTRAINT CK__#TabBudPohyby__Objednat CHECK(Objednat >=0))
CREATE NONCLUSTERED INDEX IX__#TabBudPohyby__IDKmeneZbozi__Sklad__IDZakazka ON #TabBudPohyby(IDKmeneZbozi,Sklad,IDZakazka) 
CREATE NONCLUSTERED INDEX IX__#TabBudPohyby__Oblast ON #TabBudPohyby(Oblast)

--naplníme tabulku s ID kmenovými kartami
INSERT INTO #TabOznacIDSS_GenBudPoh(ID)
--VALUES (79141)--,(113141),(113140),(113137)
SELECT
tpl.IDTabKmen
FROM TabPlan tpl
LEFT OUTER JOIN TabKmenZbozi tkz ON tkz.ID=tpl.IDTabKmen
WHERE
((tpl.InterniZaznam=0)AND(tpl.StavPrevodu<>N'x')AND(tpl.uzavreno=0)AND(tpl.Rada LIKE N'%P_GEN%'))AND(tpl.datum<=GETDATE()+66)
--AND(tpl.IDTabKmen=113996)
GROUP BY tpl.IDTabKmen

--teď to bude asi chtít cursor po jednotlivých položkách
DECLARE PosunPlan CURSOR LOCAL FAST_FORWARD FOR
SELECT ID
FROM #TabOznacIDSS_GenBudPoh
OPEN PosunPlan
FETCH NEXT FROM PosunPlan INTO @ID
WHILE @@FETCH_STATUS = 0
BEGIN

SELECT @IDSklad=parkmz.VychoziSklad
FROM TabParKmZ parkmz WHERE parkmz.IDKmenZbozi=@ID--79141

--vyčistíme předchozí výpočet
IF OBJECT_ID(N'tempdb..#TabBudPohyby')IS NOT NULL TRUNCATE TABLE #TabBudPohyby
--vygenerujeme dispozice na skladech
EXEC hp_GenerovaniBudPohybu @Sklad=@IDSklad/*N''*/, @RespekMnozNaOstatSkladech=0, @ZobrazitChybejiciKmenKarty=0, @DoplnitPod=0, @TypStrediska=0, @R_prijemky=1, @R_vydejky=1,
@R_EP=1, @R_Rez=0, @R_Obj=1, @R_OdvPrijate=0, @R_PredPlan=0, @R_Plan=1, @R_VyrPrik=1, @JenMaterialy=0, @JenDilce=0, @GenerovatNulovePohyby=0, @ProSeznamKZ=1,
@R_OdvVydane=1, @OkamziteDoplneniPojisZasob=0, @R_DosObj=0, @R_StornaPrijemek=0, @R_StornaVydejek=0, @TypFormulare=6, @R_AdvKP=0, @R_ProjRizeni=0, @VybraneSklady=NULL, @KumulovatObjKeDni=NULL 
--upravíme pořadí a virtuální množství
EXEC hp_BudPohyby_NastavPoradiPohybu @RespekMnozNaOstatSkladech=0, @RespekZakazky=0, @UprednostnitPlusy=0
EXEC hp_BudPohyby_AktVirtMnoz @RespekMnozNaOstatSkladech=0, @TypStrediska=0, @VybraneSklady=@IDSklad/*N''*/

--spočteme rozdíl v datumových údajích
;WITH UPDPoh AS (
SELECT bp.IDPlan AS IDPlan, bp.PoradiPohybu AS Poradi, bp.DatumPohybu AS Datum, LEAD(bp.DatumPohybu) OVER (ORDER BY bp.PoradiPohybu ASC) AS NextDatum, 
DATEDIFF(DAY,DatumPohybu,LEAD(bp.DatumPohybu) OVER (ORDER BY bp.PoradiPohybu ASC)) AS DatumDiff, bp.DatumPohybuRozdil AS DatumPohybuRozdil
FROM #TabBudPohyby bp
WHERE /*bp.IDPlan IS NOT NULL AND bp.Oblast<>8 AND */bp.IDKmeneZbozi=@ID)--79141)
UPDATE UPDPoh SET DatumPohybuRozdil=DatumDiff

--upravíme datum na 21 dní do minulosti
UPDATE bp SET bp.DatumPohybu=DATEADD(DAY,-20,DatumPohybu),bp.Posunuto=1
FROM #TabBudPohyby bp
WHERE bp.Oblast=8 AND bp.DatumPohybuRozdil<21

--opětovné přeřazení po úpravě data plánu
EXEC hp_BudPohyby_NastavPoradiPohybu @RespekMnozNaOstatSkladech=0, @RespekZakazky=0, @UprednostnitPlusy=0
EXEC hp_BudPohyby_AktVirtMnoz @RespekMnozNaOstatSkladech=0, @TypStrediska=0, @VybraneSklady=@IDSklad/*N''*/

/*
--znovu spočteme rozdíl
;WITH UPDPoh AS (
SELECT bp.IDPlan AS IDPlan, bp.PoradiPohybu AS Poradi, bp.DatumPohybu AS Datum, LEAD(bp.DatumPohybu) OVER (ORDER BY bp.PoradiPohybu ASC) AS NextDatum, 
DATEDIFF(DAY,DatumPohybu,LEAD(bp.DatumPohybu) OVER (ORDER BY bp.PoradiPohybu ASC)) AS DatumDiff, bp.DatumPohybuRozdil AS DatumPohybuRozdil
FROM #TabBudPohyby bp
WHERE /*bp.IDPlan IS NOT NULL AND bp.Oblast<>8 AND */bp.IDKmeneZbozi=@ID)--79141)
UPDATE UPDPoh SET DatumPohybuRozdil=DatumDiff


--znovu upravíme datum na 21 dní do minulosti
UPDATE bp SET bp.DatumPohybu=DATEADD(DAY,-20,DatumPohybu)
FROM #TabBudPohyby bp
WHERE bp.Oblast=8 AND bp.DatumPohybuRozdil<21


--opětovné přeřazení po úpravě data plánu
EXEC hp_BudPohyby_NastavPoradiPohybu @RespekMnozNaOstatSkladech=0, @RespekZakazky=0, @UprednostnitPlusy=0
EXEC hp_BudPohyby_AktVirtMnoz @RespekMnozNaOstatSkladech=0, @TypStrediska=0, @VybraneSklady=N'20000280'--@IDSklad/*N''*/
*/
/*
--znovu po 2. spočteme rozdíl
;WITH UPDPoh AS (
SELECT bp.IDPlan AS IDPlan, bp.PoradiPohybu AS Poradi, bp.DatumPohybu AS Datum, LEAD(bp.DatumPohybu) OVER (ORDER BY bp.PoradiPohybu ASC) AS NextDatum, 
DATEDIFF(DAY,DatumPohybu,LEAD(bp.DatumPohybu) OVER (ORDER BY bp.PoradiPohybu ASC)) AS DatumDiff, bp.DatumPohybuRozdil AS DatumPohybuRozdil
FROM #TabBudPohyby bp
WHERE /*bp.IDPlan IS NOT NULL AND bp.Oblast<>8 AND */bp.IDKmeneZbozi=@ID)--79141)
UPDATE UPDPoh SET DatumPohybuRozdil=DatumDiff

--opětovné přeřazení po úpravě data plánu
EXEC hp_BudPohyby_NastavPoradiPohybu @RespekMnozNaOstatSkladech=0, @RespekZakazky=0, @UprednostnitPlusy=0
EXEC hp_BudPohyby_AktVirtMnoz @RespekMnozNaOstatSkladech=0, @TypStrediska=0, @VybraneSklady=N'20000280'--@IDSklad/*N''*/
*/

/*
SELECT
#TabBudPohyby.ID,#TabBudPohyby.IDPlan,#TabBudPohyby.Oblast,#TabBudPohyby.IDKmeneZbozi,#TabBudPohyby.DatumPohybu,#TabBudPohyby.PoradiPohybu,
#TabBudPohyby.Mnozstvi,#TabBudPohyby.MnozstviNaSklade,#TabBudPohyby.DatumPohybuRozdil
FROM #TabBudPohyby
LEFT OUTER JOIN TabKmenZbozi tkz ON #TabBudPohyby.IDKmeneZbozi=tkz.ID
--WHERE IDKmeneZbozi=@ID--79141
ORDER BY IDKmeneZbozi,PoradiPohybu ASC
*/

--propsání nových datumů do plánů za všechny posunuté položky
BEGIN
MERGE TabPlan AS TARGET
USING #TabBudPohyby AS SOURCE
ON TARGET.ID=SOURCE.IDPlan
WHEN MATCHED AND ISNULL(SOURCE.Posunuto,0)=1/* ISNULL(SOURCE.DatumPohybuRozdil,0)=21*/ AND SOURCE.Oblast=8 THEN
UPDATE SET TARGET.Datum=SOURCE.DatumPohybu;
END;


SELECT
#TabBudPohyby.ID,#TabBudPohyby.IDPlan,#TabBudPohyby.Oblast,#TabBudPohyby.IDKmeneZbozi,#TabBudPohyby.DatumPohybu,#TabBudPohyby.PoradiPohybu,
#TabBudPohyby.Mnozstvi,#TabBudPohyby.MnozstviNaSklade,#TabBudPohyby.DatumPohybuRozdil,#TabBudPohyby.Posunuto
FROM #TabBudPohyby
LEFT OUTER JOIN TabKmenZbozi tkz ON #TabBudPohyby.IDKmeneZbozi=tkz.ID
--WHERE IDKmeneZbozi=@ID--79141
ORDER BY IDKmeneZbozi,PoradiPohybu ASC

--konec kursoru
FETCH NEXT FROM PosunPlan INTO @ID

END;
CLOSE PosunPlan;
DEALLOCATE PosunPlan;

GO

