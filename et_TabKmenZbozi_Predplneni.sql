USE [HCvicna]
GO

/****** Object:  Trigger [dbo].[et_TabKmenZbozi_Predplneni]    Script Date: 02.07.2025 15:17:32 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO


CREATE TRIGGER [dbo].[et_TabKmenZbozi_Predplneni] ON [dbo].[TabKmenZbozi] FOR INSERT AS
IF @@ROWCOUNT = 0 RETURN
SET NOCOUNT ON

-- PZE 11.1.2017 - pro predplneni ext. atributu - viz trigger et_TabKmenZbozi_EXT_Predplneni
INSERT INTO TabKmenZbozi_EXT (ID) SELECT ID FROM inserted WHERE Dilec=1 AND ID NOT IN (SELECT ID FROM TabKmenZbozi_EXT)

-- MŽ 18.5.2022 - vložení CZ do obvyklé země původu
UPDATE tkz SET tkz.ObvyklaZemePuvodu=N'CZ'
FROM TabKmenZbozi tkz
WHERE ID IN (SELECT ID FROM inserted) AND tkz.SkupZbo LIKE '8%'
GO

ALTER TABLE [dbo].[TabKmenZbozi] ENABLE TRIGGER [et_TabKmenZbozi_Predplneni]
GO

