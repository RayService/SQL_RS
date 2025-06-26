USE [RayService]
GO

/****** Object:  StoredProcedure [dbo].[hpx_RS_update_location_lunch]    Script Date: 26.06.2025 14:19:16 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

CREATE PROCEDURE [dbo].[hpx_RS_update_location_lunch]
@_EXT_RS_zamestnanci_lokalita_obed NVARCHAR(30),
@ID INT
AS

BEGIN
IF (SELECT tcze.ID FROM TabCisZam_EXT tcze WHERE tcze.ID=@ID) IS NULL
 BEGIN 
    INSERT INTO TabCisZam_EXT (ID,_EXT_RS_zamestnanci_lokalita_obed)
    VALUES (@ID,@_EXT_RS_zamestnanci_lokalita_obed)
 END
ELSE
UPDATE tcze SET tcze._EXT_RS_zamestnanci_lokalita_obed = @_EXT_RS_zamestnanci_lokalita_obed
FROM TabCisZam_EXT tcze
WHERE tcze.ID = @ID
END;
GO

