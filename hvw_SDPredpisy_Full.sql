USE [RayService]
GO

/****** Object:  View [dbo].[hvw_SDPredpisy_Full]    Script Date: 04.07.2025 8:20:18 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

CREATE VIEW [dbo].[hvw_SDPredpisy_Full] AS SELECT * FROM Tabx_SDPredpisy WHERE ISNULL(Kopie, 0) = 1
GO

