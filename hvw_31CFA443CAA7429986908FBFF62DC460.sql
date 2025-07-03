USE [RayService]
GO

/****** Object:  View [dbo].[hvw_31CFA443CAA7429986908FBFF62DC460]    Script Date: 03.07.2025 11:04:20 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

CREATE VIEW [dbo].[hvw_31CFA443CAA7429986908FBFF62DC460] AS SELECT tpp.ID AS 'ID_pozice'
      ,tpp.Nazev
      ,tpp.Autor
      ,tpp.DatPorizeni
      ,tpp.Zmenil
      ,tpp.DatZmeny
      ,tpp.DatPorizeni_D
      ,tpp.DatPorizeni_M
      ,tpp.DatPorizeni_Y
      ,tpp.DatPorizeni_Q
      ,tpp.DatPorizeni_W
      ,tpp.DatPorizeni_X
      ,tpp.DatZmeny_D
      ,tpp.DatZmeny_M
      ,tpp.DatZmeny_Y
      ,tpp.DatZmeny_Q
      ,tpp.DatZmeny_W
      ,tpp.DatZmeny_X
      ,tpp.IDZdroje AS 'IdZdroje_pozice'
      ,tpp.PrenestSkoleni
      ,tppd.ID AS 'ID_detail'
      ,tppd.IdHlavicka
      ,tppd.PlatnostOd
      ,tppd.PlatnostDo
      ,tppd.Popis
      ,tppd.NaplnPrace
	  ,(SUBSTRING(REPLACE(SUBSTRING(tppd.Popis,1,255),(CHAR(13) + CHAR(10)),' '),1,255)) AS Popis_255
	  ,tppd.Popis AS Popis_ALL
	  ,(SUBSTRING(REPLACE(SUBSTRING(tppd.NaplnPrace,1,255),(CHAR(13) + CHAR(10)),' '),1,255)) AS Naplnprace_255
      ,tppd.NaplnPrace AS NaplnPrace_ALL
      ,tppd.PlatnostOd_D
      ,tppd.PlatnostOd_M
      ,tppd.PlatnostOd_Y
      ,tppd.PlatnostOd_Q
      ,tppd.PlatnostOd_W
      ,tppd.PlatnostOd_X
      ,tppd.PlatnostDo_D
      ,tppd.PlatnostDo_M
      ,tppd.PlatnostDo_Y
      ,tppd.PlatnostDo_Q
      ,tppd.PlatnostDo_W
      ,tppd.PlatnostDo_X
      ,tppd.IdZdroje AS 'IdZdroje_detail'
      ,tppd.Aktualni
      ,tppd.Profese
FROM TabPracovniPoziceDetail tppd WITH(NOLOCK)
INNER JOIN TabPracovniPozice tpp WITH(NOLOCK) ON tpp.ID = tppd.IdHlavicka
WHERE tppd.Aktualni = 1
GO

