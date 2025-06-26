USE [RayService]
GO

/****** Object:  StoredProcedure [dbo].[hpx_RayService_HromNastavOdvadeciOperaci]    Script Date: 26.06.2025 9:16:16 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO



CREATE PROCEDURE [dbo].[hpx_RayService_HromNastavOdvadeciOperaci]
	@IDZmeny INT		-- ID vybrané změny
	,@ID INT			-- ID v TabPostup - před změnou
AS
SET NOCOUNT ON;
-- =============================================
-- Author:		DJ
-- Description:	Hromadné nastavení odváděcí operace
-- =============================================
/* deklarace */
DECLARE @dilec INT;
DECLARE @IDKusovnik INT;
DECLARE @IDVarianta INT;
DECLARE @ZmenaJizProbiha BIT;
DECLARE @TranCountPred INT;
DECLARE @FlagZdvojeni BIT;
DECLARE @Operace NCHAR(4);
DECLARE @IDZakazModif INT;

SELECT
	@dilec = P.dilec
	,@IDVarianta = P.IdVarianta
	,@IDKusovnik = K.IdKusovnik
	,@Operace = P.Operace
	,@IDZakazModif = P.IDZakazModif
FROM TabPostup P
	INNER JOIN TabKmenZbozi K ON P.dilec = K.ID
WHERE P.ID = @ID;
		
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
			RAISERROR (N'Na dílci se změna již provádí  - jiná, než byla vybrána při spuštení akce!',16,1);
			RETURN;
		END;

	/* funkční tělo procedury */
	
	-- probíhá jíž změna - vybranná
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
				AND TabCZmeny.ID = @IDZmeny)
		SET @ZmenaJizProbiha = 1;
	ELSE
		SET @ZmenaJizProbiha = 0;
	
	SET @TranCountPred=@@trancount;
	IF @TranCountPred=0 BEGIN TRAN;
		
		-- generování konstrukce pro danou změnu
		IF @ZmenaJizProbiha = 0
			BEGIN
				SET @FlagZdvojeni = 1
				EXEC dbo.hp_ZdvojeniKonstrukceATech 
					@IDVyssi = @dilec
					,@IDZmena = @IDZmeny;
				SET @FlagZdvojeni = NULL;
			END;
		
		-- samotne nastaveni odvadeci operac
		UPDATE TabPostup 
			SET Odvadeci = 0 
		WHERE Dilec = @dilec
			AND (IDZakazModif IS NULL OR IDZakazModif = @IDZakazModif) 
			AND (IDVarianta IS NULL OR IDVarianta = @IDVarianta) 
			AND zmenaOd = @IDZmeny
			AND Odvadeci = 1;
			
		UPDATE TabPostup 
			SET Odvadeci = 1 
		WHERE Dilec = @dilec
			AND (IDZakazModif IS NULL OR IDZakazModif = @IDZakazModif) 
			AND (IDVarianta IS NULL OR IDVarianta = @IDVarianta) 
			AND Operace = @Operace
			AND zmenaOd = @IDZmeny
			AND Odvadeci = 0;
		
	COMMIT;
	
	-- závěrečná hláška
	IF NOT EXISTS (SELECT * FROM #TabExtKom WHERE Poznamka LIKE N'Info: Hromadné nastavení odvěděcí operace%')
		BEGIN
			INSERT INTO #TabExtKom(Poznamka) VALUES(N'Info: Hromadné nastavení odvěděcí operace');
			INSERT INTO #TabExtKom(Poznamka) VALUES(N'-------------------------------------------------------------------------------');
		END;
	INSERT INTO #TabExtKom(Poznamka)
	SELECT (K.SkupZbo + N' ' + K.RegCis + N' - ' + Nazev1 + N' - OK - Operace: ' + P.Operace + N' - ' + nazev + N' - nastavena jako odváděcí')
	FROM TabPostup P
		INNER JOIN TabKmenZbozi K ON P.dilec = K.ID
	WHERE P.ID = @ID;

END TRY
--zacneme CATCH
BEGIN CATCH

	IF @@TRANCOUNT > 0 AND @TranCountPred=0
		ROLLBACK TRANSACTION;
	DECLARE @ErrorMessage NVARCHAR(4000);
	SELECT @ErrorMessage = CASE 
		WHEN @FlagZdvojeni = 1 THEN N'Chyba při generování konstrukce a technologie pro vybranou změnu' 
		ELSE ERROR_MESSAGE() END;
	
	IF NOT EXISTS (SELECT * FROM #TabExtKom WHERE Poznamka LIKE N'Info: Hromadné nastavení odvěděcí operace%')
		BEGIN
			INSERT INTO #TabExtKom(Poznamka) VALUES(N'Info: Hromadné nastavení odvěděcí operace');
			INSERT INTO #TabExtKom(Poznamka) VALUES(N'-------------------------------------------------------------------------------');
		END;
	INSERT INTO #TabExtKom(Poznamka)
	SELECT (K.SkupZbo + N' ' + K.RegCis + N' - ' + Nazev1 + N' !!! CHYBA !!! - ' + P.Operace + N' - ' + nazev + N' - ' + @ErrorMessage)
	FROM TabPostup P
		INNER JOIN TabKmenZbozi K ON P.dilec = K.ID
	WHERE P.ID = @ID;
	
END CATCH;
GO

