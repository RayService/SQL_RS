USE [RayService]
GO

/****** Object:  View [dbo].[hvw_CreditcheckLog]    Script Date: 03.07.2025 14:27:59 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

CREATE VIEW [dbo].[hvw_CreditcheckLog] AS SELECT * FROM RayService.dbo.Tabx_CreditcheckLog
GO

