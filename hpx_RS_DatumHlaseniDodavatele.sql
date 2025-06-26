USE [RayService]
GO

/****** Object:  StoredProcedure [dbo].[hpx_RS_DatumHlaseniDodavatele]    Script Date: 26.06.2025 14:17:00 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

CREATE PROCEDURE [dbo].[hpx_RS_DatumHlaseniDodavatele]
@_EXT_RS_DatumHlaseni DATETIME,
@kontrola bit,
@ID INT
AS
IF @kontrola = 1
BEGIN
BEGIN TRANSACTION;
UPDATE dbo.TabKmenZbozi_EXT WITH (UPDLOCK, SERIALIZABLE) SET _EXT_RS_DatumHlaseni=@_EXT_RS_DatumHlaseni WHERE ID = @ID;
IF @@ROWCOUNT = 0
BEGIN
  INSERT dbo.TabKmenZbozi_EXT (ID,_EXT_RS_DatumHlaseni)
  VALUES (@ID,@_EXT_RS_DatumHlaseni);
END
COMMIT TRANSACTION;
END;
ELSE
BEGIN
RAISERROR ('Nic neproběhne, není zatrženo Přepsat.',16,1);
RETURN
END;
GO

