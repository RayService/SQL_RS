USE [RayService]
GO

/****** Object:  StoredProcedure [dbo].[hpx_RS_EditaceDatEskAR]    Script Date: 26.06.2025 15:44:34 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

CREATE PROC [dbo].[hpx_RS_EditaceDatEskAR]
@_DatEskAR DATETIME,
@kontrola bit,
@ID INT
AS
IF @kontrola = 1
BEGIN
BEGIN TRANSACTION;
UPDATE dbo.TabDokladyZbozi_EXT WITH (UPDLOCK, SERIALIZABLE) SET _DatEskAR=@_DatEskAR WHERE ID = @ID;
IF @@ROWCOUNT = 0
BEGIN
  INSERT dbo.TabDokladyZbozi_EXT (ID,_DatEskAR)
  VALUES (@ID,@_DatEskAR);
END
COMMIT TRANSACTION;
END;
ELSE
BEGIN
RAISERROR ('Nic neproběhne, není zatrženo Přepsat.',16,1);
RETURN
END;
GO

