USE [RayService]
GO

/****** Object:  StoredProcedure [dbo].[hpx_RS_generate_order_OVD]    Script Date: 26.06.2025 13:12:47 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO


CREATE PROCEDURE [dbo].[hpx_RS_generate_order_OVD] @ID INT
AS

/*
--cvičná tabulka se skladovou kartou
IF OBJECT_ID(N'tempdb..#TabOznacIDSS_GenBudPoh') IS NOT NULL DROP TABLE #TabOznacIDSS_GenBudPoh
IF OBJECT_ID(N'tempdb..#TabBudPohyby') IS NOT NULL DROP TABLE #TabBudPohyby
CREATE TABLE #TabOznacIDSS_GenBudPoh(ID INT NOT NULL PRIMARY KEY)
INSERT #TabOznacIDSS_GenBudPoh(ID)VALUES(223668)

--cvičná deklarace tabulky
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
DatumObjednani AS (CASE [TypDodaciLhuty] WHEN 0 THEN DATEADD(day, -1 * [DodaciLhuta], [DatumPohybu])  WHEN 1 THEN DATEADD(month, -1 * [DodaciLhuta], [DatumPohybu])  WHEN 2 THEN DATEADD(year, -1 * [DodaciLhuta], [DatumPohybu]) END - [LhutaNaskladneni]),
PozadDatDod AS ([DatumPohybu] - [LhutaNaskladneni]),
CONSTRAINT PK__#TabBudPohyby__ID PRIMARY KEY(ID),
CONSTRAINT CK__#TabBudPohyby__Objednat CHECK(Objednat >=0))


DECLARE @ret integer
EXEC @ret=hp_GenerovaniBudPohybu N'', 0, 0, 0, 0, 1, 1, 1, 0, 1, 0, 0, 1, 1, 0, 1, 1, 0, 0, 0, 0, 0, 0, 1, 0, 0, N''

EXEC @ret=hp_BudPohyby_NastavPoradiPohybu @RespekMnozNaOstatSkladech=0, @RespekZakazky=0, @UprednostnitPlusy=1, @JenPro_IDKmeneZbozi=NULL, @JenPro_Sklad=NULL

EXEC @ret=hp_BudPohyby_PrednabMnozKObj @RespMinDod=1, @ZadavatNasobMinDod=0, @Kumulovat=60, @DoplnitPod=0, @DoplnitNa=1, @TypStrediska=0, @VybraneSklady=N'', @DatumObjDo=N'20231231', @UprednostnitPlusy=1, @RespekMnozNaOstatSkladech=0, @RespekZakazky=0, @VyrobniObj=1


--cvičně si zobrazíme tabulku před generováním plánů
SELECT tkz.ID AS IDKmen,tkz.skupzbo, tkz.regcis, td.davka, T.Objednat, T.ID, T.IDPlan AS IDPlan, T.PrKVDoklad, T.IDPlanPrikaz, T.Oblast, T.Sklad, T.IDKmeneZbozi, T.DatumPohybu, T.PoradiPohybu, T.MnozstviNaSklade, T.Mnozstvi_Pl, T.Mnozstvi, T.Dodavatel, T.IDZakazka, T.DodaciLhuta, T.TypDodaciLhuty, T.LhutaNaskladneni, T.DatumObjednani
FROM #TabBudPohyby T
LEFT OUTER JOIN TabKmenZbozi tkz ON T.IDKmeneZbozi=tkz.ID
LEFT OUTER JOIN TabDavka td ON td.IDDilce=tkz.IDKusovnik AND EXISTS(
						SELECT * 
						FROM TabCZmeny Zod
						LEFT OUTER JOIN TabCZmeny Zdo ON (ZDo.ID=td.zmenaDo)
						WHERE Zod.ID=td.zmenaOd AND Zod.platnostTPV=1 AND Zod.datum<=GETDATE() AND (td.ZmenaDo IS NULL OR Zdo.platnostTPV=0 OR (ZDo.platnostTPV=1 AND ZDo.datum>GETDATE()))
						)
WHERE T.Objednat>0
*/


