USE [RayService]
GO

/****** Object:  StoredProcedure [dbo].[hpx_RS_GenerovaniDotaznikuKodexu]    Script Date: 26.06.2025 14:20:25 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

CREATE PROCEDURE [dbo].[hpx_RS_GenerovaniDotaznikuKodexu]
@Dotaznik BIT,	--zdali dodavatelský dotazník
@Kodex BIT,	--zdali kodex
@Rusko BIT,	--zdali ruské sankce
@Cina BIT, --zda-li čínské sankce
@ID INT
AS
SET NOCOUNT ON;

--MŽ, 2.6.2025, přidány sankce Číny

/*--cvičně, bude bráno z označeného řádku a parametrů ext.akce
DECLARE @CisloOrg INT
DECLARE @Dotaznik BIT
DECLARE @Kodex BIT
DECLARE @Rusko BIT,	--zdali ruské sankce
SET @Kodex=1
SET @Dotaznik=1
SET @Rusko=1
SET @CisloOrg=5*/

--ostrá deklarace
DECLARE @CisloOrg INT
DECLARE @PoradiNew NVARCHAR(4000)
DECLARE @Kategorie NVARCHAR(3)
DECLARE @NewID INT
DECLARE @Predmet NVARCHAR(255)
DECLARE @Popis NVARCHAR(MAX)
DECLARE @NazevOrg NVARCHAR(255)
DECLARE @OdpOsobaDod INT
DECLARE @Typ INT	--typ dotazníku 0=etický kodex, 1=dodavatelský dotazník, 2=ruské sankce

SET @CisloOrg=(SELECT CisloOrg FROM TabCisOrg WHERE ID=@ID)
SET @OdpOsobaDod=1117/*(SELECT tcz.Cislo		--MŽ, 27.1.2025 na přání MM změněno, aby to padalo jedné konkrétní kolegyni
				FROM TabCisZam tcz
				WHERE tcz.PrijmeniJmeno LIKE (SELECT tcoe._odpovednaOsobaOdberatel
							FROM TabCisOrg tco
							LEFT OUTER JOIN TabCisOrg_EXT tcoe ON tcoe.ID=tco.ID
							WHERE tco.CisloOrg=@CisloOrg) AND tcz.Cislo<10000
				)*/

--začneme větví s etickým kodexem
IF @Kodex=1
BEGIN
	SET @PoradiNew=NULL
	SET @NewID=NULL
	SET @Kategorie='072'
	SET @Predmet=(SELECT Popis FROM TabKategKontJed WHERE Cislo=@Kategorie)
	SET @PoradiNew=(SELECT MAX(PoradoveCislo)+(1) FROM TabKontaktJednani WHERE Kategorie=@Kategorie)
	IF @PoradiNew IS NULL
	BEGIN
	SET @PoradiNew=1
	END;
	SET @NazevOrg=(SELECT Nazev FROM TabCisOrg WHERE CisloOrg=@CisloOrg)
	SET @Popis=(@Predmet+' organizace '+@NazevOrg)
	--vložíme aktivitu
	INSERT INTO TabKontaktJednani (PoradoveCislo, Kategorie, Predmet, Typ, Stav, DruhVystupu, MistoKonani, DatumJednaniOd, DruhCU, Popis, CisloOrg)
	SELECT @PoradiNew,@Kategorie,@Predmet,N'',N'',N'',N'',GETDATE(),1,@Popis, @CisloOrg
	SET @NewID=SCOPE_IDENTITY()
	--vložíme úkol
	INSERT INTO TabUkoly (Predmet, TerminZahajeni, DatumKontroly, Stav, HotovoProcent, CelkemHod, HotovoHod, IDKontaktJed, TypStart, StavStart, DruhVystupuStart, TypKonec, StavKonec, DruhVystupuKonec, CisloOrg, Resitel)
	VALUES (N'Zaslán etický kodex',GETDATE(), GETDATE()+14, 0,0,0,0,@NewID,N'',N'',N'',N'',N'',N'', @CisloOrg, @OdpOsobaDod)

	--uložíme info o založení aktivit
	BEGIN TRANSACTION;
	UPDATE dbo.TabCisOrg_EXT WITH (UPDLOCK, SERIALIZABLE) SET _EXT_RS_GenerovatKodex=1 WHERE ID = @ID;
	IF @@ROWCOUNT = 0
	BEGIN
	  INSERT dbo.TabCisOrg_EXT (ID,_EXT_RS_GenerovatKodex)
	  VALUES (@ID,1);
	END
	COMMIT TRANSACTION;
	SET @Typ=0

