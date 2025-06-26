USE [RayService]
GO

/****** Object:  StoredProcedure [dbo].[hpx_Balikobot_GenerovatVychoziHmotnost]    Script Date: 26.06.2025 14:33:51 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

/*rpBalikobot.Export*/CREATE PROC [dbo].[hpx_Balikobot_GenerovatVychoziHmotnost]
@IdZasilky INT
AS
SET NOCOUNT ON
DECLARE @CelkovaHmotnost NUMERIC(19,2), @HmotnostBaliku NUMERIC(19,2), @PocetBaliku INT
SET @CelkovaHmotnost=(SELECT SUM(Hmotnost) FROM TabPohybyZbozi WHERE IDDoklad IN(SELECT IdDoklad FROM Tabx_BalikobotVZasilkyDoklady WHERE IdZasilky=@IdZasilky))
SET @PocetBaliku=(SELECT COUNT(*) FROM Tabx_BalikobotBaliky WHERE IdZasilky=@IdZasilky)
IF (@CelkovaHmotnost<>0)AND(@PocetBaliku>0)
BEGIN
SET @HmotnostBaliku=@CelkovaHmotnost/@PocetBaliku
UPDATE Tabx_BalikobotBaliky SET weight=@HmotnostBaliku WHERE IdZasilky=@IdZasilky
END
GO

