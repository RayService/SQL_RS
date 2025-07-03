USE [RayService]
GO

/****** Object:  View [dbo].[hvw_BlokovaneSarze]    Script Date: 03.07.2025 14:17:15 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

CREATE VIEW [dbo].[hvw_BlokovaneSarze] AS SELECT * FROM Gatema_BlokovaniSarze_ZK
GO

