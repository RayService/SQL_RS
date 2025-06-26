USE [RayService]
GO

/****** Object:  StoredProcedure [dbo].[hpx_RS_CopyJAGGINGToHist]    Script Date: 26.06.2025 15:59:47 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

CREATE PROCEDURE [dbo].[hpx_RS_CopyJAGGINGToHist]
AS
SET NOCOUNT ON;

IF (SELECT DATEPART(WEEKDAY,GETDATE()))=5
BEGIN
--vymažeme stávající data
DELETE FROM RayService.dbo.Tabx_RS_OUT_MANUFACTURINGORDERJAGGING_hist
--naimportujeme nová
INSERT INTO RayService.dbo.Tabx_RS_OUT_MANUFACTURINGORDERJAGGING_hist(
      Cislo_VP
      ,ID_Vyrobku
      ,Obj_Mnozstvi
      ,PST
      ,PET
      ,LPST
      ,EPST
      ,ID_Zakazek
      ,ID_Zakazky
      ,Rada_VP
      ,Pokryto
      ,Typ_Dodavky
      ,ID_Dodavky
      ,ID_Materialu
      ,Alokovano
      ,Doporuceni
      ,Zpozdeni
      ,T_Dodani
      ,T_Potreby
      ,Mn_Objednane
      ,Mn_Nevyuzite
      ,Suma_Potreb
      ,Suma_NO
      ,Suma_NNO
      ,T_PotrebyPP
      ,Mn_ObjednanePP
      ,Zmenil
      ,DatZmeny
      ,T_VystaveniPP
      ,Mn_Objednane_New
      ,T_Dodani_New
      ,Status
      ,Potvrzeny_TDOD
      ,T_Nejdrive_Mozny)

SELECT 
      Cislo_VP
      ,ID_Vyrobku
      ,Obj_Mnozstvi
      ,PST
      ,PET
      ,LPST
      ,EPST
      ,ID_Zakazek
      ,ID_Zakazky
      ,Rada_VP
      ,Pokryto
      ,Typ_Dodavky
      ,ID_Dodavky
      ,ID_Materialu
      ,Alokovano
      ,Doporuceni
      ,Zpozdeni
      ,T_Dodani
      ,T_Potreby
      ,Mn_Objednane
      ,Mn_Nevyuzite
      ,Suma_Potreb
      ,Suma_NO
      ,Suma_NNO
      ,T_PotrebyPP
      ,Mn_ObjednanePP
      ,Zmenil
      ,DatZmeny
      ,T_VystaveniPP
      ,Mn_Objednane_New
      ,T_Dodani_New
      ,Status
      ,Potvrzeny_TDOD
      ,T_Nejdrive_Mozny
FROM RayService.dbo.Tabx_RS_OUT_MANUFACTURINGORDERJAGGING
END;
GO

