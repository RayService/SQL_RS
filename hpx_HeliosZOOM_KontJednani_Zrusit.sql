USE [RayService]
GO

/****** Object:  StoredProcedure [dbo].[hpx_HeliosZOOM_KontJednani_Zrusit]    Script Date: 26.06.2025 9:37:18 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

CREATE PROC [dbo].[hpx_HeliosZOOM_KontJednani_Zrusit] @Check BIT,@ID INT
AS

DELETE TabKontaktJednani WHERE ID = @ID
GO

