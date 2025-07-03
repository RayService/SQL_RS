USE [RayService]
GO

/****** Object:  View [dbo].[hvw_97FA2B553A8445FFB14D256CFC124730]    Script Date: 03.07.2025 12:45:10 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

CREATE VIEW [dbo].[hvw_97FA2B553A8445FFB14D256CFC124730] AS SELECT
tkz.ID AS ID
,tkz.SkupZbo AS SK
,tkz.RegCis AS RegCis
,tkz.Nazev1 AS Nazev1
,tkz.Nazev2 AS Nazev2
,tkz.SKP AS DoplnkovyKod
,tkze._EXT_RS_HPhrases AS HPhrases
,SUM(tss.Mnozstvi) AS Mnozstvi
FROM TabKmenZbozi tkz WITH(NOLOCK)
LEFT OUTER JOIN TabKmenZbozi_EXT tkze WITH(NOLOCK) ON tkze.ID=tkz.ID
LEFT OUTER JOIN TabStavSkladu tss ON tss.IDKmenZbozi=tkz.ID
WHERE ISNULL(tkze._lepidloTmel,0)=1
GROUP BY tkz.ID,tkz.SkupZbo,tkz.RegCis,tkz.Nazev1,tkz.Nazev2,tkz.SKP,tkze._EXT_RS_HPhrases
GO

