USE [RayService]
GO

/****** Object:  View [dbo].[hvw_Gatema_StrukManJed]    Script Date: 03.07.2025 15:13:15 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

CREATE VIEW [dbo].[hvw_Gatema_StrukManJed] AS SELECT IDHledaneManJed=M.ID, Vnoreni=0, TypRadku=0, IDNadManJed=NULL, IDManJed=M.ID, IDManJedPol=NULL, IDKmenZbozi=NULL, VyrCislo=NULL, M.Aktivni, M.Sklad, M.IDUmisteni, Mnozstvi=NULL 
  FROM Gatema_ManJed M 
UNION ALL 
SELECT IDHledaneManJed=M.ID, Vnoreni=1, TypRadku=1, IDNadManJed=NULL, IDManJed=M.ID, IDManJedPol=P.ID, P.IDKmenZbozi, P.VyrCislo, P.Aktivni, P.Sklad, P.IDUmisteni, P.Mnozstvi 
  FROM Gatema_ManJed M 
    INNER JOIN Gatema_ManJedPol P ON (P.IDManJed=M.ID) 
UNION ALL 
SELECT IDHledaneManJed=M.IDNadrizeneManJed, Vnoreni=1, TypRadku=0, IDNadManJed=M.IDNadrizeneManJed, IDManJed=M.ID, IDManJedPol=NULL, IDKmenZbozi=NULL, VyrCislo=NULL, M.Aktivni, M.Sklad, M.IDUmisteni, Mnozstvi=NULL 
  FROM Gatema_ManJed M 
  WHERE M.RadMJ=1 
UNION ALL 
SELECT IDHledaneManJed=M.IDNadrizeneManJed, Vnoreni=2, TypRadku=1, IDNadManJed=M.IDNadrizeneManJed, IDManJed=M.ID, IDManJedPol=P.ID, P.IDKmenZbozi, P.VyrCislo, P.Aktivni, P.Sklad, P.IDUmisteni, P.Mnozstvi 
  FROM Gatema_ManJed M 
    INNER JOIN Gatema_ManJedPol P ON (P.IDManJed=M.ID) 
  WHERE M.RadMJ=1 
GO

