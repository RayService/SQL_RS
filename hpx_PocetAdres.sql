USE [RayService]
GO

/****** Object:  StoredProcedure [dbo].[hpx_PocetAdres]    Script Date: 26.06.2025 10:35:46 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO


CREATE PROCEDURE [dbo].[hpx_PocetAdres] @Pocet INT OUTPUT
AS
SELECT count(*) FROM TabMJ
GO

