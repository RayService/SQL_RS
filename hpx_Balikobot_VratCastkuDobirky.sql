USE [RayService]
GO

/****** Object:  StoredProcedure [dbo].[hpx_Balikobot_VratCastkuDobirky]    Script Date: 26.06.2025 15:04:39 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

/*rpBalikobot.Export*/CREATE PROC [dbo].[hpx_Balikobot_VratCastkuDobirky]
@IdDoklad INT
, @MultiGenerovani BIT = 0
, @CastkaDobirky NUMERIC(19,6) OUT
AS
SET NOCOUNT ON
DECLARE @PodleCehoHledatMenuACastku TINYINT
SET @PodleCehoHledatMenuACastku=dbo.hfx_Balikobot_VratZpusobHledaniMeny(@IdDoklad)
IF ISNULL(@PodleCehoHledatMenuACastku, 0)=0
BEGIN
IF @MultiGenerovani=0
SET @CastkaDobirky=(SELECT SumaValPoZao FROM TabDokladyZbozi WHERE ID=@IdDoklad)
ELSE
BEGIN
SET @CastkaDobirky=(SELECT SUM(IIF(D.DruhPohybuZbo IN(13,14), 1, -1)*D.SumaValDPoh)
FROM TabDokladyZbozi D
LEFT OUTER JOIN TabFormaUhrady FU ON FU.FormaUhrady=D.FormaUhrady
LEFT OUTER JOIN TabFormaUhrady_EXT FUE ON FUE.ID=FU.ID
WHERE ISNULL(FUE._Balikobot_Dobirka, 0)=1
AND
D.ID IN(SELECT @IdDoklad UNION SELECT IdDoklad FROM #Tabx_BalikobotMultiGenerovani)
)
SET @CastkaDobirky=ROUND(@CastkaDobirky, 0)
END
END
IF ISNULL(@PodleCehoHledatMenuACastku, 0)=1
BEGIN
IF @MultiGenerovani=0
SET @CastkaDobirky=(SELECT SumaKcPoZao FROM TabDokladyZbozi WHERE ID=@IdDoklad)
ELSE
BEGIN
SET @CastkaDobirky=(SELECT SUM(IIF(D.DruhPohybuZbo IN(13,14), 1, -1)*D.SumaKcDPoh)
FROM TabDokladyZbozi D
LEFT OUTER JOIN TabFormaUhrady FU ON FU.FormaUhrady=D.FormaUhrady
LEFT OUTER JOIN TabFormaUhrady_EXT FUE ON FUE.ID=FU.ID
WHERE ISNULL(FUE._Balikobot_Dobirka, 0)=1
AND
D.ID IN(SELECT @IdDoklad UNION SELECT IdDoklad FROM #Tabx_BalikobotMultiGenerovani)
)
SET @CastkaDobirky=ROUND(@CastkaDobirky, 0)
END
END
IF OBJECT_ID('dbo.epx_Balikobot_CastkaDobirky', 'P') IS NOT NULL
EXEC dbo.epx_Balikobot_CastkaDobirky
@IdDoklad=@IdDoklad
, @CastkaDobirky=@CastkaDobirky OUT
GO

