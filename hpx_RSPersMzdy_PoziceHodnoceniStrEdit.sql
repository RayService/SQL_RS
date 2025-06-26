USE [RayService]
GO

/****** Object:  StoredProcedure [dbo].[hpx_RSPersMzdy_PoziceHodnoceniStrEdit]    Script Date: 26.06.2025 9:24:45 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO



CREATE PROCEDURE [dbo].[hpx_RSPersMzdy_PoziceHodnoceniStrEdit]
	@TypAkce TINYINT		-- 0=INSERT, 1=UPDATE, 2=DELETE
	,@Stredisko NVARCHAR(30) = NULL		
	,@Hodnoceni_Body INT = NULL				-- 1.
	,@Hodnoceni_U1 NUMERIC(5,2) = NULL		-- 2.
	,@Hodnoceni_U2 NUMERIC(5,2) = NULL		-- 3.
	,@Hodnoceni_U3 NUMERIC(5,2) = NULL		-- 4.
	,@Hodnoceni_U4 NUMERIC(5,2) = NULL		-- 5.
	,@ID INT = NULL				-- ID v Tabx_RSPersMzdy_PoziceStredisko
AS
SET NOCOUNT ON;
-- =============================================
-- Author:		JDO
-- Description:	Stanoveni mzdy - Editor - Hodnoceni kategorie
-- =============================================

-- * Kontroly
IF @TypAkce = 0
	BEGIN
		IF NOT EXISTS(SELECT * FROM TabStrom WHERE Cislo = @Stredisko)
			BEGIN
				RAISERROR ('Kontrola údajů: Nezadáno existující středisko',16,1);
				RETURN;
			END;
			
		IF EXISTS(SELECT * FROM Tabx_RSPersMzdy_PoziceStredisko WHERE Stredisko = @Stredisko)
			BEGIN
				RAISERROR ('Kontrola: Pro dané středisko již byly řádky vygenerovány',16,1);
				RETURN;
			END;
	END;

IF @TypAkce = 1
	BEGIN
		
		-- vse kladne
		IF @Hodnoceni_Body < 0
			OR @Hodnoceni_U1 < 0.
			OR @Hodnoceni_U2 < 0.
			OR @Hodnoceni_U3 < 0.
			OR @Hodnoceni_U4 < 0.
			BEGIN
				RAISERROR ('Kontrola údajů: Číselné hodnoty > nesmí být záporné',16,1);
				RETURN;
			END;
		
		-- Rozsah mzdy Od Do
		IF @Hodnoceni_Body > 255
			BEGIN
				RAISERROR ('Kontrola údajů: Počet bodů > maximum je 255',16,1);
				RETURN;
			END;
			
	END;

/* funčkní tělo procedury */
-- INSERT
IF @TypAkce = 0
	INSERT INTO Tabx_RSPersMzdy_PoziceStredisko(
		Poradi
		,Stredisko
		,Hodnoceni_Body
		,Hodnoceni_U1
		,Hodnoceni_U2
		,Hodnoceni_U3
		,Hodnoceni_U4)
	SELECT
		P.Poradi
		,@Stredisko
		,P.Hodnoceni_Body
		,P.Hodnoceni_U1
		,P.Hodnoceni_U2
		,P.Hodnoceni_U3
		,P.Hodnoceni_U4
	FROM Tabx_RSPersMzdy_Pozice P
	WHERE NOT EXISTS(SELECT * FROM Tabx_RSPersMzdy_PoziceStredisko WHERE Poradi = P.Poradi AND Stredisko = @Stredisko);


-- UPDATE 
IF @TypAkce = 1
	UPDATE Tabx_RSPersMzdy_PoziceStredisko SET
		Hodnoceni_Body = @Hodnoceni_Body
		,Hodnoceni_U1 = @Hodnoceni_U1
		,Hodnoceni_U2 = @Hodnoceni_U2
		,Hodnoceni_U3 = @Hodnoceni_U3
		,Hodnoceni_U4 = @Hodnoceni_U4
	WHERE ID = @ID;
	
-- DELETE
IF @TypAkce = 2
	DELETE FROM Tabx_RSPersMzdy_PoziceStredisko
	WHERE Stredisko = @Stredisko;
GO

