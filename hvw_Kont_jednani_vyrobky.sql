USE [RayService]
GO

/****** Object:  View [dbo].[hvw_Kont_jednani_vyrobky]    Script Date: 03.07.2025 15:21:17 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

/*rpHCVObchKalk.D01*/CREATE VIEW [dbo].[hvw_Kont_jednani_vyrobky] 
AS 
SELECT TabSvsSpotreba.ID, SkupZbo, RegCis, Nazev1, PoradoveCislo, Predmet 
  FROM TabSvsSpotreba
       LEFT OUTER JOIN TabKontaktJednani tkj ON TabSvsSpotreba.IDKonJed=tkj.ID
GO

