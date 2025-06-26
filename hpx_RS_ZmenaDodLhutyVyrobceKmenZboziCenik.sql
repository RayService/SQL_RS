USE [RayService]
GO

/****** Object:  StoredProcedure [dbo].[hpx_RS_ZmenaDodLhutyVyrobceKmenZboziCenik]    Script Date: 26.06.2025 15:56:20 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

CREATE PROCEDURE [dbo].[hpx_RS_ZmenaDodLhutyVyrobceKmenZboziCenik] @kontrola BIT, @ID INT
AS

--6.	Aktualizace dod. lhůty VÝROBCE na kmenové kartě, spustit nad položkami v dokladu (např VOB) i v kusovník-ceník.
--MŽ: z ceníku brát Dokl_poptLT, z položek _poptLT a nakopírovat do dod.lhůta Výrobce.
--TabKmenZbozi._EXT_RS_DodaciLhutaTydnyVyrobce

DECLARE @_EXT_RS_DodaciLhutaTydnyVyrobce INT, @IDKmen INT
IF @kontrola=1
BEGIN
	SELECT @_EXT_RS_DodaciLhutaTydnyVyrobce=ISNULL(kcn.Dokl_poptLT,0), @IDKmen=kcn.IDNizsi
	FROM TabStrukKusovnik_kalk_cenik kcn WITH(NOLOCK)
	WHERE kcn.ID=@ID
	IF @_EXT_RS_DodaciLhutaTydnyVyrobce>0
	UPDATE tkze SET tkze._EXT_RS_DodaciLhutaTydnyVyrobce=@_EXT_RS_DodaciLhutaTydnyVyrobce
	FROM TabKmenZbozi tkz WITH(NOLOCK)
	LEFT OUTER JOIN TabKmenZbozi_EXT tkze WITH(NOLOCK) ON tkze.ID=tkz.ID
	WHERE tkz.ID=@IDKmen
END;

IF @kontrola=0
BEGIN
RAISERROR('Nic neproběhne, není zatrženo Spustit.',16,1)
RETURN;
END;

GO

