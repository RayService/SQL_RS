USE [RayService]
GO

/****** Object:  StoredProcedure [dbo].[hpx_RS_ciselnik_popisu_pricin_new]    Script Date: 26.06.2025 10:39:36 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

CREATE PROCEDURE [dbo].[hpx_RS_ciselnik_popisu_pricin_new]
@_PopisPric NVARCHAR(255)
AS

INSERT INTO RAY_PricinaEx (_PopisPric,Archive)
VALUES (@_PopisPric,0)
GO

