USE [RayService]
GO

/****** Object:  View [dbo].[hvw_SMD_Audit_Strediska]    Script Date: 04.07.2025 8:35:27 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

CREATE VIEW [dbo].[hvw_SMD_Audit_Strediska] AS SELECT Cislo, Nazev FROM TabStrom
GO

