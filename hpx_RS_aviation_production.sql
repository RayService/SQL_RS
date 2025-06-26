USE [RayService]
GO

/****** Object:  StoredProcedure [dbo].[hpx_RS_aviation_production]    Script Date: 26.06.2025 12:03:07 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

CREATE PROC [dbo].[hpx_RS_aviation_production]
@_EXT_RS_letecka_vyroba BIT,
@kontrola bit,
@ID INT
AS
IF @kontrola = 1
BEGIN
BEGIN TRANSACTION;
UPDATE dbo.TabKmenZbozi_EXT WITH (UPDLOCK, SERIALIZABLE) SET _EXT_RS_letecka_vyroba=@_EXT_RS_letecka_vyroba WHERE ID = @ID;
IF @@ROWCOUNT = 0
BEGIN
  INSERT dbo.TabKmenZbozi_EXT (ID,_EXT_RS_letecka_vyroba)
  VALUES (@ID,@_EXT_RS_letecka_vyroba);
END
COMMIT TRANSACTION;
END;
ELSE
BEGIN
RAISERROR ('Nic neproběhne, není zatrženo Přepsat.',16,1);
RETURN
END;
GO

