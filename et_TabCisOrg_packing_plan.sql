USE [HCvicna]
GO

/****** Object:  Trigger [dbo].[et_TabCisOrg_packing_plan]    Script Date: 03.07.2025 9:52:05 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

CREATE TRIGGER [dbo].[et_TabCisOrg_packing_plan] ON [dbo].[TabCisOrg]
AFTER INSERT
AS

IF @@ROWCOUNT = 0 RETURN
SET NOCOUNT ON

-- =============================================
-- Author:	 MŽ
-- Create date: 01.11.2019
-- Description: automaticky po založení organizace vyplní pole _EXT_RS_packing_plan hodnotou S10-TD46
-- =============================================
BEGIN

INSERT INTO TabCisOrg_EXT (ID) SELECT ID FROM inserted WHERE ID NOT IN (SELECT ID FROM TabCisOrg_EXT)
END;
BEGIN
UPDATE TabCisOrg_EXT SET _EXT_RS_packing_plan='S10-TD46' 
FROM TabCisOrg_EXT tcoe INNER JOIN TabCisOrg tco ON tcoe.ID=tco.ID INNER JOIN inserted I ON tco.ID=I.ID
END;
GO

ALTER TABLE [dbo].[TabCisOrg] ENABLE TRIGGER [et_TabCisOrg_packing_plan]
GO

