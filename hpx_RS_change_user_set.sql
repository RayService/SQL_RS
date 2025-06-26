USE [RayService]
GO

/****** Object:  StoredProcedure [dbo].[hpx_RS_change_user_set]    Script Date: 26.06.2025 10:52:26 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

CREATE PROCEDURE [dbo].[hpx_RS_change_user_set]
@Stav NVARCHAR(15),
@ID INT
AS
UPDATE tz SET tz.Stav=@Stav
FROM TabDokladyZbozi tdz
LEFT OUTER JOIN TabZakazka tz ON tz.CisloZakazky=tdz.CisloZakazky
WHERE tdz.ID=@ID
GO

