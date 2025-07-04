USE [RayService]
GO

/****** Object:  View [dbo].[TabExterniZdrojView]    Script Date: 04.07.2025 10:17:35 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

CREATE VIEW [dbo].[TabExterniZdrojView] AS
SELECT CAST(srvname AS NVARCHAR(128)) AS srvname,CAST(srvproduct AS NVARCHAR(128)) AS srvproduct,CAST(providername AS NVARCHAR(128)) AS providername,CAST(datasource AS NVARCHAR(255)) AS datasource,CAST(providerstring AS NVARCHAR(255)) AS providerstring,CAST(srvnetname AS NVARCHAR(30))AS srvnetname FROM master.dbo.sysservers
GO

