USE [RayService]
GO

/****** Object:  StoredProcedure [dbo].[hpx_RS_vypocet_poradi_form1]    Script Date: 26.06.2025 10:12:50 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

CREATE PROCEDURE [dbo].[hpx_RS_vypocet_poradi_form1] @ID INT

AS

BEGIN
UPDATE TabPohybyZbozi_EXT SET _EXT_poradovecisloEASA = (
        SELECT CONCAT('RS ', YEAR(GETDATE()), '/', RIGHT('000' + CONVERT(VARCHAR(3), CAST(SUBSTRING(
          ISNULL(MAX(_EXT_poradovecisloEASA), '0/0'),
          CHARINDEX('/', ISNULL(MAX(_EXT_poradovecisloEASA), '0/0')) + 1,
          LEN(ISNULL(MAX(_EXT_poradovecisloEASA), '0/0')) - 1
        ) AS INT) + 1), 3))
        FROM TabPohybyZbozi_EXT
        INNER JOIN TabPohybyZbozi ON TabPohybyZbozi.ID = TabPohybyZbozi_EXT.ID
        WHERE YEAR(TabPohybyZbozi.DatPorizeni) = YEAR(GETDATE())
      )
      FROM TabPohybyZbozi_EXT
      INNER JOIN TabPohybyZbozi ON TabPohybyZbozi.ID = TabPohybyZbozi_EXT.ID
      INNER JOIN TabDokladyZbozi ON TabDokladyZbozi.ID = TabPohybyZbozi.IDDoklad
      INNER JOIN TabCisOrg ON TabCisOrg.CisloOrg = TabDokladyZbozi.CisloOrg
      INNER JOIN TabCisOrg_EXT ON TabCisOrg_EXT.ID = TabCisOrg.ID AND TabCisOrg_EXT._EXT_generovat_poradi = 1
      WHERE TabPohybyZbozi.ID = @ID AND (TabPohybyZbozi_EXT._EXT_poradovecisloEASA IS NULL OR TabPohybyZbozi_EXT._EXT_poradovecisloEASA = '') AND TabDokladyZbozi.DruhPohybuZbo IN (2,4)
END
GO

