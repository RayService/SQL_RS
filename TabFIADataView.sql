USE [RayService]
GO

/****** Object:  View [dbo].[TabFIADataView]    Script Date: 04.07.2025 10:46:40 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

CREATE VIEW [dbo].[TabFIADataView]  --UPDATED 20160808 
AS 
SELECT D.* FROM /*SysJmenoDatabase*/.dbo.TabFIAData AS D 
WHERE (SUser_SName() COLLATE DATABASE_DEFAULT IN(SELECT LoginName FROM TabFIAAWarrantView AS W 
WHERE W.IdSkupina=D.IdFIADataParam 
AND(NOT W.ReadOnly=2)))
GO

