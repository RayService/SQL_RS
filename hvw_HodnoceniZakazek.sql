USE [RayService]
GO

/****** Object:  View [dbo].[hvw_HodnoceniZakazek]    Script Date: 03.07.2025 15:18:54 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

CREATE VIEW [dbo].[hvw_HodnoceniZakazek] AS SELECT Tabx_ASOL_HodnoceniZakazek.* FROM dbo.Tabx_ASOL_HodnoceniZakazek WITH(NOLOCK)  WHERE Autor=(SELECT @@spid)
GO

