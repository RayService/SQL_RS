USE [RayService]
GO

/****** Object:  StoredProcedure [dbo].[hpx_RS_ImportTC]    Script Date: 30.06.2025 8:28:22 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

CREATE PROCEDURE [dbo].[hpx_RS_ImportTC]
AS
SET NOCOUNT ON;

EXECUTE AS  USER='zufan'

DECLARE @IDzmenyOd INT;
DECLARE @IDzmenyDo INT;
DECLARE @IDzmeny INT;
DECLARE @IDPolozka INT;
DECLARE @SKV NVARCHAR(3);
DECLARE @RCV NVARCHAR(30);
DECLARE @Nazev1V NVARCHAR(100);
DECLARE @SKN NVARCHAR(3);
DECLARE @RCN NVARCHAR(30);
DECLARE @Nazev1N NVARCHAR(100);
DECLARE @UserName NVARCHAR(128);

DECLARE @IDDilce INT;
DECLARE @IDDilceV INT;
DECLARE @IDDilceN INT;
DECLARE @IDmaterial INT;
DECLARE @Mnozstvi NUMERIC(19,6);
DECLARE @Pozice NVARCHAR(100);
DECLARE @IDDavkaV INT;
DECLARE @IDDavkaN INT;
DECLARE @NewIDV INT;
DECLARE @NewIDN INT;
DECLARE @ID1 INT;
--deklarace kvůli parametrům změny
DECLARE @_CisloVykresuRSN NVARCHAR(100);
DECLARE @_IndexVykresuRSN NVARCHAR(100);
DECLARE @_CisloVykresuZakN NVARCHAR(100);
DECLARE @_IndexVykresuZakN NVARCHAR(100);
DECLARE @_CisloVykresuRSV NVARCHAR(100);
DECLARE @_IndexVykresuRSV NVARCHAR(100);
DECLARE @_CisloVykresuZakV NVARCHAR(100);
DECLARE @_IndexVykresuZakV NVARCHAR(100);
--deklarace kvůli dokumentům
DECLARE @IDdoc INT;
DECLARE @IDpripona NVARCHAR(5);
DECLARE @IDkat INT;
DECLARE @IDDokum INT;
DECLARE @IDDilceDokum NVARCHAR(30);
DECLARE @RadaDo NVARCHAR(10);
DECLARE @ZmenaDo NVARCHAR(15);

SELECT @UserName=SUSER_SNAME();

--přípravné tabulky

--import do kusovníků
IF OBJECT_ID('tempdb..#temptable') IS NOT NULL DROP TABLE #temptable
SELECT bom.* INTO #temptable
FROM tc2helios..transfer_bom bom
WHERE ISNULL(bom.Prevedeno,0)=0
ORDER BY bom.ID ASC

--import dokumentů
IF OBJECT_ID('tempdb..#temptabledoc') IS NOT NULL DROP TABLE #temptabledoc
SELECT doc.* INTO #temptabledoc
FROM tc2helios..transfer_dokum doc
WHERE ISNULL(doc.Prevedeno,0)=0
ORDER BY doc.ID ASC

--SELECT *
--FROM #temptable

--SELECT *
--FROM #temptabledoc

DECLARE @IDStartZmena INT, @IDEndZmena INT
SELECT @IDStartZmena=MIN(ID), @IDEndZmena=MAX(ID)
FROM #temptable
WHILE @IDStartZmena<=@IDEndZmena
BEGIN
--založení změny
	--ZmenaDo
	IF (SELECT tc.ID FROM HCvicna..TabCzmeny tc LEFT OUTER JOIN #temptable tc2h ON tc.Rada = tc2h.RadaDo AND tc.ciszmeny = tc2h.ZmenaDo WHERE tc2h.ID = @IDStartZmena) IS NULL
		BEGIN
		INSERT INTO HCvicna..TabCzmeny (Rada, ciszmeny, navrh, os_cislo, datum, DatPorizeni, Autor,PermanentniZmena,Running,IntPermanentniZmena)
		SELECT bom.RadaDo,bom.ZmenaDo,bom.PoznamkaZmena,tcz.ID,CONVERT(DATETIME,CONVERT(DATE,GETDATE()/*bom.datum*/)), GETDATE(),@UserName/*bom.Autor*/,0,0,0
		FROM #temptable bom
		LEFT OUTER JOIN HCvicna..TabCisZam tcz ON tcz.loginId = bom.osoba
		WHERE bom.ID = @IDStartZmena
		END
	--ZmenaOd
	IF ((SELECT tc2h.RadaOd FROM #temptable tc2h WHERE tc2h.ID = @IDStartZmena) IS NOT NULL AND
		(SELECT tc.ID FROM HCvicna..TabCzmeny tc LEFT OUTER JOIN #temptable tc2h ON tc.Rada = tc2h.RadaOd AND tc.ciszmeny = tc2h.ZmenaOd WHERE tc2h.ID = @IDStartZmena) IS NULL)
		BEGIN
		INSERT INTO HCvicna..TabCzmeny (Rada, ciszmeny, navrh, os_cislo, datum, DatPorizeni, Autor,PermanentniZmena,Running,IntPermanentniZmena)
		SELECT bom.RadaOd,bom.ZmenaOd,bom.PoznamkaZmena,tcz.ID,CONVERT(DATETIME,CONVERT(DATE,GETDATE()/*bom.datum*/)), GETDATE(),@UserName/*bom.Autor*/,0,0,0
		FROM #temptable bom
		LEFT OUTER JOIN HCvicna..TabCisZam tcz ON tcz.loginId = bom.osoba
		WHERE bom.ID = @IDStartZmena
		END

--použijeme založenou změnu a pokračujeme
BEGIN
	SET @IDzmenyOd=(SELECT tc.ID
				FROM HCvicna..TabCzmeny tc
				LEFT OUTER JOIN #temptable tc2h ON tc.Rada = tc2h.RadaOd AND tc.ciszmeny = tc2h.ZmenaOd
				WHERE tc2h.ID = @IDStartZmena)
	SET @IDzmenyDo=(SELECT tc.ID
				FROM HCvicna..TabCzmeny tc
				LEFT OUTER JOIN #temptable tc2h ON tc.Rada = tc2h.RadaDo AND tc.ciszmeny = tc2h.ZmenaDo
				WHERE tc2h.ID = @IDStartZmena)
	SET @IDzmeny=ISNULL(@IDzmenyDo, @IDzmenyOd)

--kontrolní select
--SELECT @IDzmenyOd AS IDZmenyOd, @IDzmenyDo AS IDZmenyDo, @IDzmeny AS IDZmeny

	--vyhledáme karty zboží dle nizsi a vyssi, pokud položka neexistuje, zakládáme
	--vyšší
	SET @SKV=NULL
	SET @RCV=NULL
	SET @IDDavkaN=NULL
	SET @IDDavkaV=NULL
	SELECT @SKV=vyssi_SK, @RCV=vyssi_RC--, @Nazev1V=Nazev1
	FROM #temptable tc2h
	WHERE tc2h.ID = @IDStartZmena
	SET @IDDilceV=(SELECT tkz.ID
					FROM HCvicna..TabKmenZbozi tkz
					LEFT OUTER JOIN #temptable tc2h ON tc2h.vyssi_SK = tkz.SkupZbo AND tc2h.vyssi_RC = tkz.RegCis
					WHERE tc2h.ID = @IDStartZmena)

	--vyšší  zakládáme s názvem První import  a následně updatujeme název 1
	IF @IDDilceV IS NULL AND @SKV IS NOT NULL AND @RCV IS NOT NULL
	BEGIN
		EXEC @NewIDV=HCvicna..hp_VytvorPolozkuKmeneZbozi @SZ=@SKV, @RegCis=@RCV, @Nazev1='První import', @MJEv='ks', @Dilec=1
		SET @IDDilceV=@NewIDV
	END
	
	--nizsi
	SELECT @SKN=nizsi_SK, @RCN=nizsi_RC, @Nazev1N=Nazev1
	FROM #temptable tc2h
	WHERE tc2h.ID = @IDStartZmena
	SET @IDDilceN=(SELECT tkz.ID
					FROM HCvicna..TabKmenZbozi tkz
					LEFT OUTER JOIN #temptable tc2h ON tc2h.nizsi_SK = tkz.SkupZbo AND tc2h.nizsi_RC = tkz.RegCis
					WHERE tc2h.ID = @IDStartZmena)
	IF @IDDilceN IS NULL AND @SKN IS NOT NULL AND @RCN IS NOT NULL
	BEGIN
		EXEC @NewIDN=HCvicna..hp_VytvorPolozkuKmeneZbozi @SZ=@SKN, @RegCis=@RCN, @Nazev1=@Nazev1N, @MJEv='ks', @Dilec=1
		SET @IDDilceN=@NewIDN
	END
	ELSE
	BEGIN
	UPDATE HCvicna..TabKmenZbozi SET Nazev1=@Nazev1N WHERE ID=@IDDilceN
	END;

	SET @Mnozstvi=(SELECT ISNULL(tc2h.mnozstvi,1)
					FROM #temptable tc2h
					WHERE tc2h.ID = @IDStartZmena)
	--SET @Pozice=(SELECT '     '+ISNULL(MAX(CASE WHEN ISNUMERIC(LTRIM(RTRIM(Pozice))+N'.E0')=1 AND LEN(LTRIM(Pozice))<=9 THEN CONVERT(int, CONVERT(numeric(19,6), Pozice)) END),0) + 1 
	--				FROM HCvicna..TabKVazby
	--				WHERE ISNUMERIC(LTRIM(RTRIM(Pozice))+N'.E0')=1 AND LEN(LTRIM(Pozice))<=9  AND Vyssi=@IDDilceV AND (IDVarianta IS NULL OR IDVarianta=0) AND ZmenaOd=@IDzmenyOd)

	SET @IDDilce=(SELECT ISNULL(@IDDilceV,@IDDilceN))
	
	--zkusíme pokaždé nahodit zdvojení. Může být jak nižší, tak i vyšší. Bez kontroly existence rozprac.změny, toto si procedura zajistí sama.
	IF @IDDilceN IS NOT NULL
		BEGIN
		EXEC HCvicna.dbo.hp_ZdvojeniKonstrukceATech @IDDilceN/*id vyssi*/, @IDzmeny/*id zmena*/, 1
		--teď doplníme indexy a čísla výkresů
		SET @IDDavkaN=(SELECT ID
						FROM HCvicna.dbo.TabDavka
						WHERE IDDilce=@IDDilceN AND zmenaOd=@IDzmeny AND zmenaDo IS NULL)
		END;

	IF @IDDilceV IS NOT NULL
		BEGIN
		EXEC HCvicna.dbo.hp_ZdvojeniKonstrukceATech @IDDilceV/*id vyssi*/, @IDzmeny/*id zmena*/, 1
		--teď doplníme indexy a čísla výkresů
		SET @IDDavkaV=(SELECT ID
						FROM HCvicna.dbo.TabDavka
						WHERE IDDilce=@IDDilceV AND zmenaOd=@IDzmeny AND zmenaDo IS NULL)
		END;
	--tady zjistíme rozdíl revize na nižším dílci a pokud je revize stejná, jako již máme v db, neimportujeme
	DECLARE @IndexOld NVARCHAR(15), @IndexNew VARCHAR(2), @IndexNewN VARCHAR(2)
		SET @IndexOld=ISNULL((SELECT TOP 1 td.IndexZmeny1
		FROM HCvicna..TabDavka td
		LEFT OUTER JOIN HCvicna.dbo.TabCzmeny tczOd ON tczOd.ID=td.ZmenaOd
		LEFT OUTER JOIN HCvicna.dbo.TabCzmeny tczDo ON tczDo.ID=td.ZmenaDo
		WHERE
		(((td.IDDilce=@IDDilceV ))AND((tczOd.platnostTPV=1 AND tczOd.datum<=GETDATE()))AND(((tczDo.platnostTPV=0 OR td.ZmenaDo IS NULL OR (tczDo.platnostTPV=1 AND tczDo.datum>GETDATE())) )))
		ORDER BY td.ID DESC),'XX')
		SET @IndexNew=(SELECT ISNULL(vyssi_rev,'XX') FROM #temptable WHERE ID=@IDStartZmena)
		SET @IndexNewN=(SELECT ISNULL(nizsi_rev,'XX') FROM #temptable WHERE ID=@IDStartZmena)

--kontrolní select
--SELECT @IDDilceN AS IDDilceN, @IDDilceV AS IDDilceV, @IDDavkaN AS IDDavkaN, @IDDavkaV AS IDDavkaV, @IDzmenyDo AS IDZmenyDo, @IDzmenyOd AS IDZmenyOd, @IDzmeny AS IDzmeny, @IndexOld AS IndexOld, @IndexNew AS Index_Vyssi_rev, @IndexNewN AS Index_Nizsi_rev

	--tady můžeme zapsat Parametry změny
	IF @IDDavkaV IS NOT NULL
		BEGIN
			SELECT @_CisloVykresuRSV=tc2h.vyssi_SK+'-'+tc2h.vyssi_RC, @_IndexVykresuRSV= tc2h.vyssi_rev, @_CisloVykresuZakV= 'N/A', @_IndexVykresuZakV= 'N/A'
			FROM #temptable tc2h
			WHERE tc2h.ID=@IDStartZmena
			
			UPDATE HCvicna.dbo.TabDavka SET IndexZmeny1=@IndexNew WHERE ID=@IDDavkaV
		
			IF (SELECT tde.ID  FROM HCvicna..TabDavka_EXT tde WHERE tde.ID=@IDDavkaV) IS NULL
				BEGIN
				INSERT INTO HCvicna.dbo.TabDavka_EXT (ID,_CisloVykresuRS, _IndexVykresuRS, _CisloVykresuZak, _IndexVykresuZak)
				VALUES (@IDDavkaV,@_CisloVykresuRSV, @_IndexVykresuRSV, @_CisloVykresuZakV, @_IndexVykresuZakV)
				END
				ELSE
				UPDATE HCvicna.dbo.TabDavka_EXT SET _CisloVykresuRS=@_CisloVykresuRSV, _IndexVykresuRS=@_IndexVykresuRSV, _CisloVykresuZak=@_CisloVykresuZakV, _IndexVykresuZak=@_IndexVykresuZakV WHERE ID=@IDDavkaV
		END
	IF @IDDavkaN IS NOT NULL
		BEGIN
			SELECT @_CisloVykresuRSn=tc2h.nizsi_SK+'-'+tc2h.nizsi_RC, @_IndexVykresuRSN= tc2h.nizsi_rev, @_CisloVykresuZakN= 'N/A', @_IndexVykresuZakN= 'N/A'
			FROM #temptable tc2h
			WHERE tc2h.ID=@IDStartZmena
			
			UPDATE HCvicna.dbo.TabDavka SET IndexZmeny1=@IndexNewN WHERE ID=@IDDavkaN

			IF (SELECT tde.ID  FROM HCvicna.dbo.TabDavka_EXT tde WHERE tde.ID=@IDDavkaN) IS NULL
				BEGIN
				INSERT INTO HCvicna.dbo.TabDavka_EXT (ID,_CisloVykresuRS, _IndexVykresuRS, _CisloVykresuZak, _IndexVykresuZak)
				VALUES (@IDDavkaN,@_CisloVykresuRSN, @_IndexVykresuRSN, @_CisloVykresuZakN, @_IndexVykresuZakN)
				END
				ELSE
				UPDATE HCvicna.dbo.TabDavka_EXT SET _CisloVykresuRS=@_CisloVykresuRSN, _IndexVykresuRS=@_IndexVykresuRSN, _CisloVykresuZak=@_CisloVykresuZakN, _IndexVykresuZak=@_IndexVykresuZakN WHERE ID=@IDDavkaN
		END;
--pokud je vyšší i nižší vyplněno a zároveň (index změny 1 vyššího dílce <> revize vyššího nebo revize vyššího je různá od revize nižšího)
	IF (@IDDilceV IS NOT NULL AND @IDDilceN IS NOT NULL AND @IDDilceV<>@IDDilceN AND (@IndexOld<>@IndexNew OR @IndexNew<>@IndexNewN))
		BEGIN
		--nejprve musíme smazat stávající řádek
		DELETE FROM HCvicna.dbo.TabKvazby WHERE vyssi=@IDDilceV AND nizsi=@IDDilceN AND ZmenaDo IS NULL
		--vkládáme
		--nové pozicování
		SET @Pozice=(SELECT ISNULL(tc2h.pozice,1) FROM #temptable tc2h WHERE tc2h.ID = @IDStartZmena)
		INSERT INTO HCvicna.dbo.TabKvazby (vyssi, nizsi, ZmenaOd, DavkaTPV, pozice, Operace, FixniMnozstvi, mnozstvi, ProcZtrat, mnozstviSeZtratou, Prirez, RezijniMat, VyraditZKalkulace, ID1)
		VALUES (@IDDilceV,@IDDilceN,@IDzmeny,1,@Pozice,N'',0,@Mnozstvi,0,@Mnozstvi,1,0,0,0)
		SET @ID1=(SELECT IDENT_CURRENT('TabKVazby'))
		UPDATE HCvicna..TabKvazby SET ID1=ID WHERE ID1=0 AND ID=@ID1
		END

	--začneme kurzor pro vložení dokumentů
			--začneme kurzorem při hromadném importu
			DECLARE @IndexZmeny nvarchar(30), @JmenoSouboru nvarchar(255), @Popis nvarchar(200), @ZmenaDocum INT, @IndexDilce VARCHAR(2), @Verze INT, @IDOldDoc INT, @IDVazby INT;
			DECLARE CurDok CURSOR FAST_FORWARD LOCAL FOR
			SELECT ID,IDDilce,RadaDo,ZmenaDo
			FROM #temptabledoc tc2h
			WHERE IDDilce IN (SELECT nizsi FROM #temptable WHERE ID=@IDStartZmena) AND tc2h.IndexZmeny=@IndexNewN AND ISNULL(tc2h.Prevedeno,0)=0;
			OPEN CurDok
			FETCH NEXT FROM CurDok INTO @IDDokum,@IDDilceDokum,@RadaDo,@ZmenaDo
			WHILE @@FETCH_STATUS=0
				BEGIN
				SET @IndexDilce=(SELECT nizsi_rev FROM #temptable WHERE ID=@IDStartZmena)	--přidám zjištění revize vkládaného řádku z pozice nizsi
				SET @IDpripona=(SELECT RIGHT(tc2h.JmenoSouboru,CHARINDEX('.',REVERSE(tc2h.JmenoSouboru))-1) FROM #temptabledoc tc2h WHERE tc2h.ID = @IDDokum)
				SET @IDkat=CASE @IDpripona WHEN 'step' THEN 19 WHEN 'jt' THEN 19 WHEN 'pdf' THEN 4 END
				SELECT @IndexZmeny=tcd.IndexZmeny, @Popis=LEFT(LEFT(tcd.JmenoSouboru, charindex('.', tcd.JmenoSouboru) - 1),9), @JmenoSouboru=tcd.JmenoSouboru, @Verze=ISNULL(tcd.Verze,1)
				FROM #temptabledoc tcd
				WHERE tcd.ID = @IDDokum
				SET @ZmenaDocum=@IDzmeny/*(SELECT tc.ID
								FROM HCvicna..TabCzmeny tc
								WHERE tc.Rada = @RadaDo AND tc.ciszmeny = @ZmenaDo)*/
				--zjistíme ID starého dokumentu, který bude nutno smazat
				SET @IDOldDoc=(SELECT vd.ID FROM HCvicna.dbo.TabVyrDokum vd WHERE Popis=@Popis AND ZmenaDo IS NULL AND IDKategorie=@IDkat /*AND ZmenaOd=@IDzmenyOd*/ AND TypDokumentu=@IDpripona AND Verze<@Verze)
							
				--vložení dokumentů
				IF (NOT EXISTS (SELECT tvd.* FROM HCvicna.dbo.TabVyrDokum tvd WHERE Verze=1 AND Archiv=0 AND Zdroj=1 AND IDKategorie=@IDkat AND ZmenaOd=@ZmenaDocum/*@ZmenaDo*//*bylo@IDZmeny*/ AND IndexZmeny=@IndexZmeny AND JmenoSouboru=@JmenoSouboru))
				AND (@IndexDilce=@IndexZmeny)	--přidám podmínku na rovnost revizí mezi dílcem a dokumentem
					BEGIN
					
					--nejprve smažeme z vazby dokumentů
					IF @IDOldDoc IS NOT NULL
					BEGIN
					EXEC hp_ZrusVyrDokum @ID=@IDOldDoc, @Oblast=1, @IDzmeny=@IDzmenyDo
					END;

					INSERT INTO HCvicna.dbo.TabVyrDokum (ID1, Verze, Archiv, Zdroj, IDKategorie, ZmenaOd, IndexZmeny, Popis, JmenoSouboru, Dokument, Autor)
					SELECT 0,@Verze,0,1,@IDkat,@ZmenaDocum/*@ZmenaDo*//*bylo@IDZmeny*/,tcd.IndexZmeny ,LEFT(LEFT(tcd.JmenoSouboru, charindex('.', tcd.JmenoSouboru) - 1),9),tcd.JmenoSouboru,tcd.Dokument,@UserName
					FROM #temptabledoc tcd
					WHERE tcd.ID = @IDDokum
					SET @IDdoc = SCOPE_IDENTITY()
			
					UPDATE HCvicna..TabVyrDokum SET ID1=@IDdoc WHERE ID1=0 AND ID = @IDdoc
					
					--vložení vazby dokumentů
					INSERT INTO HCvicna.dbo.TabVazbyVyrDokum(Oblast, RecID, RecID2, Operace, ID1VyrDokum, VerzeVyrDokum, ZmenaOd, Autor)
					VALUES(1, @IDDilceN, NULL, NULL, @IDdoc, NULL, @ZmenaDocum/*@ZmenaDo*//*bylo@IDZmeny*/, @UserName)
					END
					
					UPDATE tc2helios.dbo.transfer_dokum SET Prevedeno=1 WHERE ID = @IDDokum

				FETCH NEXT FROM CurDok INTO @IDDokum,@IDDilceDokum,@RadaDo,@ZmenaDo
				END;--end kurzoru
			CLOSE CurDok
			DEALLOCATE CurDok

	UPDATE tc2helios.dbo.transfer_bom SET Prevedeno = 1 WHERE ID = @IDStartZmena

END;

SET @IDStartZmena=@IDStartZmena+1
END;
GO

