USE [RayService]
GO

/****** Object:  View [dbo].[TabFIADataKumView]    Script Date: 04.07.2025 10:37:28 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

CREATE VIEW [dbo].[TabFIADataKumView]  --UPDATED 20160808 
AS 
SELECT DK.* FROM /*SysJmenoDatabase*/.dbo.TabFIADataKum AS DK
WHERE (SUser_SName() COLLATE DATABASE_DEFAULT IN(SELECT LoginName FROM TabFIAAWarrantView AS AW 
WHERE AW.IdSkupina=DK.IdFIADataParam 
AND(NOT AW.ReadOnly=2)))
GO

