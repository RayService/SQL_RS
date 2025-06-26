USE [RayService]
GO

/****** Object:  StoredProcedure [dbo].[hpx_RS_HrZmenaPrikaz]    Script Date: 26.06.2025 9:07:39 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

-- =============================================
-- Author:		OZE
-- Description:	Hromadná změna výr. příkazů
-- =============================================
CREATE PROCEDURE [dbo].[hpx_RS_HrZmenaPrikaz]
@_plan_vyroby_ukonceno BIT,
@_datum_planovani_vyroby DATETIME,
@_odpo_osoba_plan NVARCHAR(15),
@IDPrikaz INT
AS
IF NOT EXISTS (SELECT * FROM TabPrikaz_EXT WHERE ID = @IDPrikaz)
	BEGIN
		INSERT INTO TabPrikaz_EXT(ID)
		VALUES(@IDPrikaz)
	END

UPDATE TabPrikaz_EXT
SET _plan_vyroby_ukonceno = @_plan_vyroby_ukonceno,
	_datum_planovani_vyroby = @_datum_planovani_vyroby,
	_odpo_osoba_plan = @_odpo_osoba_plan
WHERE ID = @IDPrikaz
GO

