USE [RayService]
GO

/****** Object:  StoredProcedure [dbo].[hpx_RS_insert_distribucni_seznam_QMS]    Script Date: 26.06.2025 11:56:19 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

CREATE PROCEDURE [dbo].[hpx_RS_insert_distribucni_seznam_QMS]
@IDZam INT,
@ID INT
AS

BEGIN

IF @IDZam NOT IN (SELECT IDZam FROM TabKJUcastZam WHERE IDKJ=@ID)

BEGIN
INSERT TabQMSDokumLogAkci (IDKonJed, IDDokum, IDZam, Akce)
SELECT @ID, D.ID, @IDZam, 0
FROM TabDokumenty D
JOIN TabDokumVazba V ON V.IDDok=D.ID AND V.IDTab=@ID
WHERE D.Stav IN (5,6) /*zveřejněný, platný*/ AND NOT EXISTS(SELECT*FROM TabQMSDokumLogAkci
WHERE IDKonJed=@ID AND IDDokum=D.ID AND IDZam=@IDZam AND Akce=0)

INSERT TabKJUcastZam (IDKJ,IDZam) VALUES (@ID,@IDZam)
END

END
GO

