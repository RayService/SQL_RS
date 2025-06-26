USE [RayService]
GO

/****** Object:  StoredProcedure [dbo].[hpx_RS_ciselnik_podtypu_neshod_edit]    Script Date: 26.06.2025 10:44:03 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

CREATE PROCEDURE [dbo].[hpx_RS_ciselnik_podtypu_neshod_edit]
@_Pricina NVARCHAR(60),
@ID INT
AS

UPDATE RAY_Podtyp_Neshod SET
_Pricina=@_Pricina
WHERE ID = @ID
GO

