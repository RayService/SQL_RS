USE [RayService]
GO

/****** Object:  StoredProcedure [dbo].[hpx_RS_popis_pricin_edit]    Script Date: 26.06.2025 10:43:04 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

CREATE PROCEDURE [dbo].[hpx_RS_popis_pricin_edit]
@_PopisPric NVARCHAR(255),
@ID INT
AS

UPDATE RAY_PricinaEx SET
_PopisPric=@_PopisPric
WHERE ID = @ID
GO

