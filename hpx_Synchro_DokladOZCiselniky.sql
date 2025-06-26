USE [RayService]
GO

/****** Object:  StoredProcedure [dbo].[hpx_Synchro_DokladOZCiselniky]    Script Date: 26.06.2025 8:48:51 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO



-- =============================================
-- Author:		DJ
-- Description:	Synchronizace - Číselníky dokladu OZ
-- =============================================
CREATE PROCEDURE [dbo].[hpx_Synchro_DokladOZCiselniky]
	@TypSynchro TINYINT			-- Identifikátor synchronizace
	,@TypSynchroOrg TINYINT		-- Identifikátor synchronizace - Organizace
	,@TypSynchroKmen TINYINT	-- Identifikátor synchronizace - Kmenové karty
	,@IDDokladZdroj INT		-- ID dokladu v TabDokladyZbozi
AS
SET NOCOUNT ON;
/* deklarace */
DECLARE @DBZdroj NVARCHAR(2);
DECLARE @DBCil NVARCHAR(2);
DECLARE @DBVerName NVARCHAR(100);
DECLARE @IDOrgZdroj INT;
DECLARE @IDMistoUrceniZdroj INT;
DECLARE @IDPrijemceZdroj INT;
DECLARE @IDKmenZboziZdroj INT;
DECLARE @CisloOrg INT;
DECLARE @MistoUrceni INT;
DECLARE @Prijemce INT;
DECLARE @Error NVARCHAR(255);
DECLARE @ParovaciZnak NVARCHAR(20);
DECLARE @TypChyby TINYINT;
DECLARE @Prah SMALLINT;
DECLARE @Org TABLE(
	IDOrg INT NOT NULL
	,CisloOrg INT NOT NULL
	,Typ TINYINT NOT NULL);

SELECT
	@ParovaciZnak = D.ParovaciZnak
	,@IDOrgZdroj = O.ID
	,@IDMistoUrceniZdroj = M.ID
	,@IDPrijemceZdroj = P.ID
	,@CisloOrg = D.CisloOrg
	,@MistoUrceni = D.MistoUrceni
	,@Prijemce = D.Prijemce
FROM TabDokladyZbozi D
	LEFT OUTER JOIN TabCisOrg O ON D.CisloOrg = O.CisloOrg
	LEFT OUTER JOIN TabCisOrg M ON D.MistoUrceni = M.CisloOrg
	LEFT OUTER JOIN TabCisOrg P ON D.Prijemce = P.CisloOrg
WHERE D.ID = @IDDokladZdroj;

SELECT 
	@DBCil = DBCil
	,@DBZdroj = DBZdroj
FROM Tabx_SynchroTyp
WHERE TypSynchro = @TypSynchro;

SET @Prah = 30; -- práh spuštění aktualizace návazných číselníků (v sekundách)

-- již bylo synchronizováno
IF EXISTS(SELECT * FROM Tabx_SynchroLog 
					WHERE Tab = N'TabDokladyZbozi'
					AND IdTab = @IDDokladZdroj 
					AND TypSynchro = @TypSynchro
					AND Synchro = 0)
	RETURN;

