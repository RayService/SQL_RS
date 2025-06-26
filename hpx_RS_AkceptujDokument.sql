USE [RayService]
GO

/****** Object:  StoredProcedure [dbo].[hpx_RS_AkceptujDokument]    Script Date: 26.06.2025 14:15:30 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

CREATE PROCEDURE [dbo].[hpx_RS_AkceptujDokument] @ID INT
AS

DECLARE @IDZam INT;
--DECLARE @ID INT=362533;
SET @IDZam=(
SELECT tcz.ID
FROM TabCisZam tcz
WHERE tcz.LoginId=SUSER_SNAME()
)

INSERT TabQMSDokumLogAkci (IDKonJed, IDDokum, IDZam, IDKOs, Akce, Autor, DatPorizeni)SELECT tkj.ID, TabDokumenty.ID, @IDzam, NULL, 1, SUSER_SNAME(), GETDATE()
FROM TabDokumenty
LEFT OUTER JOIN TabKontaktJednani tkj ON EXISTS(SELECT*FROM TabDokumVazba V JOIN TabKontaktJednani KJ ON KJ.ID=V.IDTab AND KJ.ID=tkj.ID JOIN TabKategKontJed KK ON KK.Cislo=KJ.Kategorie WHERE V.IDDok=TabDokumenty.ID AND V.IdentVazby=1 AND KK.QMSAgenda=8)
WHERE
((EXISTS(SELECT * FROM TabKontaktJednani KJ JOIN TabDokumVazba V ON V.IDDok=TabDokumenty.ID AND V.IdentVazby=1 AND V.IDTab=KJ.ID JOIN TabKategKontJed KTG ON KJ.Kategorie=KTG.Cislo JOIN TabKJUcastZam KJUZ ON KJUZ.IDKJ=KJ.ID JOIN TabCisZam Z ON Z.ID=KJUZ.IDZam WHERE KTG.QMSAgenda=8 AND KJ.Ukonceni IS NULL AND Z.LoginId=SUSER_SNAME() AND ((TabDokumenty.DatPlatnostOd<=GETDATE()) AND (TabDokumenty.DatPlatnostDo IS NULL OR TabDokumenty.DatPlatnostDo>=GETDATE())))))
AND((CONVERT(BIT, CASE WHEN EXISTS(SELECT*FROM TabQMSDokumLogAkci L JOIN TabCisZam Z ON Z.ID=L.IDZam LEFT JOIN TabKontakty K ON K.IDCisZam=Z.ID WHERE IDDokum=TabDokumenty.ID AND L.Akce=0 AND (Z.LoginID=SUSER_SNAME() OR (K.Druh=13 AND K.Spojeni=SUSER_SNAME()))) AND NOT EXISTS(SELECT*FROM TabQMSDokumLogAkci L JOIN TabCisZam Z ON Z.ID=L.IDZam LEFT JOIN TabKontakty K ON K.IDCisZam=Z.ID WHERE IDDokum=TabDokumenty.ID AND L.Akce=1 AND (Z.LoginID=SUSER_SNAME() OR (K.Druh=13 AND K.Spojeni=SUSER_SNAME()))) THEN 1 ELSE 0 END))=1)AND TabDokumenty.ID=@ID--VALUES (17959, 775526, 2723, NULL, 1, SUSER_SNAME(), GETDATE())
GO

