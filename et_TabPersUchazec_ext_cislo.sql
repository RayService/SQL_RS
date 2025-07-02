USE [HCvicna]
GO

/****** Object:  Trigger [dbo].[et_TabPersUchazec_ext_cislo]    Script Date: 02.07.2025 15:31:43 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

CREATE TRIGGER [dbo].[et_TabPersUchazec_ext_cislo] ON [dbo].[TabPersUchazec] AFTER INSERT
  AS
    BEGIN
      SET NOCOUNT ON;
      UPDATE TabPersUchazec SET ExterniCislo = (SELECT CONCAT(YEAR(GETDATE()), RIGHT('0000' + CAST(1 + SUBSTRING(MAX(ExterniCislo), 5, 4) AS VARCHAR(4)), 4)) FROM TabPersUchazec)
      FROM TabPersUchazec P
      INNER JOIN INSERTED I ON I.ID = P.ID;
      END
GO

ALTER TABLE [dbo].[TabPersUchazec] ENABLE TRIGGER [et_TabPersUchazec_ext_cislo]
GO

