USE [HCvicna]
GO

/****** Object:  Trigger [dbo].[et_TabStavSkladu_UKod115]    Script Date: 03.07.2025 8:07:42 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO


CREATE TRIGGER [dbo].[et_TabStavSkladu_UKod115] ON [dbo].[TabStavSkladu] FOR INSERT AS
IF @@ROWCOUNT = 0 RETURN
SET NOCOUNT ON
--MŽ, 13.2.2024 doplnění kódu účtování 88 na skladové karty skladu 115
UPDATE tss SET tss.UKod=88
FROM TabStavskladu tss
WHERE tss.ID IN (SELECT ID FROM inserted) AND tss.IDSklad=N'10000115' AND tss.UKod IS NULL
GO

ALTER TABLE [dbo].[TabStavSkladu] ENABLE TRIGGER [et_TabStavSkladu_UKod115]
GO

