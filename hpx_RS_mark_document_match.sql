USE [RayService]
GO

/****** Object:  StoredProcedure [dbo].[hpx_RS_mark_document_match]    Script Date: 26.06.2025 12:46:22 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

CREATE PROCEDURE [dbo].[hpx_RS_mark_document_match] @Match BIT, @ID INT
AS
UPDATE AI2helios.dbo.Tabx_RS_Robot_Finder_Found SET Marker=SUSER_SNAME(), Matched=1,Result=@Match WHERE ID=@ID
/*UPDATE  RAYSERVEISS.AI2helios.dbo.Tabx_RS_Robot_Finder_Found SET Marker=SUSER_SNAME(), Matched=1,Result=@Match WHERE ID=@ID*/
GO

