USE [RayService]
GO

/****** Object:  StoredProcedure [dbo].[hpx_RS_update_EXT_RS_after_validation_ready_fair]    Script Date: 26.06.2025 11:04:37 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

CREATE PROCEDURE [dbo].[hpx_RS_update_EXT_RS_after_validation_ready_fair]
@kontrola1 BIT,
@_EXT_RS_after_validation_ready_fair BIT,
@ID INT
AS
IF @kontrola1=1
BEGIN
IF (SELECT tpe.ID  FROM TabPrikaz_EXT tpe WHERE tpe.ID=@ID) IS NULL
 BEGIN 
    INSERT INTO TabPrikaz_EXT (ID,_EXT_RS_after_validation_ready_fair)
    VALUES (@ID,@_EXT_RS_after_validation_ready_fair)
 END
ELSE
UPDATE tpe SET tpe._EXT_RS_after_validation_ready_fair = @_EXT_RS_after_validation_ready_fair
FROM TabPrikaz_EXT tpe
WHERE tpe.ID = @ID
END;
IF @kontrola1=0
BEGIN
RAISERROR ('Nic neproběhne, není zatržena žádná volba',16,1);
RETURN;
END;
GO

