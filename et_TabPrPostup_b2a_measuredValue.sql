USE [HCvicna]
GO

/****** Object:  Trigger [dbo].[et_TabPrPostup_b2a_measuredValue]    Script Date: 03.07.2025 8:01:25 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

/*rpB2Ameasuredvalues.rpB2Ameasuredvalues*/CREATE TRIGGER [dbo].[et_TabPrPostup_b2a_measuredValue] ON [dbo].[TabPrPostup] FOR insert, delete
as
begin
if exists(select * from inserted where IDOdchylkyOd is null)
begin
declare @newDefId int, @IDKmenZbozi int, @Operace nchar(4), @Alt nchar(1), @Doklad int, @IDPrikaz int, @IDDefinition int
declare cursor_operation cursor for
select Doklad,Alt,IDPrikaz,Operace,dilec from inserted where IDOdchylkyOd is null
open cursor_operation
fetch next from cursor_operation into @Doklad,@Alt,@IDPrikaz,@Operace,@IDKmenZbozi
while @@FETCH_STATUS = 0
begin
declare cursor_operation_pdm cursor for
select t1.ID
from B2A_MeasuredValueDefinition t1
join B2A_MeasuredValueDefinition_PdmOperation t2 on t1.IDRoot=t2.IDDefinition
join TabPostup t3 on t2.IDPdm=t3.dilec and t2.Operation=t3.Operace and t3.ZmenaDo is null
join TabCzmeny t4 on t1.ErpChangeFrom=t4.ID and t4.Platnost=1
left join TabCzmeny t5 on t1.ErpChangeTo=t5.ID
where t3.dilec=@IDKmenZbozi and t3.Operace=@Operace
 and ((t4.PermanentniZmena=1 and t1.ChangeTo is null) or (t4.PermanentniZmena=0 and (t5.Platnost is null or t5.Platnost=0)))
open cursor_operation_pdm
fetch next from cursor_operation_pdm into @IDDefinition
while @@FETCH_STATUS = 0
begin
exec up_b2a_measuredValue_duplicateDefinition @IDDefinition, @newId = @newDefId output
insert into B2A_MeasuredValueDefinition_ProductionOrderOperation ([Alt],[DocNum],[IDDefinition],[IDProductionOrder],[IDDefinitionSource])
select @Alt,@Doklad,@newDefId,@IDPrikaz,@IDDefinition
fetch next from cursor_operation_pdm into @IDDefinition
end
close cursor_operation_pdm
deallocate cursor_operation_pdm
fetch next from cursor_operation into @Doklad,@Alt,@IDPrikaz,@Operace,@IDKmenZbozi
end
close cursor_operation
deallocate cursor_operation
end
else if exists(select * from deleted where IDOdchylkyOd is null)
begin
update B2A_MeasuredValueDefinition set ChangeTo=isnull(ChangeFrom,0)+1
where IDRoot in (
select t2.IDDefinition
from deleted t1
join B2A_MeasuredValueDefinition_ProductionOrderOperation t2 on t1.IDPrikaz=t2.IDProductionOrder and t1.Doklad=t2.DocNum and t1.Alt=t2.Alt
where t1.IDOdchylkyOd is null)
end
end
GO

ALTER TABLE [dbo].[TabPrPostup] ENABLE TRIGGER [et_TabPrPostup_b2a_measuredValue]
GO

