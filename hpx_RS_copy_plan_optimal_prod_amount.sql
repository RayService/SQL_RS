USE [RayService]
GO

/****** Object:  StoredProcedure [dbo].[hpx_RS_copy_plan_optimal_prod_amount]    Script Date: 26.06.2025 13:18:41 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

CREATE PROCEDURE [dbo].[hpx_RS_copy_plan_optimal_prod_amount] @OVD NUMERIC(19,6), @kontrola BIT, @vcetnerozpadu BIT, @kontrola2 BIT, @rozpad INT, @ID INT
AS
/*
--cvičné deklarace
USE HCvicna
DECLARE @OVD NUMERIC(19,6)=10
DECLARE @ID INT=161023
DECLARE @kontrola BIT=1
DECLARE @vcetnerozpadu BIT=1
DECLARE @kontrola2 BIT
DECLARE @rozpad INT--dám tam možnost rozbalovacího menu 7=týdenní, 14=14ti denní, 60=měsíční, ale obecně umožnit jakékoli číslo
--SELECT tp.* FROM Tabplan tp LEFT OUTER JOIN TabPlan_EXT tpe ON tpe.ID=tp.ID WHERE tp.ID=@ID
*/

DECLARE
@Rada NVARCHAR(10), --Řada výrobního plánu
@IDDilce int, --ID z TabKmenZbozi
@IDZakazModif int=NULL, --ID z TabZakazModif
@IDZakazka int=NULL, --ID z TabZakazka
@mnozstvi numeric(19,6), 
@PlanUkonceni datetime=NULL, 
@IDPohyb int=NULL, --ID původního požadavku z TabPohybyZbozi
@GUIDDosObjR uniqueidentifier=NULL, --GUID původního požadavku z TabDosleObjH02
@SkupinaPlanu NVARCHAR(10)=NULL,
@NavaznaObjednavka NVARCHAR(30)=NULL,
@KmenoveStredisko NVARCHAR(30)=NULL,
@Poznamka NVarChar(MAX)=NULL,
@DatumTPV datetime=NULL,
@RespektujLhutuNaskladneni bit=0, --1=PlanUkonceni posune o LhutaNaskladneni
--deklarace RS
@IDNewPlan INT,
@IDPlan INT,
@MnozstviOld NUMERIC(19,6),
@MnozstviNew NUMERIC(19,6),
@MnozstviZbyva NUMERIC(19,6),
@PlanUkonceniNew DATETIME
--@OVD NUMERIC(19,6)

IF @kontrola=1
BEGIN
IF OBJECT_ID(N'tempdb..#BudPlan') IS NOT NULL DROP TABLE #BudPlan
CREATE TABLE #BudPlan 
(
ID INT IDENTITY(1,1),
IDPlanOld INT,
Mnozstvi NUMERIC(19,6),
Datum DATETIME
)

IF OBJECT_ID(N'tempdb..#TabPomSeznamVyrPlanuProVypocetPlanVyroby')IS NULL
CREATE TABLE #TabPomSeznamVyrPlanuProVypocetPlanVyroby(ID INT NOT NULL PRIMARY KEY)
ELSE
DROP TABLE #TabPomSeznamVyrPlanuProVypocetPlanVyroby

SELECT @Rada=Rada,@IDDilce=IDTabKmen,@IDZakazModif=IDZakazModif,@IDZakazka=IDZakazka
,@mnozstvi=mnozstvi,@PlanUkonceni=datum,@IDPohyb=IDRezervace
,@SkupinaPlanu=SkupinaPlanu,@NavaznaObjednavka=NavaznaObjednavka,@KmenoveStredisko=KmenoveStredisko,@Poznamka=Poznamka,@DatumTPV=DatumTPV,@MnozstviOld=mnozstvi,@MnozstviZbyva=mnozPrev
FROM TabPlan tp WHERE tp.ID=@ID

IF ISNULL(@MnozstviZbyva,0)>0
BEGIN
RAISERROR ('Výrobní plán je již zaplánován, nic neproběhne.',16,1)
RETURN
END;
IF ISNULL(@OVD,0)=0
BEGIN
RAISERROR ('Není stanovena optimální výrobní dávka, nic neproběhne.',16,1)
RETURN
END;
IF @MnozstviOld < @OVD
BEGIN
RAISERROR ('Optimální výrobní dávka převyšuje množství, nic neproběhne.',16,1)
RETURN
END;

SET @MnozstviNew=@MnozstviOld-@OVD
SET @PlanUkonceniNew=@PlanUkonceni+(CASE WHEN @kontrola2=1 THEN @rozpad ELSE 0 END)
SELECT @MnozstviOld,@OVD,@MnozstviNew,CASE WHEN @MnozstviNew>=@OVD THEN @OVD ELSE @MnozstviNew END AS MnoPlan, @PlanUkonceni AS Ukonceni, @PlanUkonceniNew AS Nove_ukonceni

