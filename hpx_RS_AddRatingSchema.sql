USE [RayService]
GO

/****** Object:  StoredProcedure [dbo].[hpx_RS_AddRatingSchema]    Script Date: 26.06.2025 14:05:53 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

CREATE PROCEDURE [dbo].[hpx_RS_AddRatingSchema] @Prepsat BIT, @IDSchema INT, @ID INT
AS

IF @Prepsat=1
BEGIN
BEGIN TRANSACTION;
UPDATE dbo.TabZamMzd_EXT WITH (UPDLOCK, SERIALIZABLE) SET _EXT_RS_IDRatingSchema=@IDSchema WHERE ID=@ID;
IF @@ROWCOUNT = 0
BEGIN
  INSERT dbo.TabZamMzd_EXT (ID,_EXT_RS_IDRatingSchema)
  SELECT @ID, @IDSchema
  FROM TabZamMzd WHERE ID=@ID;
END
COMMIT TRANSACTION;
END;
IF @Prepsat=0
BEGIN
RAISERROR('Nic neproběhne, není zatrženo Přepsat.',16,1)
RETURN
END;
GO

