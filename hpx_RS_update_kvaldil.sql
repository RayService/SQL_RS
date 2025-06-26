USE [RayService]
GO

/****** Object:  StoredProcedure [dbo].[hpx_RS_update_kvaldil]    Script Date: 26.06.2025 13:19:10 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

CREATE PROCEDURE [dbo].[hpx_RS_update_kvaldil]
@kontrola1 BIT,
@_KvalDil NVARCHAR(1),
@ID INT
AS
IF @kontrola1=1
BEGIN
IF (SELECT tpe.ID  FROM TabPrikaz_EXT tpe WHERE tpe.ID=@ID) IS NULL
 BEGIN 
    INSERT INTO TabPrikaz_EXT (ID,_KvalDil)
    VALUES (@ID,@_KvalDil)
 END
ELSE
UPDATE tpe SET tpe._KvalDil = @_KvalDil
FROM TabPrikaz_EXT tpe
WHERE tpe.ID = @ID
END;
IF @kontrola1=0
BEGIN
RAISERROR ('Nic neproběhne, není zatržena žádná volba',16,1);
RETURN;
END;
GO

