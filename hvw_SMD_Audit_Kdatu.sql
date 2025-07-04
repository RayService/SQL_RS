USE [RayService]
GO

/****** Object:  View [dbo].[hvw_SMD_Audit_Kdatu]    Script Date: 04.07.2025 8:31:21 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

CREATE VIEW [dbo].[hvw_SMD_Audit_Kdatu] AS (SELECT DatumOd, DatumDo FROM SMDTabVyberObdobi)
GO

