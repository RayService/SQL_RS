USE [HCvicna]
GO

/****** Object:  Trigger [dbo].[et_TabPlan_update_DatumEXT]    Script Date: 02.07.2025 15:49:31 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

CREATE TRIGGER [dbo].[et_TabPlan_update_DatumEXT] ON [dbo].[TabPlan] AFTER UPDATE
  AS
    BEGIN
      SET NOCOUNT ON;
      IF UPDATE(datum)
        BEGIN

          INSERT INTO TabPlan_EXT (ID)
            SELECT ID
            FROM INSERTED
            WHERE NOT EXISTS (SELECT * FROM TabPlan_EXT WHERE ID = (SELECT ID FROM INSERTED));

          UPDATE TabPlan_EXT
            SET _EXT_DatumEX = (SELECT datum FROM DELETED)
            WHERE TabPlan_EXT.ID = (SELECT ID FROM INSERTED)
            AND TabPlan_EXT._EXT_DatumEX IS NULL;

        END
END

GO

ALTER TABLE [dbo].[TabPlan] DISABLE TRIGGER [et_TabPlan_update_DatumEXT]
GO

