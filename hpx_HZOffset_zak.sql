USE [RayService]
GO

/****** Object:  StoredProcedure [dbo].[hpx_HZOffset_zak]    Script Date: 26.06.2025 9:49:03 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

CREATE PROC [dbo].[hpx_HZOffset_zak] @Cislo NUMERIC(19,6), @ID INT
AS
--zalozeni radku v ext tabulce
INSERT INTO TabZakazka_EXT(ID)
SELECT DZ.ID FROM TabZakazka DZ WHERE DZ.ID=@ID AND DZ.ID NOT IN (SELECT DZE.ID FROM TabZakazka_EXT DZE)

--update hodnot
UPDATE TabZakazka_EXT
SET _offset_zak = @Cislo
WHERE ID = @ID
GO

