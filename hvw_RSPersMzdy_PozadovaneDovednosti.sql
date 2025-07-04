USE [RayService]
GO

/****** Object:  View [dbo].[hvw_RSPersMzdy_PozadovaneDovednosti]    Script Date: 04.07.2025 8:08:15 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

CREATE VIEW [dbo].[hvw_RSPersMzdy_PozadovaneDovednosti] AS SELECT
ID
,IDZam
,Vypocet
,IDPPDetailZnalosti
,IDPP
FROM Tabx_RSPersMzdy_PozadovaneDovednosti
GO

