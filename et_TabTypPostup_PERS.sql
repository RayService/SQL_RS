USE [HCvicna]
GO

/****** Object:  Trigger [dbo].[et_TabTypPostup_PERS]    Script Date: 03.07.2025 8:22:21 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO


CREATE TRIGGER [dbo].[et_TabTypPostup_PERS] ON [dbo].[TabTypPostup] FOR UPDATE, DELETE
AS
-- =============================================
-- Author:		JDO
-- Description:	Osetreni generovani dovednosti - oblasti dovednosti
-- =============================================
SET NOCOUNT ON;
DECLARE @PocetInserted INT;
DECLARE @PocetDeleted INT;
SET @PocetInserted = (SELECT COUNT(*) FROM inserted);
SET @PocetDeleted  = (SELECT COUNT(*) FROM deleted);

-- UPDATE - Cislo
IF @PocetInserted > 0 AND @PocetDeleted > 0
	AND UPDATE(Cislo)
	UPDATE C SET
		C.Ident = I.Cislo
	FROM Tabx_RayService_PersZnalostiCisGen C
		INNER JOIN deleted D ON C.Typ = 2 AND C.Ident = D.Cislo
		INNER JOIN inserted I ON D.ID = I.ID;

-- UPDATE - Blokovani editoru
IF @PocetInserted > 0 AND @PocetDeleted > 0
	AND UPDATE(BlokovaniEditoru)
	AND EXISTS(SELECT * FROM inserted WHERE BlokovaniEditoru IS NULL AND TypOznaceni IS NOT NULL AND TypOznaceni <> N'' AND typ = 0)
	BEGIN
		
		DECLARE @Nazev NVARCHAR(150);
		DECLARE @Cislo INT;
		DECLARE @IDPersZnalostiCis INT;
		DECLARE @IDKategorie INT;
		
		BEGIN TRY
		
			DECLARE CurOperace CURSOR LOCAL FAST_FORWARD FOR
				SELECT
					I.Cislo
					,(I.nazev + CHAR(32) + I.TypOznaceni) as Nazev
					,G.IDPersZnalostiCis
				FROM inserted I
					LEFT OUTER JOIN Tabx_RayService_PersZnalostiCisGen G ON I.Cislo = G.Ident AND G.Typ = 2
				WHERE I.BlokovaniEditoru IS NULL AND I.TypOznaceni IS NOT NULL AND I.TypOznaceni <> N'' AND I.typ = 0; -- {select}
			OPEN CurOperace;
			FETCH NEXT FROM CurOperace INTO @Cislo, @Nazev, @IDPersZnalostiCis; -- {proměnné}
				WHILE (@@FETCH_STATUS = 0) AND (@@ERROR = 0)
				BEGIN
					-- zacatek akce v kurzoru CurOperace
					
					-- * Kontroly
					IF EXISTS(SELECT * FROM TabPersZnalostiOblastCis WHERE Nazev = @Nazev AND 
						((@IDPersZnalostiCis IS NOT NULL AND ISNULL((SELECT Nazev FROM TabPersZnalostiOblastCis WHERE ID = @IDPersZnalostiCis),@Nazev) <> @Nazev AND ID <> @IDPersZnalostiCis)
							OR (@IDPersZnalostiCis IS NULL)))
					BEGIN
						RAISERROR (N'Generování oblasti dovedností: Duplicita v názvu oblasti dovednosti - %s',16,1,@Nazev);
						RETURN;
					END;
					
					IF @IDPersZnalostiCis IS NOT NULL
						AND EXISTS(SELECT * FROM TabPersZnalostiOblastCis WHERE ID = @IDPersZnalostiCis)
						BEGIN
							IF (SELECT Nazev FROM TabPersZnalostiOblastCis WHERE ID = @IDPersZnalostiCis) <> @Nazev
							UPDATE TabPersZnalostiOblastCis SET
								Nazev = @Nazev
								,DatZmeny = GETDATE()
								,Zmenil = SUSER_SNAME()
							WHERE ID = @IDPersZnalostiCis;
						END;
					ELSE
						BEGIN
														
							INSERT INTO TabPersZnalostiOblastCis(
								Nazev
								)
							VALUES(
								@Nazev
								);
							
							SELECT @IDPersZnalostiCis = SCOPE_IDENTITY();
							
							IF NOT EXISTS(SELECT * FROM Tabx_RayService_PersZnalostiCisGen WHERE Typ = 2 AND Ident = @Cislo)
								INSERT INTO Tabx_RayService_PersZnalostiCisGen(
									Typ
									,Ident
									,IDPersZnalostiCis)
								VALUES(
									2
									,@Cislo
									,@IDPersZnalostiCis);
							ELSE
								UPDATE Tabx_RayService_PersZnalostiCisGen SET
									IDPersZnalostiCis = @IDPersZnalostiCis
								WHERE Typ = 2
									AND Ident = @Cislo;
									
						END;
					
					-- konec akce v kurzoru CurOperace
				FETCH NEXT FROM CurOperace INTO @Cislo, @Nazev, @IDPersZnalostiCis; -- {proměnné}
				END;
			CLOSE CurOperace;
			DEALLOCATE CurOperace;
		
		END TRY
		--zacneme CATCH
		BEGIN CATCH
			ROLLBACK;
			DECLARE @ErrorMessage NVARCHAR(4000);
			SELECT @ErrorMessage = ERROR_MESSAGE();
			RAISERROR (@ErrorMessage,16,1);
			RETURN;
		END CATCH;
		
	END;
	
-- DELETE
IF @PocetInserted = 0 AND @PocetDeleted > 0
	DELETE C
	FROM Tabx_RayService_PersZnalostiCisGen C
		INNER JOIN deleted D ON C.Typ = 2 AND C.Ident = D.Cislo;
GO

ALTER TABLE [dbo].[TabTypPostup] DISABLE TRIGGER [et_TabTypPostup_PERS]
GO

