USE [HCvicna]
GO

/****** Object:  Trigger [dbo].[et_TabPersZnalostiOblastCis_PERS]    Script Date: 02.07.2025 15:38:10 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO


CREATE TRIGGER [dbo].[et_TabPersZnalostiOblastCis_PERS] ON [dbo].[TabPersZnalostiOblastCis] FOR DELETE
AS
-- =============================================
-- Author:		JDO
-- Description:	Ošetření generování dovedností
-- =============================================
SET NOCOUNT ON;
DELETE C
FROM Tabx_RayService_PersZnalostiCisGen C
	INNER JOIN deleted D ON C.IDPersZnalostiCis = D.ID
WHERE Typ = 2;
GO

ALTER TABLE [dbo].[TabPersZnalostiOblastCis] ENABLE TRIGGER [et_TabPersZnalostiOblastCis_PERS]
GO

