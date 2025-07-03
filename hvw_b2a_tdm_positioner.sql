USE [RayService]
GO

/****** Object:  View [dbo].[hvw_b2a_tdm_positioner]    Script Date: 03.07.2025 13:42:22 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

CREATE VIEW [dbo].[hvw_b2a_tdm_positioner] AS select t1.ID
      ,t1.Color
      ,t2.Nazev
  from B2A_TDM_Setting_Positioner t1
  join TabSortiment t2 on t1.IDType = t2.ID
GO

