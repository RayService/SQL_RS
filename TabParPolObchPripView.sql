USE [RayService]
GO

/****** Object:  View [dbo].[TabParPolObchPripView]    Script Date: 04.07.2025 11:34:30 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

CREATE VIEW [dbo].[TabParPolObchPripView] AS 
SELECT IDPohyb=PZ.ID, IdObchPrip=PZ.IDPrikaz 
FROM TabPohybyZbozi PZ
WHERE PZ.TypVyrobnihoDokladu=4 AND PZ.DokladPrikazu=PZ.ID

 
GO

