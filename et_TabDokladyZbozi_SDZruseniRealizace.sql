USE [HCvicna]
GO

/****** Object:  Trigger [dbo].[et_TabDokladyZbozi_SDZruseniRealizace]    Script Date: 03.07.2025 9:58:16 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

/*rpSchvalovaniDokladu.Workflow*/CREATE TRIGGER [dbo].[et_TabDokladyZbozi_SDZruseniRealizace] ON [dbo].[TabDokladyZbozi] FOR UPDATE AS
SET NOCOUNT ON
IF (SELECT PovolitNerealizovane FROM Tabx_SDKonfigurace)=1
  RETURN
DECLARE @IdDoklad INT, @Hlaska NVARCHAR(4000), @Jazyk INT
IF UPDATE(DatRealizace)
BEGIN
DECLARE c CURSOR LOCAL FAST_FORWARD FOR
SELECT I.ID
FROM INSERTED I
LEFT OUTER JOIN DELETED D ON D.ID = I.ID
WHERE D.DatRealizace IS NOT NULL
AND I.DatRealizace IS NULL
OPEN c
WHILE 1=1
BEGIN
FETCH NEXT FROM c INTO @IdDoklad
IF @@fetch_status<>0 BREAK
IF EXISTS(SELECT * FROM Tabx_SDPredpisy WHERE Kopie = 1 AND TypDokladu = 0 AND IdDoklad = @IdDoklad)
BEGIN
UPDATE Tabx_SDPredpisy SET
StavSchvaleni = NULL
WHERE Kopie = 1 AND TypDokladu = 0 AND IdDoklad = @IdDoklad
SET @Jazyk=(SELECT Jazyk FROM TabUziv WHERE LoginName=SUSER_SNAME())
IF @Jazyk IS NULL SET @Jazyk=1
SET @Hlaska = (SELECT Hlaska FROM TabExtHlasky WHERE GUIDText = '7482E4CB-0995-4579-9B0D-B5AD148CE31E' AND Jazyk = @Jazyk)
IF @Hlaska IS NULL
SET @Hlaska = (SELECT Hlaska FROM TabExtHlasky WHERE GUIDText = '7482E4CB-0995-4579-9B0D-B5AD148CE31E' AND Jazyk = 1)
INSERT Tabx_SDLog(TypZaznamu, IdDoklad, TypDokladu, SchvaleniStav, SchvaleniPoznamka, SchvaleniUroven)
VALUES(1, @IdDoklad, 0, 2, @Hlaska, NULL)
END
END
DEALLOCATE c
END
GO

ALTER TABLE [dbo].[TabDokladyZbozi] ENABLE TRIGGER [et_TabDokladyZbozi_SDZruseniRealizace]
GO

