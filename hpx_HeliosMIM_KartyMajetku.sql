USE [RayService]
GO

/****** Object:  StoredProcedure [dbo].[hpx_HeliosMIM_KartyMajetku]    Script Date: 30.06.2025 8:14:43 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

CREATE PROC [dbo].[hpx_HeliosMIM_KartyMajetku] @KDatu DATETIME
AS

IF OBJECT_ID(N'tempdb..#TabExtAkce','U')IS NOT NULL
  BEGIN
    ALTER TABLE #TabExtAkce ADD Nazev NVARCHAR(255) COLLATE database_default
    ALTER TABLE #TabExtAkce ADD TypMaj NVARCHAR(100) COLLATE database_default
    ALTER TABLE #TabExtAkce ADD CisloMaj INT
    ALTER TABLE #TabExtAkce ADD Prislusenstvi INT
    ALTER TABLE #TabExtAkce ADD CarKod NVARCHAR(100) COLLATE database_default
    ALTER TABLE #TabExtAkce ADD KodLok NVARCHAR(100) COLLATE database_default
    ALTER TABLE #TabExtAkce ADD VyrCislo NVARCHAR(100) COLLATE database_default
    ALTER TABLE #TabExtAkce ADD CisloNakladovyOkruh  NVARCHAR(100) COLLATE database_default


    CREATE TABLE #TabExtAkceInt (
    Nazev NVARCHAR(255) COLLATE database_default,
    TypMaj NVARCHAR(100) COLLATE database_default,
    CisloMaj INT,
    Prislusenstvi INT,
    CarKod NVARCHAR(100) COLLATE database_default,
    KodLok NVARCHAR(100) COLLATE database_default,
    VyrCislo NVARCHAR(100) COLLATE database_default,
    CisloNakladovyOkruh NVARCHAR(100) COLLATE database_default
    ) 
    
INSERT INTO #TabExtAkceInt                           

SELECT
TabMaKar.Nazev1,TabMaKar.TypMaj, TabMaKar.CisloMaj,TabMaKar.Prislusenstvi,TabMaKar.TypCisloMaj,VMaUmisMaKarStav.KodLok,TabMaKar.VyrCislo,VMaUmisMaKarStav.CisloNakladovyOkruh
FROM TabMaKar
  LEFT OUTER JOIN TabMaUmis VMaUmisMaKarStav ON VMaUmisMaKarStav.Id = (SELECT TOP 1 T.Id FROM TabMaUmis T WHERE T.IdMaj = TabMaKar.Id AND T.DatumPlatnosti<= @KDatu  ORDER BY T.DatumPlatnosti DESC) AND TabMaKar.Id = VMaUmisMaKarStav.IdMaj
WHERE
(((EXISTS(SELECT*FROM TabMaPravaTypMaj p WHERE p.TypMaj=TabMaKar.TypMaj AND p.LoginName=SUSER_SNAME()) AND NOT EXISTS(SELECT*FROM TabMaPravaTypMaj p WHERE p.TypMaj=TabMaKar.TypMaj AND p.LoginName=SUSER_SNAME() AND p.ReadOnly=2)) OR  (NOT EXISTS(SELECT*FROM TabMaPravaTypMaj p WHERE p.TypMaj=TabMaKar.TypMaj AND p.LoginName=SUSER_SNAME()) AND NOT EXISTS(SELECT*FROM TabMaPravaTypMaj p  JOIN TabUziv u ON u.IDRole=p.IDRole WHERE p.TypMaj=TabMaKar.TypMaj AND u.LoginName=SUSER_SNAME() AND p.ReadOnly=2))))AND((TabMaKar.Prislusenstvi=0)AND(TabMaKar.DatumVyrKDatu>=@KDatu)AND(TabMaKar.DatumZav<@KDatu))
ORDER BY
TabMaKar.TypMaj ASC ,TabMaKar.CisloMaj ASC ,TabMaKar.Prislusenstvi ASC

INSERT INTO #TabExtAkce                           
SELECT * FROM #TabExtAkceInt


END
GO

