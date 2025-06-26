USE [RayService]
GO

/****** Object:  StoredProcedure [dbo].[hpx_RS_HromZmena_rekalkulace]    Script Date: 26.06.2025 11:31:48 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

CREATE PROC [dbo].[hpx_RS_HromZmena_rekalkulace]
@_rekalkulace BIT,
@kontrola bit,
@ID INT
AS

IF @kontrola = 1
BEGIN
IF (SELECT tkze.ID  FROM TabKmenZbozi_EXT tkze WHERE tkze.ID = @ID) IS NULL
 BEGIN 
    INSERT INTO TabKmenZbozi_EXT (ID,_rekalkulace)
    VALUES (@ID,@_rekalkulace)
 END
ELSE
UPDATE TabKmenZbozi_EXT SET _rekalkulace=@_rekalkulace WHERE ID = @ID
END
ELSE
BEGIN
RAISERROR ('Nic neproběhne, není zatrženo Přepsat.',16,1);
RETURN
END;
GO

