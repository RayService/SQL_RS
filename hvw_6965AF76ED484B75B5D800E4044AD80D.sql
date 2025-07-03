USE [RayService]
GO

/****** Object:  View [dbo].[hvw_6965AF76ED484B75B5D800E4044AD80D]    Script Date: 03.07.2025 11:17:28 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

CREATE VIEW [dbo].[hvw_6965AF76ED484B75B5D800E4044AD80D] AS select  atabu.id, atabu.tabulka, atabu.tabver, atabu.integr, atabu.prehledy, atabu.zakazatzurnal, atabu.zurnaln, atabu.zurnalo, atabu.zurnalz, atabu.fyzickejmeno, atabu.mezid, atabu.typimexshop, atabu.poradiexport,
atabu.pocetdniprovymaz, atabu.druhyklic, atabu.tretiklic, saplogovanitiskufm, atabu.pocetzaznamu, atabu.pocetzaznamutestu,atabu.dentestovani, atabu.kontrolarychlosti,atabu.autor, atabu.datporizeni, 
day(atabu.datporizeni) as datporizeni_d, month(atabu.datporizeni) as datporizeni_m,  DATEPART(QUARTER,atabu.DatPorizeni) as datporizeni_q,  DATEPART(week,atabu.DatPorizeni) as datporizeni_w, 
year(atabu.datporizeni) as datporizeni_y, CONVERT(DATETIME,CONVERT(INT,CONVERT(FLOAT,atabu.DatPorizeni))) as datporizeni_x, 
zmenil, datzmeny,
day(atabu.datzmeny) as datzmeny_d, month(atabu.datzmeny) as datzmeny_m,  DATEPART(QUARTER,atabu.datzmeny) as datzmeny_q,  DATEPART(week,atabu.datzmeny) as datzmeny_w, 
year(atabu.datzmeny) as datzmeny_y, CONVERT(DATETIME,CONVERT(INT,CONVERT(FLOAT,atabu.datzmeny))) as datzmeny_x, filtrshop, aktdatzme
 from atabu
GO

