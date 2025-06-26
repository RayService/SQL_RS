USE [RayService]
GO

/****** Object:  StoredProcedure [dbo].[hpx_RSPersMzdy_ZamDilciVysledek]    Script Date: 26.06.2025 9:29:28 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO


CREATE PROCEDURE [dbo].[hpx_RSPersMzdy_ZamDilciVysledek]
	@Algoritmus NVARCHAR(3)
	,@IDZam INT
	,@Vypocet SMALLINT
AS
SET NOCOUNT ON;
-- =============================================
-- Author:		JDO
-- Description: Stanoveni mzdy - napocet dilcich vysledku za zamestnance
-- =============================================

-- vymaz v pripade existence
IF EXISTS(SELECT * FROM Tabx_RSPersMzdy_DilciVysledek WHERE IDZam = @IDZam AND Vypocet = @Vypocet)
	DELETE FROM Tabx_RSPersMzdy_DilciVysledek WHERE IDZam = @IDZam AND Vypocet = @Vypocet;
IF EXISTS(SELECT * FROM Tabx_RSPersMzdy_PoziceZarazeniZam WHERE IDZam = @IDZam AND Vypocet = @Vypocet)
	DELETE FROM Tabx_RSPersMzdy_PoziceZarazeniZam WHERE IDZam = @IDZam AND Vypocet = @Vypocet;

-- ** Výpočet

-- * THP
IF @Algoritmus = N'THP'
	EXEC hpx_RSPersMzdy_ZamDilciVysledekTHP
		 @IDZam = @IDZam
		 ,@Vypocet = @Vypocet;
		 
-- * TK
IF @Algoritmus = N'TK'
	EXEC hpx_RSPersMzdy_ZamDilciVysledekTK
		 @IDZam = @IDZam
		 ,@Vypocet = @Vypocet;
GO

