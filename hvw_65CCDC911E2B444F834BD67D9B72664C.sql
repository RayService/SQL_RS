USE [RayService]
GO

/****** Object:  View [dbo].[hvw_65CCDC911E2B444F834BD67D9B72664C]    Script Date: 03.07.2025 11:15:17 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

CREATE VIEW [dbo].[hvw_65CCDC911E2B444F834BD67D9B72664C] AS select *, objecttype as typeobj, cast(cast(last_worker_time as numeric(19,6)) /1000000.00 as numeric(19,6)) as praccassek, cast(cast(max_elapsed_time as numeric(19,6)) /1000000.00 as numeric(19,6)) as elapccasek from dbo.Saperta_Tab_objectLog
GO

