USE [RayService]
GO

/****** Object:  StoredProcedure [dbo].[hpx_RS_zmena_COFC_EN10204]    Script Date: 26.06.2025 11:26:35 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

CREATE PROCEDURE [dbo].[hpx_RS_zmena_COFC_EN10204]
@_Cofc_en10204 BIT,
@kontrola bit,
@ID int
AS
IF @kontrola = 1
BEGIN
IF (SELECT tkze.ID  FROM TabKmenZbozi_EXT as tkze WHERE tkze.ID = @ID) IS NULL
 BEGIN 
    INSERT INTO TabKmenZbozi_EXT (ID,_Cofc_en10204)
    VALUES (@ID,@_Cofc_en10204)
 END
ELSE
UPDATE TabKmenZbozi_EXT SET _Cofc_en10204=@_Cofc_en10204 WHERE ID = @ID
END
GO

