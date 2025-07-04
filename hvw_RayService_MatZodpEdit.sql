USE [RayService]
GO

/****** Object:  View [dbo].[hvw_RayService_MatZodpEdit]    Script Date: 04.07.2025 7:23:58 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

CREATE VIEW [dbo].[hvw_RayService_MatZodpEdit] AS SELECT
ID
,dilec
,IDPostup
,IDPracovniPozice
,Dimenze
,Autor
,DatPorizeni
,Zmenil
,DatZmeny
FROM Tabx_RayService_MatZodp
GO

