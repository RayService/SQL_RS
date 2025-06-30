USE [RayService]
GO

/****** Object:  StoredProcedure [dbo].[hpx_HeliosMIM_Zamestnanci]    Script Date: 30.06.2025 8:16:06 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

CREATE PROCEDURE [dbo].[hpx_HeliosMIM_Zamestnanci]
AS
BEGIN TRAN
BEGIN TRY
IF OBJECT_ID(N'tempdb..#TabExtAkce','U')IS NOT NULL
BEGIN
	ALTER TABLE #TabExtAkce ADD Cislo INT
	ALTER TABLE #TabExtAkce ADD Jmeno NVARCHAR(100) COLLATE database_default
	ALTER TABLE #TabExtAkce ADD Prijmeni NVARCHAR(100) COLLATE database_default
	ALTER TABLE #TabExtAkce ADD Stredisko NVARCHAR(30) COLLATE database_default
	ALTER TABLE #TabExtAkce ADD StavES INT

	CREATE TABLE #TabExtAkceInt (Cislo INT, Jmeno NVARCHAR(100) COLLATE database_default, Prijmeni NVARCHAR(100) COLLATE database_default, Stredisko NVARCHAR(30) COLLATE database_default, StavES INT)
	
	DECLARE @IdMzdObd INT

	SELECT @IdMzdObd = ID FROM TabMzdObd WHERE Stav = 1

	IF (@IdMzdObd IS NOT NULL)
	BEGIN
		INSERT INTO #TabExtAkceInt  
		SELECT cz.Cislo, cz.Jmeno, cz.Prijmeni, cz.Stredisko, ISNULL(zm.StavES, 10)
		FROM TabCisZam cz
		LEFT OUTER JOIN TabZamMzd zm ON zm.ZamestnanecId = cz.ID AND zm.IdObdobi = @IdMzdObd
	END
	ELSE
		INSERT INTO #TabExtAkceInt  
		SELECT Cislo, Jmeno, Prijmeni, Stredisko, 0 AS StavES FROM TabCisZam

	INSERT INTO #TabExtAkce(Cislo, Jmeno, Prijmeni, Stredisko, StavES)                           
	SELECT * FROM #TabExtAkceInt
END

END TRY
BEGIN CATCH
	DECLARE @ErrorMessage NVARCHAR(4000);
	SELECT @ErrorMessage = 'Došlo k chybě, záznam se neuložil. ' + ERROR_MESSAGE()
	IF @@TRANCOUNT > 0 
		ROLLBACK;
    THROW 50001,@ErrorMessage,1
END CATCH

IF @@TRANCOUNT > 0
	COMMIT
GO

