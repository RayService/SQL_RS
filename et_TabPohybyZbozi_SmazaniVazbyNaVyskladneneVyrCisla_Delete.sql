USE [HCvicna]
GO

/****** Object:  Trigger [dbo].[et_TabPohybyZbozi_SmazaniVazbyNaVyskladneneVyrCisla_Delete]    Script Date: 02.07.2025 15:58:32 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

/*PlugGatemaSDMaterial.plgSDMater*/CREATE TRIGGER [dbo].[et_TabPohybyZbozi_SmazaniVazbyNaVyskladneneVyrCisla_Delete] ON [dbo].[TabPohybyZbozi] FOR DELETE 
AS 
SET NOCOUNT ON 
IF EXISTS (SELECT 1 
             FROM dbo.Tab_SDMater_VyrCislaKVyskladneni 
             WHERE IDPohybyZbozi in (Select ID From DELETED) 
           )
  Delete dbo.Tab_SDMater_VyrCislaKVyskladneni Where IDPohybyZbozi in (Select ID From DELETED)
GO

ALTER TABLE [dbo].[TabPohybyZbozi] ENABLE TRIGGER [et_TabPohybyZbozi_SmazaniVazbyNaVyskladneneVyrCisla_Delete]
GO

