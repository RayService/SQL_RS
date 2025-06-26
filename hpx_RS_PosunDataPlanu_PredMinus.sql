USE [RayService]
GO

/****** Object:  StoredProcedure [dbo].[hpx_RS_PosunDataPlanu_PredMinus]    Script Date: 26.06.2025 13:34:18 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

CREATE PROCEDURE [dbo].[hpx_RS_PosunDataPlanu_PredMinus]
AS
/*posunout datum před první mínusovou položku a ještě přidat mínus 7 (dříve 21) dnů*/
--USE HCvicna

DECLARE @ID INT;
DECLARE @IDSklad NVARCHAR(50);
DECLARE @DateToUpdate DATETIME;
DECLARE @IDPlanu INT;

IF OBJECT_ID(N'tempdb..#TabOznacIDSS_GenBudPoh_Priprava')IS NULL
CREATE TABLE #TabOznacIDSS_GenBudPoh_Priprava(ID INT NOT NULL PRIMARY KEY)
ELSE
TRUNCATE TABLE #TabOznacIDSS_GenBudPoh_Priprava

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
CONSTRAINT CK__#TabBudPohyby__Objednat CHECK(Objednat >=0))
CREATE NONCLUSTERED INDEX IX__#TabBudPohyby__IDKmeneZbozi__Sklad__IDZakazka ON #TabBudPohyby(IDKmeneZbozi,Sklad,IDZakazka) 
CREATE NONCLUSTERED INDEX IX__#TabBudPohyby__Oblast ON #TabBudPohyby(Oblast)

--naplníme tabulku s ID kmenovými kartami
INSERT INTO #TabOznacIDSS_GenBudPoh_Priprava(ID)
SELECT tpl.IDTabKmen
FROM TabPlan tpl
LEFT OUTER JOIN TabKmenZbozi tkz ON tkz.ID=tpl.IDTabKmen
LEFT OUTER JOIN TabParKmZ pkmz ON pkmz.IDKmenZbozi=tkz.ID
LEFT OUTER JOIN TabZakazka tz ON tz.ID=tpl.IDZakazka
WHERE
((tpl.InterniZaznam=0)AND(tpl.StavPrevodu<>N'x')AND(tpl.uzavreno=0)AND(tpl.Rada LIKE N'%P_GEN%'))
--AND(tpl.datum<=GETDATE()+66)
--AND(tkz.SkupZbo = '850')
/*přidána podmínka na vyřazení DaGových karet*/--18.8.2023 vypnuto--9.10.2023 zapnuto--24.11.2023 zapnuto
AND(((ISNULL(tpl.KmenoveStredisko, (SELECT ISNULL(ZMD.KmenoveStredisko,KZ.KmenoveStredisko)
											FROM TabKmenZbozi KZ
											LEFT OUTER JOIN TabZakazModifDilce ZMD ON (ZMD.IDZakazModif=tpl.IDZakazModif AND ZMD.IDKmenZbozi=tpl.IDTabKmen) 
	WHERE KZ.ID=tpl.IDTabKmen)))<>N'20000230100')AND(tz.CisloZakazky<>N'20226858'))
AND(pkmz.RadaVyrPrikazu<>N'803')--21.6.2023 přidána podmínka na vyřazení karet, které mají řadu VP=803--9.10.2023 zapnuto--24.11.2023 zapnuto
--AND(pkmz.RadaVyrPrikazu<>N'820')--9.10.2023 přidána podmínka na vyřazení karet, které mají řadu VP=820
--dočasně 22.6.2023 pouze pro DaGovy karty
/*
AND(((ISNULL(tpl.KmenoveStredisko, (SELECT ISNULL(ZMD.KmenoveStredisko,KZ.KmenoveStredisko)
											FROM TabKmenZbozi KZ
											LEFT OUTER JOIN TabZakazModifDilce ZMD ON (ZMD.IDZakazModif=tpl.IDZakazModif AND ZMD.IDKmenZbozi=tpl.IDTabKmen) 
	WHERE KZ.ID=tpl.IDTabKmen)))=N'20000230100')OR(tz.CisloZakazky=N'20226858'))*/
