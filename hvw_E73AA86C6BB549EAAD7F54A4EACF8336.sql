USE [RayService]
GO

/****** Object:  View [dbo].[hvw_E73AA86C6BB549EAAD7F54A4EACF8336]    Script Date: 03.07.2025 14:40:03 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

CREATE VIEW [dbo].[hvw_E73AA86C6BB549EAAD7F54A4EACF8336] AS SELECT 
tcz.Cislo
,dpich.picIDOsoby
,dpich.picIDPichacka
,dpich.picDatum
,NULLIF(dpich.picCasPrichodu,'1900-01-01') AS picCasPrichodu
,NULLIF(dpich.picCasOdchodu,'1900-01-01') AS picCasOdchodu
,dpich.picOdpracDoba
,dpich.picOdchylka
,CONVERT(NUMERIC(19,6),dpich.picOdpracDoba)/60 AS Odprac_H
,CONVERT(NUMERIC(19,6),dpich.picOdchylka)/60 AS Odchylka_H
FROM DOCHAZKASQL.IdentitaNET.dbo.DochPichacka dpich WITH(NOLOCK)
LEFT OUTER JOIN RayService..TabCisZam tcz WITH(NOLOCK) ON tcz.Cislo=dpich.picIDOsoby
WHERE DATEPART(YEAR,dpich.picDatum)=DATEPART(YEAR,GETDATE()) AND DATEPART(YEAR,dpich.picCasPrichodu)=DATEPART(YEAR,GETDATE()) AND dpich.picDatum<CONVERT(DATE,GETDATE())
GO

