USE [RayService]
GO

/****** Object:  StoredProcedure [dbo].[hpx_RS_generate_laser_plan]    Script Date: 26.06.2025 11:09:12 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

CREATE PROCEDURE [dbo].[hpx_RS_generate_laser_plan]
AS
IF OBJECT_ID(N'TabRSPlanLaser') IS NOT NULL DELETE FROM TabRSPlanLaser-- WHERE Autor=SUSER_SNAME()
INSERT INTO TabRSPlanLaser (Datum, Mnozstvi, Autor)
SELECT Datum_plan_X,SUM(Mnozstvi_pozadavek)/100, SUSER_SNAME()
FROM hvw_8B36A3CEFE994866BC19631BEA2E8D6E
WHERE hvw_8B36A3CEFE994866BC19631BEA2E8D6E.ID IN (SELECT ID FROM #TabExtKomID)
GROUP BY Datum_plan_X
GO

