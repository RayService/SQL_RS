USE [RayService]
GO

/****** Object:  StoredProcedure [dbo].[hpx_RS_update_vp000vp100]    Script Date: 26.06.2025 11:16:30 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

CREATE PROCEDURE [dbo].[hpx_RS_update_vp000vp100]
@_DS_RS_vyroba_rezim_VP NVARCHAR(6),
@ID INT
AS

BEGIN
IF (SELECT tcze.ID FROM TabCisZam_EXT tcze WHERE tcze.ID=@ID) IS NULL
 BEGIN 
    INSERT INTO TabCisZam_EXT (ID,_DS_RS_vyroba_rezim_VP)
    VALUES (@ID,@_DS_RS_vyroba_rezim_VP)
 END
ELSE
UPDATE tcze SET tcze._DS_RS_vyroba_rezim_VP = @_DS_RS_vyroba_rezim_VP
FROM TabCisZam_EXT tcze
WHERE tcze.ID = @ID
END;
GO

