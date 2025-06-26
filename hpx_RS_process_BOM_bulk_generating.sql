USE [RayService]
GO

/****** Object:  StoredProcedure [dbo].[hpx_RS_process_BOM_bulk_generating]    Script Date: 26.06.2025 12:58:04 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO


CREATE PROC [dbo].[hpx_RS_process_BOM_bulk_generating]
@IDZmeny INT,
@ID INT
AS
-- ============================================================================================
-- Author:		MŽ
-- Create date:            2.11.2022
-- Description:	Generování podřízených procesních dílců hromadně za označené dílce. Včetně výběru změny.
-- ============================================================================================

DECLARE @SkupZbo NVARCHAR(3);
DECLARE @RegCis  NVARCHAR(30);
DECLARE @AutoCislovani BIT;
DECLARE @Nazev1 NVARCHAR(100);
DECLARE @Nazev2 NVARCHAR(100);
DECLARE @DobaMeziPrikazy NUMERIC(19,6)=480;
DECLARE @Dilec BIT;
DECLARE @IDDilce INT;
DECLARE @Rada NVARCHAR(10);
DECLARE @NazevRodic NVARCHAR(100);
DECLARE @NazevSkupZbo NVARCHAR(30);
DECLARE @SK NVARCHAR(3);
DECLARE @BratTechnikTPV INT;
DECLARE @TechnikRodic NVARCHAR(50);
DECLARE @OperaceSkupiny NVARCHAR(3);
DECLARE @IDOPerace INT;
DECLARE @ProcentoCasu NUMERIC(19,6);
DECLARE @MezioperCas NUMERIC(19,6);
DECLARE @MinimalniCas NUMERIC(19,6);
DECLARE @LhutaNaskladneni INT;
DECLARE @SumaCasOperaceRodic NUMERIC(19,6);
DECLARE @TechnikTK NVARCHAR(50);
DECLARE @Schvalovatel NVARCHAR(50);
DECLARE @Nazev3 NVARCHAR(100);
DECLARE @OznaceniRodic NVARCHAR(255);
DECLARE @IDNizsi INT;
DECLARE @DavkaTPV NUMERIC(19,6);
DECLARE @Pozice NVARCHAR(100);

--dohledání ID dílce, pro nějž kusovník upravujeme
DECLARE @IDHlavicka INT
SELECT @IDHlavicka = @ID

--dohledání ID změny
DECLARE @IDZmena INT
SELECT @IDZmena = @IDZmeny

IF EXISTS (SELECT ID FROM TabCzmeny WHERE ID=@IDZmena AND Platnost=1)
BEGIN
RAISERROR ('Nelze pokračovat v generování, vybraná změna je již zplatněna.',16,1)
RETURN
END;


DECLARE @ret integer
EXEC @ret=hp_ZdvojeniKonstrukceATech @IDHlavicka, @IDZmena

DECLARE CurGenKVazby CURSOR LOCAL FAST_FORWARD FOR
	SELECT SkupZbo
	FROM TabSkupinyZbozi tsz
	LEFT OUTER JOIN TabSkupinyZbozi_EXT tsze ON tsze.ID=tsz.ID
	WHERE tsze._EXT_RS_generovat_kusovniky=1;
		OPEN CurGenKVazby;
		FETCH NEXT FROM CurGenKVazby INTO @SK;
		WHILE (@@FETCH_STATUS = 0) AND (@@ERROR = 0)
		BEGIN
		--kontrola na existenci karty ve stávajícím kusovníku dle SK.
		IF @SK NOT IN (SELECT
		tkzn.SkupZbo
		FROM TabKvazby tkv
		LEFT OUTER JOIN TabCzmeny tczOd ON tkv.ZmenaOd=tczOd.ID
		LEFT OUTER JOIN TabCzmeny tczDo ON tkv.ZmenaDo=tczDo.ID
		LEFT OUTER JOIN TabKmenZbozi tkzn ON tkv.nizsi=tkzn.ID
		WHERE
		(((tkv.vyssi=@IDHlavicka AND (@IDZmena>0 AND tkv.zmenaOd=@IDZmena OR  @IDZmena=0 AND tczOd.platnostTPV=1 AND tczOd.datum<=GETDATE() AND 
		(tczDo.platnostTPV=0 OR tkv.ZmenaDo IS NULL OR (tczDo.platnostTPV=1 AND tczDo.datum>GETDATE())) ) ))))
		
		BEGIN
		
		SET @SkupZbo = @SK
		SET @RegCis = NULL
		SET @NazevRodic=(SELECT Nazev1 FROM TabKmenZbozi WHERE ID=@IDHlavicka)
		SET @OznaceniRodic=(SELECT SkupZbo+'/'+RegCis FROM TabKmenZbozi WHERE ID=@IDHlavicka)
		SET @Nazev1=(SELECT Nazev+' - '+@NazevRodic FROM TabSkupinyZbozi WHERE SkupZbo=@SkupZbo)
		SET @NazevSkupZbo=(SELECT Nazev FROM TabSkupinyZbozi WHERE SkupZbo=@SkupZbo)
		SET @BratTechnikTPV=(SELECT tsze._EXT_RS_prebirat_technikTPV100 FROM TabSkupinyZbozi tsz LEFT OUTER JOIN TabSkupinyZbozi_EXT tsze ON tsze.ID=tsz.ID WHERE tsz.SkupZbo=@SkupZbo)
		SET @TechnikTK=(SELECT tcz.PrijmeniJmeno FROM TabKmenZbozi tkz LEFT OUTER JOIN TabKmenZbozi_EXT tkze ON tkze.ID=tkz.ID LEFT OUTER JOIN TabCisZam tcz ON tcz.ID=tkze._EXT_RS_technikTK WHERE tkz.ID=@IDHlavicka)
		SET @Schvalovatel=(SELECT tcz.PrijmeniJmeno FROM TabKmenZbozi tkz LEFT OUTER JOIN TabKmenZbozi_EXT tkze ON tkze.ID=tkz.ID LEFT OUTER JOIN TabCisZam tcz ON tcz.ID=tkze._EXT_RS_schvalovatel WHERE tkz.ID=@IDHlavicka)
		SET @TechnikRodic=(SELECT CASE WHEN @BratTechnikTPV=1 THEN tkze._TechnikTPV100 WHEN @BratTechnikTPV=2 THEN @TechnikTK WHEN @BratTechnikTPV=3 THEN @Schvalovatel ELSE NULL END  FROM TabKmenZbozi tkz LEFT OUTER JOIN TabKmenZbozi_EXT tkze ON tkze.ID=tkz.ID WHERE tkz.ID=@IDHlavicka)
		SET @OperaceSkupiny=(SELECT ttp.ID
							FROM TabTypPostup ttp
							LEFT OUTER JOIN TabTypPostup_EXT ttpe ON ttpe.ID=ttp.ID
							LEFT OUTER JOIN TabSkupinyZbozi tsz ON tsz.SkupZbo=ttpe._EXT_RS_skup_zbo_ENG
							WHERE tsz.SkupZbo=@SkupZbo)
		SET @ProcentoCasu=(SELECT tsze._EXT_RS_procento_casu FROM TabSkupinyZbozi tsz LEFT OUTER JOIN TabSkupinyZbozi_EXT tsze ON tsze.ID=tsz.ID WHERE tsz.SkupZbo=@SkupZbo)
		SET @MinimalniCas=(SELECT tsze._EXT_RS_minimum_casu FROM TabSkupinyZbozi tsz LEFT OUTER JOIN TabSkupinyZbozi_EXT tsze ON tsze.ID=tsz.ID WHERE tsz.SkupZbo=@SkupZbo)
		SET @MezioperCas=(SELECT tsze._EXT_RS_mezioperacni_cas FROM TabSkupinyZbozi tsz LEFT OUTER JOIN TabSkupinyZbozi_EXT tsze ON tsze.ID=tsz.ID WHERE tsz.SkupZbo=@SkupZbo)
		SET @LhutaNaskladneni=(SELECT ISNULL(tsze._EXT_RS_LhutaNaskladneni,0) FROM TabSkupinyZbozi tsz LEFT OUTER JOIN TabSkupinyZbozi_EXT tsze ON tsze.ID=tsz.ID WHERE tsz.SkupZbo=@SkupZbo)
		SET @SumaCasOperaceRodic=(SELECT SUM(TabPostup.TAC)
								FROM TabPostup WITH(NOLOCK)
								LEFT OUTER JOIN TabCzmeny tcOD WITH(NOLOCK) ON TabPostup.ZmenaOd=tcOD.ID
								LEFT OUTER JOIN TabCzmeny tcDo WITH(NOLOCK) ON TabPostup.ZmenaDo=tcDo.ID
								LEFT OUTER JOIN  TabPostup_EXT WITH(NOLOCK) ON TabPostup_EXT.ID=TabPostup.ID
								WHERE
								(((TabPostup.dilec=@IDHlavicka ))AND((tcOD.platnostTPV=1 AND tcOD.datum<=GETDATE()))
								AND(((tcDo.platnostTPV=0 OR TabPostup.ZmenaDo IS NULL OR (tcDo.platnostTPV=1 AND tcDo.datum>GETDATE())) ))))
		SET @Nazev3=@OznaceniRodic--@SkupZbo+'/'+@RegCis

		EXEC dbo.hp_VytvorPolozkuKmeneZbozi @SZ=@SkupZbo,@RegCis=@RegCis, @Nazev1=@Nazev1,@Nazev2=@NazevSkupZbo,@Nazev3=@Nazev3,@Dilec=1
		SET @IDDilce=(SELECT IDENT_CURRENT('TabKmenZbozi'))
		--vložení do Stavu skladu
		EXEC hp_InsertStavSkladu @IDKmen=@IDDilce, @IDSklad=N'20000275900'
		--zde musím založit externí tabulku TabKmenZbozi_EXT a vložit do ní technika TPV 100
		IF @BratTechnikTPV IS NOT NULL
		BEGIN
		IF (SELECT tkze.ID  FROM TabKmenZbozi_EXT tkze WHERE tkze.ID=@IDDilce) IS NULL
		 BEGIN 
			INSERT INTO TabKmenZbozi_EXT (ID,_TechnikTPV100) 
			VALUES (@IDDilce,@TechnikRodic)
		 END
		END

		UPDATE tpkz SET tpkz.VychoziSklad=N'20000275900', tpkz.PrednasFixniMnozstvi=1
		FROM TabParametryKmeneZbozi tpkz
		WHERE IDKmenZbozi=@IDDilce

		UPDATE tpkmz SET tpkmz.VychoziSklad=N'20000275900', tpkmz.RadaVyrPlanu=N'TPV',tpkmz.RadaVyrPrikazu=N'950',tpkmz.DobaMeziPrikazy=480,tpkmz.VyraditZGenerPodrizPrikazu=1,tpkmz.TypDilce=0
		FROM TabParKmZ tpkmz
		WHERE IDKmenZbozi=@IDDilce
		--lhůta naskladnění
		UPDATE tkz SET LhutaNaskladneni=@LhutaNaskladneni
		FROM TabKmenZbozi tkz
		WHERE ID=@IDDilce

		--založení technologie na založeném dílci
		
		IF NOT EXISTS (SELECT * FROM TabPostup tp WHERE tp.dilec = @IDDilce AND tp.ZmenaOd = @IDZmena AND tp.Operace = N'0010')
				INSERT INTO TabPostup (dilec, ZmenaOd, DavkaTPV, Operace, BlokovaniEditoru, JeNovaVetaEditor,nazev,pracoviste,tarif,TAC_Obsluhy,TAC_Obsluhy_T,TAC,TAC_T,NasobekTAC,TAC_J,TAC_Obsluhy_J,TAC_J_T,TAC_Obsluhy_J_T,MeziOperCas,MeziOperCas_T,Poznamka,TypOznaceni,typ)
					SELECT @IDDilce,@IDZmena,1,N'0010',ttp.BlokovaniEditoru,0,ttp.nazev,ttp.pracoviste,ttp.tarif,ttp.TAC_Obsluhy,ttp.TAC_Obsluhy_T,ttp.TAC,ttp.TAC_T,1,ttp.TAC,ttp.TAC_Obsluhy,ttp.TAC_T,ttp.TAC_Obsluhy_T,@MezioperCas,2,ttp.Poznamka,ttp.TypOznaceni,ttp.typ
					FROM TabTypPostup ttp
					WHERE ttp.ID = @OperaceSkupiny
		SET @IDOPerace=(SELECT IDENT_CURRENT('TabPostup'))
		--úprava času na právě vložené operaci
		IF (@SumaCasOperaceRodic*@ProcentoCasu*0.01)>@MinimalniCas
			UPDATE TabPostup SET TAC_Obsluhy = @SumaCasOperaceRodic*@ProcentoCasu*0.01, TAC = @SumaCasOperaceRodic*@ProcentoCasu*0.01, TAC_Obsluhy_J = @SumaCasOperaceRodic*@ProcentoCasu*0.01, TAC_J = @SumaCasOperaceRodic*@ProcentoCasu*0.01
                                   WHERE (TabPostup.ID = @IDOPerace)
		ELSE
			UPDATE TabPostup SET TAC_Obsluhy = @MinimalniCas/60, TAC = @MinimalniCas/60, TAC_Obsluhy_J = @MinimalniCas/60, TAC_J = @MinimalniCas/60
                                   WHERE (TabPostup.ID = @IDOPerace)
		/*
		--založení externí tabulky TabPostup a vložení Technik TPV 100 do 
		IF (SELECT tkze.ID  FROM TabPostup_EXT tkze WHERE tkze.ID=@IDDilce) IS NULL
		 BEGIN 
			INSERT INTO TabPostup_EXT (ID,_EXT_B2ADIMARS_IdAssignedEmployee) 
			VALUES (@IDDilce,@TechnikRodic)
		 END
		END
		*/

		--vložení kusovníkud do založeného dílce
		SET @IDNizsi=225813 
		SET @Pozice=(SELECT '     '+ISNULL(MAX(CASE WHEN ISNUMERIC(LTRIM(RTRIM(Pozice))+N'.E0')=1 AND LEN(LTRIM(Pozice))<=9 THEN CONVERT(int, CONVERT(numeric(19,6), Pozice)) END),0) + 1 
						FROM TabKvazby
						WHERE ISNUMERIC(LTRIM(RTRIM(Pozice))+N'.E0')=1 AND LEN(LTRIM(Pozice))<=9  AND Vyssi=@IDDilce AND (IDVarianta IS NULL OR IDVarianta=0) AND ZmenaOd=@IDZmena)
		SET @DavkaTPV=(SELECT td.Davka FROM TabDavka td WHERE td.IDDilce=@IDDilce 
		AND EXISTS(SELECT * FROM TabCZmeny Zod LEFT OUTER JOIN TabCZmeny Zdo ON (ZDo.ID=td.zmenaDo) 
		WHERE Zod.ID=td.zmenaOd AND Zod.platnostTPV=1 AND Zod.datum<=GETDATE() AND (td.ZmenaDo IS NULL OR Zdo.platnostTPV=0 OR (ZDo.platnostTPV=1 AND ZDo.datum>GETDATE()))          ) 
		)
		INSERT INTO TabKvazby (vyssi, nizsi, ZmenaOd, DavkaTPV, pozice, Operace, FixniMnozstvi, mnozstvi, ProcZtrat, mnozstviSeZtratou, Prirez, RezijniMat, VyraditZKalkulace, ID1)
		VALUES (@IDDilce, @IDNizsi, @IDZmena, ISNULL(@DavkaTPV,1), @Pozice,N'', 1, 0.0, 0, 0.0, 1, 0, 0, 0)

		--vložení výše založeného dílce do aktuálně otevřeného kusovníku
		--zjištění čísla nové pozice
		DECLARE @Pozice_new NVARCHAR(100);
		SET @Pozice_new=(SELECT ISNULL(MAX(CASE WHEN ISNUMERIC(LTRIM(RTRIM(Pozice))+N'.E0')=1 AND LEN(LTRIM(Pozice))<=9 THEN CONVERT(int, CONVERT(numeric(19,6), Pozice)) END),0) + 1 
		  FROM TabKVazby 
		  WHERE ISNUMERIC(LTRIM(RTRIM(Pozice))+N'.E0')=1 AND LEN(LTRIM(Pozice))<=9  AND Vyssi=@IDHlavicka AND (IDVarianta IS NULL OR IDVarianta=0) AND ZmenaOd=@IDZmena)
		SELECT @Pozice_new
		INSERT INTO TabKvazby (vyssi, nizsi, ZmenaOd, DavkaTPV, pozice, Operace, FixniMnozstvi, mnozstvi, ProcZtrat, mnozstviSeZtratou, Prirez, RezijniMat, VyraditZKalkulace, ID1)
		VALUES (@IDHlavicka,@IDDilce,@IDZmena,1,@Pozice_new,N'',1,0,0,0,1,0,0,0)
		DECLARE @IDvazby INT;
		SET @IDvazby=(SELECT IDENT_CURRENT('TabKVazby'))
		UPDATE tabKVazby SET ID1=ID WHERE ID1=0 AND ID = @IDvazby

		END;

		FETCH NEXT FROM CurGenKVazby INTO @SK;
		END;
CLOSE CurGenKVazby;
DEALLOCATE CurGenKVazby;



GO

