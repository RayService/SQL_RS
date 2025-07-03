USE [HCvicna]
GO

/****** Object:  Trigger [dbo].[et_TabDokladyZbozi_EXT_doklad_ke_schvaleni]    Script Date: 03.07.2025 9:56:10 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

CREATE TRIGGER [dbo].[et_TabDokladyZbozi_EXT_doklad_ke_schvaleni] on [dbo].[TabDokladyZbozi_EXT] 
FOR INSERT, UPDATE, DELETE
AS
BEGIN
DECLARE  @Action AS CHAR(1);
DECLARE @IdDoklad INT;
DECLARE @DruhPohybuZbo INT;
DECLARE @Schvaleny_doklad BIT;
SET @IdDoklad = (SELECT TOP 1 ID FROM INSERTED);
SET @DruhPohybuZbo = (SELECT td.DruhPohybuZbo FROM TabDokladyZbozi td WHERE td.ID = @IdDoklad);
SET @Schvaleny_doklad = (SELECT TOP 1 _EXT_RS_doklad_ke_schvaleni FROM INSERTED);
SET @Action = (CASE WHEN EXISTS(SELECT * FROM INSERTED)
                         AND EXISTS(SELECT * FROM DELETED)
                        THEN 'U'  -- Set Action to Updated.
                        WHEN EXISTS(SELECT * FROM INSERTED)
                        THEN 'I'  -- Set Action to Insert.
                        WHEN EXISTS(SELECT * FROM DELETED)
                        THEN 'D'  -- Set Action to Deleted.
                        ELSE 'N' -- Skip. It may have been a "failed delete".   
                    END);
IF (@action IN ('U','D') AND @DruhPohybuZbo IN (6,9,11))
	BEGIN			  
		IF (UPDATE(_EXT_RS_doklad_ke_schvaleni)
		AND EXISTS (SELECT SDL.SchvaleniUroven FROM Tabx_SDLog SDL WHERE SDL.IdDoklad = @IdDoklad AND SDL.SchvaleniUroven IS NOT NULL)
		AND /*NOT*/ EXISTS (SELECT * FROM Tabx_SDPredpisy WHERE ISNULL(Kopie, 0) = 1 AND (StavSchvaleni NOT IN (3,4,5)) AND IdDoklad = @IdDoklad))
			BEGIN
				ROLLBACK
				RAISERROR ('Nelze měnit parametr Doklad ke schválení na dokladu se zahájeným schvalovacím řízením!',16,1)
				RETURN
			END	
	END
END
GO

ALTER TABLE [dbo].[TabDokladyZbozi_EXT] ENABLE TRIGGER [et_TabDokladyZbozi_EXT_doklad_ke_schvaleni]
GO

