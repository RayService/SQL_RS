USE [RayService]
GO

/****** Object:  View [dbo].[TabFIAWebDatabaseView]    Script Date: 04.07.2025 10:48:52 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

CREATE VIEW [dbo].[TabFIAWebDatabaseView] --UPDATED 20170127
AS SELECT * FROM /*SysJmenoDatabaseWeb*/.dbo.TabFIAWebDatabase
GO

