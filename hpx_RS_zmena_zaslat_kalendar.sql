USE [RayService]
GO

/****** Object:  StoredProcedure [dbo].[hpx_RS_zmena_zaslat_kalendar]    Script Date: 26.06.2025 11:20:14 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

CREATE PROCEDURE [dbo].[hpx_RS_zmena_zaslat_kalendar]
@_zaslat_kalendar BIT,
@kontrola bit,
@ID int
AS
IF @kontrola = 1
BEGIN
IF (SELECT KOS.ID  FROM TabCisKOs_EXT as KOS WHERE KOS.ID = @ID) IS NULL
 BEGIN 
    INSERT INTO TabcisKOs_EXT (ID,_zaslat_kalendar)
    VALUES (@ID,@_zaslat_kalendar)
 END
ELSE
UPDATE TabCisKOs_EXT SET _zaslat_kalendar = @_zaslat_kalendar WHERE ID = @ID
END
GO

