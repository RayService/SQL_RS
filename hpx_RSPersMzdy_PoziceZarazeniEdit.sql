USE [RayService]
GO

/****** Object:  StoredProcedure [dbo].[hpx_RSPersMzdy_PoziceZarazeniEdit]    Script Date: 26.06.2025 9:21:08 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO


CREATE PROCEDURE [dbo].[hpx_RSPersMzdy_PoziceZarazeniEdit]
	@TypAkce TINYINT		-- 1=UPDATE
	,@Podminka_K1 NVARCHAR(30)	-- 1.
	,@Podminka_K2 NVARCHAR(30)	-- 2.
	,@Podminka_K3 NVARCHAR(30)	-- 3.
	,@Podminka_K4 NVARCHAR(30)	-- 4.
	,@ID INT				-- ID v Tabx_RSPersMzdy_Pozice
AS
SET NOCOUNT ON;
-- =============================================
-- Author:		JDO
-- Description:	Stanoveni mzdy - Editor - Podminka zarazeni na mzdovou pozici
-- =============================================

SET @Podminka_K1 = dbo.hfx_RSPersMzdy_Podminka(@Podminka_K1);
SET @Podminka_K2 = dbo.hfx_RSPersMzdy_Podminka(@Podminka_K2);
SET @Podminka_K3 = dbo.hfx_RSPersMzdy_Podminka(@Podminka_K3);
SET @Podminka_K4 = dbo.hfx_RSPersMzdy_Podminka(@Podminka_K4);

-- * Kontroly
IF @TypAkce = 1
	BEGIN
		
		-- vse kladne
		IF @Podminka_K1 = N'Err'
			OR @Podminka_K2 = N'Err'
			OR @Podminka_K3 = N'Err'
			OR @Podminka_K4 = N'Err'
			BEGIN
				RAISERROR ('Kontrola údajů: Podmínky > nesprávný formát nebo neplatné znaky',16,1);
				RETURN;
			END;
		
	END;

-- UPDATE 
IF @TypAkce = 1
	UPDATE Tabx_RSPersMzdy_Pozice SET
		Podminka_K1 = @Podminka_K1
		,Podminka_K2 = @Podminka_K2
		,Podminka_K3 = @Podminka_K3
		,Podminka_K4 = @Podminka_K4
	WHERE ID = @ID;
GO

