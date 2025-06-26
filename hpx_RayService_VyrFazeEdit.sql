USE [RayService]
GO

/****** Object:  StoredProcedure [dbo].[hpx_RayService_VyrFazeEdit]    Script Date: 26.06.2025 8:57:21 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO


-- =============================================
-- Author:		DJ
-- Description:	Správa operací v rámci výrobních fází
-- =============================================
CREATE PROCEDURE [dbo].[hpx_RayService_VyrFazeEdit]
	@TypAkce TINYINT			-- typ akce 0-insert / 1-update / 2-delete
	,@CisloTypPostup INT		-- číslo typové operace
	,@IDRadku INT = NULL		-- ID řádku v Tabx_RayService_MatVyrFaze
AS
SET NOCOUNT ON;
/* deklarace */
DECLARE @IDKmenZbozi INT;
DECLARE @Poradi TINYINT;

/* kontroly */
-- typ akce
IF @TypAkce NOT IN(0,1,2)
	BEGIN
		RAISERROR (N'Neznámý identifikátor typu akce!',16,1);
		RETURN;
	END;
	
-- kmen / selectorvurce
IF @TypAkce = 0 
	BEGIN
		SELECT TOP 1 @IDKmenZbozi = CAST(Cislo as INT)
		FROM #TabExtKomPar
		WHERE Popis='STVlastID';
		
		IF @IDKmenZbozi IS NULL
			OR NOT EXISTS(SELECT * FROM TabKmenZbozi WHERE ID = @IDKmenZbozi)
			BEGIN
				RAISERROR (N'Neznámý identifikátor kmenové karty!',16,1);
				RETURN;
			END;
	END;
	
-- operace
IF @TypAkce IN (0,1) AND 
	(ISNULL(@CisloTypPostup,0) = 0
	OR NOT EXISTS(SELECT * FROM TabTypPostup WHERE Cislo = @CisloTypPostup))
	BEGIN
		RAISERROR (N'Nesprávné nebo nezadané číslo typové operace!',16,1);
		RETURN;
	END;

-- id řádku pro smazání
IF @TypAkce IN (1,2) AND
	@IDRadku IS NULL
	BEGIN
		RAISERROR (N'Neznámý identifikátor řádku pro smazání!',16,1);
		RETURN;
	END;

/* funkční tělo procedury */

-- * insert
IF @TypAkce = 0
	BEGIN
		-- Pořadí
		SELECT @Poradi = (ISNULL(MAX(Poradi),0) + 1 )
		FROM Tabx_RayService_MatVyrFaze
		WHERE IDKmenZbozi = @IDKmenZbozi;

		-- vložíme
		INSERT INTO Tabx_RayService_MatVyrFaze(
			IDKmenZbozi
			,IDTypPostup
			,Poradi)
		VALUES(
			@IDKmenZbozi
			,@CisloTypPostup
			,@Poradi);
	END;
	
-- * update
IF @TypAkce = 1
 IF @CisloTypPostup <> (SELECT IDTypPostup FROM Tabx_RayService_MatVyrFaze WHERE ID = @IDRadku)
	UPDATE Tabx_RayService_MatVyrFaze SET
		IDTypPostup = @CisloTypPostup
		,DatZmeny = GETDATE()
		,Zmenil = SUSER_SNAME()
	WHERE ID = @IDRadku;

-- * delete
IF @TypAkce = 2
	BEGIN
		SELECT @IDKmenZbozi = IDKmenZbozi
		FROM Tabx_RayService_MatVyrFaze
		WHERE ID = @IDRadku;
		
		DELETE FROM Tabx_RayService_MatVyrFaze WHERE ID = @IDRadku;
		
		EXEC dbo.hpx_RayService_VyrFazeSetres
			 @IDKmenZbozi;
	END;
GO

