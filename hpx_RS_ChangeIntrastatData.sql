USE [RayService]
GO

/****** Object:  StoredProcedure [dbo].[hpx_RS_ChangeIntrastatData]    Script Date: 26.06.2025 13:40:32 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

CREATE PROCEDURE [dbo].[hpx_RS_ChangeIntrastatData] @DD TINYINT,@Prepsat1 BIT,@DodaciPodminky NVARCHAR(3),@Prepsat2 BIT, @PovahaTransakce TINYINT,@Prepsat3 BIT, @DatPrijOdeslZbozi DATETIME, @Prepsat4 BIT, @ID INT
AS
IF @Prepsat1=1
BEGIN
UPDATE dzd SET dzd.DD=@DD
FROM TabDokladyZbozi tdz
LEFT OUTER JOIN TabDokZboDodatek dzd ON tdz.ID=dzd.IDHlavicky
WHERE tdz.ID=@ID
END;
IF @Prepsat2=1
BEGIN
UPDATE dzd SET dzd.DodaciPodminky=@DodaciPodminky
FROM TabDokladyZbozi tdz
LEFT OUTER JOIN TabDokZboDodatek dzd ON tdz.ID=dzd.IDHlavicky
WHERE tdz.ID=@ID
END;
IF @Prepsat3=1
BEGIN
UPDATE dzd SET dzd.PovahaTransakce=@PovahaTransakce
FROM TabDokladyZbozi tdz
LEFT OUTER JOIN TabDokZboDodatek dzd ON tdz.ID=dzd.IDHlavicky
WHERE tdz.ID=@ID
END;
IF @Prepsat4=1
BEGIN
UPDATE dzd SET dzd.DatPrijOdeslZbozi=@DatPrijOdeslZbozi
FROM TabDokladyZbozi tdz
LEFT OUTER JOIN TabDokZboDodatek dzd ON tdz.ID=dzd.IDHlavicky
WHERE tdz.ID=@ID
END;

IF @Prepsat1=0 AND @Prepsat2=0 AND @Prepsat3=0 AND @Prepsat4=0
BEGIN
RAISERROR('Nic neproběhne, není zatrženo žádné Prepsat',16,1)
RETURN
END;
GO

