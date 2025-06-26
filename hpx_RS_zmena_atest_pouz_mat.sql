USE [RayService]
GO

/****** Object:  StoredProcedure [dbo].[hpx_RS_zmena_atest_pouz_mat]    Script Date: 26.06.2025 11:22:40 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

CREATE PROCEDURE [dbo].[hpx_RS_zmena_atest_pouz_mat]
@_atest_pouz_mat BIT,
@kontrola bit,
@ID int
AS
IF @kontrola = 1
BEGIN
IF (SELECT KZE.ID  FROM TabKmenZbozi_EXT as KZE WHERE KZE.ID = @ID) IS NULL
 BEGIN 
    INSERT INTO TabKmenZbozi_EXT (ID,_atest_pouz_mat) 
    VALUES (@ID,@_atest_pouz_mat)
 END
ELSE
UPDATE TabKmenZbozi_EXT SET _atest_pouz_mat = @_atest_pouz_mat WHERE ID = @ID
END
GO

