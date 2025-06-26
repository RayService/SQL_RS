USE [RayService]
GO

/****** Object:  StoredProcedure [dbo].[hpx_RS_zmena_upozorneni]    Script Date: 26.06.2025 11:24:04 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

CREATE PROCEDURE [dbo].[hpx_RS_zmena_upozorneni]
@upozorneni NVARCHAR(255),
@kontrola bit,
@ID int
AS
IF @kontrola = 1
BEGIN
UPDATE TabKmenZbozi SET TabKmenZbozi.Upozorneni=@upozorneni WHERE ID=@ID
END
GO

