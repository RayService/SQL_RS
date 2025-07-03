USE [RayService]
GO

/****** Object:  View [dbo].[hvw__StromTracebility]    Script Date: 03.07.2025 10:51:13 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

CREATE VIEW [dbo].[hvw__StromTracebility] AS SELECT * FROM GTab_StromTracebility WHERE Autor=suser_sname()
GO

