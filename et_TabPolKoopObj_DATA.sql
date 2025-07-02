USE [HCvicna]
GO

/****** Object:  Trigger [dbo].[et_TabPolKoopObj_DATA]    Script Date: 02.07.2025 16:01:03 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO


CREATE TRIGGER [dbo].[et_TabPolKoopObj_DATA] ON [dbo].[TabPolKoopObj] FOR INSERT
AS
IF @@ROWCOUNT = 0 RETURN;
SET NOCOUNT ON;
-- =============================================
-- Author:		JDO
-- Description:	Trigger - doplnění dat v TabPolKoopObj / TabPolKoopObj_EXT
-- =============================================
DECLARE @PocetInserted INT;
DECLARE @PocetDeleted INT;
SET @PocetInserted = (SELECT COUNT(*) FROM inserted);
SET @PocetDeleted  = (SELECT COUNT(*) FROM deleted);
-- INSERT
-- ** Doplnění externích informací ze zdrojové výrobní operace
IF @PocetInserted > 0 AND @PocetDeleted = 0
	AND EXISTS(SELECT * FROM inserted I 
				INNER JOIN  TabPrPostup P ON P.IDOdchylkyDo IS NULL AND P.IDPrikaz = I.IDPrikaz AND P.Doklad = I.DokladPrPostup AND P.Alt = I.AltPrPostup
				INNER JOIN TabPrPostup_EXT PE ON P.ID = PE.ID
			WHERE PE._pottermdod IS NOT NULL OR PE._termprijmat IS NOT NULL)
	BEGIN
	
		WITH D AS 
			(SELECT 
				I.ID
				,PE._pottermdod as _PotTermDodKoopPol
				,PE._termprijmat as _TermPrijKoopPolKont
			FROM inserted I 
				INNER JOIN  TabPrPostup P ON P.IDOdchylkyDo IS NULL AND P.IDPrikaz = I.IDPrikaz AND P.Doklad = I.DokladPrPostup AND P.Alt = I.AltPrPostup
				INNER JOIN TabPrPostup_EXT PE ON P.ID = PE.ID
			WHERE PE._pottermdod IS NOT NULL OR PE._termprijmat IS NOT NULL)
		MERGE TabPolKoopObj_EXT as E
		USING D ON E.ID = D.ID
		WHEN MATCHED THEN
			UPDATE SET E._PotTermDodKoopPol = D._PotTermDodKoopPol, E._TermPrijKoopPolKont = D._TermPrijKoopPolKont
		WHEN NOT MATCHED BY TARGET THEN
			INSERT (ID, _PotTermDodKoopPol, _TermPrijKoopPolKont) VALUES(D.ID, D._PotTermDodKoopPol, D._TermPrijKoopPolKont);
	
	END;
GO

ALTER TABLE [dbo].[TabPolKoopObj] ENABLE TRIGGER [et_TabPolKoopObj_DATA]
GO

