USE [RayService]
GO

/****** Object:  StoredProcedure [dbo].[hpx_RS_vypocet_poradi_form1_VCprijem]    Script Date: 26.06.2025 11:30:34 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

CREATE PROCEDURE [dbo].[hpx_RS_vypocet_poradi_form1_VCprijem] @ID INT

AS
DECLARE @EASANew NVARCHAR(15)
SET @EASANew=(SELECT CONCAT('RS ', YEAR(GETDATE()), '/', RIGHT('000' + CONVERT(VARCHAR(3), CAST(SUBSTRING(
          ISNULL(MAX(_EXT_poradovecisloEASA), '0/0'),
          CHARINDEX('/', ISNULL(MAX(_EXT_poradovecisloEASA), '0/0')) + 1,
          LEN(ISNULL(MAX(_EXT_poradovecisloEASA), '0/0')) - 1
        ) AS INT) + 1), 3))
        FROM TabVyrCP_EXT vcpe1 WITH(NOLOCK)
		LEFT OUTER JOIN TabVyrCP vcp1 WITH(NOLOCK) ON vcp1.ID=vcpe1.ID
		INNER JOIN TabPohybyZbozi tp WITH(NOLOCK) ON tp.ID = vcp1.IDPolozkaDokladu
        WHERE YEAR(tp.DatPorizeni) = YEAR(GETDATE()))

BEGIN TRANSACTION;

UPDATE vcpe SET vcpe._EXT_poradovecisloEASA = @EASANew
      FROM TabVyrCP_EXT vcpe WITH(NOLOCK)
	  LEFT OUTER JOIN TabVyrCP vcp WITH(NOLOCK) ON vcp.ID=vcpe.ID
	  INNER JOIN TabPohybyZbozi tpz WITH(NOLOCK) ON tpz.ID = vcp.IDPolozkaDokladu
	  LEFT OUTER JOIN TabPohybyZbozi_EXT tpze WITH(NOLOCK) ON tpze.ID = tpz.ID
      INNER JOIN TabDokladyZbozi tdz WITH(NOLOCK) ON tdz.ID = tpz.IDDoklad
      WHERE vcp.ID = @ID AND (vcpe._EXT_poradovecisloEASA IS NULL OR vcpe._EXT_poradovecisloEASA = '') AND tdz.DruhPohybuZbo IN (0,1)
IF @@ROWCOUNT = 0
BEGIN
  INSERT TabVyrCP_EXT (ID, _EXT_poradovecisloEASA) VALUES(@ID, @EASANew);
END
COMMIT TRANSACTION;
GO

