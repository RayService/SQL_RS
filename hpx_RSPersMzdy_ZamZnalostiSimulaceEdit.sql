USE [RayService]
GO

/****** Object:  StoredProcedure [dbo].[hpx_RSPersMzdy_ZamZnalostiSimulaceEdit]    Script Date: 26.06.2025 9:25:57 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO



CREATE PROCEDURE [dbo].[hpx_RSPersMzdy_ZamZnalostiSimulaceEdit]
	@TypAkce TINYINT		-- NULL=Zruseni priznamu,1=Simulace-Zahrnout;2=Simulace-nezahrnout
	,@ID INT				-- ID v TabCisZamZnalosti
AS
SET NOCOUNT ON;
-- =============================================
-- Author:		JDO
-- Description:	Stanoveni mzdy - "Editor" - Priznak simulace v dovednostech zamestnance
-- =============================================

/* funkční tělo procedury */

IF @TypAkce IS NULL
	AND NOT EXISTS(SELECT * FROM TabCisZamZnalosti_EXT WHERE ID = @ID)
	RETURN;

IF NOT EXISTS(SELECT * FROM TabCisZamZnalosti_EXT WHERE ID = @ID)
	INSERT INTO TabCisZamZnalosti_EXT(ID) VALUES(@ID)
UPDATE TabCisZamZnalosti_EXT SET
	_RSPersMzdy_Simulace = @TypAkce
WHERE ID = @ID;
GO

