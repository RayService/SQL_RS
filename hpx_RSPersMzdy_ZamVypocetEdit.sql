USE [RayService]
GO

/****** Object:  StoredProcedure [dbo].[hpx_RSPersMzdy_ZamVypocetEdit]    Script Date: 26.06.2025 9:25:28 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO



CREATE PROCEDURE [dbo].[hpx_RSPersMzdy_ZamVypocetEdit]
	@TypAkce TINYINT				-- 0-predvypln Vypocet,1-vloz,1-smaz
	,@Vypocet SMALLINT = NULL		-- Druh vypoctu
	,@ID INT = NULL					-- ID v Tabx_RSPersMzdy_Vypocet
AS
SET NOCOUNT ON;
-- =============================================
-- Author:		JDO
-- Description:	Stanoveni mzdy - "Editor" - Priznak simulace v dovednostech zamestnance
-- =============================================

/* deklarace */
DECLARE @IDZam INT;

/* funkční tělo procedury */

-- pradvypln vypocet
IF @TypAkce = 0
	BEGIN
	
		-- EA (2)
		UPDATE TabExtKom SET
			Poznamka = N'NOT EXISTS(SELECT * FROM Tabx_RSPersMzdy_Vypocet WHERE IDZam = TabCisZam.ID AND Vypocet = ' + CAST(@Vypocet as NVARCHAR) + N')'
		WHERE GUIDText = N'42512855-B24A-45A7-985E-50719D91A16E';
		
		-- EA (3)
		UPDATE TabExtKom SET
			Parametry = N'1,' + CAST(@Vypocet as NVARCHAR)
		WHERE GUIDText = N'603AB917-3E67-4526-9E3F-84D9F4E355B5';
		
	END;

-- vloz ID
IF @TypAkce = 1
	BEGIN
		
		IF OBJECT_ID('tempdb..#TabObecnyPrenos_PrenosID') IS NULL
			RETURN;
			
		INSERT INTO Tabx_RSPersMzdy_Vypocet(
			IDZam
			,Vypocet)
		SELECT
			Z.ID
			,@Vypocet
		FROM #TabObecnyPrenos_PrenosID P
			INNER JOIN TabCisZam Z ON P.ID = Z.ID
		WHERE NOT EXISTS(SELECT * FROM Tabx_RSPersMzdy_Vypocet WHERE IDZam = Z.ID AND Vypocet = @Vypocet);
		
		IF OBJECT_ID('tempdb..#TabObecnyPrenos_PrenosID') IS NOT NULL
			DROP TABLE #TabObecnyPrenos_PrenosID;
			
		IF OBJECT_ID('tempdb..#TabObecnyPrenos_ID') IS NOT NULL
			DROP TABLE #TabObecnyPrenos_ID;
			
	
	END;

-- DELETE
IF @TypAkce = 2
	BEGIN
		
		SELECT 
			@IDZam = IDZam
			,@Vypocet = Vypocet 
		FROM Tabx_RSPersMzdy_Vypocet
		WHERE ID = @ID;
		
		DELETE FROM Tabx_RSPersMzdy_SouladDovednosti WHERE IDZam = @IDZam AND Vypocet = @Vypocet;
		DELETE FROM Tabx_RSPersMzdy_DilciVysledek WHERE IDZam = @IDZam AND Vypocet = @Vypocet;
		DELETE FROM Tabx_RSPersMzdy_PoziceZarazeniZam WHERE IDZam = @IDZam AND Vypocet = @Vypocet;
		DELETE FROM Tabx_RSPersMzdy_PozadovaneDovednosti WHERE IDZam = @IDZam AND Vypocet = @Vypocet;
		
		DELETE FROM Tabx_RSPersMzdy_Vypocet WHERE ID = @ID;
		
	END;
GO

