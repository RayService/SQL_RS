USE [RayService]
GO

/****** Object:  StoredProcedure [dbo].[hpx_RayService_GenSouhrnnyKusovnik_IDKmene]    Script Date: 26.06.2025 9:14:12 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO


CREATE PROCEDURE [dbo].[hpx_RayService_GenSouhrnnyKusovnik_IDKmene]
	@IDPohybyZbozi INT
AS
SET NOCOUNT ON;
-- =============================================
-- Author:		JDO
-- Description:	Generování IDKmenZbozi souhrnného kusovníku položky dokladu do globální temporary table
-- =============================================

DECLARE @IDKmenZbozi INT;
DECLARE @DatumTPV DATETIME;
DECLARE @Oznacenych SMALLINT;
DECLARE @Aktualni SMALLINT;

SELECT @Oznacenych = Cislo FROM #TabExtKomPar WHERE Popis = 'CELKEM';
SELECT @Aktualni = Cislo FROM #TabExtKomPar WHERE Popis = 'PRECHOD';
IF @Aktualni IS NOT NULL OR @Oznacenych IS NOT NULL
	BEGIN
		RAISERROR ('Akci lze spustit pouze nad jedním označeným řádkem!',16,1);
		RETURN;
	END;

-- zalozime globální tabulku
IF OBJECT_ID('tempdb..##RayService_SouKusovnik') IS NULL
			CREATE TABLE [##RayService_SouKusovnik](
				[IDKmenZbozi] [int] NOT NULL,
				[SPID] [smallint] NOT NULL);
		ELSE
			DELETE FROM ##RayService_SouKusovnik
			WHERE SPID = @@SPID;

-- ID kmene ze položky
SELECT 
	@IDKmenZbozi = IDKmenZbozi
	,@DatumTPV = CONVERT(DATETIME,CONVERT(INT,CONVERT(FLOAT,GETDATE())))
FROM TabPohybyZbozi P
	INNER JOIN TabStavSkladu S ON P.IDZboSklad = S.ID
WHERE P.ID = @IDPohybyZbozi;

-- není to dílec, jdeme pryč
IF (SELECT Dilec FROM TabKmenZbozi WHERE ID = @IDKmenZbozi) <> 1
	RETURN;
	
-- dočasná tabulka pro souhrnný kusovník
IF OBJECT_ID('tempdb..#tabKusovnik_ProSouhKus') IS NOT NULL
	DROP TABLE #tabKusovnik_ProSouhKus;
CREATE TABLE #tabKusovnik_ProSouhKus (
	vyssi integer NULL
	,IDKmenZbozi integer NOT NULL
	,IDKVazby integer NULL
	,mnozstvi numeric(20,6) NOT NULL
	,prirez numeric(20,6) NULL
	,prime bit NOT NULL
	,RezijniMat tinyint NOT NULL
	,VyraditZKalkulace tinyint NOT NULL);
	
INSERT INTO #tabKusovnik_ProSouhKus 
EXEC hp_generujQuickKusovnik
	@IDFinal = @IDKmenZbozi
	,@MNF = 1.
	,@datum = @DatumTPV;
	
-- naplníme globální tabulku
INSERT INTO ##RayService_SouKusovnik(
	IDKmenZbozi
	,SPID)
SELECT
	IDKmenZbozi
	,@@SPID
FROM #tabKusovnik_ProSouhKus;
GO

