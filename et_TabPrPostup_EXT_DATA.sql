USE [HCvicna]
GO

/****** Object:  Trigger [dbo].[et_TabPrPostup_EXT_DATA]    Script Date: 03.07.2025 8:02:14 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO


CREATE TRIGGER [dbo].[et_TabPrPostup_EXT_DATA] ON [dbo].[TabPrPostup_EXT] FOR UPDATE
AS
IF @@ROWCOUNT = 0 RETURN;
SET NOCOUNT ON;
-- =============================================
-- Author:		JDO
-- Description:	Trigger - modifikace dat v TabPrPostup_EXT
-- =============================================
DECLARE @PocetInserted INT;
DECLARE @PocetDeleted INT;
SET @PocetInserted = (SELECT COUNT(*) FROM inserted);
SET @PocetDeleted  = (SELECT COUNT(*) FROM deleted);
-- UPDATE
-- ** Změna externích informací ve vazební Položce kooperační objednávky
IF @PocetInserted > 0 AND @PocetDeleted > 0
	AND OBJECT_ID('tempdb..#FlagAktTabPolKoopObj_EXT') IS NULL
	BEGIN
		IF (UPDATE(_pottermdod) OR UPDATE(_termprijmat))
			AND EXISTS(SELECT * FROM inserted IE
						INNER JOIN TabPrPostup P ON IE.ID = P.ID
						INNER JOIN TabPolKoopObj I ON P.IDPrikaz = I.IDPrikaz AND P.Doklad = I.DokladPrPostup AND P.Alt = I.AltPrPostup
						WHERE P.IDOdchylkyDo IS NULL)
			BEGIN
			
				IF OBJECT_ID('tempdb..#FlagAktTabPrPostup_EXT') IS NULL
					CREATE TABLE #FlagAktTabPrPostup_EXT (ID INT NOT NULL);
			
				WITH D AS 
					(SELECT 
						I.ID
						,IE._pottermdod as _PotTermDodKoopPol
						,IE._termprijmat as _TermPrijKoopPolKont
					FROM inserted IE
						INNER JOIN TabPrPostup P ON IE.ID = P.ID
						INNER JOIN TabPolKoopObj I ON P.IDPrikaz = I.IDPrikaz AND P.Doklad = I.DokladPrPostup AND P.Alt = I.AltPrPostup
					WHERE P.IDOdchylkyDo IS NULL)
				MERGE TabPolKoopObj_EXT as E
				USING D ON E.ID = D.ID
				WHEN MATCHED THEN
					UPDATE SET E._PotTermDodKoopPol = D._PotTermDodKoopPol, E._TermPrijKoopPolKont = D._TermPrijKoopPolKont
				WHEN NOT MATCHED BY TARGET THEN
					INSERT (ID, _PotTermDodKoopPol, _TermPrijKoopPolKont) VALUES(D.ID, D._PotTermDodKoopPol, D._TermPrijKoopPolKont);
		
				IF OBJECT_ID('tempdb..#FlagAktTabPrPostup_EXT') IS NOT NULL
					DROP TABLE #FlagAktTabPrPostup_EXT;
				
			END;	
	END;
GO

ALTER TABLE [dbo].[TabPrPostup_EXT] ENABLE TRIGGER [et_TabPrPostup_EXT_DATA]
GO

