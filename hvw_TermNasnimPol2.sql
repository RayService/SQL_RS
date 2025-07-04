USE [RayService]
GO

/****** Object:  View [dbo].[hvw_TermNasnimPol2]    Script Date: 04.07.2025 8:56:19 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

CREATE VIEW [dbo].[hvw_TermNasnimPol2] AS SELECT P.* FROM Gatema_SDScanData P
 INNER JOIN Gatema_SDDoklady H ON H.ID=P.IDDokladSD
GO

