USE [RayService]
GO

/****** Object:  StoredProcedure [dbo].[hpx_RS_HromZmena_cofc_vyrobce]    Script Date: 26.06.2025 11:29:52 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

CREATE PROC [dbo].[hpx_RS_HromZmena_cofc_vyrobce]
@_cofc_vyrobce BIT,
@kontrola bit,
@ID INT
AS

IF @kontrola = 1
BEGIN
IF (SELECT tkze.ID  FROM TabKmenZbozi_EXT tkze WHERE tkze.ID = @ID) IS NULL
 BEGIN 
    INSERT INTO TabKmenZbozi_EXT (ID,_cofc_vyrobce)
    VALUES (@ID,@_cofc_vyrobce)
 END
ELSE
UPDATE TabKmenZbozi_EXT SET _cofc_vyrobce=@_cofc_vyrobce WHERE ID = @ID
END
ELSE
BEGIN
RAISERROR ('Nic neproběhne, není zatrženo Přepsat.',16,1);
RETURN
END;
GO

