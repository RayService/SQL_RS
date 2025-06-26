USE [RayService]
GO

/****** Object:  StoredProcedure [dbo].[hpx_RS_enigma_generate_vydejky]    Script Date: 26.06.2025 11:01:19 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO


CREATE PROCEDURE [dbo].[hpx_RS_enigma_generate_vydejky] @ID INT
AS
DECLARE @IDPrikaz INT;
DECLARE @enigma_nr_new INT,@enigma_nr INT
--nejprve zjistíme položky výdejek - #tabulka a seřadíme podle ID příkazu
IF OBJECT_ID(N'tempdb..#TabPolPrikazy') IS NOT NULL DROP TABLE #TabPolPrikazy

CREATE TABLE #TabPolPrikazy(
ID INT IDENTITY(1,1) NOT NULL,
IDPrikaz INT NOT NULL,
PRIMARY KEY(ID)) 
INSERT INTO #TabPolPrikazy (IDPrikaz)
SELECT tp.ID
FROM TabPohybyZbozi tpz
LEFT OUTER JOIN TabPrikaz tp ON tpz.TypVyrobnihoDokladu IN (1,2) AND tpz.IDPrikaz=tp.ID
WHERE tp.ID IS NOT NULL AND tpz.IDDoklad=@ID

SELECT * FROM #TabPolPrikazy

--spustíme cursor:
DECLARE CurGenEnigma CURSOR LOCAL FAST_FORWARD FOR
	SELECT IDPrikaz
	FROM #TabPolPrikazy;
		OPEN CurGenEnigma;
		FETCH NEXT FROM CurGenEnigma INTO 
				@IDPrikaz;
		WHILE (@@FETCH_STATUS = 0) AND (@@ERROR = 0)
		BEGIN
		--běh cursoru
		
		SET @enigma_nr=(SELECT tpe._EXT_RS_enigma_nr
						FROM TabPrikaz_EXT tpe
						WHERE tpe.ID=@IDPrikaz)
		IF @enigma_nr IS NULL
		BEGIN
		SET @enigma_nr_new = (SELECT (SELECT TOP 1 tpe._EXT_RS_enigma_nr
		FROM Tabprikaz_ext tpe
		ORDER BY tpe._EXT_RS_enigma_date DESC, tpe._EXT_RS_enigma_nr DESC)+1)
		IF @enigma_nr_new = 1000 SET @enigma_nr_new=1
		--Print @enigma_nr_new;
		UPDATE tpe SET _EXT_RS_enigma_nr=@enigma_nr_new, _EXT_RS_enigma_date=GETDATE()
		FROM Tabprikaz_ext tpe
		WHERE tpe.ID=@IDPrikaz
		END;

		FETCH NEXT FROM CurGenEnigma INTO 
			@IDPrikaz;
		END;
CLOSE CurGenEnigma;
DEALLOCATE CurGenEnigma;
GO

