USE [RayService]
GO

/****** Object:  View [dbo].[hvw_RayService_MatVyrFaze]    Script Date: 04.07.2025 7:23:13 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

CREATE VIEW [dbo].[hvw_RayService_MatVyrFaze] AS SELECT
ID
,IDKmenZbozi
,IDTypPostup
,Poradi
,DatPorizeni
,Autor
,DatZmeny
,Zmenil
FROM Tabx_RayService_MatVyrFaze
GO

