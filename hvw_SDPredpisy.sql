USE [RayService]
GO

/****** Object:  View [dbo].[hvw_SDPredpisy]    Script Date: 04.07.2025 8:18:46 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

CREATE VIEW [dbo].[hvw_SDPredpisy] AS SELECT * FROM Tabx_SDPredpisy WHERE ISNULL(Kopie, 0) = 0
GO

