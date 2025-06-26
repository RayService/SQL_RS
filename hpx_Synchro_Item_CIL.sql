USE [RayService]
GO

/****** Object:  StoredProcedure [dbo].[hpx_Synchro_Item_CIL]    Script Date: 26.06.2025 10:56:35 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

CREATE PROCEDURE [dbo].[hpx_Synchro_Item_CIL]
		@IDDoklad INT -- ID označeného dokladu
AS
SET NOCOUNT ON;

-- =============================================
-- Author:		MŽ
-- Description:	Zpětná synchronizace EP > VOB do zdrojové DB
-- =============================================
DECLARE @IDPohybMC INT;
DECLARE @Poznamka NVARCHAR(MAX);
DECLARE @SkupZbo NVARCHAR(3);
DECLARE @RegCis NVARCHAR(30);
DECLARE @Mnozstvi NUMERIC(19,6);
DECLARE @VstupniCena TINYINT;
DECLARE @NastaveniSlev SMALLINT;
DECLARE @SlevaSkupZbo NUMERIC(5,2);
DECLARE @SlevaZboKmen NUMERIC(5,2);
DECLARE @SlevaZboSklad NUMERIC(5,2);
DECLARE @SlevaOrg NUMERIC(5,2);
DECLARE @SlevaSozNa NUMERIC(5,2);
DECLARE @TerminSlevaProc NUMERIC(5,2);
DECLARE @SlevaCastka NUMERIC(19,6);
DECLARE @NazevSozNa1 NVARCHAR(100);
DECLARE @NazevSozNa2 NVARCHAR(100);
DECLARE @NazevSozNa3 NVARCHAR(100);
DECLARE @Popis4 NVARCHAR(100);
DECLARE @IDPolozka INT;
DECLARE @_EXT_RS_IDPohybMCOriginal INT;
DECLARE @IDZboSklad INT;
DECLARE @Error NVARCHAR(255);
DECLARE @IDDokladCil INT;
-- deklarace pro UpdatePolozky
DECLARE @JCBezDaniKC NUMERIC(19,6);
DECLARE @JCBezDaniVal NUMERIC(19,6);
DECLARE @JCsDPHKc NUMERIC(19,6);
DECLARE @CCbezDaniKc NUMERIC(19,6);
DECLARE @CCsDPHKc NUMERIC(19,6);
DECLARE @JCsDPHVal NUMERIC(19,6);
DECLARE @CCbezDaniVal NUMERIC(19,6);
DECLARE @CCsDPHVal NUMERIC(19,6);
DECLARE @JCsSDKc NUMERIC(19,6);
DECLARE @CCsSDKc NUMERIC(19,6);
DECLARE @JCsSDVal NUMERIC(19,6);
DECLARE @CCsSDVal NUMERIC(19,6);
DECLARE @SazbaDPH NUMERIC(5,2);
DECLARE @JednotkaMeny INT;
DECLARE @Kurz NUMERIC(19,6);
DECLARE @KurzEuro NUMERIC(19,6);
DECLARE @SazbaSD NUMERIC(19,6);
DECLARE @ZakazanoDPH TINYINT;
DECLARE @Selectem BIT;
DECLARE @VstupniCenaProPrepocet INT;
DECLARE @SlevaDokladu NUMERIC(19,6);
DECLARE @Nabidka INT;
DECLARE @MJ NVARCHAR(10);
DECLARE @HlidanoProOrg BIT;
DECLARE @OrgProCeny INT;
DECLARE @TranCountPred INT;
DECLARE @ServerName NVARCHAR(128);
DECLARE @SQLZdroj NVARCHAR(128);
DECLARE @ExecSQL NVARCHAR(MAX);
DECLARE @CRLF CHAR(2);
DECLARE @LServer BIT;
DECLARE @SQLCil NVARCHAR(128);
-- * Deklarace - Ray Service
DECLARE @DatPovinnostiFa DATETIME;
DECLARE @FormaDopravy NVARCHAR(30);
DECLARE @FormaUhrady NVARCHAR(30);
DECLARE @IDKmenRS INT;
DECLARE @PotvrzDatDod DATETIME;
DECLARE @NahradniDatum DATETIME;
DECLARE @_dat_pri_zme_pot DATETIME;
/* funkční tělo procedury */
--zacneme TRY
BEGIN TRY
	IF(OBJECT_ID('tempdb..#TempItem') IS NOT NULL) BEGIN DROP TABLE #TempItem END
		SELECT *
		INTO #TempItem
		FROM (SELECT tpz.*,tpze._EXT_RS_IDPohybMCOriginal,tpze._dat_dod
				FROM TabPohybyZbozi tpz
				LEFT OUTER JOIN TabPohybyZbozi_EXT tpze ON tpze.ID=tpz.ID
				WHERE tpz.IDDoklad=@IDDoklad)
		AS X
	/* kontroly */
