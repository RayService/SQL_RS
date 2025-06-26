USE [RayService]
GO

/****** Object:  StoredProcedure [dbo].[hpx_RS_ZmenaAktualniDodavatelKmenZbozi]    Script Date: 26.06.2025 15:52:42 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO


CREATE PROCEDURE [dbo].[hpx_RS_ZmenaAktualniDodavatelKmenZbozi] @kontrola BIT, @ID INT
AS

--3.	Aktualizace aktuálního dodavatele na kmenové kartě – nová fce pro nastavení aktuálního dodavatele dle organizace na hlavičce dokladu, spustit nad položkami v dokladu (např VOB) i v kusovník-ceník.
--MŽ: označené položky uvnitř VOB, NAB). U kusovníku vyvolat dotaz, zda chce uživatel aktualizovat dle Organizace nebo Organizace 2 nebo Organizace 3. Nebude-li pole vyplněno, neaktualizovat.

--TabKmenZbozi.Aktualni_Dodavatel
--TabCisOrg(CisloOrg)
DECLARE @Dodavatel INT;
IF @kontrola=1
BEGIN
	SET @Dodavatel=(SELECT tdz.CisloOrg
	FROM TabPohybyZbozi tpz WITH(NOLOCK)
	LEFT OUTER JOIN TabDokladyZbozi tdz WITH(NOLOCK) ON tdz.ID=tpz.IDDoklad
	WHERE (tpz.ID=@ID))
	IF @Dodavatel IS NOT NULL
	UPDATE tkz SET tkz.Aktualni_Dodavatel=@Dodavatel
	FROM TabPohybyZbozi tpz WITH(NOLOCK)
	LEFT OUTER JOIN TabKmenZbozi tkz WITH(NOLOCK) ON tkz.ID=(SELECT TabStavSkladu.IDKmenZbozi FROM TabStavSkladu WHERE TabStavSkladu.ID=tpz.IDZboSklad)
	WHERE
	(tpz.ID=@ID)
END;
ELSE
BEGIN
RAISERROR('Nic neproběhne, není zatrženo Spustit.',16,1)
RETURN;
END;

GO

