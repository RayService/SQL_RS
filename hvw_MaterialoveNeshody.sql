USE [RayService]
GO

/****** Object:  View [dbo].[hvw_MaterialoveNeshody]    Script Date: 03.07.2025 15:24:24 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

CREATE VIEW [dbo].[hvw_MaterialoveNeshody] AS SELECT SU.ID, SU.IDStavSkladu, SU.IDVyrCis, SU.IDUmisteni, KZ.SkupZbo, KZ.RegCis, U.Kod, SU.Mnozstvi, KZID=KZ.ID, SS.IDSklad
  FROM TabStavSkladu SS
    INNER JOIN TabKmenZbozi KZ ON KZ.ID=SS.IDKmenZbozi
    INNER JOIN Gatema_StavUmisteni SU ON SU.IDStavSkladu=SS.ID
    INNER JOIN TabUmisteni U ON U.Id=SU.IDUmisteni
    INNER JOIN TabUmisteni UN ON UN.Id=(SELECT TOP 1 K.IDUmisteniNeshod FROM Tab_SDMater_Konfig K)
WHERE SU.Mnozstvi>0 AND U.Kod=UN.Kod
GO