--na konci přibude generování mailu
EXEC dbo.hpx_RS_GenerovaniDotaznikuKodexu_OdeslaniMailu @ID, @Typ

END;


--a nyní pokračuje větev dotazník
IF @Dotaznik=1
BEGIN
	SET @PoradiNew=NULL
	SET @NewID=NULL
	SET @Kategorie='071'
	SET @Predmet=(SELECT Popis FROM TabKategKontJed WHERE Cislo=@Kategorie)
	SET @PoradiNew=(SELECT MAX(PoradoveCislo)+(1) FROM TabKontaktJednani WHERE Kategorie=@Kategorie)
	IF @PoradiNew IS NULL
	BEGIN
	SET @PoradiNew=1
	END;
	SET @NazevOrg=(SELECT Nazev FROM TabCisOrg WHERE CisloOrg=@CisloOrg)
	SET @Popis=(@Predmet+' organizace '+@NazevOrg)
	--vložíme aktivitu
	INSERT INTO TabKontaktJednani (PoradoveCislo, Kategorie, Predmet, Typ, Stav, DruhVystupu, MistoKonani, DatumJednaniOd, DruhCU, Popis, CisloOrg)
	SELECT @PoradiNew,@Kategorie,@Predmet,N'',N'',N'',N'',GETDATE(),1,@Popis, @CisloOrg
	SET @NewID=SCOPE_IDENTITY()
	--vložíme úkol
	INSERT INTO TabUkoly (Predmet, TerminZahajeni, Stav, HotovoProcent, CelkemHod, HotovoHod, IDKontaktJed, TypStart, StavStart, DruhVystupuStart, TypKonec, StavKonec, DruhVystupuKonec, CisloOrg, Resitel)
	VALUES (N'Zaslán dodavatelský dotazník',GETDATE(),0,0,0,0,@NewID,N'',N'',N'',N'',N'',N'', @CisloOrg, @OdpOsobaDod)

	--uložíme info o založení aktivit
	BEGIN TRANSACTION;
	UPDATE dbo.TabCisOrg_EXT WITH (UPDLOCK, SERIALIZABLE) SET _EXT_RS_GenerovanDotaznikDodavatele=1 WHERE ID = @ID;
	IF @@ROWCOUNT = 0
	BEGIN
	  INSERT dbo.TabCisOrg_EXT (ID,_EXT_RS_GenerovanDotaznikDodavatele)
	  VALUES (@ID,1);
	END
	COMMIT TRANSACTION;
	SET @Typ=1

	--na konci přibude generování mailu
EXEC dbo.hpx_RS_GenerovaniDotaznikuKodexu_OdeslaniMailu @ID, @Typ

END;


