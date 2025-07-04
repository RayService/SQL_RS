USE [RayService]
GO

/****** Object:  View [dbo].[TabStavSkladuAVAView]    Script Date: 04.07.2025 12:52:28 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

CREATE VIEW [dbo].[TabStavSkladuAVAView] AS

SELECT       --K.SkupZbo, K.RegCis, K.Nazev1,
             AVA.ID,
             AVA.AVAReferenceID,
             SUB.SID AS IDStavSkladu,
             SUB.UID AS IDUmisteni,
             --  VV.IDUmisteni AS VUID,
             ISNULL(VV.IDVyrCS, VCBU.VCID) AS IDVyrCislo,
             --  ISNULL(CU.Kod, '')    AS CUKod,
             --  ISNULL(CU.Nazev, '')  AS CUNazev,
             --  ISNULL(ISNULL(VC.Nazev1, VCBU.Nazev1), '') AS VCNazev,
             --  SUB.SMnoz, SUB.UMnoz,
             ISNULL(ISNULL(VV.Mnozstvi, VCBU.Mnozstvi), 0) AS Mnozstvi,
             VC.DatExpirace AS DatExpirace,
             --  VC.IDVyrCK AS IDVyrCK,
             S.IDKmenZbozi AS IDKmenZbozi,
             TabStrom.ID AS IDStrom
                 FROM
             (
             -- umistene zbozi
                SELECT SID, UID, SMnoz, UMnoz
                  FROM
                   (SELECT S.ID AS SID, U.ID  AS UID,
                      S.Mnozstvi AS SMnoz, U.MnozstviUmisteni AS UMnoz
                    FROM TabStavSkladu AS S
                    JOIN TabVStavUmisteni AS U ON U.IDStav = S.ID
                   ) AS SumReg
                  WHERE SMnoz > 0

                UNION ALL

                -- stavy zbozi mimo regal
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
              JOIN TabStavSkladu AS S ON S.ID = SUB.SID
              JOIN TabKmenZbozi  AS K ON K.ID = S.IDKmenZbozi
              JOIN TabStrom ON S.IDSklad=TabStrom.Cislo
              LEFT OUTER JOIN TabVStavUmisteni AS U ON U.IDStav = S.ID AND U.ID = SUB.UID
              LEFT OUTER JOIN TabUmisteni AS CU ON CU.ID = U.IDUmisteni
              LEFT OUTER JOIN TabUmistVCView AS VV ON VV.IDUmisteni = U.ID
              LEFT OUTER JOIN TabVyrCS AS VC ON VC.ID = VV.IDVyrCS
              LEFT OUTER JOIN
               (
                -- stavy VC pro zbozi mimo regal
                SELECT TVC.IDStavSkladu, TVC.ID AS VCID, TVC.Nazev1, (TVC.Mnozstvi -
                 (SELECT ISNULL(SUM(OPVC.Mnozstvi),0) FROM TabUmistPrijemVC AS OPVC
                  WHERE OPVC.IDVyrCS = TVC.ID)) AS Mnozstvi
                FROM TabVyrCS AS TVC

                UNION ALL

                -- stavy zbozi bez VC mimo regal
                SELECT SS.ID, NULL, NULL, SS.Mnozstvi -
                   (SELECT ISNULL(SUM(Mnozstvi), 0) FROM TabVyrCS WHERE IDStavSkladu = SS.ID) -
                   (SELECT ISNULL(SUM(MnozstviUmisteni), 0) FROM TabVStavUmisteni WHERE IDStav = SS.ID) +
                   (SELECT ISNULL(SUM(XVC.Mnozstvi), 0)
                    FROM TabUmistPrijemVC  AS XVC
                    JOIN TabUmisteniPrijem AS XUP ON XUP.ID = XVC.IDUmistPrijem
                    JOIN TabVStavUmisteni  AS XUS ON XUS.ID = XUP.IDUmisteni
                    WHERE XUS.IDStav = SS.ID)
                  FROM TabStavSkladu AS SS
               ) AS VCBU ON U.ID  IS NULL AND VCBU.Mnozstvi > 0 AND VCBU.IDStavSkladu = S.ID
               LEFT JOIN TabStavSkladuAVA AVA ON AVA.IDStavSkladu=SUB.SID AND ISNULL(AVA.IDUmisteni,-1)=ISNULL(SUB.UID,-1) AND ISNULL(AVA.IDVyrCislo,-1)=ISNULL(ISNULL(VV.IDVyrCS, VCBU.VCID),-1)
               WHERE ISNULL(ISNULL(VV.Mnozstvi, VCBU.Mnozstvi), 0)>0
          --    WHERE S.ID = :ID
GO

