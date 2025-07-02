USE [HCvicna]
GO

/****** Object:  Trigger [dbo].[et_TabPracovniPozice_PERS]    Script Date: 02.07.2025 16:06:22 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO


CREATE TRIGGER [dbo].[et_TabPracovniPozice_PERS] ON [dbo].[TabPracovniPozice] FOR DELETE
AS
-- =============================================
-- Author:		JDO
-- Description:	Osetreni matice zodpovednosti
-- =============================================
IF @@ROWCOUNT = 0 RETURN;
SET NOCOUNT ON;
DELETE C
FROM Tabx_RayService_MatZodp C
	INNER JOIN deleted D ON C.IDPracovniPozice = D.ID;
GO

ALTER TABLE [dbo].[TabPracovniPozice] ENABLE TRIGGER [et_TabPracovniPozice_PERS]
GO