--a nyní pokračuje větev ruské sankce
IF @Rusko=1
	BEGIN
	SET @PoradiNew=NULL
	SET @NewID=NULL
	SET @Kategorie='073'
	SET @Predmet=(SELECT Popis FROM TabKategKontJed WHERE Cislo=@Kategorie)
	SET @PoradiNew=(SELECT MAX(PoradoveCislo)+(1) FROM TabKontaktJednani WHERE Kategorie=@Kategorie)
	IF @PoradiNew IS NULL
	BEGIN
	SET @PoradiNew=1
	END;
	SET @NazevOrg=(SELECT Nazev FROM TabCisOrg WHERE CisloOrg=@CisloOrg)
	SET @Popis=(@Predmet+' organizace '+@NazevOrg)
	--vložíme aktivitu
	INSERT INTO TabKontaktJednani (PoradoveCislo, Kategorie, Predmet, Typ, Stav, DruhVystupu, MistoKonani, DatumJednaniOd, DruhCU, Popis, CisloOrg)
	SELECT @PoradiNew,@Kategorie,@Predmet,N'',N'',N'',N'',GETDATE(),1,@Popis, @CisloOrg
	SET @NewID=SCOPE_IDENTITY()
	--vložíme úkol
	INSERT INTO TabUkoly (Predmet, TerminZahajeni, Stav, HotovoProcent, CelkemHod, HotovoHod, IDKontaktJed, TypStart, StavStart, DruhVystupuStart, TypKonec, StavKonec, DruhVystupuKonec, CisloOrg, Resitel)
	VALUES (N'Zaslána sankce Rusku',GETDATE(),0,0,0,0,@NewID,N'',N'',N'',N'',N'',N'', @CisloOrg, @OdpOsobaDod)

	--uložíme info o založení aktivit
	BEGIN TRANSACTION;
	UPDATE dbo.TabCisOrg_EXT WITH (UPDLOCK, SERIALIZABLE) SET _EXT_RS_GenerovanySankceRusko=1 WHERE ID = @ID;
	IF @@ROWCOUNT = 0
	BEGIN
	  INSERT dbo.TabCisOrg_EXT (ID,_EXT_RS_GenerovanySankceRusko)
	  VALUES (@ID,1);
	END
	COMMIT TRANSACTION;
	SET @Typ=2

--na konci přibude generování mailu
EXEC dbo.hpx_RS_GenerovaniDotaznikuKodexu_OdeslaniMailu @ID, @Typ

END;

--MŽ, 2.6.2025, přidány čínské sankce
--a nyní pokračuje větev čínské sankce
IF @Cina=1
	BEGIN
	SET @PoradiNew=NULL
	SET @NewID=NULL
	SET @Kategorie='074'
	SET @Predmet=(SELECT Popis FROM TabKategKontJed WHERE Cislo=@Kategorie)
	SET @PoradiNew=(SELECT MAX(PoradoveCislo)+(1) FROM TabKontaktJednani WHERE Kategorie=@Kategorie)
	IF @PoradiNew IS NULL
	BEGIN
	SET @PoradiNew=1
	END;
	SET @NazevOrg=(SELECT Nazev FROM TabCisOrg WHERE CisloOrg=@CisloOrg)
	SET @Popis=(@Predmet+' organizace '+@NazevOrg)
	--vložíme aktivitu
	INSERT INTO TabKontaktJednani (PoradoveCislo, Kategorie, Predmet, Typ, Stav, DruhVystupu, MistoKonani, DatumJednaniOd, DruhCU, Popis, CisloOrg)
	SELECT @PoradiNew,@Kategorie,@Predmet,N'',N'',N'',N'',GETDATE(),1,@Popis, @CisloOrg
	SET @NewID=SCOPE_IDENTITY()
	--vložíme úkol
	--úkol nevkládáme, není potřeba
	--INSERT INTO TabUkoly (Predmet, TerminZahajeni, Stav, HotovoProcent, CelkemHod, HotovoHod, IDKontaktJed, TypStart, StavStart, DruhVystupuStart, TypKonec, StavKonec, DruhVystupuKonec, CisloOrg, Resitel)
	--VALUES (N'Zaslána sankce Rusku',GETDATE(),0,0,0,0,@NewID,N'',N'',N'',N'',N'',N'', @CisloOrg, @OdpOsobaDod)

	--uložíme info o založení aktivit
	BEGIN TRANSACTION;
	UPDATE dbo.TabCisOrg_EXT WITH (UPDLOCK, SERIALIZABLE) SET _EXT_RS_GenerovanySankceCina=1 WHERE ID = @ID;
	IF @@ROWCOUNT = 0
	BEGIN
	  INSERT dbo.TabCisOrg_EXT (ID,_EXT_RS_GenerovanySankceCina)
	  VALUES (@ID,1);
	END
	COMMIT TRANSACTION;
	SET @Typ=3


--na konci přibude generování mailu
EXEC dbo.hpx_RS_GenerovaniDotaznikuKodexu_OdeslaniMailu @ID, @Typ

END;


GO

