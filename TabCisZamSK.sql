USE [RayService]
GO

/****** Object:  View [dbo].[TabCisZamSK]    Script Date: 04.07.2025 9:48:53 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO


CREATE VIEW [dbo].[TabCisZamSK] AS
SELECT tczSK.ID, tczSK.Cislo, tczSK.Jmeno, tczSK.Prijmeni, tczSK.PrijmeniJmeno, tczSKe._EXT_B2ADIMA_ProductionUnitId
FROM HEOSQL.RayService5.dbo.TabCisZam tczSK
LEFT OUTER JOIN HEOSQL.RayService5.dbo.TabCisZam_EXT tczSKe ON tczSKe.ID=tczSK.ID
;
GO

