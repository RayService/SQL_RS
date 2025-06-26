USE [RayService]
GO

/****** Object:  StoredProcedure [dbo].[hpx_RS_update_PozadovanyIndexZmeny]    Script Date: 26.06.2025 11:10:37 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

CREATE PROCEDURE [dbo].[hpx_RS_update_PozadovanyIndexZmeny]
@kontrola1 BIT,
@_PozadovanyIndexZmeny NVARCHAR(15),
@ID INT
AS

IF @kontrola1=1
BEGIN
IF (SELECT tpze.ID FROM TabPohybyZbozi_EXT tpze WHERE tpze.ID=@ID) IS NULL
 BEGIN 
    INSERT INTO TabPohybyZbozi_EXT (ID,_PozadovanyIndexZmeny)
    VALUES (@ID,@_PozadovanyIndexZmeny)
 END
ELSE
UPDATE tpe SET tpe._PozadovanyIndexZmeny = @_PozadovanyIndexZmeny
FROM TabPohybyZbozi_EXT tpe
WHERE tpe.ID = @ID
END;
IF (@kontrola1=0)
BEGIN
RAISERROR ('Nic neproběhne, není zatržena žádná volba',16,1);
RETURN;
END;
GO

