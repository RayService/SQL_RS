USE [RayService]
GO

/****** Object:  StoredProcedure [dbo].[hpx_RS_ZmenaDodLhutyVyrobceKmenZbozi]    Script Date: 26.06.2025 15:55:43 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

CREATE PROCEDURE [dbo].[hpx_RS_ZmenaDodLhutyVyrobceKmenZbozi] @kontrola BIT, @ID INT
AS

--6.	Aktualizace dod. lhůty VÝROBCE na kmenové kartě, spustit nad položkami v dokladu (např VOB) i v kusovník-ceník.
--MŽ: z ceníku brát Dokl_poptLT, z položek _poptLT a nakopírovat do dod.lhůta Výrobce.
--TabKmenZbozi._EXT_RS_DodaciLhutaTydnyVyrobce

DECLARE @_EXT_RS_DodaciLhutaTydnyVyrobce INT;
IF @kontrola=1
BEGIN
	SET @_EXT_RS_DodaciLhutaTydnyVyrobce=(SELECT ISNULL(tpze._poptLT,0)
	FROM TabPohybyZbozi tpz WITH(NOLOCK)
	LEFT OUTER JOIN TabPohybyZbozi_EXT tpze WITH(NOLOCK) ON tpze.ID=tpz.ID
	WHERE (tpz.ID=@ID))
	IF @_EXT_RS_DodaciLhutaTydnyVyrobce>0
	UPDATE tkze SET tkze._EXT_RS_DodaciLhutaTydnyVyrobce=@_EXT_RS_DodaciLhutaTydnyVyrobce
	FROM TabPohybyZbozi tpz WITH(NOLOCK)
	LEFT OUTER JOIN TabKmenZbozi tkz WITH(NOLOCK) ON tkz.ID=(SELECT TabStavSkladu.IDKmenZbozi FROM TabStavSkladu WHERE TabStavSkladu.ID=tpz.IDZboSklad)
	LEFT OUTER JOIN TabKmenZbozi_EXT tkze WITH(NOLOCK) ON tkze.ID=tkz.ID
	WHERE	(tpz.ID=@ID)
END;
ELSE
BEGIN
RAISERROR('Nic neproběhne, není zatrženo Spustit.',16,1)
RETURN;
END;

GO

