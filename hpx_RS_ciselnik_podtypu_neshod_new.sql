USE [RayService]
GO

/****** Object:  StoredProcedure [dbo].[hpx_RS_ciselnik_podtypu_neshod_new]    Script Date: 26.06.2025 10:51:33 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

ALTER PROCEDURE [dbo].[hpx_RS_ciselnik_podtypu_neshod_new]
@_Pricina nvarchar(60)
AS

INSERT INTO RAY_Podtyp_Neshod (_Pricina,Archive)
VALUES (@_Pricina,0)
GO

