USE [RayService]
GO

/****** Object:  StoredProcedure [dbo].[hpx_RS_update_foreman]    Script Date: 26.06.2025 13:08:11 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

CREATE PROCEDURE [dbo].[hpx_RS_update_foreman]
@_EXT_RS_workplace_IDForeman INT,
@kontrola BIT,
@ID INT
AS

IF @kontrola=1
BEGIN
IF (SELECT tcze.ID FROM TabCisZam_EXT tcze WHERE tcze.ID=@ID) IS NULL
 BEGIN 
    INSERT INTO TabCisZam_EXT (ID,_EXT_RS_workplace_IDForeman)
    VALUES (@ID,@_EXT_RS_workplace_IDForeman)
 END
ELSE
UPDATE tcze SET tcze._EXT_RS_workplace_IDForeman = @_EXT_RS_workplace_IDForeman
FROM TabCisZam_EXT tcze
WHERE tcze.ID = @ID
END;
IF @kontrola=0
BEGIN
RAISERROR('Nic neproběhne, není zatržena žádná volba.',16,1)
RETURN;
END;
GO

