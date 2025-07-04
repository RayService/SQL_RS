USE [RayService]
GO

/****** Object:  View [dbo].[TabKmenZboziDodatekView]    Script Date: 04.07.2025 11:28:56 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

CREATE VIEW [dbo].[TabKmenZboziDodatekView] AS
SELECT
kz.AVAReferenceID AS AVAReferenceID
,kz.AVAExternalID AS AVAExternalID
,kzd.ID AS ID
,kzd.KodRecyk AS KodRecyk
,kzd.MJRecyk AS MJRecyk
,kzd.CastkaGarRecyk AS CastkaGarRecyk
,kzd.PrepMJRecyk AS PrepMJRecyk
FROM
TabKmenZboziDodatek kzd
JOIN TabKmenZbozi kz ON kzd.ID = kz.ID
GO

