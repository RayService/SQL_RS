USE [RayService]
GO

/****** Object:  StoredProcedure [dbo].[hpx_HeliosZOOM_Organizace_Novy]    Script Date: 26.06.2025 9:37:56 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

CREATE PROCEDURE [dbo].[hpx_HeliosZOOM_Organizace_Novy]
@Nazev NVARCHAR(100),
@Ulice NVARCHAR(100),
@PopCislo NVARCHAR(15),
@PSC NVARCHAR(10),
@Misto NVARCHAR(100),
@ICO NVARCHAR(20),
@Poznamka NTEXT
AS

DECLARE @CisloOrg INT

EXEC @CisloOrg=dbo.hp_NajdiPrvniVolny 'TabCisOrg','CisloOrg',1,2147483647,'',1,1

INSERT INTO TabCisOrg (CisloOrg, Nazev, Ulice, PopCislo, PSC, Misto, ICO, Poznamka)
VALUES
(@CisloOrg, @Nazev, @Ulice, @PopCislo, @PSC, @Misto, @ICO, @Poznamka)
GO

