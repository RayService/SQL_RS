USE [RayService]
GO

/****** Object:  StoredProcedure [dbo].[hpx_RS_zmena_COP_nepozadovan]    Script Date: 26.06.2025 11:23:04 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

CREATE PROCEDURE [dbo].[hpx_RS_zmena_COP_nepozadovan]
@_NVCOP BIT,
@kontrola bit,
@ID int
AS
IF @kontrola = 1
BEGIN
IF (SELECT KZE.ID  FROM TabKmenZbozi_EXT as KZE WHERE KZE.ID = @ID) IS NULL
 BEGIN 
    INSERT INTO TabKmenZbozi_EXT (ID,_NVCOP) 
    VALUES (@ID,@_NVCOP)
 END
ELSE
UPDATE TabKmenZbozi_EXT SET _NVCOP = @_NVCOP WHERE ID = @ID
END
GO

