USE [RayService]
GO

/****** Object:  StoredProcedure [dbo].[hpx_RayService_VyrFazePosun]    Script Date: 26.06.2025 8:58:14 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO


-- =============================================
-- Author:		DJ
-- Description:	Setřesení operací operací v rámci výrobních fází
-- =============================================
CREATE PROCEDURE [dbo].[hpx_RayService_VyrFazePosun]
	@Smer CHAR(1)		-- směr posunu N-nahoru / D-dolu
	,@IDRadku INT		-- ID v Tabx_RayService_MatVyrFaze
AS
SET NOCOUNT ON;
/* deklarace */
DECLARE @1 TINYINT;
DECLARE @2 TINYINT;
DECLARE @IDKmenZbozi INT;

SELECT 
	@1 = Poradi
	,@IDKmenZbozi = IDKmenZbozi
FROM Tabx_RayService_MatVyrFaze 
WHERE ID = @IDRadku;

/* funkční tělo procedury */

SELECT
	@2 = CASE WHEN @Smer = 'D' THEN MIN(Poradi)
		WHEN @Smer = 'N' THEN MAX(Poradi)END
FROM Tabx_RayService_MatVyrFaze
WHERE IDKmenZbozi = @IDKmenZbozi
	AND ((@Smer = 'D' AND Poradi > @1)
		OR (@Smer = 'N' AND Poradi < @1));

IF @2 IS NULL
	RETURN;
	
UPDATE Tabx_RayService_MatVyrFaze SET
	Poradi = CASE Poradi WHEN @1 THEN @2 WHEN @2 THEN @1 ELSE Poradi END
	,DatZmeny = GETDATE()
	,Zmenil = SUSER_SNAME()
WHERE IDKmenZbozi = @IDKmenZbozi
	AND Poradi IN(@1,@2);
GO

