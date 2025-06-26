USE [RayService]
GO

/****** Object:  StoredProcedure [dbo].[hpx_RS_ZmenaNetisknoutCastVydej]    Script Date: 26.06.2025 15:29:52 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

CREATE PROC [dbo].[hpx_RS_ZmenaNetisknoutCastVydej]
@_EXT_RS_PrintParcialIssue BIT,
@kontrola bit,
@ID INT
AS
IF @kontrola = 1
BEGIN
BEGIN TRANSACTION;
UPDATE dbo.TabPohybyZbozi_EXT WITH (UPDLOCK, SERIALIZABLE) SET _EXT_RS_PrintParcialIssue=@_EXT_RS_PrintParcialIssue WHERE ID = @ID;
IF @@ROWCOUNT = 0
BEGIN
  INSERT dbo.TabPohybyZbozi_EXT (ID,_EXT_RS_PrintParcialIssue)
  VALUES (@ID,@_EXT_RS_PrintParcialIssue);
END
COMMIT TRANSACTION;
END;

IF @kontrola = 0
BEGIN
RAISERROR ('Nic neproběhne, není zatrženo Přepsat.',16,1);
RETURN
END;
GO

