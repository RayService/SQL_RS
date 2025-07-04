USE [RayService]
GO

/****** Object:  View [dbo].[hvw_RayService_LezakyRadky]    Script Date: 04.07.2025 7:22:05 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

CREATE VIEW [dbo].[hvw_RayService_LezakyRadky] AS SELECT
L.ID
,S.IDSklad
,L.Rok
,L.Mesic
,L.M
,L.S
,L.A
FROM Tabx_RayService_LezakyRadky L
LEFT OUTER JOIN TabStavSkladu S ON L.ID = S.ID
GO

