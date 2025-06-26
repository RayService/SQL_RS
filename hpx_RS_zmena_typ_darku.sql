USE [RayService]
GO

/****** Object:  StoredProcedure [dbo].[hpx_RS_zmena_typ_darku]    Script Date: 26.06.2025 11:24:34 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

CREATE PROCEDURE [dbo].[hpx_RS_zmena_typ_darku]
@_typ_darku NVARCHAR(10),
@kontrola bit,
@ID int
AS
IF @kontrola = 1
BEGIN
IF (SELECT KOS.ID  FROM TabCisKOs_EXT as KOS WHERE KOS.ID = @ID) IS NULL
 BEGIN 
    INSERT INTO TabcisKOs_EXT (ID,_typ_darku)
    VALUES (@ID,@_typ_darku)
 END
ELSE
UPDATE TabCisKOs_EXT SET _typ_darku = @_typ_darku WHERE ID = @ID
END
GO