INSERT INTO #BudPlan (IDPlanOld,Mnozstvi,Datum)
SELECT @ID,CASE WHEN @MnozstviNew>=@OVD THEN @OVD ELSE @MnozstviNew END AS MnoPlan,@PlanUkonceniNew

WHILE @MnozstviNew>=@OVD
BEGIN
SET @MnozstviNew=@MnozstviNew-@OVD
SET @PlanUkonceniNew=@PlanUkonceniNew+(CASE WHEN @kontrola2=1 THEN @rozpad ELSE 0 END)
IF @MnozstviNew<>0
BEGIN
SELECT @MnozstviOld,@OVD,@MnozstviNew,CASE WHEN @MnozstviNew>=@OVD THEN @OVD ELSE @MnozstviNew END AS MnoPlan
INSERT INTO #BudPlan (IDPlanOld,Mnozstvi,Datum)
SELECT @ID,CASE WHEN @MnozstviNew>=@OVD THEN @OVD ELSE @MnozstviNew END AS MnoPlan,@PlanUkonceniNew
END
END

SELECT *
FROM #BudPlan

DECLARE @IDBudPlan INT, @IDBudOld INT, @MnoBudPlan NUMERIC(19,6), @DatumBudPlan DATETIME
DECLARE CurPlan CURSOR LOCAL FAST_FORWARD FOR
	SELECT ID, IDPlanOld, Mnozstvi, Datum
	FROM #BudPlan
	OPEN CurPlan;
	FETCH NEXT FROM CurPlan INTO @IDBudPlan, @IDBudOld, @MnoBudPlan, @DatumBudPlan;
	WHILE (@@FETCH_STATUS = 0) AND (@@ERROR = 0)
	BEGIN

	DECLARE @NewID int
	EXEC @NewID=hp_NewVyrobniPlan @Rada=@Rada,@IDDilce=@IDDilce, @IDZakazModif=@IDZakazModif,@IDZakazka=@IDZakazka,@mnozstvi=@MnoBudPlan,@PlanUkonceni=@DatumBudPlan
	,@IDPohyb=@IDPohyb,@SkupinaPlanu=@SkupinaPlanu,@NavaznaObjednavka=@NavaznaObjednavka,@KmenoveStredisko=@KmenoveStredisko,@Poznamka=@Poznamka,@DatumTPV=@DatumTPV
	SET @IDNewPlan= (SELECT IDENT_CURRENT('TabPlan'))
	--SELECT TOP 1 * FROM TabPlan WHERE Autor=SUSER_SNAME() ORDER BY ID DESC
	INSERT #TabPomSeznamVyrPlanuProVypocetPlanVyroby(ID) VALUES (@IDNewPlan)

FETCH NEXT FROM CurPlan INTO @IDBudPlan, @IDBudOld, @MnoBudPlan, @DatumBudPlan;
END;
CLOSE CurPlan;
DEALLOCATE CurPlan;

--úprava množství na stávajícím plánu
UPDATE tp SET tp.mnozstvi=@OVD
FROM Tabplan tp
WHERE ID=@ID

--aktualizace plánované výroby
IF @vcetnerozpadu=1
BEGIN
INSERT #TabPomSeznamVyrPlanuProVypocetPlanVyroby(ID)VALUES(@ID)

DECLARE @ret integer
EXEC @ret=hp_VyrPlan_VypocetPlanovaneVyroby 0
SELECT @ret
END
--Uloženka na vytvoření nového výrobního plánu. Vrací ID nového výrobního plánu.
/*
CREATE PROCEDURE hp_NewVyrobniPlan
@Rada NVARCHAR(10), --Řada výrobního plánu
@IDDilce int, --ID z TabKmenZbozi
@IDZakazModif int=NULL, --ID z TabZakazModif
@IDZakazka int=NULL, --ID z TabZakazka
@mnozstvi numeric(19,6), 
@PlanUkonceni datetime=NULL, 
@IDPohyb int=NULL, --ID původního požadavku z TabPohybyZbozi
@GUIDDosObjR uniqueidentifier=NULL, --GUID původního požadavku z TabDosleObjH02
@SkupinaPlanu NVARCHAR(10)=NULL,
@NavaznaObjednavka NVARCHAR(30)=NULL,
@KmenoveStredisko NVARCHAR(30)=NULL,
@Poznamka NVarChar(MAX)=NULL,
@DatumTPV datetime=NULL,
@RespektujLhutuNaskladneni bit=0 --1=PlanUkonceni posune o LhutaNaskladneni
*/

END
ELSE
BEGIN
RAISERROR('Nic neproběhne, není zatrženo Spustit.',16,1)
RETURN
END;
GO

