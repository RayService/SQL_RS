USE [RayService]
GO

/****** Object:  View [dbo].[hvw_9A01981A8EF14FBEA1F00770DC6FBCB2]    Script Date: 03.07.2025 12:46:29 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

CREATE VIEW [dbo].[hvw_9A01981A8EF14FBEA1F00770DC6FBCB2] AS SELECT      ID,
	Created,
	CreatedBy,
	Updated,
	UpdatedBy,
	IDProtocol,
ProtocolNumber,
	IDRequest,
	IDTool,
	IDCombination,

	CASE Status
	WHEN 0 THEN 'Ke schválení'
	WHEN 1 THEN 'Schváleno'
	WHEN 2 THEN 'Schváleno s odchylkou'
	ELSE 'Zamítnuto' END AS Status

	FROM B2A_TDM_CuttingTest
GO

