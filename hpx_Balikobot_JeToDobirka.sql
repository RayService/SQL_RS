USE [RayService]
GO

/****** Object:  StoredProcedure [dbo].[hpx_Balikobot_JeToDobirka]    Script Date: 26.06.2025 14:35:54 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

/*rpBalikobot.Export*/CREATE PROC [dbo].[hpx_Balikobot_JeToDobirka]
@IdDoklad INT
, @MultiGenerovani BIT
, @JeToDobirka BIT OUT
AS
SET NOCOUNT ON
SET @JeToDobirka=0
IF @MultiGenerovani=0
SET @JeToDobirka=(SELECT ISNULL(FUE._Balikobot_Dobirka, 0)
FROM TabDokladyZbozi D
LEFT OUTER JOIN TabFormaUhrady FU ON FU.FormaUhrady=D.FormaUhrady
LEFT OUTER JOIN TabFormaUhrady_EXT FUE ON FUE.ID=FU.ID
WHERE D.ID=@IdDoklad)
IF @MultiGenerovani=1
BEGIN
IF EXISTS(SELECT *
FROM TabDokladyZbozi D
LEFT OUTER JOIN TabFormaUhrady FU ON FU.FormaUhrady=D.FormaUhrady
LEFT OUTER JOIN TabFormaUhrady_EXT FUE ON FUE.ID=FU.ID
WHERE ISNULL(FUE._Balikobot_Dobirka, 0)=1
AND
D.ID IN(SELECT @IdDoklad UNION SELECT IdDoklad FROM #Tabx_BalikobotMultiGenerovani)
)
SET @JeToDobirka=1
END
GO

