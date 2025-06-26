USE [RayService]
GO

/****** Object:  StoredProcedure [dbo].[hpx_HeliosZOOM_RS_UzavreniUkolu]    Script Date: 26.06.2025 15:14:25 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

CREATE PROCEDURE [dbo].[hpx_HeliosZOOM_RS_UzavreniUkolu]
@ID INT
AS
BEGIN
UPDATE TabUkoly SET DatumDokonceni=GETDATE(), Stav=2, HotovoProcent=100, DatZmeny=GETDATE(), Zmenil=SUSER_SNAME()
WHERE ID = @ID
END;
GO

