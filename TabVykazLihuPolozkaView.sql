USE [RayService]
GO

/****** Object:  View [dbo].[TabVykazLihuPolozkaView]    Script Date: 04.07.2025 13:21:43 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

CREATE VIEW [dbo].[TabVykazLihuPolozkaView] AS
SELECT IdZbozi, IdOdberatel, CAST(SUM(Pocet) AS NUMERIC(19,2)) AS Pocet, OpustiloDanovySklad, Storno
FROM TabVykazLihuDetail
WHERE ZahrnoutDoVykazu = 1
GROUP BY IdZbozi, IdOdberatel, OpustiloDanovySklad, Storno
HAVING SUM(Pocet) > 0.009
GO

