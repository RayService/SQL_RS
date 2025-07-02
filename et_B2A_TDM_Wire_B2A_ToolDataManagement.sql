USE [HCvicna]
GO

/****** Object:  Trigger [dbo].[et_B2A_TDM_Wire_B2A_ToolDataManagement]    Script Date: 02.07.2025 12:56:31 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

/*rpB2Atooldatamanagement.rpB2Atooldatamanagement*/CREATE TRIGGER [dbo].[et_B2A_TDM_Wire_B2A_ToolDataManagement] ON [dbo].[B2A_TDM_Wire] FOR update as
begin
  declare @IDSetting int
  declare cursor_setting cursor for
    select distinct IDSetting
    from B2A_TDM_Setting_Wire
    where IDWire in (select ID from inserted)
  open cursor_setting
  fetch next from cursor_setting into @IDSetting
  while @@FETCH_STATUS = 0
  begin
    exec UP_B2A_ToolDataManagement_UpdateSettingCode @IDSetting
    fetch next from cursor_setting into @IDSetting
  end
  close cursor_setting
  deallocate cursor_setting
end
GO

ALTER TABLE [dbo].[B2A_TDM_Wire] ENABLE TRIGGER [et_B2A_TDM_Wire_B2A_ToolDataManagement]
GO

