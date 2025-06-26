USE [RayService]
GO

/****** Object:  StoredProcedure [dbo].[hpx_RS_SimplifiedEnterControl]    Script Date: 26.06.2025 13:58:54 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

CREATE PROCEDURE [dbo].[hpx_RS_SimplifiedEnterControl] @ID INT AS
--akce na označení řádků pro zjednodušenou kontrolu
--akce probíhá na označených řádcích v příjemce
--změna doby z 366 dní na 183 dní (půl roku)

--DECLARE @ID INT=5306805;--ID řádků
DECLARE @IDPrij INT;
DECLARE @CisloOrg INT;
DECLARE @StavDod NVARCHAR(15);
DECLARE @PocetPrij INT;
DECLARE @PocetPolPrij INT;
DECLARE @PocetRekl INT;
DECLARE @PocetPolRekl INT;
DECLARE @PPM INT;
DECLARE @KatVD NVARCHAR(54);
DECLARE @SpecVstup BIT;
DECLARE @IDPol INT;
DECLARE @Cena NUMERIC(19,6);

SET @IDPrij=(SELECT TOP 1 tpz.IDDOklad FROM TabPohybyZbozi tpz WHERE tpz.ID=@ID)
SET @CisloOrg=(SELECT tdz.CisloOrg FROM TabDokladyZbozi tdz WHERE tdz.ID=@IDPrij)
SELECT @IDPrij,@CisloOrg
SET @PocetRekl=(SELECT COUNT(tdz.ID) AS Poc_rekl FROM TabDokladyZbozi tdz WITH(NOLOCK)
LEFT OUTER JOIN TabcisOrg tco WITH(NOLOCK) ON tco.CisloOrg=tdz.CisloOrg
WHERE ((tdz.PoradoveCislo>=0)AND(tdz.CisloOrg=@CisloOrg)AND(tdz.RadaDokladu LIKE N'%925%')AND(tdz.DruhPohybuZbo=11))AND(tdz.DatPorizeni>=GETDATE()-183)AND(tdz.IDSklad=N'100'))
SET @PocetPolRekl=(SELECT COUNT(tpz.ID) AS Poc_pol_rekl FROM TabDokladyZbozi tdz WITH(NOLOCK)
LEFT OUTER JOIN TabcisOrg tco WITH(NOLOCK) ON tco.CisloOrg=tdz.CisloOrg
LEFT OUTER JOIN TabPohybyZbozi tpz WITH(NOLOCK) ON tpz.IDDoklad=tdz.ID
WHERE ((tdz.PoradoveCislo>=0)AND(tdz.CisloOrg=@CisloOrg)AND(tdz.RadaDokladu LIKE N'%925%')AND(tdz.DruhPohybuZbo=11))AND(tdz.DatPorizeni>=GETDATE()-183)AND(tdz.IDSklad=N'100'))
SET @PocetPrij=(SELECT COUNT(tdz.ID) AS Poc_prij FROM TabDokladyZbozi tdz WITH(NOLOCK)
LEFT OUTER JOIN TabcisOrg tco WITH(NOLOCK) ON tco.CisloOrg=tdz.CisloOrg
WHERE (tdz.PoradoveCislo>=0)AND(tdz.CisloOrg=@CisloOrg)AND(tdz.DruhPohybuZbo=0)AND(tdz.DatPorizeni>=GETDATE()-183)AND(tdz.Realizovano=1)AND(tdz.IDSklad=N'100'))
SET @PocetPolPrij=(SELECT COUNT(tpz.ID) AS Poc_pol_prij FROM TabDokladyZbozi tdz WITH(NOLOCK)
LEFT OUTER JOIN TabcisOrg tco WITH(NOLOCK) ON tco.CisloOrg=tdz.CisloOrg
LEFT OUTER JOIN TabPohybyZbozi tpz WITH(NOLOCK) ON tpz.IDDoklad=tdz.ID
WHERE (tdz.PoradoveCislo>=0)AND(tdz.CisloOrg=@CisloOrg)AND(tdz.DruhPohybuZbo=0)AND(tdz.DatPorizeni>=GETDATE()-183)AND(tdz.Realizovano=1)AND(tdz.IDSklad=N'100'))
IF CONVERT(NUMERIC(19,2),@PocetPolPrij)<=0
		BEGIN
			RAISERROR('Nelze provést zjednodušenou vstupní kontrolu, počet položek příjemek je <= 0.',16,1);
			--RETURN;
		END;

SET @PPM=(CONVERT(NUMERIC(19,2),@PocetPolRekl)/CONVERT(NUMERIC(19,2),@PocetPolPrij)*1000000)
SET @StavDod=(SELECT tcoe._stav_dodavatele FROM  TabcisOrg tco WITH(NOLOCK)
LEFT OUTER JOIN TabCisOrg_EXT tcoe WITH(NOLOCK) ON tcoe.ID=tco.ID WHERE tco.CisloOrg=@CisloOrg)

IF (SELECT tdz.Realizovano FROM TabDokladyZbozi tdz WITH (NOLOCK) WHERE tdz.ID=@IDPrij)=1
BEGIN
	RAISERROR('Chyba, nelze provádět ve zrealizované příjemce.',16,1);
	RETURN;
END;
--nejprve zapíšeme PPM = -1, abychom logovali, že k výpočtu vůbec došlo
BEGIN
	IF (SELECT tcoe.ID  FROM TabcisOrg_EXT as tcoe
		LEFT OUTER JOIN TabCisOrg tco WITH(NOLOCK) ON tco.ID=tcoe.ID
		WHERE tco.CisloOrg = @CisloOrg) IS NULL
	BEGIN
	INSERT INTO TabcisOrg_EXT (ID,_EXT_PPMsupplier)
	SELECT tcoe.ID,-1
	FROM TabcisOrg_EXT as tcoe
	LEFT OUTER JOIN TabCisOrg tco WITH(NOLOCK) ON tco.ID=tcoe.ID
	WHERE tco.CisloOrg = @CisloOrg
	END
	ELSE
	BEGIN
	UPDATE TabcisOrg_EXT SET _EXT_PPMsupplier = -1
	FROM TabcisOrg_EXT as tcoe
	LEFT OUTER JOIN TabCisOrg tco WITH(NOLOCK) ON tco.ID=tcoe.ID
	WHERE tco.CisloOrg = @CisloOrg
	END
END

--nejprve uložíme PPM, je-li nenulové
IF @PPM >= 0
BEGIN
	IF (SELECT tcoe.ID  FROM TabcisOrg_EXT as tcoe
		LEFT OUTER JOIN TabCisOrg tco WITH(NOLOCK) ON tco.ID=tcoe.ID
		WHERE tco.CisloOrg = @CisloOrg) IS NULL
	BEGIN
	INSERT INTO TabcisOrg_EXT (ID,_EXT_PPMsupplier)
	SELECT tcoe.ID,@PPM
	FROM TabcisOrg_EXT as tcoe
	LEFT OUTER JOIN TabCisOrg tco WITH(NOLOCK) ON tco.ID=tcoe.ID
	WHERE tco.CisloOrg = @CisloOrg
	END
	ELSE
	BEGIN
	UPDATE TabcisOrg_EXT SET _EXT_PPMsupplier = @PPM
	FROM TabcisOrg_EXT as tcoe
	LEFT OUTER JOIN TabCisOrg tco WITH(NOLOCK) ON tco.ID=tcoe.ID
	WHERE tco.CisloOrg = @CisloOrg
	END
END

--uložení označených řádků a spuštění až nad posledním
DECLARE @Oznacenych SMALLINT, @Aktualni SMALLINT
-- Počet řádků a aktuálně zpracovávaný řádek načteme do proměnných
SELECT @Oznacenych = Cislo FROM #TabExtKomPar WHERE Popis = 'CELKEM'
SELECT @Aktualni = MAX(Cislo) FROM #TabExtKomPar WHERE Popis = 'PRECHOD'
-- Smažeme při prvním průchodu možná existující původní vybrané záznamy
IF @Aktualni = 1 OR (@Aktualni IS NULL AND @Oznacenych IS NULL)
DELETE FROM OznaceneRadky WHERE Ident = @@SPID
-- Při každém průchodu vložíme do tabulky pro označené řádky potřebné atributy
INSERT INTO OznaceneRadky(ID,Ident) VALUES(@ID,@@SPID)
-- Samotné tělo procedury při průchodu posledním záznamem
IF @Aktualni = @Oznacenych OR (@Aktualni IS NULL AND @Oznacenych IS NULL)
BEGIN
	--SELECT @PocetRekl AS Poc_rekl,@PocetPolRekl AS Poc_pol_rekl,@PocetPrij AS Poc_prij,@PocetPolPrij AS Poc_pol_prij, @PPM AS PPM
	IF (/*@PocetPrij<=8 OR */@PocetPolPrij<12 OR (@StavDod IS NULL OR @StavDod <> N'Schválený')/* OR @PPM >= 15000*/)
		BEGIN
			RAISERROR('Nelze provést zjednodušenou vstupní kontrolu, organizace nesplňuje podmínky.',16,1);
			--RETURN;
		END;

	IF (/*@PocetPrij>8 AND */@PocetPolPrij>=12 AND @StavDod=N'Schválený'/* AND @PPM<15000*/)

	BEGIN
	--začneme kurzorem nad položkami
	DECLARE CurRealDokl CURSOR LOCAL FAST_FORWARD FOR
	SELECT oznr.ID,tpz.JCbezDaniKC,tsor.KatAllTecky,tkze._spec_vstup_kontr
	FROM OznaceneRadky oznr WITH (NOLOCK)
	LEFT OUTER JOIN TabPohybyZbozi tpz WITH (NOLOCK) ON tpz.ID=oznr.ID
	LEFT OUTER JOIN TabSortiment tsor ON tpz.IDZboSklad IN (SELECT ss.ID FROM TabStavSkladu AS ss WHERE ss.IDKmenZbozi IN (SELECT kz.ID FROM TabKmenZbozi kz WHERE kz.IdSortiment=tsor.ID))
	LEFT OUTER JOIN TabKmenZbozi tkz ON tkz.ID=(SELECT TabStavSkladu.IDKmenZbozi FROM TabStavSkladu WHERE TabStavSkladu.ID=tpz.IDZboSklad)
	LEFT OUTER JOIN TabKmenZbozi_EXT tkze ON tkze.ID=tkz.ID
	WHERE((tsor.KatAllTecky<>N'vd')OR(tsor.KatAllTecky IS NULL))AND(ISNULL(tkze._spec_vstup_kontr,0)=0)AND(tpz.IDDoklad=@IDPrij)
	OPEN CurRealDokl;
	FETCH NEXT FROM CurRealDokl INTO 
		@IDPol,@Cena,@KatVD,@SpecVstup;
	WHILE (@@FETCH_STATUS = 0) AND (@@ERROR = 0)
	BEGIN
		--tělo kurzoru
		IF @Cena<1000.00
			BEGIN
			SELECT @Cena=@Cena,@KatVD=@KatVD,@SpecVstup=@SpecVstup
			FROM TabPohybyZbozi tpzcur
			WHERE tpzcur.ID=@IDPol

			IF (SELECT tpze.ID  FROM TabPohybyZbozi_EXT as tpze WHERE tpze.ID = @IDPol) IS NULL
			BEGIN 
			INSERT INTO TabPohybyZbozi_EXT (ID,_EXT_RS_SimplifiedEnterControl)
			VALUES (@ID,1)
			END
			ELSE
			UPDATE TabPohybyZbozi_EXT SET _EXT_RS_SimplifiedEnterControl = 1 WHERE ID = @IDPol
			END

		FETCH NEXT FROM CurRealDokl INTO @IDPol,@Cena,@KatVD,@SpecVstup;
		END;
	CLOSE CurRealDokl;
	DEALLOCATE CurRealDokl;
	END;

END;--konec pro označené řádky
GO

