USE [RayService]
GO

/****** Object:  StoredProcedure [dbo].[hpx_RS_ZmenaAktualniDodavatelKmenZboziCenik]    Script Date: 26.06.2025 15:53:11 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO


CREATE PROCEDURE [dbo].[hpx_RS_ZmenaAktualniDodavatelKmenZboziCenik] @Org BIT, @Org2 BIT, @Org3 BIT, @kontrola BIT, @ID INT
AS

--3.	Aktualizace aktuálního dodavatele na kmenové kartě – nová fce pro nastavení aktuálního dodavatele dle organizace na hlavičce dokladu, spustit nad položkami v dokladu (např VOB) i v kusovník-ceník.
--MŽ: označené položky uvnitř VOB, NAB). U kusovníku vyvolat dotaz, zda chce uživatel aktualizovat dle Organizace nebo Organizace 2 nebo Organizace 3. Nebude-li pole vyplněno, neaktualizovat.

DECLARE @Dodavatel INT, @IDKmen INT;
IF @kontrola=1 AND @Org=1
BEGIN
	SELECT @Dodavatel=kcn.OrgNabidka, @IDKmen=kcn.IDNizsi
	FROM TabStrukKusovnik_kalk_cenik kcn WITH(NOLOCK)
	WHERE kcn.ID=@ID
	IF @Dodavatel IS NOT NULL
	UPDATE TabKmenZbozi SET Aktualni_Dodavatel=@Dodavatel WHERE ID=@IDKmen
END;

IF @kontrola=1 AND @Org2=1
BEGIN
	SELECT @Dodavatel=kcn.OrgNabidka2, @IDKmen=kcn.IDNizsi
	FROM TabStrukKusovnik_kalk_cenik kcn WITH(NOLOCK)
	WHERE kcn.ID=@ID
	IF @Dodavatel IS NOT NULL
	UPDATE TabKmenZbozi SET Aktualni_Dodavatel=@Dodavatel WHERE ID=@IDKmen
END;

IF @kontrola=1 AND @Org3=1
BEGIN
	SELECT @Dodavatel=kcn.OrgNabidka3, @IDKmen=kcn.IDNizsi
	FROM TabStrukKusovnik_kalk_cenik kcn WITH(NOLOCK)
	WHERE kcn.ID=@ID
	IF @Dodavatel IS NOT NULL
	UPDATE TabKmenZbozi SET Aktualni_Dodavatel=@Dodavatel WHERE ID=@IDKmen
END;

IF @kontrola=0
BEGIN
RAISERROR('Nic neproběhne, není zatrženo Spustit.',16,1)
RETURN;
END;

IF @kontrola=1 AND ((@Org=1 AND @Org2=1)OR(@Org=1 AND @Org3=1)OR(@Org2=1 AND @Org3=1))
BEGIN
RAISERROR('Je označeno více organizací, nelze spustit.',16,1)
RETURN;
END;

IF @kontrola=1 AND @Org=0 AND @Org2=0 AND @Org3=0
BEGIN
RAISERROR('Nic neproběhne, nebyla vybrána organizace.',16,1)
RETURN;
END;
GO

