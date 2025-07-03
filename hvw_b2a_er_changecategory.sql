USE [RayService]
GO

/****** Object:  View [dbo].[hvw_b2a_er_changecategory]    Script Date: 03.07.2025 13:40:22 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

CREATE VIEW [dbo].[hvw_b2a_er_changecategory] AS select t1.ID
      ,t1.Code
      ,t1.Title
from B2A_EmployeeRating_ChangeCategory t1
GO

