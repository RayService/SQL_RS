USE [RayService]
GO

/****** Object:  StoredProcedure [dbo].[hpx_RS_KK_ValidaceLTMOQDne]    Script Date: 30.06.2025 8:37:46 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

CREATE PROC [dbo].[hpx_RS_KK_ValidaceLTMOQDne]
@_EXT_RS_ValidateLTMOQDne DATETIME,
@kontrola BIT,
@ID INT
AS
IF @kontrola = 1
BEGIN
BEGIN TRANSACTION;
	UPDATE tkze
	SET tkze._EXT_RS_ValidateLTMOQDne=@_EXT_RS_ValidateLTMOQDne
	FROM TabPohybyZbozi tpz
	LEFT JOIN TabStavSkladu tss ON tss.ID = tpz.IDZboSklad
	LEFT JOIN TabKmenZbozi tkz ON tkz.ID = tss.IDKmenZbozi
	LEFT JOIN TabKmenZbozi_EXT tkze ON tkze.ID = tkz.ID
              WHERE tpz.ID = @ID
	IF @@ROWCOUNT = 0
	BEGIN
		INSERT INTO TabKmenZbozi_EXT (ID, _EXT_RS_ValidateLTMOQDne)
		SELECT tkz.ID, @_EXT_RS_ValidateLTMOQDne
		FROM TabPohybyZbozi tpz
		LEFT JOIN TabStavSkladu tss ON tss.ID = tpz.IDZboSklad
		LEFT JOIN TabKmenZbozi tkz ON tkz.ID = tss.IDKmenZbozi
		WHERE tpz.ID = @ID
	END
COMMIT TRANSACTION;
END;
ELSE
BEGIN
RAISERROR ('Nic neproběhne, není zatrženo Přepsat.',16,1);
RETURN
END;
GO

