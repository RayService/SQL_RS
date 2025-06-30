USE [RayService]
GO

/****** Object:  StoredProcedure [dbo].[hpx_HeliosMIM_TypMajetku]    Script Date: 30.06.2025 8:17:04 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

CREATE PROCEDURE [dbo].[hpx_HeliosMIM_TypMajetku]
AS
BEGIN TRAN
BEGIN TRY
IF OBJECT_ID(N'tempdb..#TabExtAkce','U')IS NOT NULL
BEGIN
	ALTER TABLE #TabExtAkce ADD Cislo INT
	ALTER TABLE #TabExtAkce ADD TypMaj NCHAR(3) COLLATE database_default
	ALTER TABLE #TabExtAkce ADD NazevTypu NVARCHAR(50) COLLATE database_default
	

	CREATE TABLE #TabExtAkceInt (Cislo INT, TypMaj NCHAR(3) COLLATE database_default, NazevTypu NVARCHAR(50) COLLATE database_default)
	
	INSERT INTO #TabExtAkceInt  
		SELECT Id Cislo, TypMaj, NazevTypu FROM TabMaTyp 


	INSERT INTO #TabExtAkce(Cislo, TypMaj, NazevTypu)                           
	SELECT * FROM #TabExtAkceInt
END

END TRY
BEGIN CATCH
	DECLARE @ErrorMessage NVARCHAR(4000);
	SELECT @ErrorMessage = 'Došlo k chybě. ' + ERROR_MESSAGE()
	IF @@TRANCOUNT > 0 
		ROLLBACK;
    THROW 50001,@ErrorMessage,1
END CATCH

IF @@TRANCOUNT > 0
	COMMIT
GO

