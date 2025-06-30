USE [RayService]
GO

/****** Object:  StoredProcedure [dbo].[hpx_HeliosMIM_Sestavy]    Script Date: 30.06.2025 8:19:00 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

CREATE PROCEDURE [dbo].[hpx_HeliosMIM_Sestavy] @IdInventury INT
AS
IF OBJECT_ID(N'tempdb..#TabExtAkce','U')IS NOT NULL
BEGIN
	ALTER TABLE #TabExtAkce ADD IdFiltr INT
	ALTER TABLE #TabExtAkce ADD Nazev NVARCHAR(50) COLLATE database_default

	CREATE TABLE #TabExtAkceInt (IdFiltr INT, Nazev NVARCHAR(50) COLLATE database_default)
	
	INSERT INTO #TabExtAkceInt  
	SELECT mis.IDFiltr, f.Nazev
	FROM TabMaInvSestavy mis
	LEFT OUTER JOIN TabFiltr f ON mis.IDFiltr = f.ID
	WHERE ((NOT EXISTS(SELECT * FROM TabPravaFiltr WHERE IDFiltr=f.ID) 
		OR EXISTS(SELECT * FROM TabPravaFiltr WHERE IDFiltr=f.ID AND LoginName=SUSER_SNAME()) 
		OR EXISTS(SELECT * FROM TabPravaFiltr PD JOIN TabRoleUzivView u ON u.IDRole=PD.IDRole WHERE PD.IDFiltr=f.ID AND u.LoginName=SUSER_SNAME())))
		AND (mis.IDMaInv = @IdInventury)
	
	INSERT INTO #TabExtAkce(IdFiltr, Nazev)                           
	SELECT * FROM #TabExtAkceInt
END
GO

