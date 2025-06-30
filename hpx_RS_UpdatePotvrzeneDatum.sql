USE [RayService]
GO

/****** Object:  StoredProcedure [dbo].[hpx_RS_UpdatePotvrzeneDatum]    Script Date: 30.06.2025 8:52:58 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

CREATE PROC [dbo].[hpx_RS_UpdatePotvrzeneDatum]
@kontrola bit,
@ID INT
AS

DECLARE @PozadovaneDatum DATETIME
SET @PozadovaneDatum=(SELECT PozadDatDod FROM TabPohybyZbozi WHERE ID=@ID)
IF @kontrola=1 AND @PozadovaneDatum IS NOT NULL
BEGIN
UPDATE TabPohybyZbozi SET PotvrzDatDod=@PozadovaneDatum WHERE ID = @ID
END;
IF @kontrola=0
BEGIN
RAISERROR('Nic neproběhne, není zatrženo Přepsat.',16,1)
RETURN
END;
GO

