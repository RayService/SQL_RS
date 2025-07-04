USE [RayService]
GO

/****** Object:  View [dbo].[hvw_RozdilKPrijmu]    Script Date: 04.07.2025 8:02:57 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

CREATE VIEW [dbo].[hvw_RozdilKPrijmu] AS SELECT SU.ID, SU.IDStavSkladu, SU.IDVyrCis, SU.IDUmisteni, KZ.SkupZbo, KZ.RegCis, U.Kod, SU.Mnozstvi, KZID=KZ.ID, SS.IDSklad
FROM TabStavSkladu SS
INNER JOIN TabKmenZbozi KZ ON KZ.ID=SS.IDKmenZbozi
LEFT OUTER JOIN Gatema_StavUmisteni SU ON SU.IDStavSkladu=SS.ID
LEFT OUTER JOIN TabUmisteni U ON U.Id=SU.IDUmisteni
--INNER JOIN Tab_SDMater_Konfig K ON K.IDUmisteniRozdil=SU.IDUmisteni
WHERE SU.Mnozstvi<0 AND U.Kod in (Select Um.kod From TabUmisteni Um Inner join Tab_SDMater_Konfig SDK ON SDK.IDUmisteniRozdil=Um.ID /*and SS.IDSklad=Um.IdSklad*/)

/*SELECT SU.ID, SU.IDStavSkladu, SU.IDVyrCis, SU.IDUmisteni, KZ.SkupZbo, KZ.RegCis, U.Kod, SU.Mnozstvi, KZID=KZ.ID, SS.IDSklad
FROM TabStavSkladu SS
INNER JOIN TabKmenZbozi KZ ON KZ.ID=SS.IDKmenZbozi
LEFT OUTER JOIN Gatema_StavUmisteni SU ON SU.IDStavSkladu=SS.ID
LEFT OUTER JOIN TabUmisteni U ON U.Id=SU.IDUmisteni
INNER JOIN Tab_SDMater_Konfig K ON K.IDUmisteniRozdil=SU.IDUmisteni
WHERE SU.Mnozstvi<0*/
GO

