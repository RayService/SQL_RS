USE [RayService]
GO

/****** Object:  View [dbo].[hvw_8927375B837844A8A5AFE4B04AF62308]    Script Date: 03.07.2025 12:15:33 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

CREATE VIEW [dbo].[hvw_8927375B837844A8A5AFE4B04AF62308] AS SELECT H.*, U.Jmeno, (SELECT ABS(ISNULL(SUM(mnozstvi), 0)) FROM Gatema_SDScanData WHERE IDDokladSD=H.ID) Suma,
	DATEDIFF(SECOND, DatPorizeni, ISNULL(DatGenerovani, DatGenerInv))/60.0 DobaVyskladneni,
	(DATEPART(MONTH, DatGenerovani)) DatGenerovani_M, (DATEPART(QUARTER, DatGenerovani)) DatGenerovani_Q,
	(DATEPART(YEAR, DatGenerovani)) DatGenerovani_Y
FROM Gatema_SDDoklady H
LEFT OUTER JOIN SDServer_Users U ON U.Login = H.Autor
WHERE DatGenerovani IS NULL
GO

