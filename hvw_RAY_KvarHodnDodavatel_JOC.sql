USE [RayService]
GO

/****** Object:  View [dbo].[hvw_RAY_KvarHodnDodavatel_JOC]    Script Date: 04.07.2025 6:59:10 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

CREATE VIEW [dbo].[hvw_RAY_KvarHodnDodavatel_JOC] AS SELECT K.Cislo, K.Nazev, K.DatumOd, K.DatumDo  FROM RAYKvartalJOC K
GO

