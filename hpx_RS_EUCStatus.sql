USE [RayService]
GO

/****** Object:  StoredProcedure [dbo].[hpx_RS_EUCStatus]    Script Date: 30.06.2025 8:40:16 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

CREATE PROC [dbo].[hpx_RS_EUCStatus]
@EUCStatus INT,
@kontrola bit,
@ID INT
AS
IF @kontrola = 1
BEGIN
BEGIN TRANSACTION;
UPDATE dbo.TabZakazka_EXT WITH (UPDLOCK, SERIALIZABLE) SET _EXT_RS_EUCStatus=@EUCStatus WHERE ID = @ID;
IF @@ROWCOUNT = 0 
BEGIN
  INSERT dbo.TabZakazka_EXT (ID,_EXT_RS_EUCStatus)
  VALUES (@ID,@EUCStatus);
END
COMMIT TRANSACTION;
END;
ELSE
BEGIN
RAISERROR ('Nic neproběhne, není zatrženo Přepsat.',16,1);
RETURN
END;
GO

