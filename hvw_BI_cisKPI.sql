USE [RayService]
GO

/****** Object:  View [dbo].[hvw_BI_cisKPI]    Script Date: 03.07.2025 14:13:08 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

CREATE VIEW [dbo].[hvw_BI_cisKPI] AS select 1 as id, 'Šipky' as popis

union

select 2 as id, 'Kolečka' as popis

union

select 3 as id, 'Znamínka' as popis

union

select 4 as id, 'Splněno/Nesplněno' as popis
GO