--začátek procedury v externí akci
--založíme novou tabuli, z níž pak načerpáme do #TabBudPohyby
IF OBJECT_ID(N'tempdb..#BudPlan') IS NOT NULL DROP TABLE #BudPlan

CREATE TABLE #BudPlan (
ID INT IDENTITY NOT NULL,
IDPlanOld INT NULL,
Mnozstvi NUMERIC(19,6) NULL,
Objednat NUMERIC(19,6) NOT NULL,
IDPlan INT NULL,
PrKVDoklad INT NULL,
IDPlanPrikaz INT NULL,
Oblast TINYINT NOT NULL,
Sklad NVARCHAR(30) COLLATE database_default NULL,
IDKmeneZbozi INT NOT NULL,
DatumPohybu DATETIME NOT NULL,
PoradiPohybu INT NOT NULL,
MnozstviNaSklade NUMERIC(19,6) NOT NULL,
Mnozstvi_Pl NUMERIC(19,6) NOT NULL,
Dodavatel INT NULL, 
IDZakazka INT NULL,
DodaciLhuta INT NOT NULL,
TypDodaciLhuty TINYINT NOT NULL,
LhutaNaskladneni INT NOT NULL,
DatumObjednani AS (CASE [TypDodaciLhuty] WHEN 0 THEN DATEADD(day, -1 * [DodaciLhuta], [DatumPohybu])  WHEN 1 THEN DATEADD(month, -1 * [DodaciLhuta], [DatumPohybu])  WHEN 2 THEN DATEADD(year, -1 * [DodaciLhuta], [DatumPohybu]) END - [LhutaNaskladneni]),
)

/*
--pojedu po označených řádcích
DECLARE @ID INT
--cvičně jeden vyberu
SET @ID=95
*/
DECLARE @MnozstviNew NUMERIC(19,6),@MnozstviOld NUMERIC(19,6),@OVD NUMERIC(19,6)
--natáhneme si OVD a původní množství k objednání
SELECT @OVD=td.davka, @MnozstviOld=T.Objednat
FROM #TabBudPohyby T
LEFT OUTER JOIN TabKmenZbozi tkz ON T.IDKmeneZbozi=tkz.ID
LEFT OUTER JOIN TabDavka td ON td.IDDilce=tkz.IDKusovnik AND EXISTS(
						SELECT * 
						FROM TabCZmeny Zod
						LEFT OUTER JOIN TabCZmeny Zdo ON (ZDo.ID=td.zmenaDo)
						WHERE Zod.ID=td.zmenaOd AND Zod.platnostTPV=1 AND Zod.datum<=GETDATE() AND (td.ZmenaDo IS NULL OR Zdo.platnostTPV=0 OR (ZDo.platnostTPV=1 AND ZDo.datum>GETDATE()))
						)
WHERE T.ID=@ID

--zjistíme první odečtené množství
SET @MnozstviNew=@MnozstviOld-@OVD


SELECT @MnozstviOld AS MnoOld, @OVD AS OVD, @MnozstviNew AS MnoNew, CASE WHEN @MnozstviNew>=@OVD THEN @OVD ELSE @MnozstviNew END AS MnoPlan

--vložím první vypočtenou hodnotu
INSERT INTO #BudPlan (IDPlanOld,Mnozstvi,Objednat, IDPlan, PrKVDoklad, IDPlanPrikaz, Oblast, Sklad, IDKmeneZbozi, DatumPohybu, PoradiPohybu, MnozstviNaSklade, Mnozstvi_Pl, Dodavatel, IDZakazka, DodaciLhuta, TypDodaciLhuty, LhutaNaskladneni)
SELECT @ID,CASE WHEN @MnozstviNew>=@OVD THEN @OVD ELSE @MnozstviNew END, CASE WHEN @MnozstviNew>=@OVD THEN @OVD ELSE @MnozstviNew END, IDPlan, PrKVDoklad, IDPlanPrikaz, Oblast, Sklad, IDKmeneZbozi, DatumPohybu, PoradiPohybu, MnozstviNaSklade, Mnozstvi_Pl, Dodavatel, IDZakazka, DodaciLhuta, TypDodaciLhuty, LhutaNaskladneni
FROM #TabBudPohyby
WHERE ID=@ID

