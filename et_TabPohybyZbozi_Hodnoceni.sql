USE [HCvicna]
GO

/****** Object:  Trigger [dbo].[et_TabPohybyZbozi_Hodnoceni]    Script Date: 02.07.2025 15:56:15 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO


-- =============================================
-- Author:		OZE
-- Description:	Hodnocení dodávky
-- =============================================
CREATE TRIGGER [dbo].[et_TabPohybyZbozi_Hodnoceni] ON [dbo].[TabPohybyZbozi] FOR UPDATE
AS
DECLARE @PocetInserted	INT
DECLARE @PocetDeleted	INT
DECLARE @IDPol			INT			-- ID Položky (položek)

SET @PocetInserted = (SELECT COUNT(*) FROM inserted)
SET @PocetDeleted  = (SELECT COUNT(*) FROM deleted)
SELECT @IDPol = ID FROM inserted

IF @PocetInserted =1 AND @PocetDeleted = 1 AND EXISTS (SELECT * FROM TabPohybyZbozi_EXT WHERE ID = @IDPol AND ISNULL(_jakost,N'') <> N'' AND ISNULL(_uplnost,N'') <> N'' AND ISNULL(_vcasnost,N'') <> N'')
	BEGIN
		IF NOT EXISTS(SELECT * FROM TabPohybyZbozi_EXT PZE WHERE PZE.ID = @IDPol)
			BEGIN
				INSERT INTO TabPohybyZbozi_EXT(ID)
				VALUES(@IDPol)
			END
		
--Kontroly jednotlivých polí hodnocení a doplnění nejnižšího		
		IF EXISTS(SELECT * FROM TabPohybyZbozi_EXT WHERE ID = @IDPol AND (ISNULL(_jakost,N'') = N'D' OR ISNULL(_uplnost,N'') = N'D' OR ISNULL(_vcasnost,N'') = N'D')) 
			BEGIN
				UPDATE TabPohybyZbozi_EXT
				SET _celk_hod_dod = N'D'
				WHERE ID = @IDPol
				RETURN
			END

		IF EXISTS(SELECT * FROM TabPohybyZbozi_EXT WHERE ID = @IDPol AND (ISNULL(_jakost,N'') = N'C' OR ISNULL(_uplnost,N'') = N'C' OR ISNULL(_vcasnost,N'') = N'C')) 
			BEGIN
				UPDATE TabPohybyZbozi_EXT
				SET _celk_hod_dod = N'C'
				WHERE ID = @IDPol
				RETURN
			END

		IF EXISTS(SELECT * FROM TabPohybyZbozi_EXT WHERE ID = @IDPol AND (ISNULL(_jakost,N'') = N'B' OR ISNULL(_uplnost,N'') = N'B' OR ISNULL(_vcasnost,N'') = N'B')) 
			BEGIN
				UPDATE TabPohybyZbozi_EXT
				SET _celk_hod_dod = N'B'
				WHERE ID = @IDPol
				RETURN
			END

		IF EXISTS(SELECT * FROM TabPohybyZbozi_EXT WHERE ID = @IDPol AND (ISNULL(_jakost,N'') = N'A' OR ISNULL(_uplnost,N'') = N'A' OR ISNULL(_vcasnost,N'') = N'A')) 
			BEGIN
				UPDATE TabPohybyZbozi_EXT
				SET _celk_hod_dod = N'A'
				WHERE ID = @IDPol
				RETURN
			END
	END
GO

ALTER TABLE [dbo].[TabPohybyZbozi] ENABLE TRIGGER [et_TabPohybyZbozi_Hodnoceni]
GO

