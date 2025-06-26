USE [RayService]
GO

/****** Object:  StoredProcedure [dbo].[hpx_RS_HromZmenaUdajuDataPrezkumu]    Script Date: 26.06.2025 13:52:40 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

CREATE PROC [dbo].[hpx_RS_HromZmenaUdajuDataPrezkumu]
@_EXT_RS_datum_prezkumu DATETIME,
@kontrola1 bit,
@_EXT_DateGenerateMat DATETIME,
@kontrola2 bit,
@ID INT
AS

IF @kontrola1 = 1
BEGIN
UPDATE TabZakazka_EXT SET _EXT_RS_datum_prezkumu=@_EXT_RS_datum_prezkumu WHERE ID = @ID
END

IF @kontrola2 = 1
BEGIN
UPDATE TabZakazka_EXT SET _EXT_DateGenerateMat=@_EXT_DateGenerateMat WHERE ID = @ID
END

IF (@kontrola1=0 AND @kontrola2=0)
BEGIN
RAISERROR ('Nic neproběhne, není zatrženo Přepsat.',16,1);
RETURN
END;
GO

