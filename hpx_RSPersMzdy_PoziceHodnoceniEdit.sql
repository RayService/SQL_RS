USE [RayService]
GO

/****** Object:  StoredProcedure [dbo].[hpx_RSPersMzdy_PoziceHodnoceniEdit]    Script Date: 26.06.2025 9:20:06 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO


CREATE PROCEDURE [dbo].[hpx_RSPersMzdy_PoziceHodnoceniEdit]
	@TypAkce TINYINT		-- 1=UPDATE
	,@Hodnoceni_Body INT	-- 1.
	,@Hodnoceni_U1 NUMERIC(5,2)		-- 2.
	,@Hodnoceni_U2 NUMERIC(5,2)		-- 3.
	,@Hodnoceni_U3 NUMERIC(5,2)		-- 4.
	,@Hodnoceni_U4 NUMERIC(5,2)		-- 4.
	,@ID INT				-- ID v Tabx_RSPersMzdy_Pozice
AS
SET NOCOUNT ON;
-- =============================================
-- Author:		JDO
-- Description:	Stanoveni mzdy - Editor - Hodnoceni kategorie
-- =============================================

-- * Kontroly
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

-- UPDATE 
IF @TypAkce = 1
	UPDATE Tabx_RSPersMzdy_Pozice SET
		Hodnoceni_Body = @Hodnoceni_Body
		,Hodnoceni_U1 = @Hodnoceni_U1
		,Hodnoceni_U2 = @Hodnoceni_U2
		,Hodnoceni_U3 = @Hodnoceni_U3
		,Hodnoceni_U4 = @Hodnoceni_U4
	WHERE ID = @ID;
GO

