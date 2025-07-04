USE [RayService]
GO

/****** Object:  View [dbo].[hvw_RAY_CisloEx]    Script Date: 04.07.2025 6:57:15 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

CREATE VIEW [dbo].[hvw_RAY_CisloEx] AS SELECT _Cislo FROM TabPohybyZbozi_EXT
WHERE  _Cislo  IS NOT NULL
GROUP BY _Cislo
GO

