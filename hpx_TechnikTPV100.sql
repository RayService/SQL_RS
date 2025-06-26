USE [RayService]
GO

/****** Object:  StoredProcedure [dbo].[hpx_TechnikTPV100]    Script Date: 26.06.2025 12:29:51 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

CREATE PROC [dbo].[hpx_TechnikTPV100] @TechnikTPV100 NVARCHAR(50), @ID INT
AS

IF NOT EXISTS (SELECT * FROM TabKmenZbozi_EXT WHERE ID =@ID)
    Begin
             INSERT INTO TabKmenZbozi_EXT (ID)
             VALUES (@ID)
    End

IF @TechnikTPV100 <> ''
UPDATE TabKmenZbozi_EXT
SET _TechnikTPV100 =@TechnikTPV100
WHERE ID =@ID
IF @TechnikTPV100 = ''
UPDATE TabKmenZbozi_EXT
SET _TechnikTPV100 =NULL
WHERE ID =@ID
GO

