USE [RayService]
GO

/****** Object:  View [dbo].[hvw_0EEC27C943514A8684FC3BB7AB17605D]    Script Date: 03.07.2025 10:54:12 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

CREATE VIEW [dbo].[hvw_0EEC27C943514A8684FC3BB7AB17605D] AS select t1.ID
      ,t3.Title as Contact
      ,t4.Position
      ,t4.CrossSection
      ,t4.Code as Wire
      ,t6.Nazev as Positioner
      ,t5.Color
      ,t4.IDTool
      ,t1.IDProductionOrder
      ,t2.IDSetting
      ,t4.IDPositioner
      ,t2.IDContact
      ,t1.ChangeTo
      ,t1.IDCombination
	  ,TP.IDTabKmen
from B2A_TDM_Combination_ProductionOrder t1 WITH(NOLOCK)
join B2A_TDM_Combination t2 WITH(NOLOCK) on t1.IDCombination = t2.ID
join B2A_TDM_Contact t3 WITH(NOLOCK) on t3.ID = t2.IDContact
join B2A_TDM_Setting t4 WITH(NOLOCK) on t4.ID = t2.IDSetting
left join B2A_TDM_Setting_Positioner t5 WITH(NOLOCK) on t5.ID = t4.IDPositioner
left join TabSortiment t6 WITH(NOLOCK) on t6.ID = t5.IDType
LEFT OUTER JOIN TabPrikaz TP WITH(NOLOCK) ON TP.ID=t1.IDProductionOrder
WHERE TP.StavPrikazu<=40
GO

