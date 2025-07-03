USE [RayService]
GO

/****** Object:  View [dbo].[hvw_E1E467587E33463796E6016B9937023D]    Script Date: 03.07.2025 14:38:03 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

CREATE VIEW [dbo].[hvw_E1E467587E33463796E6016B9937023D] AS /*SELECT *
FROM Tabx_RS_TabPlanPrKVazby*/
SELECT [ID]
      ,[ID_orig]
      ,[IDPlan]
      ,[IDPlanPrikaz]
      ,[Doklad]
      ,[Sklad]
      ,[mnoz_zad]
      ,[vyssi]
      ,[nizsi]
      ,[pozice]
      ,[Operace]
      ,[RezijniMat]
      ,[Poznamka]
      ,[Autor]
      ,[DatPorizeni]
      ,[DatPorizeni_D]
      ,[DatPorizeni_M]
      ,[DatPorizeni_Y]
      ,[DatPorizeni_Q]
      ,[DatPorizeni_W]
      ,[DatPorizeni_X]
      ,[DavkaTPV]
      ,[FixniMnozstvi]
      ,[mnozstvi]
      ,[ProcZtrat]
      ,[mnozstviSeZtratou]
      ,[VychoziSklad]
      ,[Prirez]
      ,[SpotRozmer]
      ,[_DatZajMat]
      ,[_KontrolaPokryti_Nepokryto]
      ,[_KontrolaPokryti_Vysledek]
      ,[Datum_ulozeni]
      ,(SUBSTRING(REPLACE(SUBSTRING(Tabx_RS_TabPlanPrKVazby.[Poznamka],1,255),(NCHAR(13) + NCHAR(10)),NCHAR(32)),1,255)) AS Poznamka_255
  FROM [RayService].[dbo].[Tabx_RS_TabPlanPrKVazby] WITH(NOLOCK)
GO

