USE [RayService]
GO

/****** Object:  View [dbo].[hvw_86DA7EFB9A1C47909A80C388875A2530]    Script Date: 03.07.2025 11:27:46 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

CREATE VIEW [dbo].[hvw_86DA7EFB9A1C47909A80C388875A2530] AS (SELECT
tpl.ID AS IDPolozka,
0 AS Typ,
tpl.IDZakazka AS IDZakazka,
tpl.IDTabKmen AS IDTabKmen
FROM TabPlan tpl  WITH(NOLOCK)
WHERE tpl.Rada NOT IN (N'PT_burza',N'P_Freezed')/*tpl.mnozNeprev>0*/
)
UNION ALL
(SELECT
tp.ID AS IDPolozka,
1 AS Typ,
tp.IDZakazka AS IDZakazka,
tp.IDTabKmen AS IDTabKmen
FROM TabPrikaz tp  WITH(NOLOCK)
WHERE tp.StavPrikazu>20
)
GO

