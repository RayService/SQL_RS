USE [RayService]
GO

/****** Object:  StoredProcedure [dbo].[hpx_RS_EditaceDatEskPr]    Script Date: 26.06.2025 15:45:15 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

CREATE PROC [dbo].[hpx_RS_EditaceDatEskPr]
@_DatEskPr DATETIME,
@kontrola bit,
@ID INT
AS
IF @kontrola = 1
BEGIN
BEGIN TRANSACTION;
UPDATE dbo.TabKontaktJednani_EXT WITH (UPDLOCK, SERIALIZABLE) SET _DatEskPr=@_DatEskPr WHERE ID = @ID;
IF @@ROWCOUNT = 0
BEGIN
  INSERT dbo.TabKontaktJednani_EXT (ID,_DatEskPr)
  VALUES (@ID,@_DatEskPr);
END
COMMIT TRANSACTION;
END;
ELSE
BEGIN
RAISERROR ('Nic neproběhne, není zatrženo Přepsat.',16,1);
RETURN
END;
GO

