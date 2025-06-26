USE [RayService]
GO

/****** Object:  StoredProcedure [dbo].[hpx_RS_HromZmenaKumulaceDnuLogis]    Script Date: 26.06.2025 15:23:34 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

CREATE PROC [dbo].[hpx_RS_HromZmenaKumulaceDnuLogis]
@_EXT_RS_AccumDays INT,
@kontrola bit,
@ID INT
AS

IF @kontrola = 1
BEGIN
IF (SELECT tkze.ID  FROM TabKmenZbozi_EXT as tkze WHERE tkze.ID = @ID) IS NULL
 BEGIN 
    INSERT INTO TabKmenZbozi_EXT (ID,_EXT_RS_AccumDays)
    VALUES (@ID,@_EXT_RS_AccumDays)
 END
ELSE
UPDATE TabKmenZbozi_EXT SET _EXT_RS_AccumDays=@_EXT_RS_AccumDays WHERE ID = @ID
END
IF @kontrola=0
BEGIN
RAISERROR('Nic neproběhne, není zatrženo Přepsat.',16,1)
RETURN
END;
GO

