USE [RayService]
GO

/****** Object:  StoredProcedure [dbo].[hpx_RayService_TPVKvalifikaceHromZmena]    Script Date: 26.06.2025 9:41:17 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

CREATE PROCEDURE [dbo].[hpx_RayService_TPVKvalifikaceHromZmena] @_KvalPrac NVARCHAR(255), @ID INT
AS
IF NOT EXISTS (SELECT * FROM TabPostup_EXT WHERE ID =@ID)
    Begin
             INSERT INTO TabPostup_EXT (ID)
             VALUES (@ID)
    End

UPDATE TabPostup_EXT
SET _KvalPrac =@_KvalPrac
WHERE ID =@ID
GO

