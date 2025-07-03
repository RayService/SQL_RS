USE [RayService]
GO

/****** Object:  View [dbo].[hvw_CB502BD3272C4BEAA1A1D150DF099145]    Script Date: 03.07.2025 14:25:35 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

CREATE VIEW [dbo].[hvw_CB502BD3272C4BEAA1A1D150DF099145] AS SELECT ID, LoginId, Cislo, Jmeno, Prijmeni, PrijmeniJmeno, Stredisko, Obrazek
FROM TabCisZam tcz WITH(NOLOCK)
GO

