USE [HCvicna]
GO

/****** Object:  Trigger [dbo].[et_TabHGlob_plgLogZmen]    Script Date: 02.07.2025 15:08:48 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

/*PlugGatemaLogovaniZmen.PlugGatemaLogovaniZmenRun*/create trigger [dbo].[et_TabHGlob_plgLogZmen] on [dbo].[TabHGlob] for update
as
set nocount on 
declare @existsInserted bit, @existsDeleted bit
if exists(select * from inserted) set @existsInserted=1 else set @existsInserted=0 
if exists(select * from deleted) set @existsDeleted=1 else set @existsDeleted=0 
if @existsInserted=0 and @existsDeleted=0 return
if @existsInserted=1 and @existsDeleted=1
 if
 update(Davka)
or update(Davka_TEC)
or update(AplikovatKVOPouzeNaTAC)
or update(Tarif)
or update(ZarovnaniOperaceTechPos)
or update(PoziceZaokrPriPrepoctuCasuTechPos)
or update(MaxVnoreni)
or update(DelkaPoziceKV)
or update(ZarovnaniPoziceKV)
or update(AutoCislovaniPoziceKV)
or update(Proc_ztrat)
or update(TypPlanovaciDoby)
or update(Prub_doba)
or update(DobaMeziPrikazy)
or update(VychoziStavBlokaceVyroby)
or update(ZdrojTarifuProMzdy_Nor)
or update(ZdrojTarifuProMzdy_Cas)
or update(MzdovaSlozUkolMzd)
or update(MzdovaSlozUhradZmet)
  insert into GTabLogovaneInformace(SysNazevTabulka,SysNazevAtribut,IDZaznam,OldHodnota,NewHodnota,Akce)
    select v.SysNazevTabulka,v.SysNazevAtribut,v.IDZaznam,left(v.OldHodnota,255),left(v.NewHodnota,255),1
      from(select SysNazevTabulka=N'TabHGlob',SysNazevAtribut=LA.SysNazevAtribut,IDZaznam=D.ID
                 ,OldHodnota=case LA.SysNazevAtribut 
when N'Davka' then convert(nvarchar(max),D.Davka,121)
when N'Davka_TEC' then convert(nvarchar(max),D.Davka_TEC,121)
when N'AplikovatKVOPouzeNaTAC' then convert(nvarchar(max),D.AplikovatKVOPouzeNaTAC,121)
when N'Tarif' then convert(nvarchar(max),D.Tarif,121)
when N'ZarovnaniOperaceTechPos' then convert(nvarchar(max),D.ZarovnaniOperaceTechPos,121)
when N'PoziceZaokrPriPrepoctuCasuTechPos' then convert(nvarchar(max),D.PoziceZaokrPriPrepoctuCasuTechPos,121)
when N'MaxVnoreni' then convert(nvarchar(max),D.MaxVnoreni,121)
when N'DelkaPoziceKV' then convert(nvarchar(max),D.DelkaPoziceKV,121)
when N'ZarovnaniPoziceKV' then convert(nvarchar(max),D.ZarovnaniPoziceKV,121)
when N'AutoCislovaniPoziceKV' then convert(nvarchar(max),D.AutoCislovaniPoziceKV,121)
when N'Proc_ztrat' then convert(nvarchar(max),D.Proc_ztrat,121)
when N'TypPlanovaciDoby' then convert(nvarchar(max),D.TypPlanovaciDoby,121)
when N'Prub_doba' then convert(nvarchar(max),D.Prub_doba,121)
when N'DobaMeziPrikazy' then convert(nvarchar(max),D.DobaMeziPrikazy,121)
when N'VychoziStavBlokaceVyroby' then convert(nvarchar(max),D.VychoziStavBlokaceVyroby,121)
when N'ZdrojTarifuProMzdy_Nor' then convert(nvarchar(max),D.ZdrojTarifuProMzdy_Nor,121)
when N'ZdrojTarifuProMzdy_Cas' then convert(nvarchar(max),D.ZdrojTarifuProMzdy_Cas,121)
when N'MzdovaSlozUkolMzd' then convert(nvarchar(max),D.MzdovaSlozUkolMzd,121)
when N'MzdovaSlozUhradZmet' then convert(nvarchar(max),D.MzdovaSlozUhradZmet,121)
                             end
                 ,NewHodnota=case LA.SysNazevAtribut 
when N'Davka' then convert(nvarchar(max),I.Davka,121)
when N'Davka_TEC' then convert(nvarchar(max),I.Davka_TEC,121)
when N'AplikovatKVOPouzeNaTAC' then convert(nvarchar(max),I.AplikovatKVOPouzeNaTAC,121)
when N'Tarif' then convert(nvarchar(max),I.Tarif,121)
when N'ZarovnaniOperaceTechPos' then convert(nvarchar(max),I.ZarovnaniOperaceTechPos,121)
when N'PoziceZaokrPriPrepoctuCasuTechPos' then convert(nvarchar(max),I.PoziceZaokrPriPrepoctuCasuTechPos,121)
when N'MaxVnoreni' then convert(nvarchar(max),I.MaxVnoreni,121)
when N'DelkaPoziceKV' then convert(nvarchar(max),I.DelkaPoziceKV,121)
when N'ZarovnaniPoziceKV' then convert(nvarchar(max),I.ZarovnaniPoziceKV,121)
when N'AutoCislovaniPoziceKV' then convert(nvarchar(max),I.AutoCislovaniPoziceKV,121)
when N'Proc_ztrat' then convert(nvarchar(max),I.Proc_ztrat,121)
when N'TypPlanovaciDoby' then convert(nvarchar(max),I.TypPlanovaciDoby,121)
when N'Prub_doba' then convert(nvarchar(max),I.Prub_doba,121)
when N'DobaMeziPrikazy' then convert(nvarchar(max),I.DobaMeziPrikazy,121)
when N'VychoziStavBlokaceVyroby' then convert(nvarchar(max),I.VychoziStavBlokaceVyroby,121)
when N'ZdrojTarifuProMzdy_Nor' then convert(nvarchar(max),I.ZdrojTarifuProMzdy_Nor,121)
when N'ZdrojTarifuProMzdy_Cas' then convert(nvarchar(max),I.ZdrojTarifuProMzdy_Cas,121)
when N'MzdovaSlozUkolMzd' then convert(nvarchar(max),I.MzdovaSlozUkolMzd,121)
when N'MzdovaSlozUhradZmet' then convert(nvarchar(max),I.MzdovaSlozUhradZmet,121)
                             end
             from inserted I
             inner join deleted D on D.ID=I.ID
             inner join GTabLogovaneAtributy LA on LA.sysNazevTabulka=N'TabHGlob' and LA.LogUpdate=1)v
      where isnull(v.oldHodnota,N'')<>isnull(v.newHodnota,N'')
GO

ALTER TABLE [dbo].[TabHGlob] ENABLE TRIGGER [et_TabHGlob_plgLogZmen]
GO

