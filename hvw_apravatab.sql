USE [RayService]
GO

/****** Object:  View [dbo].[hvw_apravatab]    Script Date: 03.07.2025 12:52:37 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

CREATE VIEW [dbo].[hvw_apravatab] AS select *, typ as typ_r from apravatab
GO

