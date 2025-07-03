USE [RayService]
GO

/****** Object:  View [dbo].[hvw_676006E2286D44E1806CE4539100762E]    Script Date: 03.07.2025 11:16:04 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

CREATE VIEW [dbo].[hvw_676006E2286D44E1806CE4539100762E] AS SELECT tdz.ID, tdz.RadaDokladu, tdz.PoradoveCislo
FROM RayService5.dbo.TabDokladyZbozi tdz WITH(NOLOCK)
LEFT OUTER JOIN RayService.dbo.TabDokladyZbozi_EXT tdze WITH(NOLOCK) ON tdze.ID=tdz.ID
WHERE (tdz.DruhPohybuZbo=0)AND(tdz.RadaDokladu='533')
GO