/*		
	-- Položky - zda někdo nevymazal původní pohyb ve zdrojové DB
	SET @Error = NULL;
	DECLARE CurKontrolaPol CURSOR LOCAL FAST_FORWARD FOR
		SELECT DISTINCT
			SkupZbo
			,RegCis
		FROM #TempItem;
	OPEN CurKontrolaPol;
	FETCH NEXT FROM CurKontrolaPol INTO @SkupZbo, @RegCis;
		WHILE (@@FETCH_STATUS = 0) AND (@@ERROR = 0)
		BEGIN
			-- zacatek akce v kurzoru CurKontrolaPol
			IF NOT EXISTS(SELECT * FROM TabKmenZbozi WHERE SkupZbo = @SkupZbo AND RegCis = @RegCis)
				SET @Error = ISNULL((@Error + N', ' + @SkupZbo + N' ' + @RegCis),(@SkupZbo + N' ' + @RegCis))
			
			-- konec akce v kurzoru CurKontrolaPol
		FETCH NEXT FROM CurKontrolaPol INTO @SkupZbo, @RegCis;
		END;
	CLOSE CurKontrolaPol;
	DEALLOCATE CurKontrolaPol;
	
	IF @Error IS NOT NULL
		BEGIN
			RAISERROR('- v databázi %s neexistují následující kmenové karty: %s', 16, 1, @DBVerName, @Error);
			RETURN;
		END;
*/		
	-- ** nahození transakce
	SET @TranCountPred=@@trancount
	IF @TranCountPred=0 BEGIN TRAN
	SET @IDDokladCil = (SELECT tdzMC.ID FROM RayService6..TabDokladyZbozi tdzMC
						WHERE tdzMC.ID IN (SELECT tpzMC.IDDoklad
											FROM RayService6..TabPohybyZbozi tpzMC
											JOIN #TempItem ON #TempItem._EXT_RS_IDPohybMCOriginal=tpzMC.ID))
	-- ** update položek ve zdrojové db
		-- docasna tabulka za normalnich okolnosti generovana HeO
		IF OBJECT_ID('tempdb..#TabTempUziv') IS NULL
			CREATE TABLE #TabTempUziv(
					[Tabulka] [varchar] (255) NOT NULL,
					[SCOPE_IDENTITY] [int] NULL,
					[Datum] [datetime] NULL
				);
		-- procházíme položky
		DECLARE CurUpdateItem CURSOR LOCAL FAST_FORWARD FOR
			SELECT 
				ID
				,SkupZbo
				,RegCis
				,Mnozstvi
				,VstupniCena
				,JCbezDaniKC
				,JCsDPHKc
				,CCbezDaniKc
				,CCsDPHKc
				,JCbezDaniVal
				,JCsDPHVal
				,CCbezDaniVal
				,CCsDPHVal
				,JCsSDKc
				,CCsSDKc
				,JCsSDVal
				,CCsSDVal
				,NastaveniSlev
				,SlevaSkupZbo
				,SlevaZboKmen
				,SlevaZboSklad
				,SlevaOrg
				,SlevaSozNa
				,TerminSlevaProc
				,SlevaCastka
				,NazevSozNa1
				,NazevSozNa2
				,NazevSozNa3
				,Popis4
				,SazbaDPH
				,SazbaSD
				,_EXT_RS_IDPohybMCOriginal
				,PotvrzDatDod
				,_dat_dod
			FROM #TempItem;
		OPEN CurUpdateItem;
		FETCH NEXT FROM CurUpdateItem INTO 
				@IDPolozka
				,@SkupZbo
				,@RegCis
				,@Mnozstvi
				,@VstupniCena
				,@JCbezDaniKC
				,@JCsDPHKc
				,@CCbezDaniKc
				,@CCsDPHKc
				,@JCBezDaniVal
				,@JCsDPHVal
				,@CCbezDaniVal
				,@CCsDPHVal
				,@JCsSDKc
				,@CCsSDKc
				,@JCsSDVal
				,@CCsSDVal
				,@NastaveniSlev
				,@SlevaSkupZbo
				,@SlevaZboKmen
				,@SlevaZboSklad
				,@SlevaOrg
				,@SlevaSozNa
				,@TerminSlevaProc
				,@SlevaCastka
				,@NazevSozNa1
				,@NazevSozNa2
				,@NazevSozNa3
				,@Popis4
				,@SazbaDPH
				,@SazbaSD
				,@_EXT_RS_IDPohybMCOriginal
				,@PotvrzDatDod
				,@NahradniDatum;
			WHILE (@@FETCH_STATUS = 0) AND (@@ERROR = 0)
			BEGIN
				-- zacatek akce v kurzoru CurUpdateItem
				SET @_dat_pri_zme_pot=(SELECT tpz.PotvrzDatDod FROM RayService6..TabPohybyZbozi tpz WHERE tpz.ID=@_EXT_RS_IDPohybMCOriginal);
				-- aktualizujeme údaje položky
				-- přesuneme na původním dokladu Potvrzené datum dodání do Prvotně potvrzené datum dodání od dodavatele
					IF (SELECT tpze._dat_dod1 FROM RayService6..TabPohybyZbozi_EXT tpze WHERE tpze.ID=@_EXT_RS_IDPohybMCOriginal) IS NULL
					BEGIN
					IF (SELECT tpze.ID FROM RayService6..TabPohybyZbozi_EXT tpze WHERE tpze.ID=@_EXT_RS_IDPohybMCOriginal) IS NULL
						BEGIN 
						INSERT INTO RayService6..TabPohybyZbozi_EXT (ID,_dat_dod1) 
						SELECT @_EXT_RS_IDPohybMCOriginal,tpz.PotvrzDatDod
						FROM RayService6..TabPohybyZbozi tpz
						WHERE tpz.ID=@_EXT_RS_IDPohybMCOriginal
						END
					ELSE
					UPDATE tpze SET _dat_dod1=tpz.PotvrzDatDod
					FROM RayService6..TabPohybyZbozi_EXT tpze
					LEFT OUTER JOIN RayService6..TabPohybyZbozi tpz ON tpz.ID=tpze.ID
					WHERE tpze.ID=@_EXT_RS_IDPohybMCOriginal
					END
				--vyplníme dnešním datem pole Datum příchodu Potvrzení objednávky na položce, není-li vyplněno
					IF (SELECT tpze._dat_pri_pot FROM RayService6..TabPohybyZbozi_EXT tpze WHERE tpze.ID=@_EXT_RS_IDPohybMCOriginal) IS NULL
					BEGIN
					IF (SELECT tpze.ID FROM RayService6..TabPohybyZbozi_EXT tpze WHERE tpze.ID=@_EXT_RS_IDPohybMCOriginal) IS NULL
						BEGIN 
						INSERT INTO RayService6..TabPohybyZbozi_EXT (ID,_dat_pri_pot) 
						SELECT @_EXT_RS_IDPohybMCOriginal,GETDATE()
						FROM RayService6..TabPohybyZbozi tpz
						WHERE tpz.ID=@_EXT_RS_IDPohybMCOriginal
						END
					ELSE
					UPDATE tpze SET _dat_pri_pot=GETDATE()
					FROM RayService6..TabPohybyZbozi_EXT tpze
					LEFT OUTER JOIN RayService6..TabPohybyZbozi tpz ON tpz.ID=tpze.ID
					WHERE tpze.ID=@_EXT_RS_IDPohybMCOriginal
					END
				
					UPDATE RayService6..TabPohybyZbozi SET
					VstupniCena = @VstupniCena
					,JCbezDaniKC = @JCbezDaniKC
					,JCsDPHKc = @JCsDPHKc
					,CCbezDaniKc = @CCbezDaniKc
					,CCsDPHKc = @CCsDPHKc
					,JCbezDaniVal = @JCBezDaniVal
					,JCsDPHVal = @JCsDPHVal
					,CCbezDaniVal = @CCbezDaniVal
					,CCsDPHVal = @CCsDPHVal
					,JCsSDKc = @JCsSDKc
					,CCsSDKc = @CCsSDKc
					,JCsSDVal = @JCsSDVal
					,CCsSDVal = @CCsSDVal
					,NastaveniSlev = @NastaveniSlev
					,SlevaSkupZbo = @SlevaSkupZbo
					,SlevaZboKmen = @SlevaZboKmen
					,SlevaZboSklad = @SlevaZboSklad
					,SlevaOrg = @SlevaOrg
					,SlevaSozNa = @SlevaSozNa
					,TerminSlevaProc = @TerminSlevaProc
					,SlevaCastka = @SlevaCastka
					,NazevSozNa1 = @NazevSozNa1
					,NazevSozNa2 = @NazevSozNa2
					,NazevSozNa3 = @NazevSozNa3
					,Popis4 = @Popis4
					,PotvrzDatDod = @PotvrzDatDod
				WHERE ID = @_EXT_RS_IDPohybMCOriginal;

				--zkopírujeme Náhradní datum, je-li vyplněno do Potvrzeného data
					IF @NahradniDatum IS NOT NULL
						BEGIN
						UPDATE RayService6..TabPohybyZbozi SET
						PotvrzDatDod = @NahradniDatum
						WHERE ID = @_EXT_RS_IDPohybMCOriginal;
						END
					IF @NahradniDatum IS NOT NULL AND @_dat_pri_zme_pot<>@NahradniDatum
						BEGIN
							UPDATE tpze SET _dat_pri_zme_pot=GETDATE()
							FROM RayService6..TabPohybyZbozi_EXT tpze
							LEFT OUTER JOIN RayService6..TabPohybyZbozi tpz ON tpz.ID=tpze.ID
							WHERE tpze.ID=@_EXT_RS_IDPohybMCOriginal
						END
						
				-- konec akce v kurzoru CurUpdateItem
			FETCH NEXT FROM CurUpdateItem INTO 
				@IDPolozka
				,@SkupZbo
				,@RegCis
				,@Mnozstvi
				,@VstupniCena
				,@JCbezDaniKC
				,@JCsDPHKc
				,@CCbezDaniKc
				,@CCsDPHKc
				,@JCBezDaniVal
				,@JCsDPHVal
				,@CCbezDaniVal
				,@CCsDPHVal
				,@JCsSDKc
				,@CCsSDKc
				,@JCsSDVal
				,@CCsSDVal
				,@NastaveniSlev
				,@SlevaSkupZbo
				,@SlevaZboKmen
				,@SlevaZboSklad
				,@SlevaOrg
				,@SlevaSozNa
				,@TerminSlevaProc
				,@SlevaCastka
				,@NazevSozNa1
				,@NazevSozNa2
				,@NazevSozNa3
				,@Popis4
				,@SazbaDPH
				,@SazbaSD
				,@_EXT_RS_IDPohybMCOriginal
				,@PotvrzDatDod
				,@NahradniDatum;
			END;
		CLOSE CurUpdateItem;
		DEALLOCATE CurUpdateItem;
	COMMIT;	
	-- * nápočtové rutiny dokladu
	EXEC RayService6.dbo.hp_VypCenOZPolozek_IDDokladu @IDDokladCil,0;
	UPDATE RayService6.dbo.TabDokladyZbozi SET BlokovaniEditoru = NULL WHERE ID = @IDDokladCil;
END TRY
--zacneme CATCH
BEGIN CATCH
	IF @@TRANCOUNT > 0 AND @TranCountPred=0
		ROLLBACK TRANSACTION;
	DECLARE @ErrorMessage VARCHAR(4000);
	SELECT @ErrorMessage = ERROR_MESSAGE();
	SET @Error = @ErrorMessage;
	RETURN;
END CATCH;
GO

