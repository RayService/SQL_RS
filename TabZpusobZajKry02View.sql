USE [RayService]
GO

/****** Object:  View [dbo].[TabZpusobZajKry02View]    Script Date: 04.07.2025 13:09:39 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

CREATE VIEW [dbo].[TabZpusobZajKry02View] WITH SCHEMABINDING AS
SELECT R.ID AS IDZpusob, S.ID AS IDZboSklad,
SUM(X.MnKryteEvid) AS MnKryteEvid,
COUNT_BIG(*) AS CNT
FROM dbo.TabStavSkladu S
-- zpusob zajisteni kryti, ziskam zde IDZboSklad
JOIN dbo.TabZpusobZajKry02 X ON X.IDZboSklad = S.ID
JOIN dbo.TabDosleObjR02 R ON R.ID = X.IDZpusob
WHERE X.MnKryteEvid IS NOT NULL
AND R.IDZboSklad <> X.IDZboSklad
GROUP BY R.ID, S.ID
GO

