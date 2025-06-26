USE [RayService]
GO

/****** Object:  StoredProcedure [dbo].[hpx_RSPersMzdy_PoziceEdit]    Script Date: 26.06.2025 9:19:25 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO


CREATE PROCEDURE [dbo].[hpx_RSPersMzdy_PoziceEdit]
	@TypAkce TINYINT		-- 1=UPDATE
	,@Nazev NVARCHAR(100)	-- 1.
	,@TK_Od NUMERIC(19,6)	-- 2.
	,@TK_Do NUMERIC(19,6)	-- 3.
	,@THP_MzdaFix NUMERIC(19,6)	-- 4.
	,@THP_MzdaPohyb NUMERIC(19,6)	-- 5.
	,@THP_MzdaOdmena NUMERIC(19,6)	-- 6.
	,@TPV_KS NUMERIC(19,6)	-- 7.
	,@TPV_EL NUMERIC(19,6)	-- 8.
	,@TPV_MD NUMERIC(19,6)	-- 9.
	,@ID INT				-- ID v Tabx_RSPersMzdy_Pozice
AS
SET NOCOUNT ON;
-- =============================================
-- Author:		JDO
-- Description:	Stanoveni mzdy - Editor - Pozice
-- =============================================

-- * Kontroly
IF @TypAkce = 1
	BEGIN
		
		-- vse kladne
		IF @TK_Od < 0.
			OR @TK_Do < 0.
			OR @THP_MzdaFix < 0.
			OR @THP_MzdaPohyb < 0.
			OR @THP_MzdaOdmena < 0.
			OR @TPV_KS < 0.
			OR @TPV_EL < 0.
			OR @TPV_MD < 0.
			BEGIN
				RAISERROR ('Kontrola údajů: Číselné hodnoty > nesmí být záporné',16,1);
				RETURN;
			END;
		
		-- Rozsah mzdy Od Do
		IF @TK_Od > @TK_Do
			BEGIN
				RAISERROR ('Kontrola údajů: TK - Mzda Od-Do > Od je větší než Do',16,1);
				RETURN;
			END;
			
		IF EXISTS(SELECT * FROM Tabx_RSPersMzdy_Pozice
					WHERE ID <> @ID
						AND @TK_Do > 0.
						AND TK_Do > 0.
						AND (@TK_Od BETWEEN TK_Od AND TK_Do OR @TK_Do BETWEEN TK_Od AND TK_Do)
					)
			BEGIN
				RAISERROR (N'Kontrola údajů: TK - Mzda Od-Do > Spadá do intervalu jiné pozice',16,1);
				RETURN;
			END;
		
	END;

-- UPDATE 
IF @TypAkce = 1
	UPDATE Tabx_RSPersMzdy_Pozice SET
		Nazev = @Nazev
		,TK_Od = @TK_Od
		,TK_Do = @TK_Do
		,THP_MzdaFix = @THP_MzdaFix
		,THP_MzdaPohyb = @THP_MzdaPohyb
		,THP_MzdaOdmena = @THP_MzdaOdmena
		,TPV_KS = @TPV_KS
		,TPV_EL = @TPV_EL
		,TPV_MD = @TPV_MD
	WHERE ID = @ID;
GO

