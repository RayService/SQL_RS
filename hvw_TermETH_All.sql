USE [RayService]
GO

/****** Object:  View [dbo].[hvw_TermETH_All]    Script Date: 04.07.2025 8:54:57 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

CREATE VIEW [dbo].[hvw_TermETH_All] AS SELECT
*,
CelkCasN=CelkCasS/60.0,
CelkCasH=CelkCasS/3600.0,
Ukonceno=convert(bit,CASE WHEN ISNULL(IDKolegy,-1)<0 THEN 0 ELSE 1 END)
FROM Gatema_TermETH
GO

