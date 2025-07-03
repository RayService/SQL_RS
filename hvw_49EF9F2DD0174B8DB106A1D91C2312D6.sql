USE [RayService]
GO

/****** Object:  View [dbo].[hvw_49EF9F2DD0174B8DB106A1D91C2312D6]    Script Date: 03.07.2025 11:08:28 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

CREATE VIEW [dbo].[hvw_49EF9F2DD0174B8DB106A1D91C2312D6] AS select aprevfa.id, aprevfa.idfa, aprevfa.idnadrizeny, aprevfa.cislo, aprevfa.nukaz, aprevfa.doplnaz, aprevfa.skupina, aprevfa.text, substring(aprevfa.text,1,255) as text_255, aprevfa.guidtext, aprevfa.tabulka, aprevfa.ex_akce,aprevfa.datumod, aprevfa.datumdo,
aprevfa.atribut, aprevfa.atribut2, aprevfa.atribut3, aprevfa.atribut4, aprevfa.atribut5, aprevfa.atribut6, aprevfa.atribut7, 
aprevfa.copocitat, aprevfa.copocitat2, aprevfa.slqdotaz, aprevfa.typakt, aprevfa.pocets, aprevfa.ukonceno, aprevfa.neakt, aprevfa.zpusobvyp, aprevfa.interval, 
aprevfa.prumer, aprevfa.impprumer, aprevfa.aritm, aprevfa.kcmn_cas, aprevfa.popis, aprevfa.kor, aprevfa.zk, aprevfa.kum, aprevfa.tis, aprevfa.procento, aprevfa.koef, aprevfa.typ, 
aprevfa.filtr, substring(aprevfa.filtr,1,255) as filtr_255,
 aprevfa.filtrucet, aprevfa.filtrdoklad, aprevfa.filtrpohyb, aprevfa.prodej, aprevfa.nakup, aprevfa.prirses, aprevfa.prirsesz, cast((case when aprevfa.prirses is null then 0 else 1 end) as bit) as jeprirses, aprevfa.stavbs, aprevfa.ps, aprevfa.prubstavy, 
aprevfa.vzorec, aprevfa.jmenovatel, aprevfa.zpusobzobr, aprevfa.export, aprevfa.schvalenodne, cast((case  when aprevfa.schvalenodne is null then 0 else 1 end) as bit) as schvaleno , aprevfa.schvalil,

aprevfa.copocitat3, aprevfa.copocitat4, aprevfa.copocitat5, aprevfa.copocitat6, aprevfa.copocitat7, aprevfa.copocitat8, aprevfa.copocitat9, aprevfa.natribut, aprevfa.natribut2, aprevfa.natribut3, aprevfa.natribut4, aprevfa.natribut5, aprevfa.natribut6, 
aprevfa.natribut7, aprevfa.autor, aprevfa.datporizeni, aprevfa.zmenil, aprevfa.datzmeny, dataktual,aprevfa.dathroakt, aprevfa.blokovanieditoru, 
cast((case when aprevfa.idfa is null then 0 else 1 end) as bit) as jeidfa, cast((case when exists(select apravatab.id from apravatab where apravatab.idukaz=aprevfa.id and apravatab.typ='F') then 1 else 0 end) as bit) as prava,   
cast((case when isnull(aprevfa.popis,'')<>'' then 1 else 0 end) as bit) as extechpopis, (case when left(isnull(aprevfa.dcislozam,''),1)='' then '0' else left(aprevfa.dcislozam,1) end) as typintervalu, nsuma1, aprevfa.pocetzaznamu , nactikumulaci

from aprevfa left outer join atabu on atabu.tabulka=aprevfa.tabulka where aprevfa.typ='K' and 
(not exists(select apravatab.id from apravatab where apravatab.idukaz=aprevfa.id and apravatab.typ='F') 
or exists(select apravatab.id from apravatab where apravatab.iduziv=suser_sname() and apravatab.idukaz=aprevfa.id and apravatab.typ='F')
or isnull((select tabuziv.idrole from tabuziv where tabuziv.LoginName=suser_sname()),-1) 
in (select apravatab.idrole from apravatab where apravatab.typ='F' and apravatab.idukaz=aprevfa.id))
and
(not exists(select apravatab.id from apravatab where apravatab.idukaz=atabu.id and apravatab.typ='T') 
or exists(select apravatab.id from apravatab where apravatab.iduziv=suser_sname() and apravatab.idukaz=atabu.id and apravatab.typ='T')
or isnull((select tabuziv.idrole from tabuziv where tabuziv.LoginName=suser_sname()),-1) 
in (select apravatab.idrole from apravatab where apravatab.typ='T' and apravatab.idukaz=atabu.id))
GO

