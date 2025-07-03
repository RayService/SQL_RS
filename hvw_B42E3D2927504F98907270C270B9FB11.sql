USE [RayService]
GO

/****** Object:  View [dbo].[hvw_B42E3D2927504F98907270C270B9FB11]    Script Date: 03.07.2025 13:48:30 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

CREATE VIEW [dbo].[hvw_B42E3D2927504F98907270C270B9FB11] AS select asloupce.id as idd, asloupce.tabulka, isnull(trats.NazevAtrVer,asloupce.jmeno) as jmeno, asloupce.atribut, asloupce.typ, cast(asloupce.apoc as bit) as apoc, asloupce.definice as definice, 
substring(asloupce.definice,1,255) as definice255, 
(case when isnull(asloupce.definice,'')='' then asloupce.tabulka+'.'+asloupce.atribut else substring(asloupce.definice,1,255) end) as definicezkr, asloupce.tabulka+'.'+asloupce.atribut as tabulkaatribut, 
(select atabu.typimexshop from atabu where atabu.tabulka=asloupce.tabulka) as typimexshop, 

(case when isnull(asloupce.anul,0)=0 then '' when charindex('bit',asloupce.typ)>0 or charindex('num',asloupce.typ)>0 or charindex('floa',asloupce.typ)>0 then 'isnull(' else '' end)
+(case when isnull(asloupce.definice,'')='' then asloupce.tabulka+'.'+asloupce.atribut  else/* cast(asloupce.definice as varchar(max)) end)+  */
asloupce.tabulka+'.'+asloupce.atribut end)+
(case when isnull(asloupce.anul,0)=0 then '' when charindex('bit',asloupce.typ)>0 or charindex('num',asloupce.typ)>0 or charindex('floa',asloupce.typ)>0 then ',0)' else '' end) as definiceuplna,
'A'+cast(asloupce.id as varchar(15)) as id, asloupce.hromeditace, isnull(asloupce.vyberfa,1000000) as vyberfa, asloupce.mutace as mutace,'H' as zdroj, isnull(trats.NazevAtrVerZkr,asloupce.jmenozkr) as jmenozkr, 
/*isnull(asloupce.zurnalo,0) as zurnalo, */0 as externi, /*isnull(mezid,0) as mezid, */asloupce.oblibene, asloupce.sapkopirovattabulku, asloupce.synchronizace as synchronizace
 from asloupce left outer join TabRenameAtr trats on trats.NazevTabulkySys=asloupce.Tabulka and trats.nazevatrsys=asloupce.atribut 

union all select (tabuzivatr.id+10000000) as idd,
tabuzivatr.nazevtabulkysys, isnull(trat.NazevAtrVer,tabuzivatr.nazevatrver) as nazevatrver, tabuzivatr.nazevatrsys, tabuzivatr.typatr, cast((case when tabuzivatr.externi=1 then 0 else 1 end) as bit),
tabuzivatr.definiceatr, substring(tabuzivatr.definiceatr,1,255), (case when tabuzivatr.externi=1 then tabuzivatr.nazevtabulkysys+'_ext.'+tabuzivatr.nazevatrsys else substring(tabuzivatr.definiceatr,1,255) end),
tabuzivatr.nazevtabulkysys+'.'+tabuzivatr.nazevatrsys, (select atabu.typimexshop from atabu where atabu.tabulka=tabuzivatr.nazevtabulkysys) 
as typimexshop, 
(case when charindex('bit',tabuzivatr.typatr)>0  or charindex('num',tabuzivatr.typatr)>0 or charindex('floa',tabuzivatr.typatr)>0 then 'isnull(' else '' end)+
(case when tabuzivatr.externi=1 then tabuzivatr.nazevtabulkysys+'_ext.'+tabuzivatr.nazevatrsys else cast(tabuzivatr.definiceatr as varchar(max)) end)+ 
(case when charindex('bit',tabuzivatr.typatr)>0 or charindex('num',tabuzivatr.typatr)>0 or charindex('floa',tabuzivatr.typatr)>0 then ',0)' else '' end),
'U'+cast(tabuzivatr.id as varchar(15)), _hromeditace, isnull(tabuzivatr_ext._vyberfa,1000000) as vyberfa, _mutace as mutace, 'U',  isnull(trat.NazevAtrVerZkr,TabUzivAtr.NazevAtrVerZkr), 
/*isnull(tabuzivatr_ext._zurnalo,0) as zurnalo,*/ isnull(tabuzivatr.externi,0) as externi,/* isnull(tabuzivatr_ext._mezid,0),*/ tabuzivatr_ext._oblibene, tabuzivatr_ext._sapkopirovattabulku, tabuzivatr_ext._synchronizace
 from tabuzivatr left outer join tabuzivatr_ext on tabuzivatr_ext.id=tabuzivatr.id 
left outer join TabRenameAtr trat on trat.NazevTabulkySys=tabuzivatr.NazevTabulkySys and trat.nazevatrsys=tabuzivatr.nazevatrsys
GO

