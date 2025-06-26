USE [RayService]
GO

/****** Object:  StoredProcedure [dbo].[hpx_RS_HromZmenaMinimumVyrobce]    Script Date: 26.06.2025 15:18:08 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

CREATE PROC [dbo].[hpx_RS_HromZmenaMinimumVyrobce]
@_EXT_RS_MinVyrobce INT,
@kontrola bit,
@ID INT
AS

IF @kontrola = 1
BEGIN
IF (SELECT tkze.ID  FROM TabKmenZbozi_EXT as tkze WHERE tkze.ID = @ID) IS NULL
 BEGIN 
    INSERT INTO TabKmenZbozi_EXT (ID,_EXT_RS_MinVyrobce)
    VALUES (@ID,@_EXT_RS_MinVyrobce)
 END
ELSE
UPDATE TabKmenZbozi_EXT SET _EXT_RS_MinVyrobce=@_EXT_RS_MinVyrobce WHERE ID = @ID
END
IF @kontrola=0
BEGIN
RAISERROR('Nic neproběhne, není zatrženo Přepsat.',16,1)
RETURN
END;
GO

