USE [HCvicna]
GO

/****** Object:  Trigger [dbo].[et_TabPrNVazby_B2A_ToolDataManagement]    Script Date: 03.07.2025 7:59:56 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

/*rpB2Atooldatamanagement.rpB2Atooldatamanagement*/CREATE TRIGGER [dbo].[et_TabPrNVazby_B2A_ToolDataManagement] ON [dbo].[TabPrNVazby] FOR insert, delete as
begin
  if exists(select top 1 * from inserted where ID1=0)
  begin
    declare @IDProdOrder int, @IDCombination int, @IDCombinationNew int
    declare cursor_tool cursor for
    select t3.ID,t1.IDPrikaz
      from inserted t1
      join B2A_TDM_Combination_Pdm t2 on t1.Dilec=t2.IDPdm
      join B2A_TDM_Combination t3 on t2.IDCombination=t3.ID
		   join B2A_TDM_Setting t4 on t3.IDSetting=t4.ID and t1.Naradi=t4.IDTool
			 join TabCzmeny t5 on t2.ErpChangeFrom=t5.ID and t5.Platnost=1
      left join TabCzmeny t6 on t2.ErpChangeTo=t6.ID
      where t1.IDOdchylkyOd is null and ((t5.PermanentniZmena=1 and t2.ChangeTo is null) or (t5.PermanentniZmena=0 and (isnull(t6.Platnost,0)=0)))
    open cursor_tool
    fetch next from cursor_tool into @IDCombination,@IDProdOrder
    while @@FETCH_STATUS = 0
    begin
      insert into B2A_TDM_Combination_ProductionOrder(IDProductionOrder,IDCombination)
        select @IDProdOrder,@IDCombination
      fetch next from cursor_tool into @IDCombination,@IDProdOrder
    end
    update B2A_TDM_Combination_ProductionOrder set ID0=ID where ID0=0
    close cursor_tool
    deallocate cursor_tool
  end
  else if exists(select top 1 * from deleted)
  begin
    update B2A_TDM_Combination_ProductionOrder set ChangeTo=isnull(ChangeFrom,0)+1
      where ID in (
        select t2.ID
        from deleted t1
        join B2A_TDM_Combination_ProductionOrder t2 on t1.IDPrikaz=t2.IDProductionOrder and t2.ChangeTo is null
        join B2A_TDM_Combination t3 on t2.IDCombination=t3.ID
        join B2A_TDM_Setting t4 on t3.IDSetting=t4.ID and t1.Naradi=t4.IDTool
        left join TabPrNVazby t5 on t1.IDPrikaz=t5.IDPrikaz and t1.Naradi=t5.Naradi and t5.ID not in (select ID from deleted)
        where t5.ID is null
      )
  end
end
GO

ALTER TABLE [dbo].[TabPrNVazby] ENABLE TRIGGER [et_TabPrNVazby_B2A_ToolDataManagement]
GO

