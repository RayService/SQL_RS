USE [RayService]
GO

/****** Object:  StoredProcedure [dbo].[hpx_RS_update_fair_proveden]    Script Date: 26.06.2025 11:03:56 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

CREATE PROCEDURE [dbo].[hpx_RS_update_fair_proveden]
@kontrola1 BIT,
@_fair_proveden BIT,
@ID INT
AS
IF @kontrola1=1
BEGIN
IF (SELECT tpe.ID  FROM TabPrikaz_EXT tpe WHERE tpe.ID=@ID) IS NULL
 BEGIN 
    INSERT INTO TabPrikaz_EXT (ID,_fair_proveden)
    VALUES (@ID,@_fair_proveden)
 END
ELSE
UPDATE tpe SET tpe._fair_proveden = @_fair_proveden
FROM TabPrikaz_EXT tpe
WHERE tpe.ID = @ID
END;
IF @kontrola1=0
BEGIN
RAISERROR ('Nic neproběhne, není zatržena žádná volba',16,1);
RETURN;
END;
GO

