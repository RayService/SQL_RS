USE [RayService]
GO

/****** Object:  StoredProcedure [dbo].[hpx_RS_doklad_ke_schvaleni]    Script Date: 26.06.2025 10:37:29 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

CREATE PROCEDURE [dbo].[hpx_RS_doklad_ke_schvaleni] @IdDoklad INT
AS
--DECLARE @IdDoklad INT=1242988;
DECLARE @TypDokladu INT;
DECLARE @DruhPohybuZbo INT;
DECLARE @RadaDokladu NVARCHAR(3);
DECLARE @IDSklad NVARCHAR(30);
DECLARE @Cena NUMERIC (19,2);
DECLARE @CenaAlt NUMERIC (19,2);
DECLARE @Schvaleny_dodavatel NVARCHAR(15);
DECLARE @Schvaleny_doklad BIT;
SET @TypDokladu = 0;
SET @DruhPohybuZbo = (SELECT DruhPohybuZbo FROM TabDokladyZbozi WHERE ID=@IdDoklad);
SET @Cena = (SELECT SumaKcBezDPH FROM TabDokladyZbozi WHERE ID=@IdDoklad);
SET @CenaAlt = (SELECT SUM(P.CCbezDaniKcPoS)
				FROM TabPohybyZbozi P WITH(NOLOCK)
				LEFT OUTER JOIN TabPohybyZbozi_EXT PE WITH(NOLOCK) ON P.ID = PE.ID
				WHERE P.IDDoklad = @IdDoklad AND ISNULL(PE._PrevodA,0) = 0)
SET @RadaDokladu = (SELECT RadaDokladu FROM TabDokladyZbozi WHERE ID=@IdDoklad);
SET @IDSklad = (SELECT IDSklad FROM TabDokladyZbozi WHERE ID=@IdDoklad);

--zařídíme existenci externí tabulky
IF NOT EXISTS (SELECT ID FROM TabDokladyZbozi_EXT WHERE ID=@IdDoklad)
BEGIN
INSERT INTO TabDokladyZbozi_EXT (ID) VALUES (@IdDoklad);
END;
SET @Schvaleny_dodavatel = (SELECT ISNULL(tco_EXT._stav_dodavatele,'')
							FROM TabDokladyZbozi WITH(NOLOCK)
							LEFT OUTER JOIN TabCisOrg tco WITH(NOLOCK) ON TabDokladyZbozi.CisloOrg=tco.CisloOrg
							LEFT OUTER JOIN TabCisOrg_EXT tco_EXT WITH(NOLOCK) ON tco_EXT.ID=tco.ID
							WHERE TabDokladyZbozi.ID = @IdDoklad);
SET @Schvaleny_doklad = (SELECT ISNULL(tde._EXT_RS_doklad_ke_schvaleni,0)
							FROM TabDokladyZbozi_EXT tde WITH(NOLOCK)
							WHERE tde.ID = @IdDoklad);

BEGIN
--řádek 11-OBCHOD Kupní smlouva, potvrzení objednávky 100.000,- Kč - 500.000,- Kč včetně
IF ((@DruhPohybuZbo = 9 AND @RadaDokladu IN ('400','410','411') AND @IDSklad <> N'200') OR (@DruhPohybuZbo = 11 AND @RadaDokladu IN ('382','385'))) AND (@Cena > 100000 AND @Cena <= 500000)
	BEGIN			  
		IF (NOT EXISTS (SELECT ID FROM Tabx_SDPredpisy WHERE IdDoklad = @IdDoklad) AND @Schvaleny_doklad <> 1)
			BEGIN
			EXEC dbo.hpx_SDPripojPredpis
			@IdDoklad,41290
			INSERT INTO Tabx_SDLog(TypZaznamu, IdDoklad, TypDokladu, SchvaleniStav) VALUES(1, @IdDoklad, @TypDokladu, 3);
			END
	END
--řádek 12-OBCHOD Kupní smlouva, potvrzení objednávky 500.000,- Kč - 1.000.000,- Kč včetně
--20.4.2021 MŽ: upraveno KS nad 500 tis do 3 mil včetně
IF ((@DruhPohybuZbo = 9 AND @RadaDokladu IN ('400','410','411') AND @IDSklad <> N'200') OR (@DruhPohybuZbo = 11 AND @RadaDokladu IN ('382','385'))) AND (@Cena > 500000 AND @Cena <= 3000000)
	BEGIN			  
		IF (NOT EXISTS (SELECT ID FROM Tabx_SDPredpisy WHERE IdDoklad = @IdDoklad) AND @Schvaleny_doklad <> 1)
			BEGIN
			EXEC dbo.hpx_SDPripojPredpis
			@IdDoklad,41291
			INSERT INTO Tabx_SDLog(TypZaznamu, IdDoklad, TypDokladu, SchvaleniStav) VALUES(1, @IdDoklad, @TypDokladu, 3);
			END
	END
--řádek 13-OBCHOD Kupní smlouva, potvrzení objednávky nad 1.000.000,- Kč
--20.4.2021 MŽ: upraveno KS nad 3 mil
IF ((@DruhPohybuZbo = 9 AND @RadaDokladu IN ('400','410','411') AND @IDSklad <> N'200') OR (@DruhPohybuZbo = 11 AND @RadaDokladu IN ('382','385'))) AND (@Cena > 3000000)
	BEGIN			  
		IF (NOT EXISTS (SELECT ID FROM Tabx_SDPredpisy WHERE IdDoklad = @IdDoklad) AND @Schvaleny_doklad <> 1)
			BEGIN
			EXEC dbo.hpx_SDPripojPredpis
			@IdDoklad,41292
			INSERT INTO Tabx_SDLog(TypZaznamu, IdDoklad, TypDokladu, SchvaleniStav) VALUES(1, @IdDoklad, @TypDokladu, 3);
			END
	END
--řádek 14-VÝROBA Kupní smlouva, smlouva o dílo, potvrzení objednávky 250.000,- Kč - 1.000.000,- Kč včetně
--20.4.2021 MŽ: upraveno KS nad 300 tis do 3 mil včetně, řádek 15
IF ((@DruhPohybuZbo = 9 AND @RadaDokladu IN ('400','410','411','420','430','474') AND @IDSklad = N'200') OR (@DruhPohybuZbo = 11 AND @RadaDokladu IN ('383','384'))) AND (@Cena > 300000 AND @Cena <= 1000000)
	BEGIN			  
		IF (NOT EXISTS (SELECT ID FROM Tabx_SDPredpisy WHERE IdDoklad = @IdDoklad) AND @Schvaleny_doklad <> 1)
			BEGIN
			EXEC dbo.hpx_SDPripojPredpis
			@IdDoklad,41293
			INSERT INTO Tabx_SDLog(TypZaznamu, IdDoklad, TypDokladu, SchvaleniStav) VALUES(1, @IdDoklad, @TypDokladu, 3);
			END
	END
--řádek 15-VÝROBA Kupní smlouva, smlouva o dílo, potvrzení objednávky nad 1.000.000,- Kč
--20.4.2021 MŽ: upraveno KS nad 1 mil do 3 mil včetně, řádek 16
IF ((@DruhPohybuZbo = 9 AND @RadaDokladu IN ('400','410','411','420','430','474') AND @IDSklad = N'200') OR (@DruhPohybuZbo = 11 AND @RadaDokladu IN ('383','384'))) AND (@Cena > 1000000 AND @Cena <= 3000000)
	BEGIN			  
		IF (NOT EXISTS (SELECT ID FROM Tabx_SDPredpisy WHERE IdDoklad = @IdDoklad) AND @Schvaleny_doklad <> 1)
			BEGIN
			EXEC dbo.hpx_SDPripojPredpis
			@IdDoklad,41294
			INSERT INTO Tabx_SDLog(TypZaznamu, IdDoklad, TypDokladu, SchvaleniStav) VALUES(1, @IdDoklad, @TypDokladu, 3);
			END
	END
--řádek 17-VÝROBA Kupní smlouva, smlouva o dílo, potvrzení objednávky nad 3.000.000,- Kč
--20.4.2021 MŽ
IF ((@DruhPohybuZbo = 9 AND @RadaDokladu IN ('400','410','411','420','430','474') AND @IDSklad = N'200') OR (@DruhPohybuZbo = 11 AND @RadaDokladu IN ('383','384'))) AND (@Cena > 3000000)
	BEGIN			  
		IF (NOT EXISTS (SELECT ID FROM Tabx_SDPredpisy WHERE IdDoklad = @IdDoklad) AND @Schvaleny_doklad <> 1)
			BEGIN
			EXEC dbo.hpx_SDPripojPredpis
			@IdDoklad,61192
			INSERT INTO Tabx_SDLog(TypZaznamu, IdDoklad, TypDokladu, SchvaleniStav) VALUES(1, @IdDoklad, @TypDokladu, 3);
			END
	END
--řádek 2-Objednávky 50.000 - 100.0000 včetně
--22.4.2021 MŽ vyřazena podmínka na schváleného dodavatele
IF ((@DruhPohybuZbo = 6 AND @RadaDokladu IN ('800','850','860','861','810','820'))) AND (@Cena >= 50000 AND @Cena < 100000)-- AND (@Schvaleny_dodavatel LIKE 'Schválený%')
	BEGIN			  
		IF (NOT EXISTS (SELECT ID FROM Tabx_SDPredpisy WHERE IdDoklad = @IdDoklad) AND @Schvaleny_doklad <> 1)
			BEGIN
			EXEC dbo.hpx_SDPripojPredpis
			@IdDoklad,41282
			INSERT INTO Tabx_SDLog(TypZaznamu, IdDoklad, TypDokladu, SchvaleniStav) VALUES(1, @IdDoklad, @TypDokladu, 3);
			END
	END
--řádek 3-Objednávky nad 100.0000
--22.4.2021 MŽ vyřazena podmínka na schváleného dodavatele
IF ((@DruhPohybuZbo = 6 AND @RadaDokladu IN ('800','850','860','861','810','820'))) AND (@Cena >= 100000)-- AND (@Schvaleny_dodavatel LIKE 'Schválený%')
	BEGIN			  
		IF (NOT EXISTS (SELECT ID FROM Tabx_SDPredpisy WHERE IdDoklad = @IdDoklad) AND @Schvaleny_doklad <> 1)
			BEGIN
			EXEC dbo.hpx_SDPripojPredpis
			@IdDoklad,41283
			INSERT INTO Tabx_SDLog(TypZaznamu, IdDoklad, TypDokladu, SchvaleniStav) VALUES(1, @IdDoklad, @TypDokladu, 3);
			END
	END
--řádek 4-Objednávky - neschválený dodavatel
--22.4.2021 MŽ přidána podmínka do 50 tis
IF ((@DruhPohybuZbo = 6 AND @RadaDokladu IN ('800','850','860','861','810','820'))) AND (@Cena < 50000) AND (@Schvaleny_dodavatel NOT LIKE N'Schválený%' OR @Schvaleny_dodavatel='' OR @Schvaleny_dodavatel IS NULL)
	BEGIN			  
		IF (NOT EXISTS (SELECT ID FROM Tabx_SDPredpisy WHERE IdDoklad = @IdDoklad) AND @Schvaleny_doklad <> 1)
			BEGIN
			EXEC dbo.hpx_SDPripojPredpis
			@IdDoklad,41284
			INSERT INTO Tabx_SDLog(TypZaznamu, IdDoklad, TypDokladu, SchvaleniStav) VALUES(1, @IdDoklad, @TypDokladu, 3);
			END
	END
--řádek 6-OBCHOD Vystavená nabídka 100.000,- Kč - 500.000,- Kč včetně
--31.8.2020 MŽ: upraveno @Cena nahrazena @CenaAlt
IF ((@DruhPohybuZbo = 11 AND @RadaDokladu IN ('300','310','311','315'))) AND (@CenaAlt > 100000 AND @CenaAlt <= 500000)
	BEGIN			  
		IF (NOT EXISTS (SELECT ID FROM Tabx_SDPredpisy WHERE IdDoklad = @IdDoklad) AND @Schvaleny_doklad <> 1)
			BEGIN
			EXEC dbo.hpx_SDPripojPredpis
			@IdDoklad,41285
			INSERT INTO Tabx_SDLog(TypZaznamu, IdDoklad, TypDokladu, SchvaleniStav) VALUES(1, @IdDoklad, @TypDokladu, 3);
			END
	END
--řádek 7-OBCHOD Vystavená nabídka nad 500.000,- Kč - 1.000.000,- Kč včetně
--31.8.2020 MŽ: upraveno @Cena nahrazena @CenaAlt
--20.4.2021 MŽ: upraveno nabídka nad 500 tis do 3 mil včetně
IF ((@DruhPohybuZbo = 11 AND @RadaDokladu IN ('300','310','311','315'))) AND (@CenaAlt > 500000 AND @CenaAlt <= 3000000)
	BEGIN			  
		IF (NOT EXISTS (SELECT ID FROM Tabx_SDPredpisy WHERE IdDoklad = @IdDoklad) AND @Schvaleny_doklad <> 1)
			BEGIN
			EXEC dbo.hpx_SDPripojPredpis
			@IdDoklad,41286
			INSERT INTO Tabx_SDLog(TypZaznamu, IdDoklad, TypDokladu, SchvaleniStav) VALUES(1, @IdDoklad, @TypDokladu, 3);
			END
	END
--řádek 8-OBCHOD Vystavená nabídka nad 1.000.000,- Kč
--31.8.2020 MŽ: upraveno @Cena nahrazena @CenaAlt
--20.4.2021 MŽ: upraveno nabídka nad 3 mil
IF ((@DruhPohybuZbo = 11 AND @RadaDokladu IN ('300','310','311','315'))) AND (@CenaAlt > 3000000)
	BEGIN			  
		IF (NOT EXISTS (SELECT ID FROM Tabx_SDPredpisy WHERE IdDoklad = @IdDoklad) AND @Schvaleny_doklad <> 1)
			BEGIN
			EXEC dbo.hpx_SDPripojPredpis
			@IdDoklad,41287
			INSERT INTO Tabx_SDLog(TypZaznamu, IdDoklad, TypDokladu, SchvaleniStav) VALUES(1, @IdDoklad, @TypDokladu, 3);
			END
	END
--řádek 9-VÝROBA Vystavená nabídka  250.000,- Kč - 1.000.000,- Kč včetně
--31.8.2020 MŽ: upraveno @Cena nahrazena @CenaAlt
--20.4.2021 MŽ: upraveno nabídka nad 300 tis do 1 mil
IF ((@DruhPohybuZbo = 11 AND @RadaDokladu IN ('300','310','311','315','320','330','374'))) AND (@CenaAlt > 300000 AND @CenaAlt <= 1000000)
	BEGIN			  
		IF (NOT EXISTS (SELECT ID FROM Tabx_SDPredpisy WHERE IdDoklad = @IdDoklad) AND @Schvaleny_doklad <> 1)
			BEGIN
			EXEC dbo.hpx_SDPripojPredpis
			@IdDoklad,41288
			INSERT INTO Tabx_SDLog(TypZaznamu, IdDoklad, TypDokladu, SchvaleniStav) VALUES(1, @IdDoklad, @TypDokladu, 3);
			END
	END
--řádek 10-VÝROBA Vystavená nabídka nad 1.000.000,- Kč
--31.8.2020 MŽ: upraveno @Cena nahrazena @CenaAlt
--20.4.2021 MŽ: upraveno nabídka nad 1 mil do 3 mil
IF ((@DruhPohybuZbo = 11 AND @RadaDokladu IN ('320','330','374'))) AND (@CenaAlt > 1000000 AND @CenaAlt <= 3000000)
	BEGIN			  
		IF (NOT EXISTS (SELECT ID FROM Tabx_SDPredpisy WHERE IdDoklad = @IdDoklad) AND @Schvaleny_doklad <> 1)
			BEGIN
			EXEC dbo.hpx_SDPripojPredpis
			@IdDoklad,41289
			INSERT INTO Tabx_SDLog(TypZaznamu, IdDoklad, TypDokladu, SchvaleniStav) VALUES(1, @IdDoklad, @TypDokladu, 3);
			END
	END
--řádek 11-VÝROBA Vystavená nabídka nad 3.000.000,- Kč
--20.4.2021 MŽ: upraveno nabídka nad 3 mil
IF ((@DruhPohybuZbo = 11 AND @RadaDokladu IN ('320','330','374'))) AND (@CenaAlt > 3000000)
	BEGIN			  
		IF (NOT EXISTS (SELECT ID FROM Tabx_SDPredpisy WHERE IdDoklad = @IdDoklad) AND @Schvaleny_doklad <> 1)
			BEGIN
			EXEC dbo.hpx_SDPripojPredpis
			@IdDoklad,61190
			INSERT INTO Tabx_SDLog(TypZaznamu, IdDoklad, TypDokladu, SchvaleniStav) VALUES(1, @IdDoklad, @TypDokladu, 3);
			END
	END
END;
BEGIN
UPDATE tdze SET tdze._EXT_RS_doklad_ke_schvaleni=1
FROM TabDokladyZbozi_EXT tdze
WHERE tdze.ID=@IdDoklad
END;
GO

