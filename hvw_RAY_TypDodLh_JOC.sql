USE [RayService]
GO

/****** Object:  View [dbo].[hvw_RAY_TypDodLh_JOC]    Script Date: 04.07.2025 7:05:49 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

CREATE VIEW [dbo].[hvw_RAY_TypDodLh_JOC] AS SELECT ('Den') verejnynazev, (0) typ UNION SELECT ('Měsíc ') verejnynazev, (1) typ UNION SELECT ('Rok ') verejnynazev, (2) typ
GO

