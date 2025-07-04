USE [RayService]
GO

/****** Object:  View [dbo].[hvw_RAY_PopisNeshodyEx]    Script Date: 04.07.2025 7:04:09 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

CREATE VIEW [dbo].[hvw_RAY_PopisNeshodyEx] AS SELECT _PopisNeshody FROM TabPohybyZbozi_EXT
WHERE  _PopisNeshody IS NOT NULL
GROUP BY _PopisNeshody
GO

