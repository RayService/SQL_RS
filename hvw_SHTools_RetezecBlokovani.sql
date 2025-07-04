USE [RayService]
GO

/****** Object:  View [dbo].[hvw_SHTools_RetezecBlokovani]    Script Date: 04.07.2025 8:29:08 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

CREATE VIEW [dbo].[hvw_SHTools_RetezecBlokovani] AS SELECT
ID
,Retezec
,SPID
,LoginName
,HostName
,ProgramName
,DbName
,ObjectId
,Query
,CAST((SUBSTRING(REPLACE(SUBSTRING(Query,1,255),(NCHAR(13) + NCHAR(10)),NCHAR(32)),1,255)) as  NVARCHAR(255)) as Query_255
,Query as Query_All
,ParentQuery
,CAST((SUBSTRING(REPLACE(SUBSTRING(ParentQuery,1,255),(NCHAR(13) + NCHAR(10)),NCHAR(32)),1,255))  as  NVARCHAR(255)) as ParentQuery_255
,ParentQuery as ParentQuery_All
,Deadlock
,DatPorizeni
,Autor
FROM dbo.Tabx_SHTools_RetezecBlokovani
GO

