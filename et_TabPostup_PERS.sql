USE [HCvicna]
GO

/****** Object:  Trigger [dbo].[et_TabPostup_PERS]    Script Date: 02.07.2025 16:04:04 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO


CREATE TRIGGER [dbo].[et_TabPostup_PERS] ON [dbo].[TabPostup] FOR INSERT, UPDATE, DELETE
AS
-- =============================================
-- Author:		JDO
-- Description:	Osetreni pro potreby personalistiky - generovani dovednosti, matice zodpovednosti
-- =============================================
IF @@ROWCOUNT = 0 RETURN;
SET NOCOUNT ON;
DECLARE @PocetInserted INT;
DECLARE @PocetDeleted INT;
SET @PocetInserted = (SELECT COUNT(*) FROM inserted);
SET @PocetDeleted  = (SELECT COUNT(*) FROM deleted);

-- insert
IF @PocetDeleted = 0 AND @PocetInserted > 0
	BEGIN
	
		IF OBJECT_ID('tempdb..#MatZodpKopieTPV') IS NULL
			CREATE TABLE #MatZodpKopieTPV (
				Flag BIT NOT NULL);
				
		INSERT INTO Tabx_RayService_MatZodp(
			dilec
			,IDPostup
			,IDPracovniPozice
			,Dimenze
			,Autor
			,DatPorizeni
			,Zmenil
			,DatZmeny)
		SELECT
			I.dilec
			,I.ID
			,M.IDPracovniPozice
			,M.Dimenze
			,M.Autor
			,M.DatPorizeni
			,M.Zmenil
			,M.DatZmeny
		FROM inserted I
			INNER JOIN TabPostup P ON I.dilec = P.dilec 
					AND ((I.IDZakazModif IS NULL AND P.IDZakazModif IS NULL) OR I.IDZakazModif = P.IDZakazModif)
					AND ((I.IDVarianta IS NULL AND P.IDVarianta IS NULL) OR I.IDVarianta = P.IDVarianta)
					AND I.Operace = P.Operace
					AND I.ZmenaOd = P.ZmenaDo
			INNER JOIN Tabx_RayService_MatZodp M ON M.IDPostup = P.ID;
			
		IF OBJECT_ID('tempdb..#MatZodpKopieTPV') IS NOT NULL
			DROP TABLE #MatZodpKopieTPV
			
	END;
		
-- update
IF @PocetInserted > 0 AND @PocetDeleted > 0
	AND UPDATE(Operace)
	AND EXISTS(SELECT * FROM Tabx_RayService_PersZnalostiCisGen P
					INNER JOIN deleted D ON P.Ident = D.dilec AND P.Operace = D.Operace
				WHERE P.Typ = 1)
	UPDATE P SET
		P.Operace = I.Operace
	FROM Tabx_RayService_PersZnalostiCisGen P
		INNER JOIN deleted D ON P.Ident = D.dilec AND P.Operace = D.Operace
		INNER JOIN inserted I ON D.ID = I.ID;

-- delete
IF @PocetInserted = 0 AND @PocetDeleted > 0
	DELETE C 
	FROM Tabx_RayService_MatZodp C
		INNER JOIN deleted Z ON C.IDPostup = Z.ID;
GO

ALTER TABLE [dbo].[TabPostup] ENABLE TRIGGER [et_TabPostup_PERS]
GO

