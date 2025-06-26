USE [RayService]
GO

/****** Object:  StoredProcedure [dbo].[hpx_RS_HromZmena_PovolitZmenuSarze]    Script Date: 26.06.2025 11:29:17 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

CREATE PROC [dbo].[hpx_RS_HromZmena_PovolitZmenuSarze]
@_PovolitZmenuSarze BIT,
@kontrola bit,
@ID INT
AS

IF @kontrola = 1
BEGIN
IF (SELECT tpze.ID  FROM TabPohybyZbozi_EXT tpze WHERE tpze.ID = @ID) IS NULL
 BEGIN 
    INSERT INTO TabPohybyZbozi_EXT (ID,_PovolitZmenuSarze)
    VALUES (@ID,@_PovolitZmenuSarze)
 END
ELSE
UPDATE TabPohybyZbozi_EXT SET _PovolitZmenuSarze=@_PovolitZmenuSarze WHERE ID = @ID
END
ELSE
BEGIN
RAISERROR ('Nic neproběhne, není zatrženo Přepsat.',16,1);
RETURN
END;
GO

