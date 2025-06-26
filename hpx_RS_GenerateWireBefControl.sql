USE [RayService]
GO

/****** Object:  StoredProcedure [dbo].[hpx_RS_GenerateWireBefControl]    Script Date: 26.06.2025 13:05:18 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

CREATE PROCEDURE [dbo].[hpx_RS_GenerateWireBefControl] @IDZadosti INT
AS

--DECLARE @IDZadosti INT=10145,
DECLARE @IDCombination INT, @IDSetting INT, @IDContact INT, @IDPrikaz INT, @Mnozstvi NUMERIC(19,6), @NewID INT, @IDGen INT, @IDGenPrikaz INT, @IDKmenZboziGen INT, @MnoGen NUMERIC(19,6);

SELECT @IDCombination=IDCombination, @IDPrikaz=IDProductionOrder
FROM B2A_TDM_TensileTest_Request
WHERE ID=@IDZadosti
--zjistíme IDSetting a použijeme na B2A_TDM_Setting_Wire, dále zjistíme IDContact a použijeme na B2A_TDM_Contact
SELECT @IDSetting=comb.IDSetting,@IDContact=IDContact
FROM B2A_TDM_Combination comb WITH(NOLOCK)
WHERE comb.ID=@IDCombination

--vodiče nasypat do dočasné tabulky
IF (OBJECT_ID('tempdb..#TempVodice') IS NOT NULL)
BEGIN
DROP TABLE #TempVodice
END;
CREATE TABLE #TempVodice 
( [ID] INT IDENTITY (1,1) PRIMARY KEY,
  [IDPolozky] [INT],
  [SkupZbo] [NVARCHAR](3),
  [RegCis] [NVARCHAR](30),
  [Mnozstvi] [NUMERIC](19,6),
  [IDPrikaz] [INT],
  [IDCombination] [INT],
  [AutomatGenVC] [BIT],
  [Autor] [NVARCHAR](128),
  [DatPorizeni] [DATETIME],
  [IDZadosti] [INT],
  [TypPol] [NVARCHAR](10)
)

INSERT INTO #TempVodice (IDPolozky,/*SkupZbo,RegCis,*/Mnozstvi,IDPrikaz,IDCombination,AutomatGenVC,Autor,DatPorizeni,IDZadosti,TypPol)
SELECT tkz.ID AS IDVodic,/* tkz.SkupZbo, tkz.RegCis,*/ 0.2, @IDPrikaz,@IDCombination,ISNULL(tkze._AutomatickeGenerovaniVCPriVydeji,0),SUSER_SNAME(),GETDATE(),@IDZadosti,'Vodič'
FROM B2A_TDM_Setting_Wire tsw WITH(NOLOCK)
LEFT OUTER JOIN B2A_TDM_Wire wire  WITH(NOLOCK) ON wire.ID=tsw.IDWire
LEFT JOIN TabKmenZbozi tkz WITH(NOLOCK) ON wire.IDMaterial = tkz.ID
LEFT OUTER JOIN TabKmenZbozi_EXT tkze WITH(NOLOCK) ON tkze.ID=tkz.ID
WHERE tsw.IDSetting=@IDSetting

--vymazání předešlých záznamů pro označenou zkoušku
DELETE FROM Tabx_RS_TDMWire_Before WHERE IDZadosti=@IDZadosti
--vložení do trvalé tabulky v HEO pro zobrazení přes uživatelským výběrem
INSERT INTO Tabx_RS_TDMWire_Before (IDPolozky,/*SkupZbo,RegCis,*/Mnozstvi,IDPrikaz,IDCombination,AutomatGenVC,IDZadosti,TypPol)
SELECT IDPolozky,/*SkupZbo,RegCis,*/Mnozstvi,IDPrikaz,IDCombination,AutomatGenVC,IDZadosti,TypPol
FROM #TempVodice

--SELECT * FROM Tabx_RS_TDMWire_Before

--kontakty nasypat do dočasné tabulky

IF (OBJECT_ID('tempdb..#TempKontakty') IS NOT NULL)
BEGIN
DROP TABLE #TempKontakty
END;
CREATE TABLE #TempKontakty 
( [ID] INT IDENTITY (1,1) PRIMARY KEY,
  [IDPolozky] [INT],
  [SkupZbo] [NVARCHAR](3),
  [RegCis] [NVARCHAR](30),
  [Mnozstvi] [NUMERIC](19,6),
  [IDPrikaz] [INT],
  [IDCombination] [INT],
  [AutomatGenVC] [BIT],
  [Autor] [NVARCHAR](128),
  [DatPorizeni] [DATETIME],
  [IDZadosti] [INT],
  [TypPol] [NVARCHAR](10)
)

--první vložení
INSERT INTO #TempKontakty (IDPolozky,/*SkupZbo,RegCis,*/Mnozstvi,IDPrikaz,IDCombination,AutomatGenVC,Autor,DatPorizeni,IDZadosti,TypPol)
SELECT tkz.ID AS IDContact,/* tkz.SkupZbo, tkz.RegCis,*/ 2, @IDPrikaz,@IDCombination,ISNULL(tkze._AutomatickeGenerovaniVCPriVydeji,0),SUSER_SNAME(),GETDATE(),@IDZadosti,'Kontakt'
FROM B2A_TDM_Contact t1 WITH(NOLOCK)
LEFT JOIN TabKmenZbozi tkz WITH(NOLOCK) ON t1.IDMaterial = tkz.ID
LEFT OUTER JOIN TabKmenZbozi_EXT tkze WITH(NOLOCK) ON tkze.ID=tkz.ID
WHERE t1.ID=@IDContact
/*--druhé vložení
INSERT INTO #TempKontakty (IDPolozky,SkupZbo,RegCis,Mnozstvi,IDPrikaz,IDCombination,AutomatGenVC,Autor,DatPorizeni,IDZadosti,TypPol)
SELECT tkz.ID AS IDContact, tkz.SkupZbo, tkz.RegCis, 1, @IDPrikaz,@IDCombination,ISNULL(tkze._AutomatickeGenerovaniVCPriVydeji,0),SUSER_SNAME(),GETDATE(),@IDZadosti,'Kontakt'
FROM B2A_TDM_Contact t1 WITH(NOLOCK)
LEFT JOIN TabKmenZbozi tkz WITH(NOLOCK) ON t1.IDMaterial = tkz.ID
LEFT OUTER JOIN TabKmenZbozi_EXT tkze WITH(NOLOCK) ON tkze.ID=tkz.ID
WHERE t1.ID=@IDContact
*/

--vymazání předešlých záznamů pro označenou zkoušku
--DELETE FROM Tabx_RS_TDMContacts_Before WHERE IDZadosti=@IDZadosti
--vložení do trvalé tabulky v HEO pro zobrazení přes uživatelským výběrem
--toto změněno INSERT INTO Tabx_RS_TDMContacts_Before (IDPolozky,SkupZbo,RegCis,Mnozstvi,IDPrikaz,IDCombination,AutomatGenVC,IDZadosti,TypPol)
INSERT INTO Tabx_RS_TDMWire_Before (IDPolozky,/*SkupZbo,RegCis,*/Mnozstvi,IDPrikaz,IDCombination,AutomatGenVC,IDZadosti,TypPol)
SELECT IDPolozky,/*SkupZbo,RegCis,*/Mnozstvi,IDPrikaz,IDCombination,AutomatGenVC,IDZadosti,TypPol
FROM #TempKontakty
GO

