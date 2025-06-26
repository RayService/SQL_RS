USE [RayService]
GO

/****** Object:  StoredProcedure [dbo].[hpx_RS_GenVyrPlanProcesniDilceInquiry]    Script Date: 26.06.2025 14:10:16 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

CREATE PROCEDURE [dbo].[hpx_RS_GenVyrPlanProcesniDilceInquiry] @ID INT
AS

DECLARE @IDPlPrKV INT;
DECLARE @IDPlan INT;
DECLARE @IDnizsi INT;
DECLARE @IDZakazka INT;
DECLARE @mnozstvi numeric(19,6);
DECLARE @Datum DATETIME;
DECLARE @Sklad NVARCHAR(30);
DECLARE @SkupZbo NVARCHAR(3);
DECLARE @RegCis NVARCHAR(30);

IF OBJECT_ID(N'tempdb..#TabPolBudPlany') IS NOT NULL DROP TABLE #TabPolBudPlany
/*
-- docasna tabulka za normalnich okolnosti generovana HeO
IF OBJECT_ID('tempdb..#TabTempUziv') IS NULL
CREATE TABLE #TabTempUziv(
[Tabulka] [varchar] (255) NOT NULL,
[SCOPE_IDENTITY] [int] NULL,
[Datum] [datetime] NULL
);
*/
CREATE TABLE #TabPolBudPlany(
ID INT IDENTITY(1,1) NOT NULL,
IDPlPrKV INT NOT NULL,
IDPlan INT NOT NULL,
Sklad nvarchar(30) COLLATE database_default NOT NULL,
nizsi INT NOT NULL,
SkupZbo NVARCHAR(3) NULL,
RegCis NVARCHAR(30) NULL,
mnozstvi numeric(19,6) NOT NULL, 
IDZakazka int NULL,
Datum DATETIME NULL,
PRIMARY KEY(ID)) 
INSERT INTO #TabPolBudPlany (IDPlPrKV,IDPlan,Sklad,nizsi,SkupZbo,RegCis,mnozstvi,IDZakazka,Datum)
SELECT plprkv.ID,plprkv.IDPlan,plprkv.Sklad,plprkv.nizsi,tkz.SkupZbo,tkz.RegCis,ISNULL(tss.Mnozstvi,0),tpl.IdZakazka,
CASE WHEN ISNULL(tsze._EXT_RS_generate_plan_date,1)=1 THEN plpr.Plan_zadani ELSE tpl.Datum END
FROM TabPlanPrKVazby plprkv WITH(NOLOCK)
LEFT OUTER JOIN TabPlanPrikaz plpr WITH(NOLOCK) ON plpr.ID=plprkv.IDPlanPrikaz
LEFT OUTER JOIN TabKmenZbozi tkz WITH(NOLOCK) ON plprkv.nizsi=tkz.ID
LEFT OUTER JOIN TabSkupinyZbozi tsz WITH(NOLOCK) ON tsz.SkupZbo=tkz.SkupZbo
LEFT OUTER JOIN TabSkupinyZbozi_EXT tsze WITH(NOLOCK) ON tsze.ID=tsz.ID
LEFT OUTER JOIN TabStavSkladu tss WITH(NOLOCK) ON tss.IDKmenZbozi=tkz.ID AND tss.IDSklad='20000275900'
JOIN TabPlan tpl WITH(NOLOCK) ON tpl.ID=plprkv.IDPlan
WHERE
(((tpl.ID = @ID/*IN (111704,111705)*/))AND(ISNULL(tsze._EXT_RS_GenerovatKusovnikPopt,0)=1))
ORDER BY tpl.Datum ASC

SELECT * FROM #TabPolBudPlany

DECLARE CurGenPlan CURSOR LOCAL FAST_FORWARD FOR
	SELECT ID--IDPlPrKV--,IDPlan,Sklad,nizsi,SkupZbo,RegCis,mnozstvi,IDZakazka,Datum
	FROM #TabPolBudPlany;
		OPEN CurGenPlan;
		FETCH NEXT FROM CurGenPlan INTO 
				@IDPlPrKV;--,@IDPlan,@Sklad,@IDnizsi,@SkupZbo,@RegCis,@mnozstvi,@IDZakazka,@Datum;
		WHILE (@@FETCH_STATUS = 0) AND (@@ERROR = 0)
		BEGIN
--běh cursoru
		SET @mnozstvi=(SELECT mnozstvi FROM #TabPolBudPlany WHERE ID=@IDPlPrKV)
		SET @IDnizsi=(SELECT nizsi FROM #TabPolBudPlany WHERE ID=@IDPlPrKV)
		SET @IDZakazka=(SELECT IDZakazka FROM #TabPolBudPlany WHERE ID=@IDPlPrKV)
		SET @Datum=(SELECT Datum FROM #TabPolBudPlany WHERE ID=@IDPlPrKV)
		SET @Sklad=(SELECT Sklad FROM #TabPolBudPlany WHERE ID=@IDPlPrKV)
		--SELECT @mnozstvi
		--SELECT tpl.* FROM TabPlan tpl WHERE tpl.IDTabKmen=@IDnizsi AND tpl.InterniZaznam=0 AND tpl.StavPrevodu<>N'x' AND tpl.uzavreno=0
		IF (@mnozstvi=0
			AND NOT EXISTS(SELECT tpl.* FROM TabPlan tpl WITH(NOLOCK) WHERE tpl.IDTabKmen=@IDnizsi AND tpl.InterniZaznam=0 AND tpl.StavPrevodu<>N'x' AND tpl.uzavreno=0)
			AND NOT EXISTS(SELECT tp.* FROM TabPrikaz tp WITH(NOLOCK) WHERE (tp.StavPrikazu<=30 AND tp.IDTabKmen=@IDnizsi)))
		EXEC dbo.hp_NewVyrobniPlan @Rada ='TPV', @IDDilce=@IDnizsi,@IDZakazModif=NULL, @IDZakazka=@IDZakazka, @mnozstvi=1,@PlanUkonceni=@Datum,@KmenoveStredisko=@Sklad,@RespektujLhutuNaskladneni=1

		FETCH NEXT FROM CurGenPlan INTO 
			@IDPlPrKV;--,@IDPlan,@Sklad,@IDnizsi,@SkupZbo,@RegCis,@mnozstvi,@IDZakazka,@Datum;
		END;
CLOSE CurGenPlan;
DEALLOCATE CurGenPlan;
GO

