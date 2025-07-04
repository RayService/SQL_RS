USE [RayService]
GO

/****** Object:  View [dbo].[hvw_RAY_PricinaEx]    Script Date: 04.07.2025 7:05:24 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

CREATE VIEW [dbo].[hvw_RAY_PricinaEx] AS 
SELECT ID,_Pricina, Archive FROM RAY_Podtyp_Neshod
/*
SELECT _Pricina FROM TabPohybyZbozi_EXT
WHERE  _Pricina  IS NOT NULL
GROUP BY _Pricina
*/
GO

