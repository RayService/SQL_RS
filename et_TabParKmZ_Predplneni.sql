USE [HCvicna]
GO

/****** Object:  Trigger [dbo].[et_TabParKmZ_Predplneni]    Script Date: 02.07.2025 15:30:37 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO


CREATE TRIGGER [dbo].[et_TabParKmZ_Predplneni] ON [dbo].[TabParKmZ] FOR INSERT AS
IF @@ROWCOUNT = 0 RETURN
SET NOCOUNT ON
	
UPDATE P SET P.TypDilce=0 FROM TabParKmZ P INNER JOIN inserted I ON I.IDKmenZbozi=P.IDKmenZbozi
 INNER JOIN TabKmenZbozi K ON P.IDKmenZbozi=K.ID WHERE K.Dilec=1
 
GO

ALTER TABLE [dbo].[TabParKmZ] ENABLE TRIGGER [et_TabParKmZ_Predplneni]
GO

