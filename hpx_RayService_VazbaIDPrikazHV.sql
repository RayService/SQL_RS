USE [RayService]
GO

/****** Object:  StoredProcedure [dbo].[hpx_RayService_VazbaIDPrikazHV]    Script Date: 26.06.2025 9:33:00 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO


CREATE PROCEDURE [dbo].[hpx_RayService_VazbaIDPrikazHV]
	@IDPrikaz INT  -- ID vybranu uzivatelem, NULL dosadit automatem
	,@IDPohyb INT
AS
SET NOCOUNT ON;
-- =============================================
-- Author:		JDO
-- Description:	
-- =============================================

DECLARE @IDKmenZbozi INT;
DECLARE @Popis NVARCHAR(150);
DECLARE @VC NVARCHAR(100);

SELECT
	@IDKmenZbozi = S.IDKmenZbozi
	,@Popis = K.SkupZbo + N' ' + K.RegCis + N' - ' + K.Nazev1
FROM TabPohybyZbozi P
	INNER JOIN TabStavSkladu S ON P.IDZboSklad = S.ID
	INNER JOIN TabKmenZbozi K ON S.IDKmenZbozi = K.ID
WHERE P.ID = @IDPohyb;

BEGIN TRY

/* kontroly */
IF @IDPrikaz IS NOT NULL
	BEGIN
	
		DECLARE @Oznacenych SMALLINT;
		DECLARE @Aktualni SMALLINT;
		SELECT @Oznacenych = Cislo FROM #TabExtKomPar WHERE Popis = 'CELKEM';
		SELECT @Aktualni = Cislo FROM #TabExtKomPar WHERE Popis = 'PRECHOD';
		IF @Aktualni IS NOT NULL OR @Oznacenych IS NOT NULL
			BEGIN
				RAISERROR ('Akci lze spustit pouze nad jedním označeným řádkem!',16,1);
				RETURN;
			END;
		
	END;

IF @IDPrikaz IS NULL
	BEGIN

	-- není výdej ze skladu
	IF (SELECT DruhPohybuZbo FROM TabPohybyZbozi WHERE ID = @IDPohyb) NOT IN (2,4)
		BEGIN
			RAISERROR ('%s: nepovolený druh pohybu (není Výdej nebo Výdej v evidenční ceně)!',16,1,@Popis);
			RETURN;
		END;
		
	-- není to dílec
	IF (SELECT Dilec FROM TabKmenZbozi WHERE ID = @IDKmenZbozi) = 0
		BEGIN
			RAISERROR ('%s: nejedná se o Dílec',16,1,@Popis);
			RETURN;
		END;

	-- nemá VČ
	IF NOT EXISTS(SELECT * FROM TabVyrCP WHERE IDPolozkaDokladu = @IDPohyb)
		BEGIN
			RAISERROR ('%s: položka bez Výrobního čísla',16,1,@Popis);
			RETURN;
		END;

	-- více VČ
	IF (SELECT COUNT(*) FROM TabVyrCP WHERE IDPolozkaDokladu = @IDPohyb) > 1
		BEGIN
			RAISERROR ('%s: položka s více Výrobními čísly',16,1,@Popis);
			RETURN;
		END;

	SELECT @VC = MAX(CS.Nazev1)
	FROM TabVyrCP CP
		INNER JOIN TabVyrCS CS ON CP.IDVyrCis = CS.ID
	WHERE IDPolozkaDokladu = @IDPohyb;

	-- ID VP
	SELECT @IDPrikaz = VP.ID
	FROM TabPrikaz VP
		INNER JOIN TabVyrCisPrikaz VCP ON VP.ID = VCP.IDPrikaz
	WHERE VP.IDTabKmen = @IDKmenZbozi
		AND VCP.VyrCislo = @VC
		AND EXISTS(SELECT * FROM TabPohybyZbozi WHERE IDPrikaz = VP.ID AND TabPohybyZbozi.TypVyrobnihoDokladu=0);

	-- vice VP
	IF @@ROWCOUNT > 1
		BEGIN
			RAISERROR ('%s: pro výrobní číslo položky nalezeno více výrobních příkazů',16,1,@Popis);
			RETURN;
		END;
		
END;

-- zadny VP
IF @IDPrikaz IS NULL
	BEGIN
		RAISERROR ('%s: výrobní příkaz nenalezen',16,1,@Popis);
		RETURN;
	END;

/* funkční tělo proc */

IF NOT EXISTS(SELECT * FROM TabPohybyZbozi_EXT WHERE ID = @IDPohyb)
	INSERT INTO TabPohybyZbozi_EXT(ID) VALUES(@IDPohyb);
UPDATE TabPohybyZbozi_EXT SET _IDPrikazHV = @IDPrikaz
WHERE ID = @IDPohyb;

IF NOT EXISTS (SELECT * FROM #TabExtKom WHERE Poznamka LIKE N'Info: Propojení položky s výrobním příkazem%')
	BEGIN
		INSERT INTO #TabExtKom(Poznamka) VALUES(N'Info: Propojení položky s výrobním příkazem');
		INSERT INTO #TabExtKom(Poznamka) VALUES(N'-------------------------------------------------------------------------------');
	END;
INSERT INTO #TabExtKom(Poznamka)
VALUES(N'OK - ' + @Popis);

END TRY
-- CATCH blok
BEGIN CATCH
	IF @@TRANCOUNT > 0 --AND @TranCountPred=0
		ROLLBACK TRANSACTION;
	DECLARE @ErrorMessage NVARCHAR(4000);
	SELECT @ErrorMessage = ERROR_MESSAGE();
	
	IF NOT EXISTS (SELECT * FROM #TabExtKom WHERE Poznamka LIKE N'Info: Propojení položky s výrobním příkazem%')
	BEGIN
		INSERT INTO #TabExtKom(Poznamka) VALUES(N'Info: Propojení položky s výrobním příkazem');
		INSERT INTO #TabExtKom(Poznamka) VALUES(N'-------------------------------------------------------------------------------');
	END;
	INSERT INTO #TabExtKom(Poznamka)
	VALUES(N'X - ' + @ErrorMessage);
	
	RETURN;

END CATCH;
GO

