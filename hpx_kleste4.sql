USE [RayService]
GO

/****** Object:  StoredProcedure [dbo].[hpx_kleste4]    Script Date: 26.06.2025 9:42:54 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

CREATE PROC [dbo].[hpx_kleste4] @Nářadí NVARCHAR(50), @ID INT
AS

IF NOT EXISTS (SELECT * FROM TabKmenZbozi_EXT WHERE ID =@ID)
    Begin
             INSERT INTO TabKmenZbozi_EXT (ID)
             VALUES (@ID)
    End

UPDATE TabKmenZbozi_EXT
SET _kleste4 =@Nářadí
WHERE ID =@ID
GO

