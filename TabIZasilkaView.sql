USE [RayService]
GO

/****** Object:  View [dbo].[TabIZasilkaView]    Script Date: 04.07.2025 11:26:55 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

CREATE VIEW [dbo].[TabIZasilkaView] as
select z.typzasilky,IsNull(h.pozice,0) as Pozice,p.poradi,z.ciszasilky,IsNull(H.SPZTahac,Z.SPZTahac) as SPZTahac,IsNull(H.SPZNaves,Z.SPZNaves) as SPZNaves,IsNull(H.Typ,Z.SPZTyp) as SPZTyp,
  Z.idzakaznik,Z.ZakNazev, IsNull(H.idDopravce,Z.idDopravce) as idDopravce,
  z.Parita,z.ParitaMisto,z.idOdesilatel,z.OdeNazev,z.idPrijemce,z.PriNazev,z.idKupujici,z.idDodavatel,z.eir,z.DatObj,
  Z.NakDatumSkl,Z.VykDatumSkl,Z.Zakpozice,z.Zbozi1,z.ZbCode,z.ZbPocet,z.ZbBaleni,Z.ZbBtto,z.ZbHodnota,z.ZbHodnotaMena,
  z.Nakladka,z.Vykladka,z.AWBSpol,z.AWBLetiste,z.AWBCislo,z.NakLetiste,z.VykLetiste,z.LetDatum1,z.Disponent,
  Z.idJCD as idJCD, Z.id as idZasilky, H.id as idPozice
from tabizasilka Z
left outer join tabipozicepo P on Z.id=P.idzasilka
left outer join tabipozicehl H on H.id=P.idpozice
left outer join tabcisorg O on O.cisloorg=IsNull(H.idDopravce,Z.iddopravce)
GO

