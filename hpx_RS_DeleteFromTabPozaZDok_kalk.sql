USE [RayService]
GO

/****** Object:  StoredProcedure [dbo].[hpx_RS_DeleteFromTabPozaZDok_kalk]    Script Date: 30.06.2025 8:38:58 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

CREATE PROCEDURE [dbo].[hpx_RS_DeleteFromTabPozaZDok_kalk]
@kontrola BIT,
@ID INT
AS
IF @kontrola=1
BEGIN
DELETE FROM TabPozaZDok_kalk WHERE ID=@ID
END;
ELSE
BEGIN
RAISERROR('Nic neproběhne, není zatrženo Provést.',16,1)
RETURN
END;
GO

