USE [RayService]
GO

/****** Object:  StoredProcedure [dbo].[hpx_RS_edit_DatPlatnostDoQMSNormy]    Script Date: 26.06.2025 12:43:24 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

CREATE PROC [dbo].[hpx_RS_edit_DatPlatnostDoQMSNormy]
@_EXT_RS_DatPlatnostDo DATETIME,
@kontrola1 bit,
@ID INT
AS
IF @kontrola1 = 1
BEGIN
BEGIN TRANSACTION;
UPDATE dbo.TabQMSCisAuditNormy_EXT WITH (UPDLOCK, SERIALIZABLE) SET _EXT_RS_DatPlatnostDo=@_EXT_RS_DatPlatnostDo WHERE ID = @ID;
IF @@ROWCOUNT = 0
BEGIN
  INSERT dbo.TabQMSCisAuditNormy_EXT (ID,_EXT_RS_DatPlatnostDo)
  VALUES (@ID,@_EXT_RS_DatPlatnostDo);
END
COMMIT TRANSACTION;
END

IF @kontrola1=0
BEGIN
RAISERROR ('Nic neproběhne, není zatrženo Přepsat.',16,1);
RETURN
END;
GO

