USE [RayService]
GO

/****** Object:  View [dbo].[hvw_RAY_VolbaRespMnoz_JOC]    Script Date: 04.07.2025 7:06:18 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

CREATE VIEW [dbo].[hvw_RAY_VolbaRespMnoz_JOC] AS SELECT ('Množství po výdeji') verejnynazev, (5) typ UNION SELECT ('Množství stavu skladu ') verejnynazev, (3) typ UNION SELECT ('Množství k dispozici ') verejnynazev, (4) typ UNION SELECT ('Množství k dispozici po výdeji ') verejnynazev, (6) typ UNION SELECT ('Množství z dokladu ') verejnynazev, (7) typ
GO

