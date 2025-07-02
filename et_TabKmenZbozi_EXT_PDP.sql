USE [HCvicna]
GO

/****** Object:  Trigger [dbo].[et_TabKmenZbozi_EXT_PDP]    Script Date: 02.07.2025 15:14:32 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

/*PluginPreneseniDanPovinnosti.PreneseniDanPovinnosti*/CREATE TRIGGER [dbo].[et_TabKmenZbozi_EXT_PDP] ON [dbo].[TabKmenZbozi_EXT] FOR INSERT, UPDATE
AS
IF @@ROWCOUNT = 0 RETURN
SET NOCOUNT ON
IF UPDATE(_ext_kodPDP)
BEGIN
UPDATE k SET k.IDKodPDP = i._ext_kodPDP
FROM TabKmenZbozi k
JOIN INSERTED i ON i.ID = k.ID
END
GO

ALTER TABLE [dbo].[TabKmenZbozi_EXT] ENABLE TRIGGER [et_TabKmenZbozi_EXT_PDP]
GO

