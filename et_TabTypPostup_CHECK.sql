USE [HCvicna]
GO

/****** Object:  Trigger [dbo].[et_TabTypPostup_CHECK]    Script Date: 03.07.2025 8:20:34 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO


CREATE TRIGGER [dbo].[et_TabTypPostup_CHECK] ON [dbo].[TabTypPostup] FOR INSERT, UPDATE
AS
IF @@ROWCOUNT = 0 RETURN;
SET NOCOUNT ON;

-- Duplicita Typoveho oznaceni - jednicovych operaci
IF EXISTS(SELECT * FROM inserted
		WHERE typ = 1
			AND TypOznaceni IS NOT NULL 
			AND TypOznaceni <> N'')
	IF EXISTS(SELECT * FROM TabTypPostup P
				INNER JOIN inserted I ON P.TypOznaceni = I.TypOznaceni AND P.typ = I.typ
			WHERE P.typ = 1
				AND P.TypOznaceni IS NOT NULL AND P.TypOznaceni <> N''
				AND I.TypOznaceni IS NOT NULL AND I.TypOznaceni <> N''
				AND P.ID <> I.ID)
		BEGIN
			ROLLBACK;
			RAISERROR (N'Duplicita typového označení jednicové operace: Nepovoleno!',16,1);
			RETURN;
		END;
		
-- Duplicita Nazvu + Typoveho oznaceni - rezijnich operaci
IF EXISTS(SELECT * FROM inserted
		WHERE typ = 0
			AND TypOznaceni IS NOT NULL 
			AND TypOznaceni <> N''
			AND nazev <> N'')
	IF EXISTS(SELECT * FROM TabTypPostup P
				INNER JOIN inserted I ON P.TypOznaceni = I.TypOznaceni AND P.typ = I.typ AND P.nazev = I.nazev
			WHERE P.typ = 0
				AND P.TypOznaceni IS NOT NULL AND P.TypOznaceni <> N''
				AND I.TypOznaceni IS NOT NULL AND I.TypOznaceni <> N''
				AND P.nazev <> N''
				AND I.nazev <> N''
				AND P.ID <> I.ID)
		BEGIN
			ROLLBACK;
			RAISERROR (N'Duplicita názvu režijní operace v typovém označen: Nepovoleno!',16,1);
			RETURN;
		END;
GO

ALTER TABLE [dbo].[TabTypPostup] DISABLE TRIGGER [et_TabTypPostup_CHECK]
GO

