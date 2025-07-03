USE [HCvicna]
GO

/****** Object:  Trigger [dbo].[et_TabUniImportDenik]    Script Date: 03.07.2025 8:28:19 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

/*rpObecneImporty.Import*/CREATE TRIGGER [dbo].[et_TabUniImportDenik] ON [dbo].[TabUniImportDenik] FOR UPDATE
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
IF @DatumImportu IS NOT NULL UPDATE TabUniImportDenik SET Chyba=NULL, DatumImportu=NULL WHERE ID=@ID
FETCH NEXT FROM c INTO @ID, @DatumImportu
IF @@fetch_status<>0 BREAK
END
CLOSE c
DEALLOCATE c
END
GO

ALTER TABLE [dbo].[TabUniImportDenik] ENABLE TRIGGER [et_TabUniImportDenik]
GO

