USE [HCvicna]
GO

/****** Object:  Trigger [dbo].[et_RAY_Parametry_Values_plgLogZmen]    Script Date: 03.07.2025 9:30:00 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

/*PlugGatemaLogovaniZmen.PlugGatemaLogovaniZmenRun*/create trigger [dbo].[et_RAY_Parametry_Values_plgLogZmen] on [dbo].[RAY_Parametry_Values] for update
as
set nocount on 
declare @existsInserted bit, @existsDeleted bit
if exists(select * from inserted) set @existsInserted=1 else set @existsInserted=0 
if exists(select * from deleted) set @existsDeleted=1 else set @existsDeleted=0 
if @existsInserted=0 and @existsDeleted=0 return
if @existsInserted=1 and @existsDeleted=1
 if
 update(Result_koef_uziv)
or update(Result_koef_calc)
  insert into GTabLogovaneInformace(SysNazevTabulka,SysNazevAtribut,IDZaznam,OldHodnota,NewHodnota,Akce)
    select v.SysNazevTabulka,v.SysNazevAtribut,v.IDZaznam,left(v.OldHodnota,255),left(v.NewHodnota,255),1
      from(select SysNazevTabulka=N'RAY_Parametry_Values',SysNazevAtribut=LA.SysNazevAtribut,IDZaznam=D.ID
                 ,OldHodnota=case LA.SysNazevAtribut 
when N'Result_koef_uziv' then convert(nvarchar(max),D.Result_koef_uziv,121)
when N'Result_koef_calc' then convert(nvarchar(max),D.Result_koef_calc,121)
                             end
                 ,NewHodnota=case LA.SysNazevAtribut 
when N'Result_koef_uziv' then convert(nvarchar(max),I.Result_koef_uziv,121)
when N'Result_koef_calc' then convert(nvarchar(max),I.Result_koef_calc,121)
                             end
             from inserted I
             inner join deleted D on D.ID=I.ID
             inner join GTabLogovaneAtributy LA on LA.sysNazevTabulka=N'RAY_Parametry_Values' and LA.LogUpdate=1)v
      where isnull(v.oldHodnota,N'')<>isnull(v.newHodnota,N'')
GO

ALTER TABLE [dbo].[RAY_Parametry_Values] ENABLE TRIGGER [et_RAY_Parametry_Values_plgLogZmen]
GO

