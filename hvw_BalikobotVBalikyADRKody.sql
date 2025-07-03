USE [RayService]
GO

/****** Object:  View [dbo].[hvw_BalikobotVBalikyADRKody]    Script Date: 03.07.2025 14:08:10 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

CREATE VIEW [dbo].[hvw_BalikobotVBalikyADRKody] AS SELECT VA.*, A.unit_code AS ADR_unit_code, A.unit_name AS ADR_unit_name
FROM Tabx_BalikobotVBalikyADRKody VA
LEFT OUTER JOIN Tabx_BalikobotADRJednotky A ON A.unit_id=VA.ADR_unit_id AND A.KodDopravce=VA.KodDopravce
GO

