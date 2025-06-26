USE [RayService]
GO

/****** Object:  StoredProcedure [dbo].[hpx_RayService_VyrFazeSetres]    Script Date: 26.06.2025 8:56:25 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO


-- =============================================
-- Author:		DJ
-- Description:	Setřesení operací operací v rámci výrobních fází
-- =============================================
CREATE PROCEDURE [dbo].[hpx_RayService_VyrFazeSetres]
	@IDKmenZbozi INT = NULL		-- ID kmenové karty
AS
SET NOCOUNT ON;

IF EXISTS(SELECT * FROM
	(SELECT MAX(Poradi) AS Maximum, COUNT(*) AS Pocet
	FROM Tabx_RayService_MatVyrFaze
	WHERE IDKmenZbozi = @IDKmenZbozi
	GROUP BY IDKmenZbozi) AS P
WHERE Maximum > Pocet) 
	OR EXISTS(SELECT * FROM Tabx_RayService_MatVyrFaze 
		WHERE Poradi IS NULL 
		AND IDKmenZbozi = @IDKmenZbozi)
	UPDATE P SET 
		Poradi = T.Poradi
	FROM Tabx_RayService_MatVyrFaze AS P
		INNER JOIN(SELECT ID, ROW_NUMBER() OVER (PARTITION BY I.IDKmenZbozi ORDER BY ISNULL(I.Poradi, I.ID)) AS Poradi
			FROM Tabx_RayService_MatVyrFaze AS I WHERE I.IDKmenZbozi= @IDKmenZbozi) AS T ON P.ID = T.ID
	WHERE P.IDKmenZbozi = @IDKmenZbozi
		AND ISNULL(P.Poradi,0) <> T.Poradi
GO

