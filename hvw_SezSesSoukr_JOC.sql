USE [RayService]
GO

/****** Object:  View [dbo].[hvw_SezSesSoukr_JOC]    Script Date: 04.07.2025 8:25:03 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

CREATE VIEW [dbo].[hvw_SezSesSoukr_JOC] AS SELECT TabFiltr.ID,TabFiltr.BrowseID, (TabFiltr.BrowseID) NazPreh, TabFiltr.Nazev,TabFiltr.Distribucni,CONVERT(bit,CASE WHEN EXISTS(SELECT * FROM TabDefaultFiltr WHERE TabDefaultFiltr.FiltrID=TabFiltr.ID) THEN 1 ELSE 0 END) AS DefaultFilt,TabFiltr.BrowseID AS BrowseIDBezKonverze,TabFiltr.Vytvoreno,TabFiltr.Vytvoril,TabFiltr.Zmeneno,TabFiltr.Zmenil, TabPravaFiltr.LoginName
FROM TabFiltr
LEFT JOIN TabPravaFiltr ON TabPravaFiltr.IDFiltr = TabFiltr.ID
GO

