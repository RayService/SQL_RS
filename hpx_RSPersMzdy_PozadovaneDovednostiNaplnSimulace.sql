USE [RayService]
GO

/****** Object:  StoredProcedure [dbo].[hpx_RSPersMzdy_PozadovaneDovednostiNaplnSimulace]    Script Date: 26.06.2025 9:31:20 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO



CREATE PROCEDURE [dbo].[hpx_RSPersMzdy_PozadovaneDovednostiNaplnSimulace]
	@Prepsat TINYINT		-- 0=doplni neexistujici / 1=smaze a zalozi
AS
SET NOCOUNT ON;
-- =============================================
-- Author:		JDO
-- Description:	Stanoveni mzdy - Editor - Prevzeti pozadovanych dovednosti z aktualnich
-- =============================================

/* deklarace */
DECLARE @ID INT;
DECLARE @IDZam INT;
DECLARE @Vypocet SMALLINT;

-- hodnota SelectoTvruce
SELECT TOP 1 @ID = CAST(Cislo as INT)
FROM #TabExtKomPar
WHERE Popis='STVlastID';

-- hodnoty z radku vypoctu
SELECT
	@IDZam = V.IDZam
	,@Vypocet = V.Vypocet
FROM Tabx_RSPersMzdy_Vypocet V
INNER JOIN TabObsazeniPracovnichPozic OPP ON V.IDZam = OPP.IDZam		-- (Z)Obsazeni prac. pozic
												AND CAST(OPP.PlatnostOd as DATE) <=  CAST(GETDATE() as DATE) 
												AND (CAST(OPP.PlatnostDo as DATE) >= CAST(GETDATE() as DATE) OR OPP.PlatnostDo IS NULL)
WHERE V.ID = @ID;

/* kontroly */

-- nezhamy zam
IF @IDZam IS NULL
	BEGIN
		RAISERROR (N'Interní chyba: Neznámý identifikátor zaměstnance',16,1);
		RETURN;
	END;
	
IF @Vypocet <= 0
	BEGIN
		RAISERROR (N'Druh výpočtu zdrojového řádku není Simulace',16,1);
		RETURN;
	END;

	
/* funkcni telo procedury */

-- smazat puvodni dovednosti
IF @Prepsat = 1
	DELETE FROM Tabx_RSPersMzdy_PozadovaneDovednosti
	WHERE IDZam = @IDZam
		AND Vypocet = @Vypocet;
	
-- prevzeti z aktualni
INSERT INTO Tabx_RSPersMzdy_PozadovaneDovednosti(
	IDZam
	,Vypocet
	,IDPPDetailZnalosti
	,IDPP)
SELECT
	@IDZam
	,@Vypocet
	,P.IDPPDetailZnalosti
	,P.IDPP
FROM Tabx_RSPersMzdy_PozadovaneDovednosti P
WHERE IDZam = @IDZam
	AND Vypocet = 0 -- Aktualni
	AND NOT EXISTS(SELECT * FROM Tabx_RSPersMzdy_PozadovaneDovednosti WHERE IDZam = @IDZam
							AND Vypocet = @Vypocet
							AND IDPPDetailZnalosti = P.IDPPDetailZnalosti);
GO

