USE [RayService]
GO

/****** Object:  StoredProcedure [dbo].[hpx_Balikobot_VratKontaktDleDruhu]    Script Date: 26.06.2025 15:05:37 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

/*rpBalikobot.Export*/CREATE PROC [dbo].[hpx_Balikobot_VratKontaktDleDruhu]
@IDCisKOs_MU_B INT,
@IDCisKOs_OD_B INT,
@IDCisKOs_MU_P INT,
@IDCisKOs_OD_P INT,
@IDVztahOrgKOs_MU_B INT,
@IDVztahOrgKOs_MU_P INT,
@IDVztahOrgKOs_OD_B INT,
@IDVztahOrgKOs_OD_P INT,
@IdMistoUrceni INT,
@IdOdberatel INT,
@Druh SMALLINT,
@Spojeni NVARCHAR(255) OUT
AS
SET @Spojeni=(SELECT TOP 1 K.Spojeni
FROM TabKontakty K
LEFT OUTER JOIN TabKontakty_EXT KE ON KE.ID=K.ID
WHERE K.IDVztahKOsOrg IS NULL
AND   K.IDCisKOs=@IDCisKOs_MU_B
AND   ISNULL(KE._Balikobot_Prednastaveno, 0)=1
AND   K.Druh=@Druh
)
IF (@Spojeni IS NULL)AND(@Druh=2)
SET @Spojeni=(SELECT TOP 1 K.Spojeni
FROM TabKontakty K
LEFT OUTER JOIN TabKontakty_EXT KE ON KE.ID=K.ID
WHERE K.IDVztahKOsOrg IS NULL
AND   K.IDCisKOs=@IDCisKOs_MU_B
AND   ISNULL(KE._Balikobot_Prednastaveno, 0)=1
AND   K.Druh=1
)
IF @Spojeni IS NULL
SET @Spojeni=(SELECT TOP 1 K.Spojeni
FROM TabKontakty K
LEFT OUTER JOIN TabKontakty_EXT KE ON KE.ID=K.ID
WHERE K.IDVztahKOsOrg=@IDVztahOrgKOs_MU_B
AND   ISNULL(KE._Balikobot_Prednastaveno, 0)=1
AND   K.Druh=@Druh
)
IF (@Spojeni IS NULL)AND(@Druh=2)
SET @Spojeni=(SELECT TOP 1 K.Spojeni
FROM TabKontakty K
LEFT OUTER JOIN TabKontakty_EXT KE ON KE.ID=K.ID
WHERE K.IDVztahKOsOrg=@IDVztahOrgKOs_MU_B
AND   ISNULL(KE._Balikobot_Prednastaveno, 0)=1
AND   K.Druh=1
)
IF @Spojeni IS NULL
SET @Spojeni=(SELECT TOP 1 K.Spojeni
FROM TabKontakty K
LEFT OUTER JOIN TabKontakty_EXT KE ON KE.ID=K.ID
WHERE K.IDVztahKOsOrg IS NULL
AND K.IdOrg=@IdMistoUrceni
AND   ISNULL(KE._Balikobot_Prednastaveno, 0)=1
AND   K.Druh=@Druh
)
IF (@Spojeni IS NULL)AND(@Druh=2)
SET @Spojeni=(SELECT TOP 1 K.Spojeni
FROM TabKontakty K
LEFT OUTER JOIN TabKontakty_EXT KE ON KE.ID=K.ID
WHERE K.IDVztahKOsOrg IS NULL
AND K.IdOrg=@IdMistoUrceni
AND   ISNULL(KE._Balikobot_Prednastaveno, 0)=1
AND   K.Druh=1
)
IF @Spojeni IS NULL
SET @Spojeni=(SELECT TOP 1 K.Spojeni
FROM TabKontakty K
WHERE K.IDVztahKOsOrg IS NULL
AND   K.IDCisKOs=@IDCisKOs_MU_P
AND   K.Prednastaveno=1
AND   K.Druh=@Druh
)
IF (@Spojeni IS NULL)AND(@Druh=2)
SET @Spojeni=(SELECT TOP 1 K.Spojeni
FROM TabKontakty K
WHERE K.IDVztahKOsOrg IS NULL
AND   K.IDCisKOs=@IDCisKOs_MU_P
AND   K.Prednastaveno=1
AND   K.Druh=1
)
IF @Spojeni IS NULL
SET @Spojeni=(SELECT TOP 1 K.Spojeni
FROM TabKontakty K
WHERE K.IDVztahKOsOrg=@IDVztahOrgKOs_MU_P
AND   K.Prednastaveno=1
AND   K.Druh=@Druh
)
IF (@Spojeni IS NULL)AND(@Druh=2)
SET @Spojeni=(SELECT TOP 1 K.Spojeni
FROM TabKontakty K
WHERE K.IDVztahKOsOrg=@IDVztahOrgKOs_MU_P
AND   K.Prednastaveno=1
AND   K.Druh=1
)
IF @Spojeni IS NULL
SET @Spojeni=(SELECT TOP 1 K.Spojeni
FROM TabKontakty K
LEFT OUTER JOIN TabKontakty_EXT KE ON KE.ID=K.ID
WHERE K.IDVztahKOsOrg IS NULL
AND K.IdOrg=@IdMistoUrceni
AND   K.Prednastaveno=1
AND   K.Druh=@Druh
)
IF (@Spojeni IS NULL)AND(@Druh=2)
SET @Spojeni=(SELECT TOP 1 K.Spojeni
FROM TabKontakty K
LEFT OUTER JOIN TabKontakty_EXT KE ON KE.ID=K.ID
WHERE K.IDVztahKOsOrg IS NULL
AND K.IdOrg=@IdMistoUrceni
AND   K.Prednastaveno=1
AND   K.Druh=1
)
IF @Spojeni IS NULL
SET @Spojeni=(SELECT TOP 1 K.Spojeni
FROM TabKontakty K
LEFT OUTER JOIN TabKontakty_EXT KE ON KE.ID=K.ID
WHERE K.IDVztahKOsOrg IS NULL
AND   K.IDCisKOs=@IDCisKOs_OD_B
AND   ISNULL(KE._Balikobot_Prednastaveno, 0)=1
AND   K.Druh=@Druh
)
IF (@Spojeni IS NULL)AND(@Druh=2)
SET @Spojeni=(SELECT TOP 1 K.Spojeni
FROM TabKontakty K
LEFT OUTER JOIN TabKontakty_EXT KE ON KE.ID=K.ID
WHERE K.IDVztahKOsOrg IS NULL
AND   K.IDCisKOs=@IDCisKOs_OD_B
AND   ISNULL(KE._Balikobot_Prednastaveno, 0)=1
AND   K.Druh=1
)
IF @Spojeni IS NULL
SET @Spojeni=(SELECT TOP 1 K.Spojeni
FROM TabKontakty K
LEFT OUTER JOIN TabKontakty_EXT KE ON KE.ID=K.ID
WHERE K.IDVztahKOsOrg=@IDVztahOrgKOs_OD_B
AND   ISNULL(KE._Balikobot_Prednastaveno, 0)=1
AND   K.Druh=@Druh
)
IF (@Spojeni IS NULL)AND(@Druh=2)
SET @Spojeni=(SELECT TOP 1 K.Spojeni
FROM TabKontakty K
LEFT OUTER JOIN TabKontakty_EXT KE ON KE.ID=K.ID
WHERE K.IDVztahKOsOrg=@IDVztahOrgKOs_OD_B
AND   ISNULL(KE._Balikobot_Prednastaveno, 0)=1
AND   K.Druh=1
)
IF @Spojeni IS NULL
SET @Spojeni=(SELECT TOP 1 K.Spojeni
FROM TabKontakty K
LEFT OUTER JOIN TabKontakty_EXT KE ON KE.ID=K.ID
WHERE K.IDVztahKOsOrg IS NULL
AND K.IdOrg=@IdOdberatel
AND   ISNULL(KE._Balikobot_Prednastaveno, 0)=1
AND   K.Druh=@Druh
)
IF (@Spojeni IS NULL)AND(@Druh=2)
SET @Spojeni=(SELECT TOP 1 K.Spojeni
FROM TabKontakty K
LEFT OUTER JOIN TabKontakty_EXT KE ON KE.ID=K.ID
WHERE K.IDVztahKOsOrg IS NULL
AND K.IdOrg=@IdOdberatel
AND   ISNULL(KE._Balikobot_Prednastaveno, 0)=1
AND   K.Druh=1
)
IF @Spojeni IS NULL
SET @Spojeni=(SELECT TOP 1 K.Spojeni
FROM TabKontakty K
WHERE K.IDVztahKOsOrg IS NULL
AND   K.IDCisKOs=@IDCisKOs_OD_P
AND   K.Prednastaveno=1
AND   K.Druh=@Druh
)
IF (@Spojeni IS NULL)AND(@Druh=2)
SET @Spojeni=(SELECT TOP 1 K.Spojeni
FROM TabKontakty K
WHERE K.IDVztahKOsOrg IS NULL
AND   K.IDCisKOs=@IDCisKOs_OD_P
AND   K.Prednastaveno=1
AND   K.Druh=1
)
IF @Spojeni IS NULL
SET @Spojeni=(SELECT TOP 1 K.Spojeni
FROM TabKontakty K
WHERE K.IDVztahKOsOrg=@IDVztahOrgKOs_OD_P
AND   K.Prednastaveno=1
AND   K.Druh=@Druh
)
IF (@Spojeni IS NULL)AND(@Druh=2)
SET @Spojeni=(SELECT TOP 1 K.Spojeni
FROM TabKontakty K
WHERE K.IDVztahKOsOrg=@IDVztahOrgKOs_OD_P
AND   K.Prednastaveno=1
AND   K.Druh=1
)
IF @Spojeni IS NULL
SET @Spojeni=(SELECT TOP 1 K.Spojeni
FROM TabKontakty K
LEFT OUTER JOIN TabKontakty_EXT KE ON KE.ID=K.ID
WHERE K.IDVztahKOsOrg IS NULL
AND K.IdOrg=@IdOdberatel
AND   K.Prednastaveno=1
AND   K.Druh=@Druh
)
IF (@Spojeni IS NULL)AND(@Druh=2)
SET @Spojeni=(SELECT TOP 1 K.Spojeni
FROM TabKontakty K
LEFT OUTER JOIN TabKontakty_EXT KE ON KE.ID=K.ID
WHERE K.IDVztahKOsOrg IS NULL
AND K.IdOrg=@IdOdberatel
AND   K.Prednastaveno=1
AND   K.Druh=1
)
GO

