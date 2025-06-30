USE [RayService]
GO

/****** Object:  StoredProcedure [dbo].[hpx_RS_DatumRevizeLezaku]    Script Date: 30.06.2025 8:21:50 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

CREATE PROC [dbo].[hpx_RS_DatumRevizeLezaku]
@_EXT_DatumRevizeLezaku DATETIME,
@kontrola BIT,
@ID INT
AS
IF @kontrola = 1
BEGIN
BEGIN TRANSACTION;
UPDATE dbo.TabKmenZbozi_EXT WITH (UPDLOCK, SERIALIZABLE) SET _EXT_DatumRevizeLezaku=@_EXT_DatumRevizeLezaku WHERE ID = @ID;
IF @@ROWCOUNT = 0
BEGIN
  INSERT dbo.TabKmenZbozi_EXT (ID,_EXT_DatumRevizeLezaku)
  VALUES (@ID,@_EXT_DatumRevizeLezaku);
END
COMMIT TRANSACTION;
END;
ELSE
BEGIN
RAISERROR ('Nic neproběhne, není zatrženo Přepsat.',16,1);
RETURN
END;
GO

