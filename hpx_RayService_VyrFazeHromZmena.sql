USE [RayService]
GO

/****** Object:  StoredProcedure [dbo].[hpx_RayService_VyrFazeHromZmena]    Script Date: 26.06.2025 9:04:05 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO


-- =============================================
-- Author:		DJ
-- Description:	Výrobní fáze - hromadná změna
-- =============================================
CREATE PROCEDURE [dbo].[hpx_RayService_VyrFazeHromZmena]
	@Smazat BIT			-- smazat oznacene
	,@TypAkce TINYINT	-- typ akce, 1-Přidej fázi, 2-Odeber fázi
AS
SET NOCOUNT ON;

-- * průchod - smazat v tabulce označených
IF @Smazat = 1
	BEGIN
		DELETE FROM Tabx_ReseniHeO_SpidOzn
		WHERE TabName = N'TabTypPostup'
			AND SPID = @@SPID;
		
		RETURN;
	END;


/* deklarace */
DECLARE @Poradi INT;
DECLARE @HlaskaFaze NVARCHAR(255);
DECLARE @IDTypPostup INT;
DECLARE @IDKmenZbozi INT;

BEGIN TRY

	/* kontroly */
	IF NOT EXISTS(SELECT * FROM #TabExtKomID)
		BEGIN
			RAISERROR (N'Nebyly označeny žádné nakupované materiály pro zpracování!',16,1);
			RETURN
		END;
		
	IF NOT EXISTS(SELECT * FROM Tabx_ReseniHeO_SpidOzn
		WHERE TabName = N'TabTypPostup'
			AND SPID = @@SPID)
		BEGIN
			RAISERROR (N'Nebyly označeny žádné výrobní fáze pro zpracování!',16,1);
			RETURN
		END;
		
	IF @TypAkce NOT IN (1,2)
		BEGIN
			RAISERROR (N'Neznámý identifikátor prováděné akce!',16,1);
			RETURN;
		END;

	/* funkční tělo procedury */

	-- hlavička

	IF NOT EXISTS (SELECT * FROM #TabExtKom WHERE Poznamka LIKE N'Info: Hromadná změna výrobních fází%')
		BEGIN
			INSERT INTO #TabExtKom(Poznamka) VALUES(N'Info: Hromadná změna výrobních fází - ' + CASE @TypAkce WHEN 1 THEN 'Přidej fázi' ELSE 'Odeber fázi' END);
			INSERT INTO #TabExtKom(Poznamka) VALUES(N'-------------------------------------------------------------------------------');
		END;

	-- procházíme označené řádky

	DECLARE CurMaterialy CURSOR LOCAL FAST_FORWARD FOR
		SELECT 
			ID
		FROM #TabExtKomID; -- {select}
	OPEN CurMaterialy;
	FETCH NEXT FROM CurMaterialy INTO @IDKmenZbozi; -- {proměnné}
		WHILE (@@FETCH_STATUS = 0) AND (@@ERROR = 0)
		BEGIN
			-- zacatek akce v kurzoru CurMaterialy
			
			INSERT INTO #TabExtKom(Poznamka)
			SELECT (SkupZbo + N' ' + RegCis + N' - ' + Nazev1)
			FROM TabKmenZbozi
			WHERE ID = @IDKmenZbozi;
			
			INSERT INTO #TabExtKom(Poznamka) VALUES(N'-------------------------------------------------------------------------------');
			
			
			DECLARE CurFaze CURSOR LOCAL FAST_FORWARD FOR
				SELECT 
					P.Cislo
					,P.nazev
				FROM Tabx_ReseniHeO_SpidOzn O
					INNER JOIN TabTypPostup P ON O.IDTab = P.ID
				WHERE O.TabName = N'TabTypPostup'
					AND O.SPID = @@SPID; -- {select}
			OPEN CurFaze;
			FETCH NEXT FROM CurFaze INTO @IDTypPostup, @HlaskaFaze; -- {proměnné}
				WHILE (@@FETCH_STATUS = 0) AND (@@ERROR = 0)
				BEGIN
					-- zacatek akce v kurzoru CurFaze
					
					-- pridání
					IF @TypAkce = 1
						BEGIN
						
							IF EXISTS(SELECT * FROM Tabx_RayService_MatVyrFaze
										WHERE IDKmenZbozi = @IDKmenZbozi
											AND IDTypPostup = @IDTypPostup)
								INSERT INTO #TabExtKom(Poznamka)
								VALUES(N'- X - ' + @HlaskaFaze + ' - materiál již má fázi přiřazenu');
							ELSE
								BEGIN
									
									SELECT @Poradi = (ISNULL(MAX(Poradi),0) + 1 )
									FROM Tabx_RayService_MatVyrFaze
									WHERE IDKmenZbozi = @IDKmenZbozi;

									-- vložíme
									INSERT INTO Tabx_RayService_MatVyrFaze(
										IDKmenZbozi
										,IDTypPostup
										,Poradi)
									VALUES(
										@IDKmenZbozi
										,@IDTypPostup
										,@Poradi);
										
									INSERT INTO #TabExtKom(Poznamka)
									VALUES(N'- OK - ' + @HlaskaFaze + N' - přidáno');
									
								END;
						
						END;
						
					-- smazání
					IF @TypAkce = 2
						BEGIN
						
							IF EXISTS(SELECT * FROM Tabx_RayService_MatVyrFaze
										WHERE IDKmenZbozi = @IDKmenZbozi
											AND IDTypPostup = @IDTypPostup)
								BEGIN
									
									DELETE FROM Tabx_RayService_MatVyrFaze 
									WHERE IDKmenZbozi = @IDKmenZbozi
											AND IDTypPostup = @IDTypPostup;
							
									EXEC dbo.hpx_RayService_VyrFazeSetres
										 @IDKmenZbozi;
										
									INSERT INTO #TabExtKom(Poznamka)
									VALUES(N'- OK - ' + @HlaskaFaze + N' - fáze odebrána');
									
								END;
							ELSE
								INSERT INTO #TabExtKom(Poznamka)
								VALUES(N'- X - ' + @HlaskaFaze + ' - materiál nemá fázi přiřazenu');
						END;
					
					
					-- konec akce v kurzoru CurFaze
				FETCH NEXT FROM CurFaze INTO @IDTypPostup, @HlaskaFaze; -- {proměnné}
				END;
			CLOSE CurFaze;
			DEALLOCATE CurFaze;
			
	
			INSERT INTO #TabExtKom(Poznamka) VALUES(N'-------------------------------------------------------------------------------');
			
			-- konec akce v kurzoru CurMaterialy
		FETCH NEXT FROM CurMaterialy INTO @IDKmenZbozi; -- {proměnné}
		END;
	CLOSE CurMaterialy;
	DEALLOCATE CurMaterialy;
	
	DELETE FROM Tabx_ReseniHeO_SpidOzn
	WHERE TabName = N'TabTypPostup'
		AND SPID = @@SPID;

END TRY
--zacneme CATCH
BEGIN CATCH

	DELETE FROM Tabx_ReseniHeO_SpidOzn
	WHERE TabName = N'TabTypPostup'
		AND SPID = @@SPID;
			
	DECLARE @ErrorMessage NVARCHAR(4000);
	SELECT @ErrorMessage = ERROR_MESSAGE();
	RAISERROR (@ErrorMessage,16,1);
	RETURN;
	
END CATCH;
GO

