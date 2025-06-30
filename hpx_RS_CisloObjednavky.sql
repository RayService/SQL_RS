USE [RayService]
GO

/****** Object:  StoredProcedure [dbo].[hpx_RS_CisloObjednavky]    Script Date: 30.06.2025 8:29:23 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

CREATE PROC [dbo].[hpx_RS_CisloObjednavky]
@CisloObjednavky NVARCHAR(30),
@kontrola BIT,
@ID INT
AS
IF @kontrola = 1
BEGIN
BEGIN TRANSACTION;
UPDATE dbo.TabDokladyZbozi WITH (UPDLOCK) SET NavaznaObjednavka=@CisloObjednavky WHERE ID = @ID;
COMMIT TRANSACTION;
END;
ELSE
BEGIN
RAISERROR ('Nic neproběhne, není zatrženo Přepsat.',16,1);
RETURN
END;
GO

