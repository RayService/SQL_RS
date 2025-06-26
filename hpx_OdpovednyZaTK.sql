USE [RayService]
GO

/****** Object:  StoredProcedure [dbo].[hpx_OdpovednyZaTK]    Script Date: 26.06.2025 9:40:05 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

CREATE PROC [dbo].[hpx_OdpovednyZaTK] @odpovida_TK NVARCHAR(30), @ID INT
AS

IF NOT EXISTS (SELECT * FROM TabPrikaz_EXT WHERE ID =@ID)
    Begin
             INSERT INTO TabPrikaz_EXT (ID)
             VALUES (@ID)
    End

UPDATE TabPrikaz_EXT
SET _odpovida_TK =@odpovida_TK
WHERE ID =@ID
GO

