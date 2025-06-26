USE [RayService]
GO

/****** Object:  StoredProcedure [dbo].[hpx_RayService_HromZmenaZpravaPrvniKus]    Script Date: 26.06.2025 8:50:11 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO


-- =============================================
-- Author:		DJ
-- Create date: 15.5.2012
-- Description:	Hromadná změna - Zpráva z ověření prvního kusu dle EN 9102
-- =============================================
CREATE PROCEDURE [dbo].[hpx_RayService_HromZmenaZpravaPrvniKus]
	@AnoNe BIT		-- příznak ano / ne
	,@ID INT			-- ID v TabKmenZbozi
AS
SET NOCOUNT ON;

SET @AnoNe = ISNULL(@AnoNe,0);

/* fuknčí tělo procedury */
IF NOT EXISTS(SELECT * FROM TabKmenZbozi_EXT WHERE ID = @ID)
	INSERT INTO TabKmenZbozi_EXT(ID) VALUES(@ID);

UPDATE TabKmenZbozi_EXT SET
	_zprava_prv_kus = @AnoNe
WHERE ID = @ID;
GO

