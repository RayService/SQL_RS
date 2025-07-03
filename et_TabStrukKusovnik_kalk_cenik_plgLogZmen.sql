USE [HCvicna]
GO

/****** Object:  Trigger [dbo].[et_TabStrukKusovnik_kalk_cenik_plgLogZmen]    Script Date: 03.07.2025 8:12:45 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

/*PlugGatemaLogovaniZmen.PlugGatemaLogovaniZmenRun*/create trigger [dbo].[et_TabStrukKusovnik_kalk_cenik_plgLogZmen] on [dbo].[TabStrukKusovnik_kalk_cenik] for update
as
set nocount on 
declare @existsInserted bit, @existsDeleted bit
if exists(select * from inserted) set @existsInserted=1 else set @existsInserted=0 
if exists(select * from deleted) set @existsDeleted=1 else set @existsDeleted=0 
if @existsInserted=0 and @existsDeleted=0 return
if @existsInserted=1 and @existsDeleted=1
 if
 update(Dokl_poptLT)
or update(Dokl_poptMOQ)
  insert into GTabLogovaneInformace(SysNazevTabulka,SysNazevAtribut,IDZaznam,OldHodnota,NewHodnota,Akce)
    select v.SysNazevTabulka,v.SysNazevAtribut,v.IDZaznam,left(v.OldHodnota,255),left(v.NewHodnota,255),1
      from(select SysNazevTabulka=N'TabStrukKusovnik_kalk_cenik',SysNazevAtribut=LA.SysNazevAtribut,IDZaznam=D.ID
                 ,OldHodnota=case LA.SysNazevAtribut 
when N'Dokl_poptLT' then convert(nvarchar(max),D.Dokl_poptLT,121)
when N'Dokl_poptMOQ' then convert(nvarchar(max),D.Dokl_poptMOQ,121)
                             end
                 ,NewHodnota=case LA.SysNazevAtribut 
when N'Dokl_poptLT' then convert(nvarchar(max),I.Dokl_poptLT,121)
when N'Dokl_poptMOQ' then convert(nvarchar(max),I.Dokl_poptMOQ,121)
                             end
             from inserted I
             inner join deleted D on D.ID=I.ID
             inner join GTabLogovaneAtributy LA on LA.sysNazevTabulka=N'TabStrukKusovnik_kalk_cenik' and LA.LogUpdate=1)v
      where isnull(v.oldHodnota,N'')<>isnull(v.newHodnota,N'')
GO

ALTER TABLE [dbo].[TabStrukKusovnik_kalk_cenik] ENABLE TRIGGER [et_TabStrukKusovnik_kalk_cenik_plgLogZmen]
GO

