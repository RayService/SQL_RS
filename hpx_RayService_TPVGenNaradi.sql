USE [RayService]
GO

/****** Object:  StoredProcedure [dbo].[hpx_RayService_TPVGenNaradi]    Script Date: 26.06.2025 8:44:17 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO


-- =============================================
-- Author:		DJ
-- Description:	Generování nářadí z kusovníkových vazeb
-- =============================================
CREATE PROCEDURE [dbo].[hpx_RayService_TPVGenNaradi]
	@IDZmeny INT	-- ID vybrané změny
	,@ID INT			-- ID v TabKmenZbozi
AS
SET NOCOUNT ON;

/* deklarace */
DECLARE @IDKusovnik INT;
DECLARE @IDVarianta INT;
DECLARE @Naradi TABLE (
	Nazev1 NVARCHAR(100) NOT NULL
	,IDKmenZbozi INT NULL);
DECLARE @FlagZdvojeni BIT;
DECLARE @DavkaTPV NUMERIC(19,6);
DECLARE @TranCountPred INT;

SELECT
	@IDKusovnik = K.IdKusovnik
	,@IDVarianta = K.IdVarianta
FROM TabKmenZbozi K
WHERE ID = @ID;

-- naplníme nářadí
WITH N AS (
	SELECT
		ME._naradi1
		,ME._kleste2
		,ME._kleste3
		,ME._kleste4
		,ME._polohovac1
		,ME._polohovac2
		,ME._polohovac3
		,ME._polohovac4
	FROM TabKvazby V
		INNER JOIN TabKmenZbozi_EXT ME ON V.nizsi = ME.ID
		LEFT OUTER JOIN TabCzmeny VZmenaOd ON V.ZmenaOd = VZmenaOd.ID
		LEFT OUTER JOIN TabCzmeny VZmenaDo ON V.ZmenaDo = VZmenaDo.ID
		
	WHERE V.vyssi = @IDKusovnik
		AND (V.IDVarianta IS NULL OR V.IDVarianta = @IDVarianta) 
		AND	(VZmenaOd.platnostTPV=1 AND VZmenaOd.datum <= GETDATE())
		AND	(VZmenaDo.platnostTPV=0 
				OR V.ZmenaDo IS NULL 
				OR (VZmenaDo.platnostTPV=1 AND VZmenaDo.datum > GETDATE()))
		)
INSERT INTO @Naradi(
	Nazev1)
SELECT
	DISTINCT Naradi
FROM N
	UNPIVOT(Naradi FOR TypN IN (
		_naradi1
		,_kleste2
		,_kleste3
		,_kleste4
		,_polohovac1
		,_polohovac2
		,_polohovac3
		,_polohovac4)
		) as U;
		
UPDATE N SET
	IDKmenZbozi = K.ID
FROM @Naradi N
	INNER JOIN TabKmenZbozi K ON N.Nazev1 = K.Nazev1 AND K.Naradi = 1;
		
/* kontroly */
-- neexistující změna
IF NOT EXISTS(SELECT * FROM TabCzmeny WHERE ID = @IDZmeny)
	BEGIN
		RAISERROR (N'Neplatná hodnoty vybrané změny!',16,1);
		RETURN;
	END;

-- vybraná změna je platná
IF (SELECT Platnost FROM TabCzmeny WHERE ID = @IDZmeny) = 1
	BEGIN
		RAISERROR (N'Nelze vybrat platnou změnu!',16,1);
		RETURN;
	END;

