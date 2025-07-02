USE [HCvicna]
GO

/****** Object:  Trigger [dbo].[et_TabPohybyZbozi_UPD]    Script Date: 02.07.2025 16:00:07 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO




CREATE TRIGGER [dbo].[et_TabPohybyZbozi_UPD] ON [dbo].[TabPohybyZbozi] FOR UPDATE
AS
SET NOCOUNT ON;
-- =============================================
-- Author:		DJ
-- Description:	Externí trigger - TabPohybyZbozi - update
-- =============================================
DECLARE @PocetInserted INT;
DECLARE @PocetDeleted INT;
SET @PocetInserted = (SELECT COUNT(*) FROM inserted);
SET @PocetDeleted  = (SELECT COUNT(*) FROM deleted);
-- UPDATE
IF @PocetInserted > 0 AND @PocetDeleted > 0
	BEGIN
	
		-- VyO: Propsání Požadované datum dodání položky do ext. info Požadované dat. dod. z gen - pokud není naplněno
		IF EXISTS(SELECT * FROM inserted WHERE DruhPohybuZbo = 6) -- VyO
			AND UPDATE(PozadDatDod)
			BEGIN
			
				-- založíme ID v EXT pro položky, které ho ještě nemají
				INSERT INTO TabPohybyZbozi_EXT(ID)
				SELECT I.ID
				FROM inserted I
				WHERE NOT EXISTS(SELECT * FROM TabPohybyZbozi_EXT WHERE ID = I.ID)
					AND I.PozadDatDod IS NOT NULL
					AND I.DruhPohybuZbo = 6;
					
				-- naplníme informaci v EXT
				UPDATE E SET
					E._RayServicePozadovaneDatDodzGen = Z.PozadDatDod
				FROM TabPohybyZbozi_EXT E
					INNER JOIN inserted Z ON E.ID = Z.ID AND Z.DruhPohybuZbo = 6
				WHERE Z.PozadDatDod IS NOT NULL
					AND E._RayServicePozadovaneDatDodzGen IS NULL;
				
			END;
		
	END;
GO

ALTER TABLE [dbo].[TabPohybyZbozi] ENABLE TRIGGER [et_TabPohybyZbozi_UPD]
GO

