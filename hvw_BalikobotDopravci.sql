USE [RayService]
GO

/****** Object:  View [dbo].[hvw_BalikobotDopravci]    Script Date: 03.07.2025 13:56:27 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

CREATE VIEW [dbo].[hvw_BalikobotDopravci] AS SELECT * FROM Tabx_BalikobotDopravci WHERE PodporovanoHeO=1
GO

