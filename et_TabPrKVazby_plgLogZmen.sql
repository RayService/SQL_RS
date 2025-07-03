USE [HCvicna]
GO

/****** Object:  Trigger [dbo].[et_TabPrKVazby_plgLogZmen]    Script Date: 03.07.2025 7:58:11 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

/*PlugGatemaLogovaniZmen.PlugGatemaLogovaniZmenRun*/create trigger [dbo].[et_TabPrKVazby_plgLogZmen] on [dbo].[TabPrKVazby] for update,delete
as
set nocount on 
declare @existsInserted bit, @existsDeleted bit
if exists(select * from inserted) set @existsInserted=1 else set @existsInserted=0 
if exists(select * from deleted) set @existsDeleted=1 else set @existsDeleted=0 
if @existsInserted=0 and @existsDeleted=0 return
if @existsInserted=1 and @existsDeleted=1
 if
 update(Sklad)
  insert into GTabLogovaneInformace(SysNazevTabulka,SysNazevAtribut,IDZaznam,OldHodnota,NewHodnota,Akce)
    select v.SysNazevTabulka,v.SysNazevAtribut,v.IDZaznam,left(v.OldHodnota,255),left(v.NewHodnota,255),1
      from(select SysNazevTabulka=N'TabPrKVazby',SysNazevAtribut=LA.SysNazevAtribut,IDZaznam=D.ID
                 ,OldHodnota=case LA.SysNazevAtribut 
when N'Sklad' then convert(nvarchar(max),D.Sklad,121)
                             end
                 ,NewHodnota=case LA.SysNazevAtribut 
when N'Sklad' then convert(nvarchar(max),I.Sklad,121)
                             end
             from inserted I
             inner join deleted D on D.ID=I.ID
             inner join GTabLogovaneAtributy LA on LA.sysNazevTabulka=N'TabPrKVazby' and LA.LogUpdate=1)v
      where isnull(v.oldHodnota,N'')<>isnull(v.newHodnota,N'') 
if @existsInserted=0
  insert into GTabLogovaneInformace(SysNazevTabulka,SysNazevAtribut,IDZaznam,OldHodnota,NewHodnota,Akce) 
    select N'TabPrKVazby',LA.SysNazevAtribut,D.ID
          ,left(case LA.SysNazevAtribut 
when N'Sklad' then convert(nvarchar(max),D.Sklad,121)
                end,255),null,2
      from deleted D
      inner join GTabLogovaneAtributy LA on LA.sysNazevTabulka=N'TabPrKVazby' and LA.LogDelete=1
GO

ALTER TABLE [dbo].[TabPrKVazby] ENABLE TRIGGER [et_TabPrKVazby_plgLogZmen]
GO

