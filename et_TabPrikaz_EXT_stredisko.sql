USE [HCvicna]
GO

/****** Object:  Trigger [dbo].[et_TabPrikaz_EXT_stredisko]    Script Date: 02.07.2025 16:12:30 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

CREATE TRIGGER [dbo].[et_TabPrikaz_EXT_stredisko] ON [dbo].[TabPrikaz_EXT]
FOR UPDATE
AS


IF UPDATE(_Popisstavu2)
	BEGIN
	UPDATE TabPrikaz_EXT
	SET _EXT_kmenove_stredisko_old = TabPrikaz.KmenoveStredisko
	FROM TabPrikaz
	WHERE (TabPrikaz_EXT.ID = TabPrikaz.ID AND TabPrikaz_EXT.ID IN (SELECT I.ID FROM INSERTED I) AND TabPrikaz_EXT._Popisstavu2 = 1 AND TabPrikaz_EXT._EXT_kmenove_stredisko_old IS NULL)
END
GO

ALTER TABLE [dbo].[TabPrikaz_EXT] ENABLE TRIGGER [et_TabPrikaz_EXT_stredisko]
GO

