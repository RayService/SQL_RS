USE [RayService]
GO

/****** Object:  StoredProcedure [dbo].[hpx_RS_prepocet_ceniku_kurzem]    Script Date: 26.06.2025 12:03:45 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

CREATE PROCEDURE [dbo].[hpx_RS_prepocet_ceniku_kurzem] @Kurz NUMERIC(19,2), @Kontrola BIT, @ID INT
AS
SET NOCOUNT ON
IF @Kontrola=1
BEGIN
UPDATE nc SET nc.CenaKC=ISNULL(nc.CenaVal1,0)*@Kurz
FROM TabNC nc
WHERE nc.CenaVal1 IS NOT NULL AND nc.ID=@ID
END;
/*
CREATE PROCEDURE dbo.hpx_RS_prepocet_ceniku_kurzem @Kurz NUMERIC(19,2), @Kontrola BIT, @IDCenik INT
AS
SET NOCOUNT ON
IF @Kontrola=1
BEGIN
UPDATE nc SET nc.CenaKC=nc.CenaVal1*@Kurz
FROM TabNC nc
WHERE nc.CenaVal1 IS NOT NULL AND nc.CenovaUroven=@IDCenik
END;*/
GO

