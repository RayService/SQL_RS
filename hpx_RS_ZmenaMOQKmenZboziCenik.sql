USE [RayService]
GO

/****** Object:  StoredProcedure [dbo].[hpx_RS_ZmenaMOQKmenZboziCenik]    Script Date: 26.06.2025 15:55:03 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

CREATE PROCEDURE [dbo].[hpx_RS_ZmenaMOQKmenZboziCenik] @kontrola BIT, @ID INT
AS

--3.	5.	Aktualizace pole Minimum dodavatel na kmenové kartě – spustit v kusovník-ceník dle zvoleného dodavatele a jeho MOQ z nabídky.
--MŽ: kopie pole Dokl_poptMOQ z ceníku do Minimum_Dodavatel na kmenové kartě. Kde není vyplněno poptMOQ, nic se nestane.

DECLARE @Dokl_poptMOQ NUMERIC(19,6), @IDKmen INT;
IF @kontrola=1
BEGIN
	SELECT @Dokl_poptMOQ=ISNULL(kcn.Dokl_poptMOQ,0), @IDKmen=kcn.IDNizsi
	FROM TabStrukKusovnik_kalk_cenik kcn WITH(NOLOCK)
	WHERE kcn.ID=@ID
	IF @Dokl_poptMOQ>0
	UPDATE TabKmenZbozi SET Minimum_Dodavatel=@Dokl_poptMOQ WHERE ID=@IDKmen
END;

IF @kontrola=0
BEGIN
RAISERROR('Nic neproběhne, není zatrženo Spustit.',16,1)
RETURN;
END;
GO

