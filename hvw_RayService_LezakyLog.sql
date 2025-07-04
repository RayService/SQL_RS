USE [RayService]
GO

/****** Object:  View [dbo].[hvw_RayService_LezakyLog]    Script Date: 04.07.2025 7:21:37 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

CREATE VIEW [dbo].[hvw_RayService_LezakyLog] AS SELECT
ID
,Obdobi
,(RIGHT(Obdobi,2) + N'/' + LEFT(Obdobi,4)) ObdobiNazev
,IDSklad
,DatumDo
,PocetMesicu
,ProcentoVydej
,Podminky
,DatPorizeni
,Autor
,Datum
FROM Tabx_RayService_LezakyLog
GO

