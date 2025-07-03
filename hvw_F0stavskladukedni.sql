USE [RayService]
GO

/****** Object:  View [dbo].[hvw_F0stavskladukedni]    Script Date: 03.07.2025 14:46:05 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

CREATE VIEW [dbo].[hvw_F0stavskladukedni] AS select tss.id as id,  asaperskladkedni.idzbosklad as idzbosklad, ass.datum as datum, tss.idsklad as idsklad, tss.idkmenzbozi, tkzz.idsortiment, 
isnull(asaperskladkedni.mnozstvikedni,0) as mnozstvikedni, 
isnull(asaperskladkedni.stavkedni,0) as stavkedni, 
cast(round(isnull(asaperskladkedni.stavkedni,0),2) as numeric(19,6)) as stavkedniucto, 
/*cast(round(isnull(asaperskladkedni.stavsnkedni,0)+isnull((select sum(isnull(asaperdsn.dsn,0)) from asaperdsn where asaperdsn.idzbosklad=tss.id and asaperdsn.datpripad_x<=ass.datum ),0),2) as numeric(19,6)) as stavsnkedni, */
stavsnkedni,
cast(isnull((case when asaperskladkedni.mnozstvikedni=0 then 0 else asaperskladkedni.stavkedni/asaperskladkedni.mnozstvikedni end),0) as numeric(19,6)) as prumerkedni, 

tss.mnozstvi, tss.stavskladu, tss.stavskladusouvis,  tkzz.skupzbo, tkzz.regcis, asaperskladkedni.datum as datumxxx,

cast(round(isnull((select sum(isnull(asaperdsn.dsn,0)) from asaperdsn where asaperdsn.idzbosklad=asaperskladkedni.idzbosklad and asaperdsn.datpripad_x<=asaperskladkedni.datum ),0),2) as numeric(19,6)) as stavdn,
cast(stavsnkedni+round(isnull((select sum(isnull(asaperdsn.dsn,0)) from asaperdsn where asaperdsn.idzbosklad=asaperskladkedni.idzbosklad and asaperdsn.datpripad_x<=asaperskladkedni.datum ),0),2)  as numeric(19,6)) as stavsndnkedni,

 asaperskladkedni.ucetzasob as ucetzasob, stavplusdsnkedni
 from tabstavskladu tss
 left outer join tabkmenzbozi tkzz on tkzz.id=tss.idkmenzbozi
 left outer join asaperkdatu ass on ass.spid=@@spid and ass.druh='SK' 
 left outer join tabhglob on tabhglob.id=tabhglob.id 
 left outer join asaperskladkedni on asaperskladkedni.Id = 
 (SELECT TOP 1 T.id FROM asaperskladkedni T WHERE T.Idzbosklad = tss.id AND T.datum<=   ass.datum 
 ORDER BY T.datum DESC ) and tss.id = asaperskladkedni.idzbosklad
GO

