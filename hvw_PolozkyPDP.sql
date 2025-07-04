USE [RayService]
GO

/****** Object:  View [dbo].[hvw_PolozkyPDP]    Script Date: 04.07.2025 6:55:21 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

CREATE VIEW [dbo].[hvw_PolozkyPDP] AS SELECT *,
CAST(CASE WHEN EXISTS (
SELECT 0 FROM TabHlavickaPDP H
JOIN TabObdobiDPH O ON O.Id=H.ObdobiDPH
WHERE
H.ID=TabPolozkyPDP.IdHlavPDP
AND TabPolozkyPDP.DatumDUZP BETWEEN O.DatumOd_X AND O.DatumDo_X
) THEN 1 ELSE 0 END AS BIT) AS SouladObdobiDPH
FROM TabPolozkyPDP
GO

