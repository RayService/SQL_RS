USE [RayService]
GO

/****** Object:  StoredProcedure [dbo].[hpx_RS_UpdateSlibeneDatumZPozadData]    Script Date: 30.06.2025 8:22:21 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

CREATE PROC [dbo].[hpx_RS_UpdateSlibeneDatumZPozadData]
@kontrola bit,
@ID INT
AS

DECLARE @PozadDatDod DATETIME
SET @PozadDatDod=(SELECT PozadDatDod FROM TabPohybyZbozi WHERE ID=@ID)
IF @kontrola=1 AND @PozadDatDod IS NOT NULL
BEGIN
IF (SELECT tpze.ID FROM TabPohybyZbozi_EXT AS tpze WHERE tpze.ID = @ID) IS NULL
 BEGIN 
    INSERT INTO TabPohybyZbozi_EXT (ID,_EXT_RS_PromisedStockingDate)
    VALUES (@ID,@PozadDatDod)
 END;
ELSE
UPDATE TabPohybyZbozi_EXT SET _EXT_RS_PromisedStockingDate=@PozadDatDod WHERE ID = @ID
END;
IF @kontrola=0
BEGIN
RAISERROR('Nic neproběhne, není zatrženo Přepsat.',16,1)
RETURN
END;
GO

