USE [RayService]
GO

/****** Object:  View [dbo].[hvw_RAY_PopisPricEx]    Script Date: 04.07.2025 7:04:32 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

CREATE VIEW [dbo].[hvw_RAY_PopisPricEx] AS SELECT * FROM RAY_PricinaEx
/*
SELECT _PopisPric FROM TabPohybyZbozi_EXT
WHERE  _PopisPric IS NOT NULL
GROUP BY _PopisPric
*/
GO

