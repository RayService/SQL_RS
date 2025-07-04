USE [RayService]
GO

/****** Object:  View [dbo].[hvw_SMD_Audit_DUD]    Script Date: 04.07.2025 8:30:53 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

CREATE VIEW [dbo].[hvw_SMD_Audit_DUD] AS SELECT Cislo,
           Nazev 
FROM TabSbornik
GO

