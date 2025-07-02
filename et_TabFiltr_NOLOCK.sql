USE [HCvicna]
GO

/****** Object:  Trigger [dbo].[et_TabFiltr_NOLOCK]    Script Date: 02.07.2025 15:07:35 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO


CREATE TRIGGER [dbo].[et_TabFiltr_NOLOCK] ON [dbo].[TabFiltr] FOR INSERT
AS
IF @@ROWCOUNT = 0 RETURN;
SET XACT_ABORT, NOCOUNT ON;
-- =============================================
-- Author: Jiri Dolezal (JiriDolezalSQL@gmail.com)
-- Description:	Defaultni zapnuti spinaveho cteni
-- =============================================

UPDATE C SET	
	PovolenNOLOCK = 1
FROM dbo.TabFiltr C
	INNER JOIN inserted I ON C.ID = I.ID
WHERE I.PovolenNOLOCK = 0;
GO

ALTER TABLE [dbo].[TabFiltr] ENABLE TRIGGER [et_TabFiltr_NOLOCK]
GO

