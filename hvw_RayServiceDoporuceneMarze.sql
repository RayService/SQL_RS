USE [RayService]
GO

/****** Object:  View [dbo].[hvw_RayServiceDoporuceneMarze]    Script Date: 04.07.2025 7:25:36 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

CREATE VIEW [dbo].[hvw_RayServiceDoporuceneMarze] AS select  m.id,
m.cisloOrg,
m.skupZbo,
	   m.marza,
	   o.Nazev
from dbo.tabx_RayServiceDoporucenaMarza m
	 left join dbo.TabCisOrg o On o.CisloOrg = m.cisloOrg
GO

