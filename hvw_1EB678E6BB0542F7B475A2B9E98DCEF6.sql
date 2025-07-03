USE [RayService]
GO

/****** Object:  View [dbo].[hvw_1EB678E6BB0542F7B475A2B9E98DCEF6]    Script Date: 03.07.2025 10:59:45 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

CREATE VIEW [dbo].[hvw_1EB678E6BB0542F7B475A2B9E98DCEF6] AS select hv.idd as id, navbubtab.tabulka as tabulka, navbubtab.nazev, navbubtab.tabulkav, hv.tabulkaatribut, hv.atribut as atribut, hv.definicezkr, definiceuplna,  cast(navbubtab.vazba as varchar(8000)) as vazba,  
navbubtab.talias as talias, hv.apoc, hv.typ, navbubtab.typvazby, tabul.tabver, hv.jmeno as jmeno, navbubtab.talias+'.'+hv.atribut as aliasatribut, hv.externi, hv.oblibene
from hvw_B42E3D2927504F98907270C270B9FB11 hv 
join (select tov.popis as nazev, TabL as tabulka, TabP as tabulkav, tov.Podminka as vazba, tov.jmenosysnew as talias, tov.typlp as typvazby from TabObecnaVazba tov 
union all select ah.popis as nazev, ah.tabulka as tabulka, ah.tabulkav as tabulkav, ah.vazba as vazba,  ah.talias as talias, ah.typvazby+1 as typvazby from aheliosvazby ah) 
navbubtab on navbubtab.tabulkav=hv.tabulka 
left outer join atabu tabul on tabul.tabulka=navbubtab.tabulkav
union all select  (hvv.idd+100000000) as id,hvv.tabulka, ata.tabver as nazev,  hvv.tabulka, hvv.tabulkaatribut, hvv.atribut, hvv.definicezkr, hvv.definiceuplna, '',  hvv.tabulka as talias, hvv.apoc, hvv.typ, 1, ata.tabver, hvv.jmeno, 
hvv.tabulka+'.'+hvv.atribut, hvv.externi, hvv.oblibene
from hvw_B42E3D2927504F98907270C270B9FB11 hvv left outer join atabu ata on ata.tabulka=hvv.tabulka
GO

