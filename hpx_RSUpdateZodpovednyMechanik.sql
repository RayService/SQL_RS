USE [RayService]
GO

/****** Object:  StoredProcedure [dbo].[hpx_RSUpdateZodpovednyMechanik]    Script Date: 26.06.2025 14:11:57 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

CREATE PROCEDURE [dbo].[hpx_RSUpdateZodpovednyMechanik]
@kontrola1 BIT,
@_zodpovednyMechanik NVARCHAR(30),
@ID INT
AS
IF @kontrola1=1
BEGIN
IF (SELECT tpe.ID  FROM TabPrikaz_EXT tpe WHERE tpe.ID=@ID) IS NULL
 BEGIN 
    INSERT INTO TabPrikaz_EXT (ID,_zodpovednyMechanik)
    VALUES (@ID,@_zodpovednyMechanik)
 END
ELSE
UPDATE tpe SET tpe._zodpovednyMechanik = @_zodpovednyMechanik
FROM TabPrikaz_EXT tpe
WHERE tpe.ID = @ID
END;
IF @kontrola1=0
BEGIN
RAISERROR ('Nic neproběhne, není zatržena žádná volba',16,1);
RETURN;
END;
GO

