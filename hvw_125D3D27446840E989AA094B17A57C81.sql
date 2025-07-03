USE [RayService]
GO

/****** Object:  View [dbo].[hvw_125D3D27446840E989AA094B17A57C81]    Script Date: 03.07.2025 10:56:10 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

CREATE VIEW [dbo].[hvw_125D3D27446840E989AA094B17A57C81] AS SELECT [ID]
      ,[Parametr]
      ,[Vyporadani_premioveho_koef]
      ,[Premiovy_koef_od]
      ,[Premiovy_koef_do]
      ,[Koef_1_od]
      ,[Koef_1_do]
      ,[Koef_08_od]
      ,[Koef_08_do]
      ,[Koef_06_od]
      ,[Koef_06_do]
      ,[Koef_0_od]
      ,[Koef_0_do]
      ,[Cetnost]
      ,[Majitel]
      ,[Poznamka]
      ,(SUBSTRING(REPLACE(SUBSTRING(RAY_Parametry_Definice.[Poznamka],1,255),(CHAR(13) + CHAR(10)),' '),1,255)) AS Poznamka_255
      ,[Poznamka] AS Poznamka_ALL 
      ,[Autor]
      ,[DatPorizeni]
      ,[DatPorizeni_D]
      ,[DatPorizeni_M]
      ,[DatPorizeni_Y]
      ,[DatPorizeni_Q]
      ,[DatPorizeni_W]
      ,[DatPorizeni_X]
      ,[Zmenil]
      ,[DatZmeny]
      ,[DatZmeny_D]
      ,[DatZmeny_M]
      ,[DatZmeny_Y]
      ,[DatZmeny_Q]
      ,[DatZmeny_W]
      ,[DatZmeny_X]
      ,[Vyhodnoceni]
      ,[Ukazatel]
      ,[Vyhodnocuje]
      ,[parameter_inclusion]
      ,[upper_lever1_param]
      ,[upper_lever2_param]
      ,[Archive]
      ,[KPI]
  FROM [RayService].[dbo].[RAY_Parametry_Definice]
GO

