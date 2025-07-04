USE [RayService]
GO

/****** Object:  View [dbo].[TabFIAWebGroupsView]    Script Date: 04.07.2025 10:49:52 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

CREATE VIEW [dbo].[TabFIAWebGroupsView]  --UPDATED 20230323
AS SELECT * FROM /*SysJmenoDatabaseWeb*/.dbo.TabFIAWebGroups
GO

