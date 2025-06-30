USE [RayService]
GO

/****** Object:  StoredProcedure [dbo].[hpx_RS_KopieUmisteniJinySkladSK]    Script Date: 30.06.2025 8:26:16 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

CREATE PROCEDURE [dbo].[hpx_RS_KopieUmisteniJinySkladSK] @IDSklad NVARCHAR(30), @ID INT
AS

SET NOCOUNT ON;
--DECLARE @IDSklad NVARCHAR(30)
--DECLARE @ID INT
--SET @IDSklad=N'100'
--SET @ID=197552
BEGIN
--ostré deklarace
DECLARE @Kod NVARCHAR(15);
DECLARE @IDNew INT;
SET @Kod=(SELECT Kod FROM TabUmisteni WHERE ID=@ID);

--SELECT tu.Id,tu.IdSklad,tu.Kod,tu.Nazev,tue._VyjmoutZMapySkladu,tue._PovolitZaporneMnozNaUmisteni,tue._IDPolice,tue._EXT_B2ADIMARS_UseForQaReportInventoryEntryPrint,tue._EXT_RS_generate_stock_taking_subordinate,tue._EXT_RS_PhysicalPlace,tue._EXT_RS_IDLocationPrint,tue._EXT_RS_IDLocationPrint,tue._EXT_RS_VypnoutFIFOFEFO,tue._EXT_RS_VypnoutVzorec
--FROM TabUmisteni tu
--LEFT OUTER JOIN TabUmisteni_EXT tue ON tue.ID=tu.ID
--WHERE tu.ID=@ID

IF EXISTS (SELECT tu.Id FROM RayService5.dbo.TabUmisteni tu WHERE tu.Kod=@Kod AND tu.IdSklad=@IDSklad)
BEGIN
RAISERROR('Na cílovém skladu již umístění se stejným kódem existuje.',16,1)
RETURN
END;

INSERT INTO RayService5.dbo.TabUmisteni (IdSklad,Kod,Nazev)
SELECT @IDSklad,tu.Kod,tu.Nazev
FROM TabUmisteni tu
--LEFT OUTER JOIN TabUmisteni_EXT tue ON tue.ID=tu.ID
WHERE tu.ID=@ID
SET @IDNew=(SELECT SCOPE_IDENTITY());

INSERT INTO RayService5.dbo.TabUmisteni_EXT (ID,_VyjmoutZMapySkladu,_PovolitZaporneMnozNaUmisteni,_IDPolice,_EXT_B2ADIMARS_UseForQaReportInventoryEntryPrint,_EXT_RS_generate_stock_taking_subordinate,_EXT_RS_PhysicalPlace,_EXT_RS_IDLocationPrint,_EXT_RS_VypnoutFIFOFEFO,_EXT_RS_VypnoutVzorec)
SELECT @IDNew,tue._VyjmoutZMapySkladu,tue._PovolitZaporneMnozNaUmisteni,tue._IDPolice,tue._EXT_B2ADIMARS_UseForQaReportInventoryEntryPrint,tue._EXT_RS_generate_stock_taking_subordinate,tue._EXT_RS_PhysicalPlace,tue._EXT_RS_IDLocationPrint,tue._EXT_RS_VypnoutFIFOFEFO,tue._EXT_RS_VypnoutVzorec
FROM TabUmisteni tu
LEFT OUTER JOIN TabUmisteni_EXT tue ON tue.ID=tu.ID
WHERE tu.ID=@ID;

--SELECT tu.Id,tu.IdSklad,tu.Kod,tu.Nazev,tue._VyjmoutZMapySkladu,tue._PovolitZaporneMnozNaUmisteni,tue._IDPolice,tue._EXT_B2ADIMARS_UseForQaReportInventoryEntryPrint,tue._EXT_RS_generate_stock_taking_subordinate,tue._EXT_RS_PhysicalPlace,tue._EXT_RS_IDLocationPrint,tue._EXT_RS_IDLocationPrint,tue._EXT_RS_VypnoutFIFOFEFO,tue._EXT_RS_VypnoutVzorec
--FROM TabUmisteni tu
--LEFT OUTER JOIN TabUmisteni_EXT tue ON tue.ID=tu.ID
--WHERE tu.Kod=@Kod AND tu.IdSklad=@IDSklad;

END;
GO

