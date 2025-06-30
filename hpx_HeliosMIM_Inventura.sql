USE [RayService]
GO

/****** Object:  StoredProcedure [dbo].[hpx_HeliosMIM_Inventura]    Script Date: 30.06.2025 8:15:12 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

CREATE PROC [dbo].[hpx_HeliosMIM_Inventura]
@DatumInventury DATETIME,
@DatumZahajeni DATETIME,
@Nazev NVARCHAR(50),
@PoznamkaIN NVARCHAR(MAX),
@Data NVARCHAR(MAX),
@IDInventury INT = NULL
AS

BEGIN TRAN
BEGIN TRY

	IF OBJECT_ID(N'tempdb..#TabExtAkce','U')IS NOT NULL
	BEGIN
		ALTER TABLE #TabExtAkce ADD MaInvID INT
		
		CREATE TABLE #TabExtAkceInt (MaInvID INT) 
	END

    
	IF (@IDInventury IS NULL) OR (@IDInventury = 0)
	BEGIN
		INSERT INTO TabMaInv
			(TabMaInv.Nazev ,
                   TabMaInv.TypInv,
                   TabMaInv.DatumInventury ,
                   TabMaInv.DatumZahajeni,
                   TabMaInv.Poznamka ,
                   TabMaInv.Osoba)
		VALUES
            (@Nazev,
             12,                                -- carovy kod
             @DatumInventury,
             @DatumZahajeni,
             @PoznamkaIN,
            '' )
		SELECT @IDInventury = SCOPE_IDENTITY()
	END
	ELSE
		UPDATE TabMaInv SET TypInv = 12 /*carovy kod*/ WHERE Id = @IDInventury

	IF OBJECT_ID(N'tempdb..#TabExtAkce','U')IS NOT NULL
	BEGIN
		INSERT INTO #TabExtAkceInt                           
		SELECT @IDInventury
		INSERT INTO #TabExtAkce                           
		SELECT * FROM #TabExtAkceInt
	END
	
	IF OBJECT_ID(N'tempdb..#TabMaInvCK','U')IS NOT NULL
		DROP TABLE #TabMaInvCK

	SELECT TOP 0 
		CarKod,
        CisloMaj,
        CisloNakladovyOkruh,
        KodLok,
        Nazev1,
        IdMaInv,
        Prislusenstvi,
        TypMaj,
        VyrCislo,
        Vysledek,
        Poznamka,
		CisZam,
		Vyrazeni,
		NovaPolozka,
        DatumNalezu
	INTO #TabMaInvCK
	FROM TabMaInvCK

	
	DECLARE @Dnes DATETIME

	SET @Dnes = GETDATE()

	DECLARE @XmlData xml 

	SET @XmlData = @Data

    INSERT INTO #TabMaInvCK (
        CarKod,
        CisloMaj,
        CisloNakladovyOkruh,
        KodLok,
        Nazev1,
        IdMaInv,
        Prislusenstvi,
        TypMaj,
        VyrCislo,
        Vysledek,
        Poznamka,
		CisZam,
		Vyrazeni,
		NovaPolozka,
        DatumNalezu
    )
    
	SELECT	x.value('carkod[1]', 'nvarchar(20)') AS CarKod,
			RIGHT(N'00000000' + RTRIM(x.value('cislomaj[1]', 'nvarchar(8)')), 8) AS CisloMaj, 
			x.value('cislonakladovyokruh[1]', 'nvarchar(15)') AS CisloNakladovyOkruh,
			x.value('kodlok[1]', 'nvarchar(20)') AS KodLok,
			x.value('nazev[1]', 'nvarchar(50)') AS Nazev1,
	         @IDInventury AS IdMaInv,--x.value('IdMaInv[1]', 'int') AS IdMaInv,
		    x.value('prislusenstvi[1]', 'nvarchar(4)') AS Prislusenstvi,
			x.value('typmaj[1]', 'nvarchar(3)') AS TypMaj,
			x.value('vyrcislo[1]', 'nvarchar(20)') AS VyrCislo, 
	        x.value('vysledek[1]', 'nvarchar(1)') AS Vysledek,
		    x.value('poznamka[1]', 'nvarchar(MAX)') AS Poznamka,
			case when ((x.value('ciszam[1]', 'nvarchar(10)') = N'0') OR (x.value('ciszam[1]', 'nvarchar(10)') = N'')) then NULL else x.value('ciszam[1]', 'int') end  AS CisZam,
			x.value('vyrazeno[1]', 'nvarchar(3)') AS Vyrazeni,
			x.value('novymajetek[1]', 'nvarchar(3)') AS NovaPolozka,
            x.value('zpracovano[1]', 'datetime') AS DatumNalezu

       FROM @xmlData.nodes('//row') XmlData(x)

	DECLARE @CarKod nchar(20), @Vyrazeni BIT, @CisloMaj nchar(8), @CisloNakladovyOkruh nvarchar(15), @KodLok nvarchar(20), @Nazev1 nvarchar(50), @IdMaInv INT, @Prislusenstvi nchar(4), @TypMaj nchar(4), @VyrCislo nvarchar(20)
	DECLARE @Vysledek nchar(1), @Poznamka nvarchar(MAX), @CisZam INT, @NovaPolozka BIT, @JizExistuje BIT
	
	DECLARE @Ulozit BIT
	
	DECLARE C_MaInvCK CURSOR FOR SELECT TypMaj, CisloMaj, Vyrazeni, Vysledek FROM #TabMaInvCK
	OPEN C_MaInvCK
	WHILE 1=1
	BEGIN
		FETCH NEXT FROM C_MaInvCK INTO @TypMaj, @CisloMaj, @Vyrazeni, @Vysledek
		IF @@FETCH_STATUS<>0 BREAK
		
		IF EXISTS(SELECT * FROM TabMaInvCK WHERE TypMaj = @TypMaj AND CisloMaj = @CisloMaj AND IdMaInv = @IDInventury)
			SET @JizExistuje = 1
		ELSE
			SET @JizExistuje = 0
		
		If @JizExistuje = 1
		BEGIN
			IF (@Vysledek = 0)
				SET @Ulozit = 0
			ELSE
			BEGIN
				DECLARE @Pocet INT
				SELECT @Pocet = COUNT(*) 
				FROM TabMaInvCK m
				JOIN #TabMaInvCK pom ON m.CarKod = pom.CarKod AND ISNULL(m.CisloNakladovyOkruh, N'') = ISNULL(pom.CisloNakladovyOkruh, N'') AND ISNULL(m.KodLok, N'') = ISNULL(pom.KodLok, N'') AND m.Nazev1 = pom.Nazev1 AND 
					m.Prislusenstvi = pom.Prislusenstvi AND m.VyrCislo = pom.VyrCislo AND m.Vysledek = pom.Vysledek   AND 
					m.TypMaj = pom.TypMaj AND m.CisloMaj = pom.CisloMaj AND  pom.TypMaj= @TypMaj AND pom.CisloMaj = @CisloMaj AND m.IdMaInv = pom.IdMaInv
					AND ISNULL(CAST(m.Poznamka AS nvarchar(MAX)), N'') = ISNULL(CAST(pom.Poznamka AS nvarchar(MAX)), N'') AND m.Vyrazeni = pom.Vyrazeni  AND m.NovaPolozka = pom.NovaPolozka AND ISNULL(m.CisZam,-1) = ISNULL(pom.CisZam,-1)

				/*	(SELECT CarKod, CisloMaj, CisloNakladovyOkruh, KodLok, Nazev1, IdMaInv, Prislusenstvi, TypMaj, VyrCislo, Vysledek, CAST(Poznamka AS nvarchar(MAX)) poz, CisZam, Vyrazeni, NovaPolozka 
					 FROM #TabMaInvCK 
					 WHERE TypMaj = @TypMaj AND CisloMaj = @CisloMaj
					UNION
					SELECT CarKod, CisloMaj, CisloNakladovyOkruh, KodLok, Nazev1, IdMaInv, Prislusenstvi, TypMaj, VyrCislo, Vysledek, CAST(Poznamka AS nvarchar(MAX)) poz, CisZam, Vyrazeni, NovaPolozka 
					FROM TabMaInvCK 
					WHERE TypMaj = @TypMaj AND CisloMaj = @CisloMaj AND IdMaInv = @IDInventury) t*/
				IF @Pocet >= 1
					SET @Ulozit = 0
				ELSE
					SET @Ulozit = 1
			END
		END
		ELSE
			SET @Ulozit = 1
			
		IF @Ulozit = 1
		BEGIN
			DELETE FROM TabMaInvCK WHERE TypMaj = @TypMaj AND CisloMaj = @CisloMaj AND IdMaInv = @IDInventury AND Vysledek = 0
			INSERT INTO TabMaInvCK (CarKod,
				CisloMaj,
				CisloNakladovyOkruh,
				KodLok,
				Nazev1,
				IdMaInv,
				Prislusenstvi,
				TypMaj,
				VyrCislo,
				Vysledek,
				Poznamka,
				CisZam,
				Vyrazeni,
				NovaPolozka,
                DatumNalezu)
			SELECT CarKod,
				RIGHT(N'00000000' + RTRIM(CisloMaj), 8),
				CisloNakladovyOkruh,
				KodLok,
				Nazev1,
				IdMaInv,
				Prislusenstvi,
				TypMaj,
				VyrCislo,
				Vysledek,
				Poznamka,
				CisZam,
				Vyrazeni,
				NovaPolozka,
                DatumNalezu
			FROM #TabMaInvCK
			WHERE TypMaj = @TypMaj AND CisloMaj = @CisloMaj
		END
	END

	CLOSE C_MaInvCK
	DEALLOCATE C_MaInvCK

	exec hp_Ma_VyhodnoceniInventuryCK @Dnes, @IDInventury

END TRY
BEGIN CATCH
	DECLARE @ErrorMessage NVARCHAR(4000);
	SELECT @ErrorMessage = 'Došlo k chybě, záznam se neuložil. ' + ERROR_MESSAGE()
	IF @@TRANCOUNT > 0 
		ROLLBACK;
    THROW 50001,@ErrorMessage,1
END CATCH

IF @@TRANCOUNT > 0
	COMMIT
GO

