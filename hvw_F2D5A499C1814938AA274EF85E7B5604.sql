USE [RayService]
GO

/****** Object:  View [dbo].[hvw_F2D5A499C1814938AA274EF85E7B5604]    Script Date: 03.07.2025 14:47:14 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

CREATE VIEW [dbo].[hvw_F2D5A499C1814938AA274EF85E7B5604] AS 
SELECT ID
      ,defectType
      ,productionOrderId
      ,operationId
      ,finalReportId
      ,unitsCount
      ,description
	  ,(SUBSTRING(REPLACE(SUBSTRING(description,1,255),(CHAR(13) + CHAR(10)),' '),1,255)) AS description_255
	  ,description AS description_ALL
      ,comment
	  ,(SUBSTRING(REPLACE(SUBSTRING(comment,1,255),(CHAR(13) + CHAR(10)),' '),1,255)) AS comment_255
	  ,comment AS comment_ALL
      ,statusId
      ,resolveTypeId
      ,Autor
      ,Zmenil
      ,Vyresil
      ,DatPorizeni
      ,DatZmeny
      ,DatVyreseni
      ,DatPorizeni_D
      ,DatPorizeni_M
      ,DatPorizeni_Y
      ,DatPorizeni_Q
      ,DatPorizeni_W
      ,DatPorizeni_X
      ,DatZmeny_D
      ,DatZmeny_M
      ,DatZmeny_Y
      ,DatZmeny_Q
      ,DatZmeny_W
      ,DatZmeny_X
      ,DatVyreseni_D
      ,DatVyreseni_M
      ,DatVyreseni_Y
      ,DatVyreseni_Q
      ,DatVyreseni_W
      ,DatVyreseni_X
  FROM RayService.dbo.Tabx_Apps_QaDefectReport WITH(NOLOCK)
GO

