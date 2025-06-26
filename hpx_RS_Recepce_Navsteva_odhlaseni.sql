USE [RayService]
GO

/****** Object:  StoredProcedure [dbo].[hpx_RS_Recepce_Navsteva_odhlaseni]    Script Date: 26.06.2025 13:37:21 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

CREATE PROCEDURE [dbo].[hpx_RS_Recepce_Navsteva_odhlaseni]
AS

--automatické nastavení data odhlášení na vteřinu před půlnocí a autora odhlášení: sa (zaměstnanec Ray Service)
UPDATE rn SET rn.DatOdhlaseni=DATEADD(DAY, DATEDIFF(DAY, 0, DatPorizeni), '23:59:59'), rn.AutorOdhlaseni='sa'
FROM Tabx_Apps_Recepce_Navsteva rn
WHERE rn.DatOdhlaseni IS NULL AND rn.DatPorizeni_X=(CONVERT(DATETIME,CONVERT(INT,CONVERT(FLOAT,GETDATE()))))

GO

