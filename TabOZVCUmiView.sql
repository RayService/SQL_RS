USE [RayService]
GO

/****** Object:  View [dbo].[TabOZVCUmiView]    Script Date: 04.07.2025 11:32:49 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

CREATE VIEW [dbo].[TabOZVCUmiView] AS
SELECT
SUB.SID AS IDZboSklad,
SUB.UID AS IDUmisteni,
ISNULL(VV.IDVyrCS, VCBU.VCID) AS IDVyrCS,
ISNULL(ISNULL(VV.Mnozstvi, VCBU.Mnozstvi), 0) AS Mnozstvi
FROM(
SELECT SID, UID, SMnoz, UMnoz
FROM
(SELECT S.ID AS SID, U.ID AS UID,
S.Mnozstvi AS SMnoz, U.MnozstviUmisteni AS UMnoz
FROM TabStavSkladu AS S
JOIN TabVStavUmisteni AS U ON U.IDStav = S.ID
) AS SumReg
WHERE SMnoz > 0
UNION ALL
SELECT SID, NULL, SMnoz, UMnoz
FROM
(SELECT S.ID AS SID, S.Mnozstvi AS SMnoz, (S.Mnozstvi -
(SELECT ISNULL(SUM(MnozstviUmisteni), 0)
FROM TabVStavUmisteni
WHERE IDStav = S.ID)) AS UMnoz
FROM TabStavSkladu AS S
) AS SumMimo
WHERE UMnoz > 0
) AS SUB
LEFT OUTER JOIN TabVStavUmisteni AS U  ON U.IDStav = SUB.SID AND U.ID = SUB.UID
LEFT OUTER JOIN TabUmistVCView   AS VV ON VV.IDUmisteni = U.ID
LEFT OUTER JOIN(
SELECT TVC.IDStavSkladu, TVC.ID AS VCID, TVC.Nazev1, (TVC.Mnozstvi -
(SELECT ISNULL(SUM(OPVC.Mnozstvi),0) FROM TabUmistPrijemVC AS OPVC
WHERE OPVC.IDVyrCS = TVC.ID)) AS Mnozstvi
FROM TabVyrCS AS TVC
UNION ALL
SELECT SS.ID, NULL, NULL, SS.Mnozstvi -
(SELECT ISNULL(SUM(Mnozstvi), 0) FROM TabVyrCS WHERE IDStavSkladu = SS.ID) -
(SELECT ISNULL(SUM(MnozstviUmisteni), 0) FROM TabVStavUmisteni WHERE IDStav = SS.ID) +
(SELECT ISNULL(SUM(XVC.Mnozstvi), 0)
FROM TabUmistPrijemVC  AS XVC
JOIN TabUmisteniPrijem AS XUP ON XUP.ID = XVC.IDUmistPrijem
JOIN TabVStavUmisteni  AS XUS ON XUS.ID = XUP.IDUmisteni
WHERE XUS.IDStav = SS.ID)
FROM TabStavSkladu AS SS
) AS VCBU ON U.ID IS NULL AND VCBU.Mnozstvi > 0 AND VCBU.IDStavSkladu = SUB.SID
GO

