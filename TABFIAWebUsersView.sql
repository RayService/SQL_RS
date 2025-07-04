USE [RayService]
GO

/****** Object:  View [dbo].[TABFIAWebUsersView]    Script Date: 04.07.2025 10:51:09 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

CREATE VIEW [dbo].[TABFIAWebUsersView]  --UPDATED 20230324
AS SELECT * FROM /*SysJmenoDatabaseWeb*/.dbo.TabFIAWebUsers
GO

