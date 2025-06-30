USE [RayService]
GO

/****** Object:  StoredProcedure [dbo].[hpx_SDOdpojPredpis]    Script Date: 30.06.2025 8:20:20 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

/*rpSchvalovaniDokladu.Workflow*/CREATE PROC [dbo].[hpx_SDOdpojPredpis]
@IdPredpis INT,
@TypDokladu INT = NULL,
@IdDoklad INT = NULL
AS
IF @IdPredpis IS NULL
RETURN
DECLARE @TypHlasky TINYINT, @Hlaska NVARCHAR(MAX)
IF (@IdDoklad IS NULL)OR(@TypDokladu IS NULL)
SELECT @IdDoklad=IdDoklad, @TypDokladu=TypDokladu FROM Tabx_SDPredpisy WHERE ID=@IdPredpis AND Kopie=1
IF @IdDoklad IS NULL
RETURN
IF OBJECT_ID('dbo.epx_SDOdpojPredpis01', 'P') IS NOT NULL
BEGIN
EXEC dbo.epx_SDOdpojPredpis01
@IdPredpis=@IdPredpis
, @TypHlasky=@TypHlasky OUT --0=info, 1=error
, @Hlaska=@Hlaska OUT
IF (@TypHlasky IS NOT NULL)AND(@Hlaska IS NOT NULL)
INSERT Tabx_SDErrors(SPID, LoginID, TypHlasky, TextHlasky) VALUES(@@SPID, SUSER_SNAME(), @TypHlasky, @Hlaska)
END
IF ISNULL(@TypHlasky, 0)=1
RETURN
DELETE FROM Tabx_SDPredpisVRoleVSchvalovatel WHERE IdPredpis=@IdPredpis
DELETE FROM Tabx_SDPredpisy WHERE ID=@IdPredpis
INSERT Tabx_SDLog(TypZaznamu, IdDoklad, TypDokladu, SchvaleniStav) VALUES(1, @IdDoklad, @TypDokladu, 5)
IF OBJECT_ID('dbo.epx_SDOdpojPredpis02', 'P') IS NOT NULL
BEGIN
EXEC dbo.epx_SDOdpojPredpis02
@IdPredpis=@IdPredpis
, @TypHlasky=@TypHlasky OUT --0=info, 1=error
, @Hlaska=@Hlaska OUT
IF (@TypHlasky IS NOT NULL)AND(@Hlaska IS NOT NULL)
INSERT Tabx_SDErrors(SPID, LoginID, TypHlasky, TextHlasky) VALUES(@@SPID, SUSER_SNAME(), @TypHlasky, @Hlaska)
END
GO

