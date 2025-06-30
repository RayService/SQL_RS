USE [RayService]
GO

/****** Object:  StoredProcedure [dbo].[hpx_HeliosMIM_Lokace]    Script Date: 30.06.2025 8:16:40 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

CREATE PROCEDURE [dbo].[hpx_HeliosMIM_Lokace]
AS
BEGIN TRAN
BEGIN TRY
IF OBJECT_ID(N'tempdb..#TabExtAkce','U')IS NOT NULL
BEGIN
	ALTER TABLE #TabExtAkce ADD Cislo INT
	ALTER TABLE #TabExtAkce ADD KodLok NVARCHAR(20) COLLATE database_default
	ALTER TABLE #TabExtAkce ADD CarKod NVARCHAR(20) COLLATE database_default
	ALTER TABLE #TabExtAkce ADD Nazev NVARCHAR(40) COLLATE database_default

	CREATE TABLE #TabExtAkceInt (Cislo INT, KodLok NVARCHAR(20) COLLATE database_default, CarKod NVARCHAR(20) COLLATE database_default, Nazev NVARCHAR(40) COLLATE database_default)
	
	INSERT INTO #TabExtAkceInt  
		SELECT Id Cislo, KodLok, CarKod, Nazev
		FROM TabMaLok 


	INSERT INTO #TabExtAkce(Cislo, KodLok, CarKod, Nazev)                           
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

