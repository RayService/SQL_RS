USE [RayService]
GO

/****** Object:  View [dbo].[hvw_RayService_MatZodp]    Script Date: 04.07.2025 7:23:36 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

CREATE VIEW [dbo].[hvw_RayService_MatZodp] AS SELECT
M.ID
,M.dilec
,P.IDVarianta
,M.IDPostup
,P.ZmenaOd
,P.ZmenaDo
,ZOd.datum as ZmenaOd_Datum
,ZDo.datum as ZmenaDo_Datum
,ZOd.PlatnostTPV as ZmenaOd_Platnost
,ZDo.PlatnostTPV as ZmenaDo_Platnost
,M.IDPracovniPozice
,M.Dimenze
,M.Autor
,M.DatPorizeni
,M.Zmenil
,M.DatZmeny
FROM Tabx_RayService_MatZodp M
	INNER JOIN TabPostup P ON M.dilec = P.dilec AND M.IDPostup = P.ID
	LEFT OUTER JOIN TabCzmeny ZOd ON P.ZmenaOd = ZOd.ID
	LEFT OUTER JOIN TabCzmeny ZDo ON P.ZmenaDo = ZDo.ID
GO

