USE [RayService]
GO

/****** Object:  StoredProcedure [dbo].[hpx_RSPersMzdy_PozadovaneDovednostiEdit]    Script Date: 26.06.2025 9:23:35 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO



CREATE PROCEDURE [dbo].[hpx_RSPersMzdy_PozadovaneDovednostiEdit]
	@TypAkce TINYINT		-- 0=INSERT;2=DELETE
	,@ID INT = NULL			-- ID v Tabx_RSPersMzdy_PozadovaneDovednosti
AS
SET NOCOUNT ON;
-- =============================================
-- Author:		JDO
-- Description:	Stanoveni mzdy - Editor - Pozadovane dovednosti
-- =============================================

/* funkční tělo procedury */
-- INSERT
IF @TypAkce = 0
	BEGIN
	
		DECLARE @IDZam INT;
		DECLARE @Vypocet SMALLINT;
		DECLARE @IDPP INT;
	
		IF OBJECT_ID('tempdb..#TabObecnyPrenos_PrenosID') IS NULL
			RETURN;
			
		IF OBJECT_ID('tempdb..#TabObecnyPrenos_ID') IS NULL
			RETURN;
			
		IF NOT EXISTS(SELECT * FROM #TabObecnyPrenos_ID P
				INNER JOIN Tabx_RSPersMzdy_Vypocet V ON P.ID = V.ID)
			BEGIN
				RAISERROR (N'Interní chyba: Neexistuje vazba na zdrojový řádek výpočtu!',1,16);
				RETURN;
			END;
		
		-- vstupni parametry ze selectotvurce	
		SELECT
			@IDZam = V.IDZam
			,@Vypocet = V.Vypocet
			,@IDPP = OPP.IDPP
		FROM #TabObecnyPrenos_ID P
			INNER JOIN Tabx_RSPersMzdy_Vypocet V ON P.ID = V.ID
			INNER JOIN TabObsazeniPracovnichPozic OPP ON V.IDZam = OPP.IDZam		-- (Z)Obsazeni prac. pozic
												AND CAST(OPP.PlatnostOd as DATE) <=  CAST(GETDATE() as DATE) 
												AND (CAST(OPP.PlatnostDo as DATE) >= CAST(GETDATE() as DATE) OR OPP.PlatnostDo IS NULL)
		
		-- zam nema pozici
		IF @IDPP IS NULL
			BEGIN
				RAISERROR (N'Zaměstnanec nemá přiřazenu platnou pracovní pozici',16,1);
				RETURN;
			END;
		
		-- naplneni id z vybranych radku v prenosu
		INSERT INTO Tabx_RSPersMzdy_PozadovaneDovednosti(
			IDZam
			,Vypocet
			,IDPPDetailZnalosti
			,IDPP)
		SELECT
			@IDZam
			,@Vypocet
			,PD.ID
			,@IDPP
		FROM #TabObecnyPrenos_PrenosID P
			INNER JOIN TabPracovniPoziceDetailZnalosti PD ON P.ID = PD.ID
		WHERE NOT EXISTS(SELECT * FROM Tabx_RSPersMzdy_PozadovaneDovednosti D
				WHERE D.IDZam = @IDZam AND D.Vypocet = @IDZam AND D.IDPP = @IDPP AND D.IDPPDetailZnalosti = PD.ID);
		
		
		-- vymaz docasnych tbl
		IF OBJECT_ID('tempdb..#TabObecnyPrenos_PrenosID') IS NOT NULL
			DROP TABLE #TabObecnyPrenos_PrenosID;
			
		IF OBJECT_ID('tempdb..#TabObecnyPrenos_ID') IS NOT NULL
			DROP TABLE #TabObecnyPrenos_ID;
			
	END;

-- DELETE
IF @TypAkce = 2
	DELETE FROM Tabx_RSPersMzdy_PozadovaneDovednosti WHERE ID = @ID;
GO

