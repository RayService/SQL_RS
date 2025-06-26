USE [RayService]
GO

/****** Object:  StoredProcedure [dbo].[hpx_RayService_editace_kontrolniho_textu]    Script Date: 26.06.2025 11:17:14 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

CREATE PROCEDURE [dbo].[hpx_RayService_editace_kontrolniho_textu]
@kontrola BIT,
@_EXT_RS_kontrola_operace NVARCHAR(100),
@ID INT
AS
IF @kontrola = 1
BEGIN
UPDATE TabPrPostup_EXT SET _EXT_RS_kontrola_operace = @_EXT_RS_kontrola_operace WHERE ID = @ID
END
GO

