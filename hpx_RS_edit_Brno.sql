USE [RayService]
GO

/****** Object:  StoredProcedure [dbo].[hpx_RS_edit_Brno]    Script Date: 26.06.2025 12:49:50 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

CREATE PROC [dbo].[hpx_RS_edit_Brno]
@_datVracVP DATETIME,
@kontrola1 bit,
@_infDodavka NVARCHAR(255),
@kontrola2 BIT,
@ID INT
AS
IF @kontrola1 = 1
BEGIN
UPDATE dbo.TabPrikaz_EXT SET _datVracVP=@_datVracVP WHERE ID = @ID;
END
IF @kontrola2 = 1
BEGIN
UPDATE dbo.TabPrikaz_EXT SET _infDodavka=@_infDodavka WHERE ID = @ID;
END

IF @kontrola1=0 AND @kontrola2=0
BEGIN
RAISERROR ('Nic neproběhne, není zatrženo Přepsat.',16,1);
RETURN
END;
GO

