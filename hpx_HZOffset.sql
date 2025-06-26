USE [RayService]
GO

/****** Object:  StoredProcedure [dbo].[hpx_HZOffset]    Script Date: 26.06.2025 9:49:39 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

CREATE PROC [dbo].[hpx_HZOffset] @Cislo NUMERIC(19,6), @ID INT
AS
--zalozeni radku v ext tabulce
INSERT INTO TabDokladyZbozi_EXT(ID)
SELECT DZ.ID FROM TabDokladyZbozi DZ WHERE DZ.ID=@ID AND DZ.ID NOT IN (SELECT DZE.ID FROM TabDokladyZbozi_EXT DZE)

--update hodnot
UPDATE TabDokladyZbozi_EXT
SET _offsety = @Cislo
WHERE ID = @ID
GO

