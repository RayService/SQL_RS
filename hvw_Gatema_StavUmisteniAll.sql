USE [RayService]
GO

/****** Object:  View [dbo].[hvw_Gatema_StavUmisteniAll]    Script Date: 03.07.2025 15:12:37 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

CREATE VIEW [dbo].[hvw_Gatema_StavUmisteniAll] AS SELECT SU.ID, ManJed=convert(bit,0), SU.IDStavSkladu, SU.IDKmenZbozi, SU.IDVyrCis, SU.IDUmisteni, IDManJed=NULL, SU.Mnozstvi 
  FROM Gatema_StavUmisteni SU 
UNION ALL 
SELECT ID=-P.ID, ManJed=convert(bit,1), IDStavSkladu=SS.ID, P.IDKmenZbozi, IDVyrCis=VC.ID, P.IDUmisteni, P.IDManJed, P.Mnozstvi 
  FROM Gatema_ManJedPol P 
    INNER JOIN TabStavSkladu SS WITH (READUNCOMMITTED) ON (SS.IDSklad=P.Sklad AND SS.IDKmenZbozi=P.IDKmenZbozi) 
    LEFT OUTER JOIN TabVyrCS VC WITH (READUNCOMMITTED) ON (VC.IDStavSkladu=SS.ID AND VC.Nazev1=P.VyrCislo) 
  WHERE P.Aktivni=1 
GO