--pokračování standardního kódu..
GROUP BY tpl.IDTabKmen
--přidána podmínka na vyřazení položek, které mají ve stavu skladu, výchozího skladu pro odvádění stejný jako je sklad na plánu, rezervováno>0
EXCEPT
SELECT tpl.IDTabKmen--, tkz.SkupZbo, tkz.RegCis, tkz.Nazev1, tkz.Nazev2
FROM TabPlan tpl
LEFT OUTER JOIN TabParKmZ pkmz ON tpl.IDTabKmen=pkmz.IDKmenZbozi
LEFT OUTER JOIN TabStavSkladu tss ON tss.ID=(SELECT tss.ID 
											FROM TabPlan tpl1 WITH(NOLOCK)
											LEFT OUTER JOIN TabKmenZbozi tkz WITH(NOLOCK) ON tkz.ID=tpl1.IDTabKmen 
											LEFT OUTER JOIN TabParKmZ parkmz WITH(NOLOCK) ON tpl1.IDTabKmen=parkmz.IDKmenZbozi
											LEFT OUTER JOIN TabStavSkladu tss WITH(NOLOCK) ON tss.IDKmenZbozi=tkz.ID AND tss.IDSklad=parkmz.VychoziSklad 
											WHERE  tpl1.ID=tpl.ID)
LEFT OUTER JOIN TabKmenZbozi tkz ON tkz.ID=tpl.IDTabKmen
WHERE
((tpl.InterniZaznam=0)AND(tpl.zadano=0)AND(tpl.uzavreno=0)
AND(tpl.Rada='P_GEN')
AND(tss.Rezervace>0))
GROUP BY tpl.IDTabKmen--, tkz.SkupZbo, tkz.RegCis, tkz.Nazev1, tkz.Nazev2

--teď to bude asi chtít cursor po jednotlivých položkách
DECLARE PosunPlan CURSOR LOCAL FAST_FORWARD FOR
SELECT ID
FROM #TabOznacIDSS_GenBudPoh_Priprava
OPEN PosunPlan
FETCH NEXT FROM PosunPlan INTO @ID
WHILE @@FETCH_STATUS = 0
BEGIN

IF OBJECT_ID(N'tempdb..#TabOznacIDSS_GenBudPoh')IS NOT NULL TRUNCATE TABLE #TabOznacIDSS_GenBudPoh
--naplníme tabulku s ID kmenovými kartami
INSERT INTO #TabOznacIDSS_GenBudPoh(ID) VALUES (@ID)

SET @IDSklad=(SELECT parkmz.VychoziSklad
FROM TabParKmZ parkmz WHERE parkmz.IDKmenZbozi=@ID--79141
)

--vyčistíme předchozí výpočet
IF OBJECT_ID(N'tempdb..#TabBudPohyby')IS NOT NULL TRUNCATE TABLE #TabBudPohyby
--vygenerujeme dispozice na skladech
EXEC hp_GenerovaniBudPohybu @Sklad=@IDSklad/*N''*/, @RespekMnozNaOstatSkladech=0, @ZobrazitChybejiciKmenKarty=0, @DoplnitPod=0, @TypStrediska=0, @R_prijemky=1, @R_vydejky=1,
@R_EP=1, @R_Rez=0, @R_Obj=1, @R_OdvPrijate=0, @R_PredPlan=0, @R_Plan=1, @R_VyrPrik=1, @JenMaterialy=0, @JenDilce=0, @GenerovatNulovePohyby=0, @ProSeznamKZ=1,
@R_OdvVydane=1, @OkamziteDoplneniPojisZasob=0, @R_DosObj=0, @R_StornaPrijemek=0, @R_StornaVydejek=0, @TypFormulare=6, @R_AdvKP=0, @R_ProjRizeni=0, @VybraneSklady=NULL, @KumulovatObjKeDni=NULL 

EXEC hp_BudPohyby_NastavPoradiPohybu @RespekMnozNaOstatSkladech=0, @RespekZakazky=0, @UprednostnitPlusy=0
EXEC hp_BudPohyby_AktVirtMnoz @RespekMnozNaOstatSkladech=0, @TypStrediska=0, @VybraneSklady=@IDSklad/*N''*/

SET @DateToUpdate=(SELECT TOP 1 bp.DatumPohybu
FROM #TabBudPohyby bp
WHERE bp.MnozstviNaSklade<0 AND bp.IDKmeneZbozi=@ID
ORDER BY bp.DatumPohybu ASC)
SET @IDPlanu=(SELECT IDPlan
FROM #TabbudPohyby WHERE ID=(SELECT TOP 1 p.ID
FROM #TabBudPohyby p
WHERE p.IDPlan IS NOT NULL AND p.Oblast=8 AND p.Mnozstvi>0
/* AND p.MnozstviNaSklade>0 */
AND p.IDKmeneZbozi=@ID
AND ISNULL(p.Posunuto,0)<>1
ORDER BY p.DatumPohybu ASC))

