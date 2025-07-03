USE [RayService]
GO

/****** Object:  View [dbo].[hvw_asapprehleedy]    Script Date: 03.07.2025 13:34:53 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

CREATE VIEW [dbo].[hvw_asapprehleedy] AS select *,(select skupina from tabobecnyprehled op where op.cislo+100000=bid) as skupina from Saperta_Tab_Prehledy
GO

