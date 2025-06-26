USE [RayService]
GO

/****** Object:  StoredProcedure [dbo].[hpx_RS_enigma_generate]    Script Date: 26.06.2025 10:51:58 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

CREATE PROCEDURE [dbo].[hpx_RS_enigma_generate] @ID INT
AS
DECLARE @enigma_nr_new INT,@enigma_nr INT
SET @enigma_nr=(SELECT tpe._EXT_RS_enigma_nr
				FROM TabPrikaz_EXT tpe
				WHERE tpe.ID=@ID)
--Print @enigma_nr
IF @enigma_nr IS NULL
BEGIN
SET @enigma_nr_new = (SELECT (SELECT TOP 1 tpe._EXT_RS_enigma_nr
FROM Tabprikaz_ext tpe
ORDER BY tpe._EXT_RS_enigma_date DESC, tpe._EXT_RS_enigma_nr DESC)+1)
IF @enigma_nr_new = 1000 SET @enigma_nr_new=1
--Print @enigma_nr_new;
UPDATE tpe SET _EXT_RS_enigma_nr=@enigma_nr_new, _EXT_RS_enigma_date=GETDATE()
FROM Tabprikaz_ext tpe
WHERE tpe.ID=@ID
END;
GO

