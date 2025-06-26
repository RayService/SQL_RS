USE [RayService]
GO

/****** Object:  StoredProcedure [dbo].[hpx_RS_prednastaveni_tisku_china_radek2]    Script Date: 26.06.2025 11:44:22 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

CREATE PROCEDURE [dbo].[hpx_RS_prednastaveni_tisku_china_radek2]
AS
BEGIN
UPDATE TabDefTisk SET Prednastaveno=0
FROM TabDefTisk
WHERE ID = 206
UPDATE TabDefTisk SET Prednastaveno=1
FROM TabDefTisk
WHERE ID = 207
END;
GO

