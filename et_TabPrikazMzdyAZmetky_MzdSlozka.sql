USE [HCvicna]
GO

/****** Object:  Trigger [dbo].[et_TabPrikazMzdyAZmetky_MzdSlozka]    Script Date: 02.07.2025 16:19:12 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

CREATE TRIGGER [dbo].[et_TabPrikazMzdyAZmetky_MzdSlozka] ON [dbo].[TabPrikazMzdyAZmetky] FOR INSERT, UPDATE
AS
IF @@ROWCOUNT = 0 RETURN;
SET NOCOUNT ON;
-- =============================================
-- Author:		JDO
-- Description:	Dosazeni mzdove slozky pro časovou mzdu
-- =============================================

IF (UPDATE(IDPrikaz)
	OR UPDATE(IDPracoviste)
	OR UPDATE(TypMzdy))
	AND EXISTS(SELECT * FROM inserted WHERE TypMzdy = 1) -- časová 
	UPDATE M SET
		MzdovaSlozUkolMzd = ISNULL(CE._RayService_MzdSlCas, RE._RayService_MzdSlCas)
	FROM TabPrikazMzdyAZmetky M
		INNER JOIN inserted I ON M.ID = I.ID
		INNER JOIN TabPrikaz P ON M.IDPrikaz = P.ID
		LEFT OUTER JOIN TabRadyPrikazu_EXT RE ON RE.ID = (SELECT ID FROM TabRadyPrikazu WHERE Rada = P.Rada)
		LEFT OUTER JOIN TabCPraco_EXT CE ON M.IDPracoviste = CE.ID
	WHERE I.TypMzdy = 1;

GO

ALTER TABLE [dbo].[TabPrikazMzdyAZmetky] ENABLE TRIGGER [et_TabPrikazMzdyAZmetky_MzdSlozka]
GO

