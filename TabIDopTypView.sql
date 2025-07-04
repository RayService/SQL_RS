USE [RayService]
GO

/****** Object:  View [dbo].[TabIDopTypView]    Script Date: 04.07.2025 11:23:48 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

CREATE VIEW [dbo].[TabIDopTypView] as
select idorg,cast(typ as nvarchar(40)) as typ,spz,spznaves,cast(IsNull(O.nazev,'') as nvarchar(100)) as Nazev,O.misto as Misto,cast(O.idzeme as nvarchar(40)) as Stat,AktDP,tabidoptyp.id as idVoz from tabidoptyp
left outer join tabcisorg O on O.cisloorg=idOrg
union all
select 0 as idorg, T.popis as typ, SPZZobraz as spz, spznaves as spznaves,cast(IsNull(O.nazev,'') as nvarchar(100)) as Nazev,O.misto as Misto,cast(O.idzeme as nvarchar(40)) as Stat,AktDP,tabivozidlo.id as idVoz from tabivozidlo
left outer join tabivoztyp T on T.id=idVozTyp
left outer join tabcisorg O on O.cisloorg=0
GO

