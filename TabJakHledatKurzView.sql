USE [RayService]
GO

/****** Object:  View [dbo].[TabJakHledatKurzView]    Script Date: 04.07.2025 11:28:21 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

CREATE VIEW [dbo].[TabJakHledatKurzView] AS
SELECT CAST(N'Pokladna' AS NVARCHAR(100)) AS Oblast,
PokladnaJakHledatKurz AS JakHledatKurz,
CAST(N'Možnosti - Konfigurace - Firemní konstanty - Pokladna' AS NVARCHAR(255)) AS KdeLzeNastavit FROM TabHGlob
UNION ALL
SELECT CAST(N'Banka - hlavička i řádky' AS NVARCHAR(100)) AS Oblast,
BankaVypisJakHledatKurz AS JakHledatKurz,
CAST(N'Možnosti - Konfigurace - Firemní konstanty - Banka - Bankovní výpisy' AS NVARCHAR(255)) AS KdeLzeNastavit FROM TabHGlob
UNION ALL
SELECT CAST(N'Oběh zboží, fakturace, aktivity' AS NVARCHAR(100)) AS Oblast,
FaSklJakHledatKurz AS JakHledatKurz,
CAST(N'Možnosti - Konfigurace - Firemní konstanty - Fakturace' AS NVARCHAR(255)) AS KdeLzeNastavit FROM TabHGlob
UNION ALL
SELECT CAST(N'Účetnictví - pro DPH' AS NVARCHAR(100)) AS Oblast,
UctoJakHledatKurzProDPH AS JakHledatKurz,
CAST(N'Možnosti - Konfigurace - Firemní konstanty - Účetnictví' AS NVARCHAR(255)) AS KdeLzeNastavit FROM TabHGlob
UNION ALL
SELECT CAST(N'Účetnictví - pro účetnictví' AS NVARCHAR(100)) AS Oblast,
UctoJakHledatKurzProZap AS JakHledatKurz,
CAST(N'Možnosti - Konfigurace - Firemní konstanty - Účetnictví' AS NVARCHAR(255)) AS KdeLzeNastavit FROM TabHGlob
UNION ALL
SELECT CAST(N'Účetnictví - pro Návrhář zápočtů' AS NVARCHAR(100)) AS Oblast,
UctoJakHledatKurzProNZ AS JakHledatKurz,
CAST(N'Možnosti - Konfigurace - Firemní konstanty - Účetnictví' AS NVARCHAR(255)) AS KdeLzeNastavit FROM TabHGlob
GO

