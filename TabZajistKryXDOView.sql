USE [RayService]
GO

/****** Object:  View [dbo].[TabZajistKryXDOView]    Script Date: 04.07.2025 13:06:00 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

CREATE VIEW [dbo].[TabZajistKryXDOView] WITH SCHEMABINDING AS
SELECT R.ID, S.ID AS IDZboSklad,
SUM(X.MnKryteEvid) AS MnKryteEvid,
COUNT_BIG(*) AS CNT
FROM dbo.TabStavSkladu S
-- zpusob zajisteni kryti, ziskam zde IDZboSklad
JOIN dbo.TabZajistKryX  X ON X.IDZboSklad = S.ID
JOIN dbo.TabZajistX     Z ON Z.ID = X.IDZajist
JOIN dbo.TabDosleObjR02 R ON R.ID = Z.IDDObjR02
WHERE X.MnKryteEvid IS NOT NULL
AND R.IDZboSklad <> X.IDZboSklad
GROUP BY R.ID, S.ID
GO

