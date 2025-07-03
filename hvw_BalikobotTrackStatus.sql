USE [RayService]
GO

/****** Object:  View [dbo].[hvw_BalikobotTrackStatus]    Script Date: 03.07.2025 14:06:34 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

CREATE VIEW [dbo].[hvw_BalikobotTrackStatus] AS SELECT *,
(SELECT carrier_id FROM Tabx_BalikobotBaliky WHERE ID=Tabx_BalikobotTrackStatus.IdBalik) AS carrier_id
FROM Tabx_BalikobotTrackStatus
GO

