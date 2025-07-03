USE [RayService]
GO

/****** Object:  View [dbo].[hvw_FDpropeshop]    Script Date: 03.07.2025 14:54:14 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

CREATE VIEW [dbo].[hvw_FDpropeshop] AS select id, zmena as zmena, datporizeni,
day(datporizeni) as datporizeni_d, month(datporizeni) as datporizeni_m,  DATEPART(QUARTER,DatPorizeni) as datporizeni_q,
DATEPART(week,DatPorizeni) as datporizeni_w, year(datporizeni) as datporizeni_y, 
CONVERT(DATETIME,CONVERT(INT,CONVERT(FLOAT,DatPorizeni))) as datporizeni_x,druhyklic, tretiklic,id1,id2, id3, 
 autor, pocitac,precteno, idtab, idtabulky from apropeshop
GO

