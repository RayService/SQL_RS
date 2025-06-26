USE [RayService]
GO

/****** Object:  StoredProcedure [dbo].[hpx_RS_zmena_VseoPoz]    Script Date: 26.06.2025 11:22:12 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

CREATE PROCEDURE [dbo].[hpx_RS_zmena_VseoPoz]
@_VseoPoz NVARCHAR(540),
@kontrola bit,
@ID int
AS
IF @kontrola = 1
BEGIN
IF (SELECT KZE.ID  FROM TabKmenZbozi_EXT as KZE WHERE KZE.ID = @ID) IS NULL
 BEGIN 
    INSERT INTO TabKmenZbozi_EXT (ID,_VseoPoz) 
    VALUES (@ID,@_VseoPoz)
 END
ELSE
UPDATE TabKmenZbozi_EXT SET _VseoPoz = @_VseoPoz WHERE ID = @ID
END
GO

