USE [RayService]
GO

/****** Object:  StoredProcedure [dbo].[hpx_RS_CisloZakazky]    Script Date: 30.06.2025 8:30:06 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

CREATE PROC [dbo].[hpx_RS_CisloZakazky]
@CisloZakazky NVARCHAR(15),
@kontrola BIT,
@ID INT
AS
IF @kontrola = 1
BEGIN
BEGIN TRANSACTION;
UPDATE dbo.TabDokladyZbozi WITH (UPDLOCK) SET CisloZakazky=@CisloZakazky WHERE ID = @ID;
COMMIT TRANSACTION;
END;
ELSE
BEGIN
RAISERROR ('Nic neproběhne, není zatrženo Přepsat.',16,1);
RETURN
END;
GO

