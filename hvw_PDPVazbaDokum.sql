USE [RayService]
GO

/****** Object:  View [dbo].[hvw_PDPVazbaDokum]    Script Date: 03.07.2025 15:31:13 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

CREATE VIEW [dbo].[hvw_PDPVazbaDokum] AS SELECT V.IdHlavPDP AS IdHlavPDP,
D.Popis AS Nazev,
D.JmenoACesta AS JmenoACesta,
D.ID AS IdDokum, 
V.ID AS ID,
V.Ident AS Ident
FROM TabDokumenty D
LEFT OUTER JOIN TabPDPVazbaDokum V ON V.IDDokum=D.ID
WHERE V.IDHlavPDP<>''
GO

