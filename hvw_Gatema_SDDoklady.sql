USE [RayService]
GO

/****** Object:  View [dbo].[hvw_Gatema_SDDoklady]    Script Date: 03.07.2025 15:10:05 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

CREATE VIEW [dbo].[hvw_Gatema_SDDoklady] AS SELECT H.*, Autor.Jmeno, Generoval=Autor_Gener.Jmeno, (SELECT ABS(ISNULL(SUM(mnozstvi), 0)) FROM Gatema_SDScanData WHERE IDDokladSD=H.ID) Suma,
	DATEDIFF(SECOND, DatPorizeni, ISNULL(DatGenerovani, DatGenerInv))/60.0 DobaVyskladneni,
	(DATEPART(MONTH, DatGenerovani)) DatGenerovani_M, (DATEPART(QUARTER, DatGenerovani)) DatGenerovani_Q,
	(DATEPART(YEAR, DatGenerovani)) DatGenerovani_Y
FROM Gatema_SDDoklady H
LEFT OUTER JOIN SDServer_Users Autor ON Autor.Login=H.Autor
LEFT OUTER JOIN SDServer_Users Autor_Gener ON Autor_Gener.Login=H.AutorGener
WHERE DatGenerovani IS NOT NULL AND TypDokladu<>700
GO

