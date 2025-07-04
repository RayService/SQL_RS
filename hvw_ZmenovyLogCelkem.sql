USE [RayService]
GO

/****** Object:  View [dbo].[hvw_ZmenovyLogCelkem]    Script Date: 04.07.2025 9:33:27 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

CREATE VIEW [dbo].[hvw_ZmenovyLogCelkem] AS SELECT * 
FROM TabZmenovyLOG
JOIN TabZurnal ON TabZmenovyLOG.IdZurnal=TabZurnal.ID
GO

