USE [HCvicna]
GO

/****** Object:  Trigger [dbo].[et_Tabx_RayService_MatZodp]    Script Date: 03.07.2025 8:41:33 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO


CREATE TRIGGER [dbo].[et_Tabx_RayService_MatZodp] ON [dbo].[Tabx_RayService_MatZodp] FOR INSERT, UPDATE, DELETE
AS
IF @@ROWCOUNT = 0 RETURN;
-- =============================================
-- Author:		JDO
-- Description:	Osetreni zmenoveho rizeni + presin radku majitele pri mazani operace
-- =============================================
SET NOCOUNT ON;
DECLARE @PocetInserted INT;
DECLARE @PocetDeleted INT;
SET @PocetInserted = (SELECT COUNT(*) FROM inserted);
SET @PocetDeleted  = (SELECT COUNT(*) FROM deleted);

-- osetreni zmenoveho rizeni - nova zmena
IF OBJECT_ID('tempdb..#MatZodpKopieTPV') IS NULL
	BEGIN
		
		WITH Z AS (
			SELECT IDPostup FROM inserted
			UNION SELECT IDPostup FROM deleted)
		MERGE TabPostup_EXT C
		USING Z ON C.ID = Z.IDPostup
		WHEN MATCHED AND Z.IDPostup IS NOT NULL THEN
			UPDATE SET _RayService_MatZodpAktualizace = GETDATE()
		WHEN NOT MATCHED BY TARGET AND Z.IDPostup IS NOT NULL THEN
			INSERT(ID, _RayService_MatZodpAktualizace)
			VALUES(Z.IDPostup, GETDATE());
		
	END;
	
-- delete - majitele - presun na jinou operaci
IF @PocetDeleted > 0 AND @PocetInserted = 0
	AND EXISTS(SELECT * FROM deleted WHERE Dimenze = 0)
	AND NOT EXISTS(SELECT * FROM deleted D INNER JOIN TabPostup P ON D.IDPostup = P.ID AND D.Dimenze = 0)
	BEGIN
	
		DECLARE @IDPostupNovy INT;
		
		SELECT TOP (1) @IDPostupNovy = PP.ID
		FROM deleted D
			INNER JOIN TabPostup PP ON D.dilec = PP.dilec
						AND PP.ZmenaDo IS NULL
		WHERE D.Dimenze = 0;
		
		IF @IDPostupNovy IS NOT NULL
			BEGIN
			
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
					D.dilec
					,@IDPostupNovy
					,D.IDPracovniPozice
					,D.Dimenze
					,D.Autor
					,D.DatPorizeni
					,D.Zmenil
					,D.DatZmeny
				FROM deleted D
				WHERE D.Dimenze = 0;
			
				MERGE TabPostup_EXT C
				USING (VALUES(@IDPostupNovy)) as Z(IDPostup) ON C.ID = Z.IDPostup
				WHEN MATCHED AND Z.IDPostup IS NOT NULL THEN
					UPDATE SET _RayService_MatZodpAktualizace = GETDATE()
				WHEN NOT MATCHED BY TARGET AND Z.IDPostup IS NOT NULL THEN
					INSERT(ID, _RayService_MatZodpAktualizace)
					VALUES(Z.IDPostup, GETDATE());
			END;
		
	END;
GO

ALTER TABLE [dbo].[Tabx_RayService_MatZodp] ENABLE TRIGGER [et_Tabx_RayService_MatZodp]
GO

