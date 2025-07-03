USE [HCvicna]
GO

/****** Object:  Trigger [dbo].[et_TabUniImportOZ]    Script Date: 03.07.2025 8:34:51 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

/*rpObecneImporty.Import*/CREATE TRIGGER [dbo].[et_TabUniImportOZ] ON [dbo].[TabUniImportOZ] FOR UPDATE
AS
IF NOT UPDATE(Chyba) AND NOT UPDATE(DatumImportu)
BEGIN
DECLARE @ID INT, @DatumImportu DATETIME
DECLARE c CURSOR LOCAL FAST_FORWARD FOR
SELECT ID, DatumImportu FROM INSERTED
OPEN c
FETCH NEXT FROM c INTO @ID, @DatumImportu
WHILE 1=1
BEGIN
IF @DatumImportu IS NOT NULL UPDATE TabUniImportOZ SET Chyba=NULL, DatumImportu=NULL WHERE ID=@ID
FETCH NEXT FROM c INTO @ID, @DatumImportu
IF @@fetch_status<>0 BREAK
END
CLOSE c
DEALLOCATE c
END
GO

ALTER TABLE [dbo].[TabUniImportOZ] ENABLE TRIGGER [et_TabUniImportOZ]
GO

