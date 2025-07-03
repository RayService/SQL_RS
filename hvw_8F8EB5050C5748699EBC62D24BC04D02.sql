USE [RayService]
GO

/****** Object:  View [dbo].[hvw_8F8EB5050C5748699EBC62D24BC04D02]    Script Date: 03.07.2025 12:33:23 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

CREATE VIEW [dbo].[hvw_8F8EB5050C5748699EBC62D24BC04D02] AS select *,  (select atabu.tabver from atabu where tabulka=asloupce.tabulka) as verjmeno from asloupce
GO

