USE [RayService]
GO

/****** Object:  StoredProcedure [dbo].[hpx_RS_update_TechnologyOffer]    Script Date: 26.06.2025 13:22:51 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

CREATE PROCEDURE [dbo].[hpx_RS_update_TechnologyOffer]
@kontrola1 BIT,
@_EXT_RS_TechnologyOffer INT,
@ID INT
AS
IF @kontrola1=1
BEGIN
IF (SELECT tde.ID  FROM TabDokladyZbozi_EXT tde WHERE tde.ID=@ID) IS NULL
 BEGIN 
    INSERT INTO TabDokladyZbozi_EXT (ID,_EXT_RS_TechnologyOffer)
    VALUES (@ID,@_EXT_RS_TechnologyOffer)
 END
ELSE
UPDATE tde SET tde._EXT_RS_TechnologyOffer = @_EXT_RS_TechnologyOffer
FROM TabDokladyZbozi_EXT tde
WHERE tde.ID = @ID
END;
IF @kontrola1=0
BEGIN
RAISERROR ('Nic neproběhne, není zatržena žádná volba',16,1);
RETURN;
END;
GO

