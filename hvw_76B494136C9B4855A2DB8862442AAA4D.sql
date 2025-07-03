USE [RayService]
GO

/****** Object:  View [dbo].[hvw_76B494136C9B4855A2DB8862442AAA4D]    Script Date: 03.07.2025 11:22:01 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

CREATE VIEW [dbo].[hvw_76B494136C9B4855A2DB8862442AAA4D] AS SELECT [ID]
      ,[Zdroje]
      ,[Poznamka]
      ,[Autor]
      ,[DatPorizeni]
      ,[Zmenil]
      ,[DatZmeny]
      ,[DatPorizeni_D]
      ,[DatPorizeni_M]
      ,[DatPorizeni_Y]
      ,[DatPorizeni_Q]
      ,[DatPorizeni_W]
      ,[DatPorizeni_X]
      ,[DatZmeny_D]
      ,[DatZmeny_M]
      ,[DatZmeny_Y]
      ,[DatZmeny_Q]
      ,[DatZmeny_W]
      ,[DatZmeny_X]
  FROM [RayService].[dbo].[RAY_Personalistika_Zdroje]
GO

