USE [RayService]
GO

/****** Object:  StoredProcedure [dbo].[hpx_TechnikTPV200]    Script Date: 26.06.2025 12:26:13 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

CREATE PROC [dbo].[hpx_TechnikTPV200] @TechnikTPV200 NVARCHAR(50), @ID INT
AS

IF NOT EXISTS (SELECT * FROM TabKmenZbozi_EXT WHERE ID =@ID)
    Begin
             INSERT INTO TabKmenZbozi_EXT (ID)
             VALUES (@ID)
    End

UPDATE TabKmenZbozi_EXT
SET _TechnikTPV200 =@TechnikTPV200
WHERE ID =@ID
GO