BEGIN TRY

	-- není žádné nářadí
	IF NOT EXISTS(SELECT * FROM @Naradi)
		BEGIN
			RAISERROR (N'Položky kusovníkových vazeb neobsahují žádné nářadí / polohovač!',16,1);
			RETURN;
		END;
		
	-- není ID kmen v nářadí
	IF EXISTS(SELECT * FROM @Naradi WHERE IDKmenZbozi IS NULL)
		BEGIN
			RAISERROR (N'Položky kusovníkových vazeb obsahují nářadí / polohovač bez vazby na kmenovou kartu nářadí!',16,1);
			RETURN;
		END;
		
	-- již probíhá změna
	IF EXISTS(SELECT *
			FROM TabCzmeny
			WHERE TabCZmeny.ID IN 
				(SELECT zmenaOd FROM tabKVazby WHERE vyssi=@IDKusovnik AND (IDVarianta IS NULL OR IDVarianta=@IDVarianta) 
				UNION SELECT zmenaDo FROM tabKVazby WHERE vyssi=@IDKusovnik AND (IDVarianta IS NULL OR IDVarianta=@IDVarianta) 
				UNION SELECT zmenaOd FROM TabAltKVazby WHERE vyssi=@IDKusovnik AND (IDVarianta IS NULL OR IDVarianta=@IDVarianta) 
				UNION SELECT zmenaDo FROM TabAltKVazby WHERE vyssi=@IDKusovnik AND (IDVarianta IS NULL OR IDVarianta=@IDVarianta) 
				UNION SELECT zmenaOd FROM tabPostup WHERE dilec=@IDKusovnik AND (IDVarianta IS NULL OR IDVarianta=@IDVarianta) 
				UNION SELECT zmenaDo FROM tabPostup WHERE dilec=@IDKusovnik AND (IDVarianta IS NULL OR IDVarianta=@IDVarianta) 
				UNION SELECT zmenaOd FROM tabAltPostup WHERE dilec=@IDKusovnik AND (IDVarianta IS NULL OR IDVarianta=@IDVarianta) 
				UNION SELECT zmenaDo FROM tabAltPostup WHERE dilec=@IDKusovnik AND (IDVarianta IS NULL OR IDVarianta=@IDVarianta) 
				UNION SELECT zmenaOd FROM tabNVazby WHERE dilec=@IDKusovnik AND (IDVarianta IS NULL OR IDVarianta=@IDVarianta) 
				UNION SELECT zmenaDo FROM tabNVazby WHERE dilec=@IDKusovnik AND (IDVarianta IS NULL OR IDVarianta=@IDVarianta) 
				UNION SELECT zmenaOd FROM tabAltNVazby WHERE dilec=@IDKusovnik AND (IDVarianta IS NULL OR IDVarianta=@IDVarianta) 
				UNION SELECT zmenaDo FROM tabAltNVazby WHERE dilec=@IDKusovnik AND (IDVarianta IS NULL OR IDVarianta=@IDVarianta) 
				UNION SELECT zmenaOd FROM tabTpvOPN WHERE dilec=@IDKusovnik AND (IDVarianta IS NULL OR IDVarianta=@IDVarianta) 
				UNION SELECT zmenaDo FROM tabTpvOPN WHERE dilec=@IDKusovnik AND (IDVarianta IS NULL OR IDVarianta=@IDVarianta) 
				UNION SELECT zmenaOd FROM tabVPVazby WHERE dilec=@IDKusovnik AND (IDVarianta IS NULL OR IDVarianta=@IDVarianta) 
				UNION SELECT zmenaDo FROM tabVPVazby WHERE dilec=@IDKusovnik AND (IDVarianta IS NULL OR IDVarianta=@IDVarianta) 
				UNION SELECT zmenaOd FROM tabDavka WHERE IDDilce=@IDKusovnik 
				UNION SELECT zmenaDo FROM tabDavka WHERE IDDilce=@IDKusovnik)
				AND TabCZmeny.Platnost = 0
				AND TabCZmeny.ID <> @IDZmeny)
		BEGIN
			RAISERROR (N'Na dílci se změna již provádí!',16,1);
			RETURN;
		END;

	/* funkční tělo procedury */
	
	SET @TranCountPred=@@trancount;
	IF @TranCountPred=0 BEGIN TRAN;

		-- generování konstrukce pro danou změnu
		SET @FlagZdvojeni = 1
		EXEC dbo.hp_ZdvojeniKonstrukceATech 
			@IDVyssi = @ID
			,@IDZmena = @IDZmeny;
		SET @FlagZdvojeni = NULL;
		
		-- potřebné údaje
		SELECT @DavkaTPV = DavkaTPV 
		FROM TabDavka 
		WHERE IDDilce = @IDKusovnik 
			AND zmenaOd = @IDZmeny
			AND zmenaDo IS NULL;
			
		-- zalozime naradi
		INSERT INTO TabNvazby (
			Dilec
			,IDVarianta
			,Naradi
			,ZmenaOd
			,DavkaTPV
			,PocetUziti)
		SELECT
			@IDKusovnik
			,@IDVarianta
			,N.IDKmenZbozi
			,@IDZmeny
			,@DavkaTPV
			,1
		FROM @Naradi N
		WHERE NOT EXISTS(SELECT * FROM TabNvazby WHERE dilec = @IDKusovnik 
							AND (IDVarianta IS NULL OR IDVarianta = @IDVarianta)
							AND ZmenaOd = @IDZmeny
							AND Naradi = N.IDKmenZbozi);
		
	COMMIT;
	
	-- závěrečná hláška
	IF NOT EXISTS (SELECT * FROM #TabExtKom WHERE Poznamka LIKE N'Info: Generování nářadí%')
		BEGIN
			INSERT INTO #TabExtKom(Poznamka) VALUES(N'Info: Generování nářadí z kusovníkových vazeb');
			INSERT INTO #TabExtKom(Poznamka) VALUES(N'-------------------------------------------------------------------------------');
		END;
	INSERT INTO #TabExtKom(Poznamka)
	SELECT (SkupZbo + N' ' + RegCis + N' - ' + Nazev1 + N': OK - vygenerováno')
	FROM TabKmenZbozi
	WHERE ID = @ID;

END TRY
--zacneme CATCH
BEGIN CATCH

	IF @@TRANCOUNT > 0 AND @TranCountPred=0
		ROLLBACK TRANSACTION;
	DECLARE @ErrorMessage NVARCHAR(4000);
	SELECT @ErrorMessage = CASE 
		WHEN @FlagZdvojeni = 1 THEN N'Chyba při generování konstrukce a technologie pro vybranou změnu' 
		ELSE ERROR_MESSAGE() END;
	
	IF NOT EXISTS (SELECT * FROM #TabExtKom WHERE Poznamka LIKE N'Info: Generování nářadí%')
		BEGIN
			INSERT INTO #TabExtKom(Poznamka) VALUES(N'Info: Generování nářadí z kusovníkových vazeb');
			INSERT INTO #TabExtKom(Poznamka) VALUES(N'-------------------------------------------------------------------------------');
		END;
	INSERT INTO #TabExtKom(Poznamka)
	SELECT (SkupZbo + N' ' + RegCis + N' - ' + Nazev1 + N': !!! CHYBA !!! - ' + @ErrorMessage)
	FROM TabKmenZbozi
	WHERE ID = @ID;
	
END CATCH;
GO

