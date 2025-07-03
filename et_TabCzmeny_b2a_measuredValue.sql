USE [HCvicna]
GO

/****** Object:  Trigger [dbo].[et_TabCzmeny_b2a_measuredValue]    Script Date: 03.07.2025 9:54:35 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

/*rpB2Ameasuredvalues.rpB2Ameasuredvalues*/CREATE TRIGGER [dbo].[et_TabCzmeny_b2a_measuredValue] ON [dbo].[TabCzmeny] FOR delete
as
begin
update B2A_MeasuredValueDefinition set ErpChangeTo = NULL
where ErpChangeTo in (select ID from deleted)
end
GO

ALTER TABLE [dbo].[TabCzmeny] ENABLE TRIGGER [et_TabCzmeny_b2a_measuredValue]
GO

