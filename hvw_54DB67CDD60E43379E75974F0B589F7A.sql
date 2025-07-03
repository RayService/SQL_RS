USE [RayService]
GO

/****** Object:  View [dbo].[hvw_54DB67CDD60E43379E75974F0B589F7A]    Script Date: 03.07.2025 11:10:10 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

CREATE VIEW [dbo].[hvw_54DB67CDD60E43379E75974F0B589F7A] AS SELECT
TabKJUcastZam.IDKJ,TabKJUcastZam.IDZam,TabKJUcastZam.ID,TabKJUcastZam.Auditor,VKJUcastZamCisZam.Cislo,VKJUcastZamCisZam.Prijmeni,VKJUcastZamCisZam.Jmeno,TabKJUcastZam.PovinneVyjadreni,(SELECT MAX(D.CisloVerze) FROM TabDokumenty D WITH(NOLOCK) JOIN TabDokumVazba V WITH(NOLOCK) ON V.IDDok=D.ID AND V.IDTab=TabKJUcastZam.IDKJ JOIN TabQMSDokumLogAkci L WITH(NOLOCK) ON L.IDDokum=D.ID AND L.IDKonJed=TabKJUcastZam.IDKJ AND L.IDZam=TabKJUcastZam.IDZam AND L.Akce=1) AS AkceptCisloVerze,(SELECT MAX(L.DatPorizeni) FROM TabDokumenty D JOIN TabDokumVazba V WITH(NOLOCK) ON V.IDDok=D.ID AND V.IDTab=TabKJUcastZam.IDKJ JOIN TabQMSDokumLogAkci L WITH(NOLOCK) ON L.IDDokum=D.ID AND L.IDKonJed=TabKJUcastZam.IDKJ AND L.IDZam=TabKJUcastZam.IDZam AND L.Akce=1 WHERE D.CisloVerze=(SELECT MAX(D.CisloVerze) FROM TabDokumenty D JOIN TabDokumVazba V ON V.IDDok=D.ID AND V.IDTab=TabKJUcastZam.IDKJ JOIN TabQMSDokumLogAkci L  WITH(NOLOCK)ON L.IDDokum=D.ID AND L.IDKonJed=TabKJUcastZam.IDKJ AND L.IDZam=TabKJUcastZam.IDZam AND L.Akce=1)) AS DatAkceptovano, CONVERT(BIT, CASE WHEN EXISTS(SELECT*FROM TabDokumDiskuzePoz P JOIN TabDokumenty D WITH(NOLOCK) ON D.ID=P.IDDokum JOIN TabDokumVazba V ON V.IDDok=D.ID AND V.IDTab=TabKJUcastZam.IDKJ JOIN TabCisZam Z WITH(NOLOCK) ON Z.ID=TabKJUcastZam.IDZam AND Z.LoginID=P.Autor WHERE D.CisloVerze=(SELECT MAX(D.CisloVerze) FROM TabDokumenty D WITH(NOLOCK) JOIN TabDokumVazba V WITH(NOLOCK) ON V.IDDok=D.ID AND V.IDTab=TabKJUcastZam.IDKJ)) THEN 1 ELSE 0 END) AS Vyjadril, tkj.Kategorie, tkj.PoradoveCislo, tkj.Predmet, tqmsa.Vyrobnicislo, tkkj.Popis, td.CisloVerze, td.DatPlatnostOd
FROM TabKJUcastZam WITH(NOLOCK)
  LEFT OUTER JOIN TabCisZam VKJUcastZamCisZam WITH(NOLOCK) ON VKJUcastZamCisZam.ID=TabKJUcastZam.IDZam
  LEFT OUTER JOIN TabKontaktJednani tkj WITH(NOLOCK) ON tkj.ID=TabKJUcastZam.IDKJ
  LEFT OUTER JOIN TabQMSAtributy tqmsa WITH(NOLOCK) ON tkj.ID=tqmsa.IDKonJed
  LEFT OUTER JOIN TabKategKontJed tkkj WITH(NOLOCK) ON tkj.Kategorie=tkkj.Cislo
  INNER JOIN TabDokumenty td WITH(NOLOCK) ON EXISTS(SELECT*FROM TabDokumVazba V JOIN TabKontaktJednani KJ WITH(NOLOCK) ON KJ.ID=V.IDTab AND KJ.ID=tkj.ID JOIN TabKategKontJed KK WITH(NOLOCK) ON KK.Cislo=KJ.Kategorie WHERE V.IDDok=td.ID AND V.IdentVazby=1 AND KK.QMSAgenda=8 AND td.Stav = 6)
WHERE tkj.Kategorie LIKE 'D%' AND td.DatPlatnostOd>='1.4.2020'

/*SELECT
TabKJUcastZam.IDKJ,TabKJUcastZam.IDZam,TabKJUcastZam.ID,TabKJUcastZam.Auditor,VKJUcastZamCisZam.Cislo,VKJUcastZamCisZam.Prijmeni,VKJUcastZamCisZam.Jmeno,TabKJUcastZam.PovinneVyjadreni,(SELECT MAX(D.CisloVerze) FROM TabDokumenty D JOIN TabDokumVazba V ON V.IDDok=D.ID AND V.IDTab=TabKJUcastZam.IDKJ JOIN TabQMSDokumLogAkci L ON L.IDDokum=D.ID AND L.IDKonJed=TabKJUcastZam.IDKJ AND L.IDZam=TabKJUcastZam.IDZam AND L.Akce=1) AS AkceptCisloVerze,(SELECT L.DatPorizeni FROM TabDokumenty D JOIN TabDokumVazba V ON V.IDDok=D.ID AND V.IDTab=TabKJUcastZam.IDKJ JOIN TabQMSDokumLogAkci L ON L.IDDokum=D.ID AND L.IDKonJed=TabKJUcastZam.IDKJ AND L.IDZam=TabKJUcastZam.IDZam AND L.Akce=1 WHERE D.CisloVerze=(SELECT MAX(D.CisloVerze) FROM TabDokumenty D JOIN TabDokumVazba V ON V.IDDok=D.ID AND V.IDTab=TabKJUcastZam.IDKJ JOIN TabQMSDokumLogAkci L ON L.IDDokum=D.ID AND L.IDKonJed=TabKJUcastZam.IDKJ AND L.IDZam=TabKJUcastZam.IDZam AND L.Akce=1)) AS DatAkceptovano, CONVERT(BIT, CASE WHEN EXISTS(SELECT*FROM TabDokumDiskuzePoz P JOIN TabDokumenty D ON D.ID=P.IDDokum JOIN TabDokumVazba V ON V.IDDok=D.ID AND V.IDTab=TabKJUcastZam.IDKJ JOIN TabCisZam Z ON Z.ID=TabKJUcastZam.IDZam AND Z.LoginID=P.Autor WHERE D.CisloVerze=(SELECT MAX(D.CisloVerze) FROM TabDokumenty D JOIN TabDokumVazba V ON V.IDDok=D.ID AND V.IDTab=TabKJUcastZam.IDKJ)) THEN 1 ELSE 0 END) AS Vyjadril, tkj.Kategorie, tkj.PoradoveCislo, tkj.Predmet, tqmsa.Vyrobnicislo, tkkj.Popis
FROM TabKJUcastZam
  LEFT OUTER JOIN TabCisZam VKJUcastZamCisZam ON VKJUcastZamCisZam.ID=TabKJUcastZam.IDZam
  LEFT OUTER JOIN TabKontaktJednani tkj ON tkj.ID=TabKJUcastZam.IDKJ
  LEFT OUTER JOIN TabQMSAtributy tqmsa ON tkj.ID=tqmsa.IDKonJed
  LEFT OUTER JOIN TabKategKontJed tkkj ON tkj.Kategorie=tkkj.Cislo
WHERE tkj.Kategorie LIKE 'D%'
*/
GO

