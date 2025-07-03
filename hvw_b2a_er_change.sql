USE [RayService]
GO

/****** Object:  View [dbo].[hvw_b2a_er_change]    Script Date: 03.07.2025 13:40:00 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

CREATE VIEW [dbo].[hvw_b2a_er_change] AS select t1.ID
      ,t2.Code
      ,t2.Title as Category
      ,t1.IsValid
      ,t1.IDSchema
      ,t1.Title
      ,t1.IDCategory
      ,t1.ValidDate
from B2A_EmployeeRating_Change t1
join B2A_EmployeeRating_ChangeCategory t2 on t1.IDCategory = t2.ID
GO

