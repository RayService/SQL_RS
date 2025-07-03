USE [RayService]
GO

/****** Object:  View [dbo].[hvw_LogoVlastniFirmyTisk]    Script Date: 03.07.2025 15:23:47 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

CREATE VIEW [dbo].[hvw_LogoVlastniFirmyTisk] AS SELECT 
CisloOrg
,Logo
,Logo_BGJ
FROM TabCisOrg
GO

