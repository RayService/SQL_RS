USE [HCvicna]
GO

/****** Object:  Trigger [dbo].[et_TabPlan_LOG]    Script Date: 02.07.2025 15:43:39 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO


CREATE TRIGGER [dbo].[et_TabPlan_LOG] ON [dbo].[TabPlan] FOR UPDATE
AS
IF @@ROWCOUNT = 0 RETURN;
SET NOCOUNT ON;
-- =============================================
-- Author:		JDO
-- Description:	Logovani zmen udaju v tabulce
-- =============================================

-- * Změna TabPlan.StavPrevodu na X - datum zaplánování (TabPlan_EXT._DatumZaplanovani)
IF (UPDATE(Uzavreno) OR UPDATE(mnozPrev))
	AND EXISTS(SELECT * FROM inserted WHERE StavPrevodu = N'X')
	MERGE TabPlan_EXT ET
	USING inserted V ON ET.ID = V.ID
	WHEN MATCHED THEN
	   UPDATE SET _DatumZaplanovani = GETDATE()
	WHEN NOT MATCHED BY TARGET THEN
	   INSERT (ID, _DatumZaplanovani)
	   VALUES (V.ID,GETDATE());
GO

ALTER TABLE [dbo].[TabPlan] ENABLE TRIGGER [et_TabPlan_LOG]
GO

