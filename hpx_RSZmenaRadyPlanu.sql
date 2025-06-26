USE [RayService]
GO

/****** Object:  StoredProcedure [dbo].[hpx_RSZmenaRadyPlanu]    Script Date: 26.06.2025 15:39:33 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

CREATE PROC [dbo].[hpx_RSZmenaRadyPlanu]
@_EXT_RS_RadaPlanu NVARCHAR(10),
@kontrola bit,
@ID INT
AS
IF @kontrola = 1
BEGIN
BEGIN TRANSACTION;
UPDATE dbo.TabPohybyZbozi_EXT WITH (UPDLOCK, SERIALIZABLE) SET _EXT_RS_RadaPlanu=@_EXT_RS_RadaPlanu WHERE ID = @ID;
IF @@ROWCOUNT = 0
BEGIN
  INSERT dbo.TabPohybyZbozi_EXT (ID,_EXT_RS_RadaPlanu)
  VALUES (@ID,@_EXT_RS_RadaPlanu);
END
COMMIT TRANSACTION;
END;
ELSE
BEGIN
RAISERROR ('Nic neproběhne, není zatrženo Přepsat.',16,1);
RETURN
END;
GO

