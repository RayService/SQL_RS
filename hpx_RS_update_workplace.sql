USE [RayService]
GO

/****** Object:  StoredProcedure [dbo].[hpx_RS_update_workplace]    Script Date: 26.06.2025 13:07:34 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

CREATE PROCEDURE [dbo].[hpx_RS_update_workplace]
@_EXT_RS_workplace_IDWorkplace INT,
@kontrola BIT,
@ID INT
AS

IF @kontrola=1
BEGIN
IF (SELECT tcze.ID FROM TabCisZam_EXT tcze WHERE tcze.ID=@ID) IS NULL
 BEGIN 
    INSERT INTO TabCisZam_EXT (ID,_EXT_RS_workplace_IDWorkplace)
    VALUES (@ID,@_EXT_RS_workplace_IDWorkplace)
 END
ELSE
UPDATE tcze SET tcze._EXT_RS_workplace_IDWorkplace = @_EXT_RS_workplace_IDWorkplace
FROM TabCisZam_EXT tcze
WHERE tcze.ID = @ID
END;
IF @kontrola=0
BEGIN
RAISERROR('Nic neproběhne, není zatržena žádná volba.',16,1)
RETURN;
END;
GO

