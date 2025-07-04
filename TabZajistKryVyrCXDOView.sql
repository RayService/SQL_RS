USE [RayService]
GO

/****** Object:  View [dbo].[TabZajistKryVyrCXDOView]    Script Date: 04.07.2025 13:05:11 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

CREATE VIEW [dbo].[TabZajistKryVyrCXDOView] WITH SCHEMABINDING AS
SELECT vcx.IDVyrCS AS ID, S.ID AS IDZboSklad,
SUM(vcx.MnKryteEv) AS MnKryteEvid,
COUNT_BIG(*) AS CNT
FROM dbo.TabStavSkladu S
JOIN dbo.TabZajistKryX       X ON X.IDZboSklad = S.ID
JOIN dbo.TabZajistX          Z ON Z.ID = X.IDZajist AND Z.JeVC = 1
JOIN dbo.TabDosleObjR02      R ON R.ID = Z.IDDObjR02
JOIN dbo.TabZajistKryVyrCX vcx ON vcx.IDZajistKry = X.ID
WHERE vcx.MnKryteEv IS NOT NULL
AND R.IDZboSklad <> X.IDZboSklad
GROUP BY vcx.IDVyrCS, S.ID
GO

