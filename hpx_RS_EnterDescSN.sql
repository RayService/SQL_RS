USE [RayService]
GO

/****** Object:  StoredProcedure [dbo].[hpx_RS_EnterDescSN]    Script Date: 26.06.2025 13:41:37 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

CREATE PROCEDURE [dbo].[hpx_RS_EnterDescSN] @Nazev2 NVARCHAR(100), @ID INT
AS
UPDATE vcs SET vcs.Nazev2=@Nazev2
FROM TabVyrCP vcp
LEFT OUTER JOIN TabVyrCS vcs ON vcp.IDVyrCis=vcs.ID
WHERE
(vcp.ID=@ID)
GO