--zahájím smyčku pomocí WHILE
WHILE @MnozstviNew>=@OVD
BEGIN
SET @MnozstviNew=@MnozstviNew-@OVD
IF @MnozstviNew<>0
--vkládám tolikrát, dokud nedojdu na nulu nebo zbytek
BEGIN
--SELECT @MnozstviOld,@OVD,@MnozstviNew,CASE WHEN @MnozstviNew>=@OVD THEN @OVD ELSE @MnozstviNew END AS MnoPlan
INSERT INTO #BudPlan (IDPlanOld,Mnozstvi,Objednat, IDPlan, PrKVDoklad, IDPlanPrikaz, Oblast, Sklad, IDKmeneZbozi, DatumPohybu, PoradiPohybu, MnozstviNaSklade, Mnozstvi_Pl, Dodavatel, IDZakazka, DodaciLhuta, TypDodaciLhuty, LhutaNaskladneni)
SELECT @ID,CASE WHEN @MnozstviNew>=@OVD THEN @OVD ELSE @MnozstviNew END, CASE WHEN @MnozstviNew>=@OVD THEN @OVD ELSE @MnozstviNew END, IDPlan, PrKVDoklad, IDPlanPrikaz, Oblast, Sklad, IDKmeneZbozi, DatumPohybu, PoradiPohybu, MnozstviNaSklade, Mnozstvi_Pl, Dodavatel, IDZakazka, DodaciLhuta, TypDodaciLhuty, LhutaNaskladneni
FROM #TabBudPohyby
WHERE ID=@ID
END
END

SELECT * FROM #BudPlan

--nasypu řádky z dočasného výpočtu do podkladů pro generování
INSERT INTO #TabBudPohyby (Objednat, IDPlan, PrKVDoklad, IDPlanPrikaz, Oblast, Sklad, IDKmeneZbozi, DatumPohybu, PoradiPohybu, MnozstviNaSklade, Mnozstvi_Pl, Mnozstvi, Dodavatel, IDZakazka, DodaciLhuta, TypDodaciLhuty, LhutaNaskladneni)
SELECT Objednat, IDPlan, PrKVDoklad, IDPlanPrikaz, Oblast, Sklad, IDKmeneZbozi, DatumPohybu, PoradiPohybu, MnozstviNaSklade, Mnozstvi_Pl, 0, Dodavatel, IDZakazka, DodaciLhuta, TypDodaciLhuty, LhutaNaskladneni
FROM #BudPlan

--úprava množství na stávajícím řádku #TabBudPohyby
UPDATE T SET T.Objednat=@OVD
FROM #TabBudPohyby T
WHERE T.ID=@ID

--kontrolní select výsledku
SELECT tkz.ID AS IDKmen,tkz.skupzbo, tkz.regcis, td.davka, T.Objednat, T.ID, T.IDPlan AS IDPlan, T.PrKVDoklad, T.IDPlanPrikaz, T.Oblast, T.Sklad, T.IDKmeneZbozi, T.DatumPohybu, T.PoradiPohybu, T.MnozstviNaSklade, T.Mnozstvi_Pl, T.Mnozstvi, T.Dodavatel, T.IDZakazka, T.DodaciLhuta, T.TypDodaciLhuty, T.LhutaNaskladneni, T.DatumObjednani
FROM #TabBudPohyby T
LEFT OUTER JOIN TabKmenZbozi tkz ON T.IDKmeneZbozi=tkz.ID
LEFT OUTER JOIN TabDavka td ON td.IDDilce=tkz.IDKusovnik AND EXISTS(
						SELECT * 
						FROM TabCZmeny Zod
						LEFT OUTER JOIN TabCZmeny Zdo ON (ZDo.ID=td.zmenaDo)
						WHERE Zod.ID=td.zmenaOd AND Zod.platnostTPV=1 AND Zod.datum<=GETDATE() AND (td.ZmenaDo IS NULL OR Zdo.platnostTPV=0 OR (ZDo.platnostTPV=1 AND ZDo.datum>GETDATE()))
						)
WHERE T.Objednat>0

GO

