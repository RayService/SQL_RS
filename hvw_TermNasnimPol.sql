USE [RayService]
GO

/****** Object:  View [dbo].[hvw_TermNasnimPol]    Script Date: 04.07.2025 8:55:52 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

CREATE VIEW [dbo].[hvw_TermNasnimPol] AS SELECT P.*, U.Jmeno FROM Gatema_SDScanData P
INNER JOIN Gatema_SDDoklady H ON H.ID=P.IDDokladSD
LEFT OUTER JOIN SDServer_Users U ON U.Login=P.Autor
WHERE H.DatGenerovani IS NOT NULL AND H.TypDokladu<>700
GO

