USE [HCvicna]
GO

/****** Object:  Trigger [dbo].[et_TabPersZnalostiKategorieCis_EXT_RSPersMzdy]    Script Date: 02.07.2025 15:37:26 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO



CREATE TRIGGER [dbo].[et_TabPersZnalostiKategorieCis_EXT_RSPersMzdy] ON [dbo].[TabPersZnalostiKategorieCis_EXT] FOR INSERT, UPDATE
AS
IF @@ROWCOUNT = 0 RETURN;
SET NOCOUNT ON;
-- =============================================
-- Author:		JDO
-- Description:	Stanoveni mzdy - osetreni kontrolni logiky reseni
-- =============================================	
DECLARE @PocetInserted INT;
DECLARE @PocetDeleted INT;
SET @PocetInserted = (SELECT COUNT(*) FROM inserted);
SET @PocetDeleted  = (SELECT COUNT(*) FROM deleted);

-- INSERT, UPDATE - jeden řádek
IF @PocetInserted = 1
	AND UPDATE(_RSPersMzdy_Kategorie)
	AND EXISTS(SELECT * FROM TabPersZnalostiKategorieCis K
				INNER JOIN TabPersZnalostiKategorieCis_EXT KE ON K.ID = KE.ID
				INNER JOIN inserted I ON 1 = 1
			WHERE I._RSPersMzdy_Kategorie IS NOT NULL 
				AND KE.ID <> I.ID 
				AND KE._RSPersMzdy_Kategorie IS NOT NULL
				AND KE._RSPersMzdy_Kategorie = I._RSPersMzdy_Kategorie)
	BEGIN
		ROLLBACK;
		RAISERROR (N'Duplicitní označení, nelze pokračovat!',16,1);
		RETURN;
	END;
GO

ALTER TABLE [dbo].[TabPersZnalostiKategorieCis_EXT] ENABLE TRIGGER [et_TabPersZnalostiKategorieCis_EXT_RSPersMzdy]
GO