/* funkční tělo procedury */
BEGIN TRY
	
	-- * synchronizace Kmenových karet
	IF @TypSynchroKmen IS NOT NULL
		BEGIN
		
			SET @TypChyby = 1
			DECLARE CurKmen CURSOR LOCAL FAST_FORWARD FOR
				SELECT
					K.ID
				FROM TabPohybyZbozi P
					INNER JOIN TabStavSkladu S ON P.IDZboSklad = S.ID
					INNER JOIN TabKmenZbozi K ON S.IDKmenZbozi = K.ID
					LEFT OUTER JOIN Tabx_SynchroLog SY ON SY.Tab = N'TabKmenZbozi' AND K.ID = SY.IdTab AND SY.TypSynchro = @TypSynchroKmen
				WHERE P.IDDoklad = @IDDokladZdroj
					AND (SY.DatSynchro IS NULL
						OR SY.Synchro = 1
						OR DATEDIFF(SECOND,SY.DatSynchro,GETDATE()) > @Prah);
			OPEN CurKmen;
			FETCH NEXT FROM CurKmen INTO @IDKmenZboziZdroj; -- {proměnné}
				WHILE (@@FETCH_STATUS = 0) AND (@@ERROR = 0)
				BEGIN
					-- zacatek akce v kurzoru CurKmen
					
					EXEC [dbo].[hpx_Synchro_KmenZboziZdroj]
						@TypSynchroKmen	-- Identifikátor synchronizace
						,1				-- @ZDokladu / volání z dokladu 1-Ano,0-ne
						,1				-- @TypAkce / typ akce 0-INSERT,1-UPDATE,2-DELETE,9-test existence
						,@Error OUT		-- návratová hodnota chyby
						,@IDKmenZboziZdroj -- ID v TabKmenZbozi
					
					IF @Error IS NOT NULL
						BEGIN
							RAISERROR (@Error,16,1);
							RETURN;
						END;
					
					-- konec akce v kurzoru CurKmen
				FETCH NEXT FROM CurKmen INTO @IDKmenZboziZdroj; -- {proměnné}
				END;
			CLOSE CurKmen;
			DEALLOCATE CurKmen;
		
		END;
		
	-- synchronizace organizací
	IF @TypSynchroOrg IS NOT NULL
		BEGIN
		
			INSERT INTO @Org(
				IDOrg
				,CisloOrg
				,Typ)
			SELECT 
				T.IDOrg
				,T.CisloOrg
				,T.Typ
			FROM (SELECT @IDOrgZdroj as IDOrg, @CisloOrg as CisloOrg, CAST(2 as TINYINT) as Typ
				UNION ALL SELECT @IDMistoUrceniZdroj, @MistoUrceni, 3
				UNION ALL SELECT @IDPrijemceZdroj, @Prijemce, 4) as T
			WHERE T.CisloOrg IS NOT NULL;
			
			DECLARE CurOrg CURSOR LOCAL FAST_FORWARD FOR
				SELECT
					O.IDOrg
					,O.Typ
				FROM @Org O
					LEFT OUTER JOIN Tabx_SynchroLog SY ON SY.Tab = N'TabCisOrg' AND O.CisloOrg = SY.IdTab AND SY.TypSynchro = @TypSynchroOrg
				WHERE SY.DatSynchro IS NULL
					OR SY.Synchro = 1
					OR DATEDIFF(SECOND,SY.DatSynchro,GETDATE()) > @Prah;
			OPEN CurOrg;
			FETCH NEXT FROM CurOrg INTO @IDOrgZdroj, @TypChyby; -- {proměnné}
				WHILE (@@FETCH_STATUS = 0) AND (@@ERROR = 0)
				BEGIN
					-- zacatek akce v kurzoru CurOrg
					
					EXEC [dbo].[hpx_Synchro_Organizace]
						@TypSynchroOrg	-- Identifikátor synchronizace
						,1				-- volání z dokladu 1-Ano,0-ne
						,@Error OUT		-- návratová hodnota chyby
						,@IDOrgZdroj	-- ID v TabCisOrg
					
					IF @Error IS NOT NULL
						BEGIN
							RAISERROR (@Error,16,1);
							RETURN;
						END;
					
					-- konec akce v kurzoru CurOrg
				FETCH NEXT FROM CurOrg INTO @IDOrgZdroj, @TypChyby; -- {proměnné}
				END;
			CLOSE CurOrg;
			DEALLOCATE CurOrg;
	
		END;
		
END TRY
--zacneme CATCH
BEGIN CATCH
	
	DECLARE @ErrorMessage NVARCHAR(4000);
	SELECT @ErrorMessage = CASE @TypChyby 
		WHEN 1 THEN N'Kmenové karty dokladu '
		WHEN 2 THEN N'Organizace dokladu '
		WHEN 3 THEN N'Místo určení dokladu '
		WHEN 2 THEN N'Příjemce dokladu '
		ELSE N'Návazné číselníky ' END + ERROR_MESSAGE();
	
	-- hláška uživateli - spouštěno z akce
	IF OBJECT_ID('tempdb..#TabExtKom') IS NOT NULL
		BEGIN
			IF NOT EXISTS (SELECT * FROM #TabExtKom WHERE Poznamka LIKE N'Info: Synchronizace dokladů%')
				BEGIN
					INSERT INTO #TabExtKom(Poznamka) VALUES(N'Info: Synchronizace dokladů');
					INSERT INTO #TabExtKom(Poznamka) VALUES(N'-------------------------------------------------------------------------------');
				END;
			INSERT INTO #TabExtKom(Poznamka)
			VALUES(@ParovaciZnak + ' - !! CHYBA !! Synchronizace číselníků dokladu OZ - ' + @ErrorMessage);
		END;
	
	-- zápis do log tabulky synchronizace
	IF NOT EXISTS(SELECT * FROM Tabx_SynchroLog 
				WHERE Tab = N'TabDokladyZbozi'
				AND IdTab = @IDDokladZdroj
				AND TypSynchro = @TypSynchro)
		INSERT INTO Tabx_SynchroLog (
			TypSynchro
			,Tab
			,IdTab
			,IdTabCil
			,DatSynchro
			,Synchronizoval
			,Zprava
			,Synchro)
		VALUES (
			@TypSynchro
			,N'TabDokladyZbozi'
			,@IDDokladZdroj
			,NULL
			,GETDATE()
			,SUSER_SNAME()
			,@ErrorMessage
			,CASE WHEN @ErrorMessage IS NULL THEN 0 ELSE 1 END);
	ELSE
		UPDATE Tabx_SynchroLog SET
			IdTabCil = NULL
			,DatSynchro = GETDATE()
			,Synchronizoval = SUSER_SNAME()
			,Zprava = @ErrorMessage
			,Synchro = CASE WHEN @ErrorMessage IS NULL THEN 0 ELSE 1 END
		WHERE Tab = N'TabDokladyZbozi'
			AND IdTab = @IDDokladZdroj
			AND TypSynchro = @TypSynchro;

END CATCH;
GO

