USE [RayService]
GO

/****** Object:  View [dbo].[hvw_Tabx_RS_TabKvazby]    Script Date: 04.07.2025 8:52:26 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

CREATE VIEW [dbo].[hvw_Tabx_RS_TabKvazby] AS SELECT ID
      ,vyssi
      ,IDVarianta
      ,nizsi
      ,ZmenaOd
      ,ZmenaDo
      ,pozice
      ,Operace
      ,mnozstvi
      ,mnoz_zad
      ,ProcZtrat
      ,Prirez
      ,Poznamka
      ,ID1
      ,DatPorizeni
      ,Autor
      ,mnozstviSeZtratou
      ,IDVzorceSpotMat
      ,PromA
      ,PromB
      ,PromC
      ,PromD
      ,PromE
      ,SpotRozmer
      ,FixniMnozstvi
      ,DavkaTPV
      ,globalni
      ,DatPorizeni_D
      ,DatPorizeni_M
      ,DatPorizeni_Y
      ,DatPorizeni_Q
      ,DatPorizeni_W
      ,DatPorizeni_X
      ,RezijniMat
      ,VyraditZKalkulace
      ,IDZakazModif
      ,JeZakazModif
      ,VychoziSklad
      ,UzivZadaniPrirezu
      ,IDPohybu
      ,IDVazby
FROM Tabx_RS_TabKvazby
GO

