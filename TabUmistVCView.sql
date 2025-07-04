USE [RayService]
GO

/****** Object:  View [dbo].[TabUmistVCView]    Script Date: 04.07.2025 13:02:39 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

CREATE VIEW [dbo].[TabUmistVCView] AS
SELECT
ROW_NUMBER() OVER (ORDER BY t.IDVyrCS) AS ID,
t.*
FROM (
SELECT IDStav AS IDZboSklad, IDUmisteni, IDVyrCS, CAST(Mnozstvi AS NUMERIC(19,6)) AS Mnozstvi
FROM
(SELECT UM.IDStav, UP.IDUmisteni, VC.IDVyrCS, SUM(VC.Mnozstvi) AS Mnozstvi
FROM TabUmistPrijemVC  AS VC
JOIN TabUmisteniPrijem AS UP ON UP.ID = VC.IDUmistPrijem
JOIN TabVStavUmisteni  AS UM ON UM.ID = UP.IDUmisteni
GROUP BY UM.IDStav, UP.IDUmisteni, VC.IDVyrCS
) AS SumVC
WHERE Mnozstvi > 0
UNION ALL
SELECT IDStav, ID, NULL, CAST(Mnozstvi AS NUMERIC(19,6)) AS Mnozstvi
FROM
(SELECT U.IDStav, U.ID, (MnozstviUmisteni -
ISNULL((SELECT SUM(VC.Mnozstvi)
FROM TabUmistPrijemVC  AS VC
JOIN TabUmisteniPrijem AS UP ON UP.ID = VC.IDUmistPrijem
WHERE UP.IDUmisteni = U.ID
GROUP BY UP.IDUmisteni), 0)) AS Mnozstvi
FROM TabVStavUmisteni AS U
) AS SumBez
WHERE Mnozstvi > 0) AS t
GO