UPDATE #TabBudPohyby SET DatumPohybu=DATEADD(DAY,-7/*21*/,@DateToUpdate), Posunuto=1 WHERE IDPlan=@IDPlanu

EXEC hp_BudPohyby_NastavPoradiPohybu @RespekMnozNaOstatSkladech=1, @RespekZakazky=0, @UprednostnitPlusy=0
EXEC hp_BudPohyby_AktVirtMnoz @RespekMnozNaOstatSkladech=1, @TypStrediska=0, @VybraneSklady=@IDSklad--N''

--spustíme smyčku
WHILE EXISTS (SELECT TOP 1 p.ID
FROM #TabBudPohyby p
WHERE p.IDPlan IS NOT NULL AND p.Oblast=8 AND p.Mnozstvi>0 AND p.MnozstviNaSklade>=0 AND p.IDKmeneZbozi=@ID AND ISNULL(p.Posunuto,0)<>1
ORDER BY p.PoradiPohybu ASC)

BEGIN

--změníme datum na první mínusový zůstatek mínus 21 dní
SET @DateToUpdate=(SELECT TOP 1 bp.DatumPohybu
FROM #TabBudPohyby bp
WHERE bp.MnozstviNaSklade<0 AND bp.IDKmeneZbozi=@ID
ORDER BY bp.DatumPohybu ASC)

SET @IDPlanu=(SELECT IDPlan
FROM #TabbudPohyby WHERE ID=(SELECT TOP 1 p.ID
FROM #TabBudPohyby p
WHERE p.IDPlan IS NOT NULL AND p.Oblast=8 AND p.Mnozstvi>0/* AND p.MnozstviNaSklade>0 */AND p.IDKmeneZbozi=@ID AND ISNULL(p.Posunuto,0)<>1
ORDER BY p.DatumPohybu ASC))

--SELECT @DateToUpdate AS DateToUpdate, @IDPlanu AS IDPlanu
--pokud už není datum odchod
IF @DateToUpdate IS NULL BREAK

UPDATE #TabBudPohyby SET DatumPohybu=DATEADD(DAY,-7/*21*/,@DateToUpdate), Posunuto=1 WHERE IDPlan=@IDPlanu

--znovu spustíme výpočet pořadí a aktualizaci virt.množství
EXEC hp_BudPohyby_NastavPoradiPohybu @RespekMnozNaOstatSkladech=1, @RespekZakazky=0, @UprednostnitPlusy=0
EXEC hp_BudPohyby_AktVirtMnoz @RespekMnozNaOstatSkladech=1, @TypStrediska=0, @VybraneSklady=@IDSklad--N''

END;
/*
--cvičný select
SELECT
#TabBudPohyby.ID,#TabBudPohyby.IDPlan,#TabBudPohyby.PrKVDoklad,#TabBudPohyby.IDPlanPrikaz,#TabBudPohyby.IDPrikaz,#TabBudPohyby.Oblast,
#TabBudPohyby.Sklad,#TabBudPohyby.IDKmeneZbozi,tkz.SkupZbo,tkz.RegCis,#TabBudPohyby.DatumPohybu,#TabBudPohyby.PoradiPohybu,
#TabBudPohyby.Mnozstvi,#TabBudPohyby.MnozstviNaSklade, #TabBudPohyby.Posunuto
FROM #TabBudPohyby
LEFT OUTER JOIN TabKmenZbozi tkz ON #TabBudPohyby.IDKmeneZbozi=tkz.ID
--WHERE Posunuto=1-- IDKmeneZbozi=182229
ORDER BY IDKmeneZbozi,PoradiPohybu ASC
*/
--propsání nových datumů do plánů za všechny posunuté položky
BEGIN
MERGE TabPlan AS TARGET
USING #TabBudPohyby AS SOURCE
ON TARGET.ID=SOURCE.IDPlan
WHEN MATCHED AND ISNULL(SOURCE.Posunuto,0)=1 AND SOURCE.DatumPohybu IS NOT NULL THEN
UPDATE SET TARGET.Datum=SOURCE.DatumPohybu;

MERGE TabPlan_EXT AS TARGET
USING #TabBudPohyby AS SOURCE
ON TARGET.ID=SOURCE.IDPlan
WHEN MATCHED AND ISNULL(SOURCE.Posunuto,0)=1  AND SOURCE.DatumPohybu IS NOT NULL THEN
UPDATE SET TARGET._EXT_RS_DateChangegAutomat=1;
END;

--konec kursoru
FETCH NEXT FROM PosunPlan INTO @ID

END;
CLOSE PosunPlan;
DEALLOCATE PosunPlan;


GO

