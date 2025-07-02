USE [HCvicna]
GO

/****** Object:  Trigger [dbo].[et_TabPrikazMzdyAZmetky_Hodnoceni]    Script Date: 02.07.2025 16:17:25 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO


-- =============================================
-- Author:		MŽ
-- Date: 28.2.2019
-- Description:	Hodnocení kooperace - automaticky vyplní externí pole Celkové hodnocení dodávky
-- =============================================
CREATE TRIGGER [dbo].[et_TabPrikazMzdyAZmetky_Hodnoceni] ON [dbo].[TabPrikazMzdyAZmetky] FOR UPDATE
AS
DECLARE @PocetInserted	INT
DECLARE @PocetDeleted	INT
DECLARE @IDPol			INT			-- ID Položky (položek)
DECLARE @TypMzdy		TINYINT

SET @PocetInserted = (SELECT COUNT(*) FROM inserted)
SET @PocetDeleted  = (SELECT COUNT(*) FROM deleted)
SELECT @IDPol = ID FROM inserted
SELECT @TypMzdy = TypMzdy FROM inserted

IF @PocetInserted =1 AND @PocetDeleted = 1 AND @TypMzdy = 2 AND EXISTS (SELECT * FROM TabPrikazMzdyAZmetky_EXT WHERE ID = @IDPol AND ISNULL(_JakostKoop,N'') <> N'' AND ISNULL(_UplnostKoop,N'') <> N'' AND ISNULL(_VcasnostKoop,N'') <> N'')
	BEGIN
		IF NOT EXISTS(SELECT * FROM TabPrikazMzdyAZmetky_EXT PZE WHERE PZE.ID = @IDPol)
			BEGIN
				INSERT INTO TabPrikazMzdyAZmetky_EXT(ID)
				VALUES(@IDPol)
			END
		
--Kontroly jednotlivých polí hodnocení a doplnění nejnižšího		
		IF EXISTS(SELECT * FROM TabPrikazMzdyAZmetky_EXT WHERE ID = @IDPol AND (ISNULL(_JakostKoop,N'') = N'D' OR ISNULL(_UplnostKoop,N'') = N'D' OR ISNULL(_VcasnostKoop,N'') = N'D') AND @TypMzdy = 2) 
			BEGIN
				UPDATE TabPrikazMzdyAZmetky_EXT
				SET _CelkHodDodKoop = N'D'
				WHERE ID = @IDPol
				RETURN
			END

		IF EXISTS(SELECT * FROM TabPrikazMzdyAZmetky_EXT WHERE ID = @IDPol AND (ISNULL(_JakostKoop,N'') = N'C' OR ISNULL(_UplnostKoop,N'') = N'C' OR ISNULL(_VcasnostKoop,N'') = N'C') AND @TypMzdy = 2) 
			BEGIN
				UPDATE TabPrikazMzdyAZmetky_EXT
				SET _CelkHodDodKoop = N'C'
				WHERE ID = @IDPol
				RETURN
			END

		IF EXISTS(SELECT * FROM TabPrikazMzdyAZmetky_EXT WHERE ID = @IDPol AND (ISNULL(_JakostKoop,N'') = N'B' OR ISNULL(_UplnostKoop,N'') = N'B' OR ISNULL(_VcasnostKoop,N'') = N'B') AND @TypMzdy = 2) 
			BEGIN
				UPDATE TabPrikazMzdyAZmetky_EXT
				SET _CelkHodDodKoop = N'B'
				WHERE ID = @IDPol
				RETURN
			END

		IF EXISTS(SELECT * FROM TabPrikazMzdyAZmetky_EXT WHERE ID = @IDPol AND (ISNULL(_JakostKoop,N'') = N'A' OR ISNULL(_UplnostKoop,N'') = N'A' OR ISNULL(_VcasnostKoop,N'') = N'A') AND @TypMzdy = 2) 
			BEGIN
				UPDATE TabPrikazMzdyAZmetky_EXT
				SET _CelkHodDodKoop = N'A'
				WHERE ID = @IDPol
				RETURN
			END
	END
GO

ALTER TABLE [dbo].[TabPrikazMzdyAZmetky] ENABLE TRIGGER [et_TabPrikazMzdyAZmetky_Hodnoceni]
GO

