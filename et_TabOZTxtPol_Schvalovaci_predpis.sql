USE [HCvicna]
GO

/****** Object:  Trigger [dbo].[et_TabOZTxtPol_Schvalovaci_predpis]    Script Date: 02.07.2025 15:23:52 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

CREATE TRIGGER [dbo].[et_TabOZTxtPol_Schvalovaci_predpis] on [dbo].[TabOZTxtPol] 
FOR INSERT, UPDATE, DELETE
AS
BEGIN
DECLARE @Action AS CHAR(1);
DECLARE @IdDoklad INT;
DECLARE @IdDoklad_DEL INT;
DECLARE @DruhPohybuZbo INT;
DECLARE @DruhPohybuZbo_DEL INT;
DECLARE @Schvaleny_doklad BIT;
DECLARE @Schvaleny_doklad_DEL BIT;
SET @Action = (CASE WHEN EXISTS(SELECT * FROM INSERTED)
                         AND EXISTS(SELECT * FROM DELETED)
                        THEN 'U'  -- Set Action to Updated.
                        WHEN EXISTS(SELECT * FROM INSERTED)
                        THEN 'I'  -- Set Action to Insert.
                        WHEN EXISTS(SELECT * FROM DELETED)
                        THEN 'D'  -- Set Action to Deleted.
                        ELSE 'N' -- Skip. It may have been a "failed delete".   
                    END);
IF (@action IN ('I','U'))
	SET @IdDoklad = (SELECT TOP 1 IDDoklad FROM INSERTED WHERE EXISTS (SELECT 1 FROM inserted));
	SET @DruhPohybuZbo = (SELECT td.DruhPohybuZbo FROM TabDokladyZbozi td WHERE td.ID = @IdDoklad);
	SET @Schvaleny_doklad = (SELECT TDE._EXT_RS_doklad_ke_schvaleni FROM TabDokladyZbozi_EXT TDE WHERE TDE.ID = @IdDoklad);
	BEGIN			  
		IF (UPDATE(CCbezDaniKc)	AND @Schvaleny_doklad = 1 AND @DruhPohybuZbo IN (6,9,11))
			BEGIN
				ROLLBACK /* BACHA - toto je nutné, NEZAPOMENOUT */
				RAISERROR ('Nelze měnit položky na dokladu, který je uzavřen pro schvalování!',16,1)
				RETURN
			END	
	END
IF (@action = 'D')
	SET @IdDoklad_DEL = (SELECT TOP 1 IDDoklad FROM DELETED);
	SET @DruhPohybuZbo_DEL = (SELECT td.DruhPohybuZbo FROM TabDokladyZbozi td WHERE td.ID = @IdDoklad_DEL);
	SET @Schvaleny_doklad_DEL = (SELECT TDE._EXT_RS_doklad_ke_schvaleni FROM TabDokladyZbozi_EXT TDE WHERE TDE.ID = @IdDoklad_DEL);
	BEGIN			  
		IF (@Schvaleny_doklad_DEL = 1 AND @DruhPohybuZbo_DEL IN (6,9,11))
			BEGIN
				ROLLBACK /* BACHA - toto je nutné, NEZAPOMENOUT */
				RAISERROR ('Nelze mazat položku na dokladu, který je uzavřen pro schvalování',16,1)
				RETURN
			END	
	END
END
GO

ALTER TABLE [dbo].[TabOZTxtPol] ENABLE TRIGGER [et_TabOZTxtPol_Schvalovaci_predpis]
GO

