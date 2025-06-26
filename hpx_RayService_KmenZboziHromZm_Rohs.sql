USE [RayService]
GO

/****** Object:  StoredProcedure [dbo].[hpx_RayService_KmenZboziHromZm_Rohs]    Script Date: 26.06.2025 9:12:21 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO



CREATE PROCEDURE [dbo].[hpx_RayService_KmenZboziHromZm_Rohs]
	@RoHs NVARCHAR(10)
	,@ID INT
AS
SET NOCOUNT ON;
-- =============================================
-- Author:		JDO
-- Description:	Hromadna zmena priznaku RoHs
-- =============================================

IF NOT EXISTS(SELECT * FROM TabKmenZbozi_EXT WHERE ID = @ID)
	INSERT INTO TabKmenZbozi_EXT(ID) VALUES(@ID);
	
UPDATE TabKmenZbozi_EXT SET 
	_RoHs = @RoHs
WHERE ID = @ID;
GO

