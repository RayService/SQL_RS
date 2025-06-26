USE [RayService]
GO

/****** Object:  StoredProcedure [dbo].[hpx_delka_odizol]    Script Date: 26.06.2025 9:47:24 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

CREATE PROC [dbo].[hpx_delka_odizol] @Nářadí NUMERIC, @ID INT
AS

IF NOT EXISTS (SELECT * FROM TabKmenZbozi_EXT WHERE ID =@ID)
    Begin
             INSERT INTO TabKmenZbozi_EXT (ID)
             VALUES (@ID)
    End

UPDATE TabKmenZbozi_EXT
SET _delka_odizol =@Nářadí
WHERE ID =@ID
GO

