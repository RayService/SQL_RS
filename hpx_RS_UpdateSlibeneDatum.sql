USE [RayService]
GO

/****** Object:  StoredProcedure [dbo].[hpx_RS_UpdateSlibeneDatum]    Script Date: 26.06.2025 15:30:35 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

CREATE PROC [dbo].[hpx_RS_UpdateSlibeneDatum]
@kontrola bit,
@ID INT
AS

DECLARE @PotvrzDatum DATETIME
SET @PotvrzDatum=(SELECT PotvrzDatDod FROM TabPohybyZbozi WHERE ID=@ID)
IF @kontrola=1 AND @PotvrzDatum IS NOT NULL
BEGIN
IF (SELECT tpze.ID FROM TabPohybyZbozi_EXT AS tpze WHERE tpze.ID = @ID) IS NULL
 BEGIN 
    INSERT INTO TabPohybyZbozi_EXT (ID,_EXT_RS_PromisedStockingDate)
    VALUES (@ID,@PotvrzDatum)
 END;
ELSE
UPDATE TabPohybyZbozi_EXT SET _EXT_RS_PromisedStockingDate=@PotvrzDatum WHERE ID = @ID
END;
IF @kontrola=0
BEGIN
RAISERROR('Nic neproběhne, není zatrženo Přepsat.',16,1)
RETURN
END;
GO

