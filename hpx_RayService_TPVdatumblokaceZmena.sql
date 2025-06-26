USE [RayService]
GO

/****** Object:  StoredProcedure [dbo].[hpx_RayService_TPVdatumblokaceZmena]    Script Date: 26.06.2025 12:25:42 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

CREATE PROCEDURE [dbo].[hpx_RayService_TPVdatumblokaceZmena] @_EXT_RS_blok_datum DATETIME, @ID INT
AS
IF NOT EXISTS (SELECT * FROM TabPostup_EXT WHERE ID =@ID)
    Begin
             INSERT INTO TabPostup_EXT (ID)
             VALUES (@ID)
    End

UPDATE TabKmenZbozi_EXT
SET _EXT_RS_blok_datum =@_EXT_RS_blok_datum
WHERE ID =@ID
GO

