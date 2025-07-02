USE [HCvicna]
GO

/****** Object:  Trigger [dbo].[et_TabPersZnalostiCis_PERS]    Script Date: 02.07.2025 15:32:35 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO


CREATE TRIGGER [dbo].[et_TabPersZnalostiCis_PERS] ON [dbo].[TabPersZnalostiCis] FOR DELETE
AS
-- =============================================
-- Author:		JDO
-- Description:	Ošetření generování dovedností
-- =============================================
SET NOCOUNT ON;
DELETE C
FROM Tabx_RayService_PersZnalostiCisGen C
	INNER JOIN deleted D ON C.IDPersZnalostiCis = D.ID
WHERE C.Typ = 1;
GO

ALTER TABLE [dbo].[TabPersZnalostiCis] ENABLE TRIGGER [et_TabPersZnalostiCis_PERS]
GO

