USE [RayService]
GO

/****** Object:  View [dbo].[hvw_Basaperrskladkedni]    Script Date: 03.07.2025 14:12:22 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

CREATE VIEW [dbo].[hvw_Basaperrskladkedni] AS select id, idzbosklad, idkmenzbozi, idsklad, datum, mnozstvi,mnozstvikedni, stav, stavkedni, stavsn, stavsnkedni, 

cast(round(isnull((select sum(isnull(asaperdsn.dsn,0)) from asaperdsn where asaperdsn.idzbosklad=asaperskladkedni.idzbosklad and asaperdsn.datpripad_x<=asaperskladkedni.datum ),0),2) as numeric(19,6)) as stavdn,
cast(stavsnkedni+round(isnull((select sum(isnull(asaperdsn.dsn,0)) from asaperdsn where asaperdsn.idzbosklad=asaperskladkedni.idzbosklad and asaperdsn.datpripad_x<=asaperskladkedni.datum ),0),2)  as numeric(19,6)) as stavsndnkedni,

stavucto, autor, datporizeni, ucetzasob, asaperskladkedni.stavplusdsnkedni, asaperskladkedni.stavplusdsn, datumpred
  from asaperskladkedni
GO

