USE [RayService]
GO

/****** Object:  View [dbo].[hvw_RayService_StavZakaznika]    Script Date: 04.07.2025 7:24:49 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

CREATE VIEW [dbo].[hvw_RayService_StavZakaznika] AS SELECT CAST('Nový' as NVARCHAR(20)) as StavZakaznika UNION SELECT 'Stávající' UNION SELECT 'Ztracený' UNION SELECT 'Transformovaný' UNION SELECT ''
GO

