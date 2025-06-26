USE [RayService]
GO

/****** Object:  StoredProcedure [dbo].[hpx_Ray_HromZmenaKVazbyNizsi_Cofc_en10204]    Script Date: 26.06.2025 9:31:52 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO


CREATE PROCEDURE [dbo].[hpx_Ray_HromZmenaKVazbyNizsi_Cofc_en10204]
	@Cofc_en10204 BIT	-- hodnota pro zmenu
	,@IDKVazby INT		-- ID v TabKVazby
AS
SET NOCOUNT ON;
-- =============================================
-- Author:		JDO
-- Description:	Hromadná zmena - CofC, dle EN10204 "2.1"
-- =============================================

DECLARE @nizsi INT;

SELECT @nizsi = nizsi
FROM TabKvazby
WHERE ID = @IDKVazby;

IF NOT EXISTS(SELECT * FROM TabKmenZbozi_EXT WHERE ID = @nizsi)
	INSERT INTO TabKmenZbozi_EXT(ID) VALUES(@nizsi);
	
UPDATE TabKmenZbozi_EXT SET
	_Cofc_en10204 = @Cofc_en10204
WHERE ID = @nizsi;
GO

