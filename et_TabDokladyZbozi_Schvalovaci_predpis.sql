USE [HCvicna]
GO

/****** Object:  Trigger [dbo].[et_TabDokladyZbozi_Schvalovaci_predpis]    Script Date: 03.07.2025 9:59:06 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

CREATE TRIGGER [dbo].[et_TabDokladyZbozi_Schvalovaci_predpis] on [dbo].[TabDokladyZbozi] 
AFTER INSERT, UPDATE, DELETE
AS
BEGIN
-- ======================================================================================================================
-- Author: MŽ
-- Date: 12.3.2020
-- Description: Automatické přiřazení schvalovacího předpisu dle podpisového řádu.
-- 31.8.2020 MŽ: upraveno @Cena nahrazena @CenaAlt
-- ======================================================================================================================
DECLARE  @Action AS CHAR(1);
DECLARE @IdDoklad INT;
DECLARE @TypDokladu INT;
DECLARE @DruhPohybuZbo INT;
DECLARE @RadaDokladu NVARCHAR(3);
DECLARE @Cena NUMERIC (19,2);
DECLARE @CenaAlt NUMERIC (19,2);
DECLARE @Schvaleny_dodavatel NVARCHAR(15);
DECLARE @Schvaleny_doklad BIT;
SET @IdDoklad = (SELECT TOP 1 ID FROM INSERTED);
SET @TypDokladu = 0;
SET @DruhPohybuZbo = (SELECT TOP 1 DruhPohybuZbo FROM INSERTED);
SET @Cena = (SELECT TOP 1 SumaKcBezDPH FROM INSERTED);
SET @CenaAlt = (SELECT SUM(P.CCbezDaniKcPoS)
				FROM TabPohybyZbozi P WITH(NOLOCK)
				LEFT OUTER JOIN TabPohybyZbozi_EXT PE WITH(NOLOCK) ON P.ID = PE.ID
				WHERE P.IDDoklad = @IdDoklad AND ISNULL(PE._PrevodA,0) = 0)
SET @RadaDokladu = (SELECT TOP 1 RadaDokladu FROM INSERTED);
SET @Schvaleny_dodavatel = (SELECT tco_EXT._stav_dodavatele
							FROM TabDokladyZbozi WITH(NOLOCK)
							LEFT OUTER JOIN TabCisOrg tco WITH(NOLOCK) ON TabDokladyZbozi.CisloOrg=tco.CisloOrg
							LEFT OUTER JOIN TabCisOrg_EXT tco_EXT WITH(NOLOCK) ON tco_EXT.ID=tco.ID
							WHERE TabDokladyZbozi.ID = @IdDoklad);
SET @Schvaleny_doklad = (SELECT tde._EXT_RS_doklad_ke_schvaleni
							FROM TabDokladyZbozi_EXT tde WITH(NOLOCK)
							WHERE tde.ID = @IdDoklad);
SET @Action = (CASE WHEN EXISTS(SELECT * FROM INSERTED)
                         AND EXISTS(SELECT * FROM DELETED)
                        THEN 'U'  -- Set Action to Updated.
                        WHEN EXISTS(SELECT * FROM INSERTED)
                        THEN 'I'  -- Set Action to Insert.
                        WHEN EXISTS(SELECT * FROM DELETED)
                        THEN 'D'  -- Set Action to Deleted.
                        ELSE 'N' -- Skip. It may have been a "failed delete".   
                    END)
;
--řádek 11-OBCHOD Kupní smlouva, potvrzení objednávky 100.000,- Kč - 500.000,- Kč včetně
IF @action IN ('U') AND ((@DruhPohybuZbo = 9 AND @RadaDokladu IN ('400','410','411')) OR (@DruhPohybuZbo = 11 AND @RadaDokladu IN ('382','385'))) AND (@Cena > 100000 AND @Cena <= 500000)
	BEGIN			  
		IF (UPDATE(BlokovaniEditoru) AND NOT EXISTS (SELECT ID FROM Tabx_SDPredpisy WHERE IdDoklad = @IdDoklad) AND @Schvaleny_doklad = 1)
			BEGIN
			EXEC dbo.hpx_SDPripojPredpis
			@IdDoklad,41290
			INSERT INTO Tabx_SDLog(TypZaznamu, IdDoklad, TypDokladu, SchvaleniStav) VALUES(1, @IdDoklad, @TypDokladu, 3);
			END
	END
--řádek 12-OBCHOD Kupní smlouva, potvrzení objednávky 500.000,- Kč - 1.000.000,- Kč včetně
IF @action IN ('U') AND ((@DruhPohybuZbo = 9 AND @RadaDokladu IN ('400','410','411')) OR (@DruhPohybuZbo = 11 AND @RadaDokladu IN ('382','385'))) AND (@Cena > 500000 AND @Cena <= 1000000)
	BEGIN			  
		IF (UPDATE(BlokovaniEditoru) AND NOT EXISTS (SELECT ID FROM Tabx_SDPredpisy WHERE IdDoklad = @IdDoklad) AND @Schvaleny_doklad = 1)
			BEGIN
			EXEC dbo.hpx_SDPripojPredpis
			@IdDoklad,41291
			INSERT INTO Tabx_SDLog(TypZaznamu, IdDoklad, TypDokladu, SchvaleniStav) VALUES(1, @IdDoklad, @TypDokladu, 3);
			END
	END
--řádek 13-OBCHOD Kupní smlouva, potvrzení objednávky nad 1.000.000,- Kč
IF @action IN ('U') AND ((@DruhPohybuZbo = 9 AND @RadaDokladu IN ('400','410','411')) OR (@DruhPohybuZbo = 11 AND @RadaDokladu IN ('382','385'))) AND (@Cena > 1000000)
	BEGIN			  
		IF (UPDATE(BlokovaniEditoru) AND NOT EXISTS (SELECT ID FROM Tabx_SDPredpisy WHERE IdDoklad = @IdDoklad) AND @Schvaleny_doklad = 1)
			BEGIN
			EXEC dbo.hpx_SDPripojPredpis
			@IdDoklad,41292
			INSERT INTO Tabx_SDLog(TypZaznamu, IdDoklad, TypDokladu, SchvaleniStav) VALUES(1, @IdDoklad, @TypDokladu, 3);
			END
	END
--řádek 14-VÝROBA Kupní smlouva, smlouva o dílo, potvrzení objednávky 250.000,- Kč - 1.000.000,- Kč včetně
IF @action IN ('U') AND ((@DruhPohybuZbo = 9 AND @RadaDokladu IN ('400','410','411','420','430','474')) OR (@DruhPohybuZbo = 11 AND @RadaDokladu IN ('383','384'))) AND (@Cena > 250000 AND @Cena <= 1000000)
	BEGIN			  
		IF (UPDATE(BlokovaniEditoru) AND NOT EXISTS (SELECT ID FROM Tabx_SDPredpisy WHERE IdDoklad = @IdDoklad) AND @Schvaleny_doklad = 1)
			BEGIN
			EXEC dbo.hpx_SDPripojPredpis
			@IdDoklad,41293
			INSERT INTO Tabx_SDLog(TypZaznamu, IdDoklad, TypDokladu, SchvaleniStav) VALUES(1, @IdDoklad, @TypDokladu, 3);
			END
	END
--řádek 15-VÝROBA Kupní smlouva, smlouva o dílo, potvrzení objednávky nad 1.000.000,- Kč
IF @action IN ('U') AND ((@DruhPohybuZbo = 9 AND @RadaDokladu IN ('400','410','411','420','430','474')) OR (@DruhPohybuZbo = 11 AND @RadaDokladu IN ('383','384'))) AND (@Cena > 1000000)
	BEGIN			  
		IF (UPDATE(BlokovaniEditoru) AND NOT EXISTS (SELECT ID FROM Tabx_SDPredpisy WHERE IdDoklad = @IdDoklad) AND @Schvaleny_doklad = 1)
			BEGIN
			EXEC dbo.hpx_SDPripojPredpis
			@IdDoklad,41294
			INSERT INTO Tabx_SDLog(TypZaznamu, IdDoklad, TypDokladu, SchvaleniStav) VALUES(1, @IdDoklad, @TypDokladu, 3);
			END
	END
--řádek 2-Objednávky 50.000 - 100.0000 včetně
IF @action IN ('U') AND ((@DruhPohybuZbo = 6 AND @RadaDokladu IN ('800','850','860','861'))) AND (@Cena > 50000 AND @Cena <= 100000) AND (@Schvaleny_dodavatel LIKE 'Schválený%')
	BEGIN			  
		IF (UPDATE(BlokovaniEditoru) AND NOT EXISTS (SELECT ID FROM Tabx_SDPredpisy WHERE IdDoklad = @IdDoklad) AND @Schvaleny_doklad = 1)
			BEGIN
			EXEC dbo.hpx_SDPripojPredpis
			@IdDoklad,41282
			INSERT INTO Tabx_SDLog(TypZaznamu, IdDoklad, TypDokladu, SchvaleniStav) VALUES(1, @IdDoklad, @TypDokladu, 3);
			END
	END
--řádek 3-Objednávky nad 100.0000
IF @action IN ('U') AND ((@DruhPohybuZbo = 6 AND @RadaDokladu IN ('800','850','860','861'))) AND (@Cena > 100000) AND (@Schvaleny_dodavatel LIKE 'Schválený%')
	BEGIN			  
		IF (UPDATE(BlokovaniEditoru) AND NOT EXISTS (SELECT ID FROM Tabx_SDPredpisy WHERE IdDoklad = @IdDoklad) AND @Schvaleny_doklad = 1)
			BEGIN
			EXEC dbo.hpx_SDPripojPredpis
			@IdDoklad,41283
			INSERT INTO Tabx_SDLog(TypZaznamu, IdDoklad, TypDokladu, SchvaleniStav) VALUES(1, @IdDoklad, @TypDokladu, 3);
			END
	END
--řádek 4-Objednávky - neschválený dodavatel
IF @action IN ('U') AND ((@DruhPohybuZbo = 6 AND @RadaDokladu IN ('800','850','860','861'))) AND (@Schvaleny_dodavatel NOT LIKE N'Schválený%')
	BEGIN			  
		IF (UPDATE(BlokovaniEditoru) AND NOT EXISTS (SELECT ID FROM Tabx_SDPredpisy WHERE IdDoklad = @IdDoklad) AND @Schvaleny_doklad = 1)
			BEGIN
			EXEC dbo.hpx_SDPripojPredpis
			@IdDoklad,41284
			INSERT INTO Tabx_SDLog(TypZaznamu, IdDoklad, TypDokladu, SchvaleniStav) VALUES(1, @IdDoklad, @TypDokladu, 3);
			END
	END
--řádek 6-OBCHOD Vystavená nabídka 100.000,- Kč - 500.000,- Kč včetně
--31.8.2020 MŽ: upraveno @Cena nahrazena @CenaAlt
IF @action IN ('U') AND ((@DruhPohybuZbo = 11 AND @RadaDokladu IN ('300','310','311','315'))) AND (@CenaAlt > 100000 AND @CenaAlt <= 500000)
	BEGIN			  
		IF (UPDATE(BlokovaniEditoru) AND NOT EXISTS (SELECT ID FROM Tabx_SDPredpisy WHERE IdDoklad = @IdDoklad) AND @Schvaleny_doklad = 1)
			BEGIN
			EXEC dbo.hpx_SDPripojPredpis
			@IdDoklad,41285
			INSERT INTO Tabx_SDLog(TypZaznamu, IdDoklad, TypDokladu, SchvaleniStav) VALUES(1, @IdDoklad, @TypDokladu, 3);
			END
	END
--řádek 7-OBCHOD Vystavená nabídka nad 500.000,- Kč - 1.000.000,- Kč včetně
--31.8.2020 MŽ: upraveno @Cena nahrazena @CenaAlt
IF @action IN ('U') AND ((@DruhPohybuZbo = 11 AND @RadaDokladu IN ('300','310','311','315'))) AND (@CenaAlt > 500000 AND @CenaAlt <= 1000000)
	BEGIN			  
		IF (UPDATE(BlokovaniEditoru) AND NOT EXISTS (SELECT ID FROM Tabx_SDPredpisy WHERE IdDoklad = @IdDoklad) AND @Schvaleny_doklad = 1)
			BEGIN
			EXEC dbo.hpx_SDPripojPredpis
			@IdDoklad,41286
			INSERT INTO Tabx_SDLog(TypZaznamu, IdDoklad, TypDokladu, SchvaleniStav) VALUES(1, @IdDoklad, @TypDokladu, 3);
			END
	END
--řádek 8-OBCHOD Vystavená nabídka nad 1.000.000,- Kč
--31.8.2020 MŽ: upraveno @Cena nahrazena @CenaAlt
IF @action IN ('U') AND ((@DruhPohybuZbo = 11 AND @RadaDokladu IN ('300','310','311','315'))) AND (@CenaAlt > 1000000)
	BEGIN			  
		IF (UPDATE(BlokovaniEditoru) AND NOT EXISTS (SELECT ID FROM Tabx_SDPredpisy WHERE IdDoklad = @IdDoklad) AND @Schvaleny_doklad = 1)
			BEGIN
			EXEC dbo.hpx_SDPripojPredpis
			@IdDoklad,41287
			INSERT INTO Tabx_SDLog(TypZaznamu, IdDoklad, TypDokladu, SchvaleniStav) VALUES(1, @IdDoklad, @TypDokladu, 3);
			END
	END
--řádek 9-VÝROBA Vystavená nabídka  250.000,- Kč - 1.000.000,- Kč včetně
--31.8.2020 MŽ: upraveno @Cena nahrazena @CenaAlt
IF @action IN ('U') AND ((@DruhPohybuZbo = 11 AND @RadaDokladu IN ('300','310','311','315','320','330','374'))) AND (@CenaAlt > 250000 AND @CenaAlt <= 1000000)
	BEGIN			  
		IF (UPDATE(BlokovaniEditoru) AND NOT EXISTS (SELECT ID FROM Tabx_SDPredpisy WHERE IdDoklad = @IdDoklad) AND @Schvaleny_doklad = 1)
			BEGIN
			EXEC dbo.hpx_SDPripojPredpis
			@IdDoklad,41288
			INSERT INTO Tabx_SDLog(TypZaznamu, IdDoklad, TypDokladu, SchvaleniStav) VALUES(1, @IdDoklad, @TypDokladu, 3);
			END
	END
--řádek 10-VÝROBA Vystavená nabídka nad 1.000.000,- Kč
--31.8.2020 MŽ: upraveno @Cena nahrazena @CenaAlt
IF @action IN ('U') AND ((@DruhPohybuZbo = 11 AND @RadaDokladu IN ('320','330','374'))) AND (@CenaAlt > 1000000)
	BEGIN			  
		IF (UPDATE(BlokovaniEditoru) AND NOT EXISTS (SELECT ID FROM Tabx_SDPredpisy WHERE IdDoklad = @IdDoklad) AND @Schvaleny_doklad = 1)
			BEGIN
			EXEC dbo.hpx_SDPripojPredpis
			@IdDoklad,41289
			INSERT INTO Tabx_SDLog(TypZaznamu, IdDoklad, TypDokladu, SchvaleniStav) VALUES(1, @IdDoklad, @TypDokladu, 3);
			END
	END
END
GO

ALTER TABLE [dbo].[TabDokladyZbozi] DISABLE TRIGGER [et_TabDokladyZbozi_Schvalovaci_predpis]
GO

