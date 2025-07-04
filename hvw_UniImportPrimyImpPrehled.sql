USE [RayService]
GO

/****** Object:  View [dbo].[hvw_UniImportPrimyImpPrehled]    Script Date: 04.07.2025 9:04:14 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

CREATE VIEW [dbo].[hvw_UniImportPrimyImpPrehled] AS SELECT o.ID AS ID, 
       CAST(o.name AS NVARCHAR(128)) AS JmenoTabulky, 
       CAST(USER_NAME(o.uid) AS NVARCHAR(128)) AS Vlastnik, 
       CAST(o.crdate AS DATETIME) AS Vytvoreno, 
       CAST(OBJECTPROPERTY(o.id,'TableHasForeignRef')AS BIT) AS FK, 
       CAST(OBJECTPROPERTY(o.id,'TableHasIdentity')AS BIT) AS MaIdentity
FROM dbo.sysindexes i
JOIN dbo.sysobjects o ON i.id=o.id
WHERE i.indid<2
AND o.type='U'
AND ISNULL(CAST(OBJECTPROPERTY(o.id,'IsMSShipped')AS BIT), 0)=0
AND (((SUBSTRING(O.Name, 1, 3)<>N'Tab')OR(SUBSTRING(O.Name, 1, 4)=N'Tabx')OR(SUBSTRING(O.Name, 1, 6)=N'TabDTU'))
     OR(O.Name IN(SELECT NazevTabulky FROM TabUniImportPrimyImpSeznam)))
GO

