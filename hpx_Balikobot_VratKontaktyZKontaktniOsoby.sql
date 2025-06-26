USE [RayService]
GO

/****** Object:  StoredProcedure [dbo].[hpx_Balikobot_VratKontaktyZKontaktniOsoby]    Script Date: 26.06.2025 15:06:59 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

/*rpBalikobot.Export*/CREATE PROC [dbo].[hpx_Balikobot_VratKontaktyZKontaktniOsoby]
@IdVztahOrgKOs INT,
@rec_email NVARCHAR(100) OUT,
@rec_phone NVARCHAR(50) OUT
AS
SET NOCOUNT ON
DECLARE @IDCisKOs INT
SET @IDCisKOs=(SELECT IDCisKOs FROM TabVztahOrgKOs WHERE ID=@IdVztahOrgKOs)
SET @rec_email=(SELECT TOP 1 K.Spojeni
FROM TabKontakty K
LEFT OUTER JOIN  TabKontakty_EXT KE ON KE.ID=K.ID
WHERE
(K.IDCisKOs=@IDCisKOs AND K.IDVztahKOsOrg IS NULL AND KE._Balikobot_Prednastaveno=1 AND K.Druh=6)
)
IF @rec_email IS NULL
SET @rec_email=(SELECT TOP 1 K.Spojeni
FROM TabKontakty K
LEFT OUTER JOIN  TabKontakty_EXT KE ON KE.ID=K.ID
WHERE
(K.IDVztahKOsOrg=@IdVztahOrgKOs AND KE._Balikobot_Prednastaveno=1 AND K.Druh=6)
)
IF @rec_email IS NULL
SET @rec_email=(SELECT TOP 1 K.Spojeni
FROM TabKontakty K
WHERE
(K.IDCisKOs=@IDCisKOs AND K.IDVztahKOsOrg IS NULL AND K.Prednastaveno=1 AND K.Druh=6)
)
IF @rec_email IS NULL
SET @rec_email=(SELECT TOP 1 K.Spojeni
FROM TabKontakty K
WHERE
(K.IDVztahKOsOrg=@IdVztahOrgKOs AND K.Prednastaveno=1 AND K.Druh=6)
)
SET @rec_phone=(SELECT TOP 1 K.Spojeni
FROM TabKontakty K
LEFT OUTER JOIN  TabKontakty_EXT KE ON KE.ID=K.ID
WHERE
(K.IDCisKOs=@IDCisKOs AND K.IDVztahKOsOrg IS NULL AND KE._Balikobot_Prednastaveno=1 AND K.Druh IN(1, 2))
ORDER BY K.Druh DESC
)
IF @rec_phone IS NULL
SET @rec_phone=(SELECT TOP 1 K.Spojeni
FROM TabKontakty K
LEFT OUTER JOIN  TabKontakty_EXT KE ON KE.ID=K.ID
WHERE
(K.IDVztahKOsOrg=@IdVztahOrgKOs AND KE._Balikobot_Prednastaveno=1 AND K.Druh IN(1, 2))
ORDER BY K.Druh DESC
)
IF @rec_phone IS NULL
SET @rec_phone=(SELECT TOP 1 K.Spojeni
FROM TabKontakty K
WHERE
(K.IDCisKOs=@IDCisKOs AND K.IDVztahKOsOrg IS NULL AND K.Prednastaveno=1 AND K.Druh IN(1, 2))
ORDER BY K.Druh DESC
)
IF @rec_phone IS NULL
SET @rec_phone=(SELECT TOP 1 K.Spojeni
FROM TabKontakty K
WHERE
(K.IDVztahKOsOrg=@IdVztahOrgKOs AND K.Prednastaveno=1 AND K.Druh IN(1, 2))
ORDER BY K.Druh DESC
)
GO

