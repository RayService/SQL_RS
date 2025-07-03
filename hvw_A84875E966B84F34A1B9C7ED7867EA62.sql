USE [RayService]
GO

/****** Object:  View [dbo].[hvw_A84875E966B84F34A1B9C7ED7867EA62]    Script Date: 03.07.2025 12:49:49 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

CREATE VIEW [dbo].[hvw_A84875E966B84F34A1B9C7ED7867EA62] AS SELECT 
tcz.Cislo
,dpich.picIDOsoby
,dpich.picIDPichacka
,dpich.picDatum
,NULLIF(dpich.picCasPrichodu,'1900-01-01') AS picCasPrichodu
,NULLIF(dpich.picCasOdchodu,'1900-01-01') AS picCasOdchodu
,dpich.picOdpracDoba
,dpich.picOdchylka
,ISNULL(dpich.picSaldoPodleDenVyrovnani,0) AS Vyrovnani
,CONVERT(NUMERIC(19,6),dpich.picOdpracDoba)/60 AS Odprac_H
,CONVERT(NUMERIC(19,6),dpich.picOdchylka)/60 AS Odchylka_H
,CONVERT(NUMERIC(19,6),ISNULL(dpich.picSaldoPodleDenVyrovnani,0))/60 AS Vyrovnani_H
FROM DOCHAZKASQL.IdentitaNET.dbo.DochPichacka dpich WITH(NOLOCK)
LEFT OUTER JOIN RayService..TabCisZam tcz WITH(NOLOCK) ON tcz.Cislo=dpich.picIDOsoby
WHERE DATEPART(YEAR,dpich.picDatum)=DATEPART(YEAR,GETDATE()) AND DATEPART(YEAR,dpich.picCasPrichodu)=DATEPART(YEAR,GETDATE()) AND dpich.picDatum<CONVERT(DATE,GETDATE()) AND tcz.LoginId=SUSER_SNAME()
GO

