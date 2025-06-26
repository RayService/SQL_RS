USE [RayService]
GO

/****** Object:  StoredProcedure [dbo].[hpx_HeliosZOOM_Organizace_Oprava]    Script Date: 26.06.2025 9:34:50 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

CREATE PROCEDURE [dbo].[hpx_HeliosZOOM_Organizace_Oprava]
@Nazev NVARCHAR(100),
@Ulice NVARCHAR(100),
@PopCislo NVARCHAR(15),
@PSC NVARCHAR(10),
@Misto NVARCHAR(100),
@ICO NVARCHAR(20),
@Poznamka NTEXT,
@ID INT
AS

UPDATE TabCisOrg SET
Nazev = @Nazev, 
Ulice = @Ulice, 
PopCislo = @PopCislo, 
PSC = @PSC, 
ICO = @ICO, 
Poznamka = @Poznamka,
Misto = @Misto
WHERE ID = @ID
GO

