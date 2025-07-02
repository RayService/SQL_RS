USE [HCvicna]
GO

/****** Object:  Trigger [dbo].[et_TabPolKoopObj_EXT_DATA]    Script Date: 02.07.2025 16:02:17 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO


CREATE TRIGGER [dbo].[et_TabPolKoopObj_EXT_DATA] ON [dbo].[TabPolKoopObj_EXT] FOR UPDATE
AS
IF @@ROWCOUNT = 0 RETURN;
SET NOCOUNT ON;
-- =============================================
-- Author:		JDO
-- Description:	Trigger - modifikace dat v TabPolKoopObj_EXT
-- =============================================
DECLARE @PocetInserted INT;
DECLARE @PocetDeleted INT;
SET @PocetInserted = (SELECT COUNT(*) FROM inserted);
SET @PocetDeleted  = (SELECT COUNT(*) FROM deleted);
-- UPDATE
-- ** Změna externích informací ve vazební Výrobní operaci
IF @PocetInserted > 0 AND @PocetDeleted > 0
	AND OBJECT_ID('tempdb..#FlagAktTabPrPostup_EXT') IS NULL
	BEGIN
		
		IF (UPDATE(_PotTermDodKoopPol) OR UPDATE(_TermPrijKoopPolKont))
			AND EXISTS(SELECT * FROM inserted IE
						INNER JOIN TabPolKoopObj I ON IE.ID = I.ID 
						INNER JOIN  TabPrPostup P ON P.IDOdchylkyDo IS NULL AND P.IDPrikaz = I.IDPrikaz AND P.Doklad = I.DokladPrPostup AND P.Alt = I.AltPrPostup)
			BEGIN
			
				IF OBJECT_ID('tempdb..#FlagAktTabPolKoopObj_EXT') IS NULL
					CREATE TABLE #FlagAktTabPrPostup_EXT (ID INT NOT NULL);
			
				WITH D AS 
					(SELECT 
						P.ID
						,IE._PotTermDodKoopPol as _pottermdod
						,IE._TermPrijKoopPolKont as _termprijmat
					FROM inserted IE
						INNER JOIN TabPolKoopObj I ON IE.ID = I.ID 
						INNER JOIN TabPrPostup P ON P.IDOdchylkyDo IS NULL AND P.IDPrikaz = I.IDPrikaz AND P.Doklad = I.DokladPrPostup AND P.Alt = I.AltPrPostup)
				MERGE TabPrPostup_EXT as E
				USING D ON E.ID = D.ID
				WHEN MATCHED THEN
					UPDATE SET E._pottermdod = D._pottermdod, E._termprijmat = D._termprijmat
				WHEN NOT MATCHED BY TARGET THEN
					INSERT (ID, _pottermdod, _termprijmat) VALUES(D.ID, D._pottermdod, D._termprijmat);
				
				IF OBJECT_ID('tempdb..#FlagAktTabPolKoopObj_EXT') IS NOT NULL
					DROP TABLE #FlagAktTabPolKoopObj_EXT;
				
			END;
	
	END;
GO

ALTER TABLE [dbo].[TabPolKoopObj_EXT] ENABLE TRIGGER [et_TabPolKoopObj_EXT_DATA]
GO

