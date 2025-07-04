USE [RayService]
GO

/****** Object:  View [dbo].[hvw_Ray_PrevazAktOrg_JOC]    Script Date: 04.07.2025 7:04:55 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

CREATE VIEW [dbo].[hvw_Ray_PrevazAktOrg_JOC] AS SELECT Poradi , Popis  FROM RayS_SegmentInfo
GO

