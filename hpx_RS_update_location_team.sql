USE [RayService]
GO

/****** Object:  StoredProcedure [dbo].[hpx_RS_update_location_team]    Script Date: 26.06.2025 11:18:26 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

CREATE PROCEDURE [dbo].[hpx_RS_update_location_team]
@_EXT_RS_zamesntanci_lokalita_tym NVARCHAR(30),
@ID INT
AS

BEGIN
IF (SELECT tcze.ID FROM TabCisZam_EXT tcze WHERE tcze.ID=@ID) IS NULL
 BEGIN 
    INSERT INTO TabCisZam_EXT (ID,_EXT_RS_zamesntanci_lokalita_tym)
    VALUES (@ID,@_EXT_RS_zamesntanci_lokalita_tym)
 END
ELSE
UPDATE tcze SET tcze._EXT_RS_zamesntanci_lokalita_tym = @_EXT_RS_zamesntanci_lokalita_tym
FROM TabCisZam_EXT tcze
WHERE tcze.ID = @ID
END;
GO

