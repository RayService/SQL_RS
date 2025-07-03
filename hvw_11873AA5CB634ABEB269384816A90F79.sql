USE [RayService]
GO

/****** Object:  View [dbo].[hvw_11873AA5CB634ABEB269384816A90F79]    Script Date: 03.07.2025 10:55:33 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

CREATE VIEW [dbo].[hvw_11873AA5CB634ABEB269384816A90F79] AS SELECT ID
      ,Dilec
      ,ZmenaOd
      ,ZmenaDo
      ,mat
      ,koop
      ,TAC_KC
      ,TBC_KC
      ,TEC_KC
      ,rezieS
      ,rezieP
      ,ReziePrac
      ,NakladyPrac
      ,naradi
      ,DatPorizeni
      ,Autor
      ,Zmenil
      ,DatZmeny
      ,OPN
      ,VedProdukt
      ,MatRezie
      ,mat_P
      ,MatRezie_P
      ,koop_P
      ,TAC_KC_P
      ,TBC_KC_P
      ,TEC_KC_P
      ,rezieS_P
      ,rezieP_P
      ,ReziePrac_P
      ,NakladyPrac_P
      ,OPN_P
      ,VedProdukt_P
      ,naradi_P
      ,Celkem
      ,Celkem_P
      ,DatPorizeni_D
      ,DatPorizeni_M
      ,DatPorizeni_Y
      ,DatPorizeni_Q
      ,DatPorizeni_W
      ,DatPorizeni_X
      ,DatZmeny_D
      ,DatZmeny_M
      ,DatZmeny_Y
      ,DatZmeny_Q
      ,DatZmeny_W
      ,DatZmeny_X
      ,IDZakazModif
      ,JeZakazModif
      ,matA
      ,matB
      ,matC
      ,matA_P
      ,matB_P
      ,matC_P
      ,DavkaVypoctu
      ,CisloZakazky
      ,TAC
      ,TBC
      ,TEC
      ,TAC_T
      ,TBC_T
      ,TEC_T
      ,Davka AS Davka
  FROM Tabx_RS_ZKalkulace WITH(NOLOCK)
GO

