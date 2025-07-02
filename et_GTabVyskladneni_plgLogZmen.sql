USE [HCvicna]
GO

/****** Object:  Trigger [dbo].[et_GTabVyskladneni_plgLogZmen]    Script Date: 02.07.2025 14:39:18 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

/*PlugGatemaLogovaniZmen.PlugGatemaLogovaniZmenRun*/create trigger [dbo].[et_GTabVyskladneni_plgLogZmen] on [dbo].[GTabVyskladneni] for update
as
set nocount on 
declare @existsInserted bit, @existsDeleted bit
if exists(select * from inserted) set @existsInserted=1 else set @existsInserted=0 
if exists(select * from deleted) set @existsDeleted=1 else set @existsDeleted=0 
if @existsInserted=0 and @existsDeleted=0 return
if @existsInserted=1 and @existsDeleted=1
 if
 update(Uzavreno)
  insert into GTabLogovaneInformace(SysNazevTabulka,SysNazevAtribut,IDZaznam,OldHodnota,NewHodnota,Akce)
    select v.SysNazevTabulka,v.SysNazevAtribut,v.IDZaznam,left(v.OldHodnota,255),left(v.NewHodnota,255),1
      from(select SysNazevTabulka=N'GTabVyskladneni',SysNazevAtribut=LA.SysNazevAtribut,IDZaznam=D.ID
                 ,OldHodnota=case LA.SysNazevAtribut 
when N'Uzavreno' then convert(nvarchar(max),D.Uzavreno,121)
                             end
                 ,NewHodnota=case LA.SysNazevAtribut 
when N'Uzavreno' then convert(nvarchar(max),I.Uzavreno,121)
                             end
             from inserted I
             inner join deleted D on D.ID=I.ID
             inner join GTabLogovaneAtributy LA on LA.sysNazevTabulka=N'GTabVyskladneni' and LA.LogUpdate=1)v
      where isnull(v.oldHodnota,N'')<>isnull(v.newHodnota,N'')
GO

ALTER TABLE [dbo].[GTabVyskladneni] ENABLE TRIGGER [et_GTabVyskladneni_plgLogZmen]
GO

