USE [RayService]
GO

/****** Object:  StoredProcedure [dbo].[hpx_RS_zmena_typ_vyr_tpv]    Script Date: 26.06.2025 14:08:29 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

CREATE PROCEDURE [dbo].[hpx_RS_zmena_typ_vyr_tpv]
@kontrola bit,
@_EXT_RS_TypVyrobkuTPV NVARCHAR(5),
@ID int
AS
IF @kontrola = 1
BEGIN
IF (SELECT tkze.ID  FROM TabKmenZbozi_EXT as tkze WHERE tkze.ID = @ID) IS NULL
 BEGIN 
    INSERT INTO TabKmenZbozi_EXT (ID,_EXT_RS_TypVyrobkuTPV)
    VALUES (@ID,@_EXT_RS_TypVyrobkuTPV)
 END
ELSE
UPDATE TabKmenZbozi_EXT SET _EXT_RS_TypVyrobkuTPV=@_EXT_RS_TypVyrobkuTPV WHERE ID = @ID
END
GO

