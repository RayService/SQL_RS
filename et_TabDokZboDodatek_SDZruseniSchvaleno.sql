USE [HCvicna]
GO

/****** Object:  Trigger [dbo].[et_TabDokZboDodatek_SDZruseniSchvaleno]    Script Date: 03.07.2025 10:02:01 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

/*rpSchvalovaniDokladu.Workflow*/CREATE TRIGGER [dbo].[et_TabDokZboDodatek_SDZruseniSchvaleno] ON [dbo].[TabDokZboDodatek] FOR UPDATE AS
SET NOCOUNT ON
DECLARE @PriznakSchvalenoVOBJ BIT, @PriznakSchvalenoEP BIT
SELECT @PriznakSchvalenoVOBJ=PriznakSchvalenoVOBJ, @PriznakSchvalenoEP=PriznakSchvalenoEP FROM Tabx_SDKonfigurace
IF (@PriznakSchvalenoVOBJ=0)AND(@PriznakSchvalenoEP=0)
  RETURN
DECLARE @IdDoklad INT, @Hlaska NVARCHAR(4000), @Jazyk INT, @DruhPohybuZbo INT
IF UPDATE(DatumSchvaleni)
BEGIN
DECLARE c CURSOR LOCAL FAST_FORWARD FOR
SELECT I.IDHlavicky, DOKLAD.DruhPohybuZbo
FROM INSERTED I
LEFT OUTER JOIN DELETED D ON D.ID = I.ID
LEFT OUTER JOIN TabDokladyZbozi DOKLAD ON DOKLAD.ID=I.IdHlavicky
WHERE D.DatumSchvaleni IS NOT NULL
AND I.DatumSchvaleni IS NULL
AND DOKLAD.DruhPohybuZbo IN(6,9)
OPEN c
WHILE 1=1
BEGIN
FETCH NEXT FROM c INTO @IdDoklad, @DruhPohybuZbo
IF @@fetch_status<>0 BREAK
IF (@DruhPohybuZbo=6)AND(@PriznakSchvalenoVOBJ=0)
  CONTINUE
IF (@DruhPohybuZbo=9)AND(@PriznakSchvalenoEP=0)
  CONTINUE
IF EXISTS(SELECT * FROM Tabx_SDPredpisy WHERE Kopie = 1 AND TypDokladu = 0 AND IdDoklad = @IdDoklad)
BEGIN
UPDATE Tabx_SDPredpisy SET
StavSchvaleni = NULL
WHERE Kopie = 1 AND TypDokladu = 0 AND IdDoklad = @IdDoklad
SET @Jazyk=(SELECT Jazyk FROM TabUziv WHERE LoginName=SUSER_SNAME())
IF @Jazyk IS NULL SET @Jazyk=1
SET @Hlaska = (SELECT Hlaska FROM TabExtHlasky WHERE GUIDText = 'F8F738BC-B788-458A-AAB9-3431A85CF059' AND Jazyk = @Jazyk)
IF @Hlaska IS NULL
SET @Hlaska = (SELECT Hlaska FROM TabExtHlasky WHERE GUIDText = 'F8F738BC-B788-458A-AAB9-3431A85CF059' AND Jazyk = 1)
INSERT Tabx_SDLog(TypZaznamu, IdDoklad, TypDokladu, SchvaleniStav, SchvaleniPoznamka, SchvaleniUroven)
VALUES(1, @IdDoklad, 0, 2, @Hlaska, NULL)
END
END
DEALLOCATE c
END
GO

ALTER TABLE [dbo].[TabDokZboDodatek] ENABLE TRIGGER [et_TabDokZboDodatek_SDZruseniSchvaleno]
GO

