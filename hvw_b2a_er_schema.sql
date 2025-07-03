USE [RayService]
GO

/****** Object:  View [dbo].[hvw_b2a_er_schema]    Script Date: 03.07.2025 13:41:14 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

CREATE VIEW [dbo].[hvw_b2a_er_schema] AS select t1.ID,t1.Title from B2A_EmployeeRating_Schema t1
GO

