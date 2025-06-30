USE [RayService]
GO

/****** Object:  StoredProcedure [dbo].[hpx_HeliosMIM_Inventury]    Script Date: 30.06.2025 8:17:40 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

CREATE PROCEDURE [dbo].[hpx_HeliosMIM_Inventury]
AS
IF OBJECT_ID(N'tempdb..#TabExtAkce','U')IS NOT NULL
BEGIN
	ALTER TABLE #TabExtAkce ADD IdInventury INT
	ALTER TABLE #TabExtAkce ADD Nazev NVARCHAR(50) COLLATE database_default

	CREATE TABLE #TabExtAkceInt (IdInventury INT, Nazev NVARCHAR(50) COLLATE database_default)
	
	INSERT INTO #TabExtAkceInt  
	SELECT Id IdInventury, Nazev FROM TabMaInv 
	WHERE DatumSchvaleni IS NULL

	INSERT INTO #TabExtAkce(IdInventury, Nazev)                           
	SELECT * FROM #TabExtAkceInt
END
GO

