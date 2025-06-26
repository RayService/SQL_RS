USE [RayService]
GO

/****** Object:  StoredProcedure [dbo].[hpx_SDSchvalovani_EServer]    Script Date: 26.06.2025 10:26:29 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

/*rpSchvalovaniDokladu.Workflow*/CREATE PROCEDURE [dbo].[hpx_SDSchvalovani_EServer]
@Schvalit INT,
@Duvod NVARCHAR(5),
@Poznamka NVARCHAR(4000),
@IdDoklad INT
AS
DECLARE @DuvodText NVARCHAR(100)
DECLARE @DuvodTxt NVARCHAR(MAX), @PoznamkaTxt NVARCHAR(MAX)
DECLARE @Messages TABLE
(
Message NVARCHAR(MAX)
)
INSERT INTO @Messages
EXEC dbo.hp_CtiOznamGUID 0x7E326FF6C4C1A44EB272272926DE419E
SELECT TOP 1 @DuvodTxt = Message FROM @Messages
DELETE FROM @Messages
INSERT INTO @Messages
EXEC dbo.hp_CtiOznamGUID 0xEBAE707E5A352B4993B6A6590BC260DC
SELECT TOP 1 @PoznamkaTxt = Message FROM @Messages
SET @Duvod = SUBSTRING(@Duvod, 2, 5)
SELECT @DuvodText = hvw_SDDuvody.Duvod FROM hvw_SDDuvody WHERE hvw_SDDuvody.ID = @Duvod
SET @DuvodText = ISNULL(@DuvodText, '')
SET @Poznamka = ISNULL(@Poznamka, '')
IF (SELECT LogNezapisovatIdentPoznamky FROM Tabx_SDKonfigurace)=0
SET @Poznamka =  N''+@DuvodTxt+': '+@DuvodText+'   '+@PoznamkaTxt +': '+@Poznamka
ELSE
SET @Poznamka =  N''+@DuvodText+'  ##  '+@Poznamka
IF @Schvalit = 2
BEGIN
EXEC dbo.hpx_SDPozastavitSchvalovani
@IdDoklad,
1, -- Pozastavit
0, -- TypDokladu
@Poznamka,
0 -- ZeSchvalovani
END
ELSE
BEGIN
EXEC dbo.hpx_SDSchvalitNeschvalitDoklad
@Schvalit ,
0, -- TypDokladu
@IdDoklad,
@Poznamka
END
GO

