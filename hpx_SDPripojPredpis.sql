USE [RayService]
GO

/****** Object:  StoredProcedure [dbo].[hpx_SDPripojPredpis]    Script Date: 26.06.2025 9:05:11 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

/*rpSchvalovaniDokladu.Workflow*/CREATE PROC [dbo].[hpx_SDPripojPredpis]
@IdDoklad INT,
@IdPredpis INT,
@ZapsatDoLogu BIT = 0
AS
DECLARE @IdPredpisNEW INT, @TypDokladu INT
DECLARE @TypHlasky TINYINT, @Hlaska NVARCHAR(MAX)
IF EXISTS(SELECT * FROM Tabx_SDPredpisy
          WHERE Kopie=1 AND IdPredpisZdroj=@IdPredpis AND IdDoklad=@IdDoklad
          AND TypDokladu=(SELECT TypDokladu FROM Tabx_SDPredpisy WHERE ID=@IdPredpis)
         )
BEGIN
  DECLARE @JazykVerze INT
  SET @JazykVerze=(SELECT Jazyk FROM TabUziv WHERE LoginName=SUSER_SNAME())
  IF @JazykVerze IS NULL SET @JazykVerze=1
  SET @Hlaska=(SELECT Hlaska FROM TabExtHlasky WHERE GUIDText='F5546AD3-D61C-40D6-9F38-693D6DED03DA' AND Jazyk=@JazykVerze)
  IF @Hlaska IS NULL
    SET @Hlaska=(SELECT Hlaska FROM TabExtHlasky WHERE GUIDText='F5546AD3-D61C-40D6-9F38-693D6DED03DA' AND Jazyk=1)
  INSERT Tabx_SDErrors(SPID, LoginID, TypHlasky, TextHlasky) VALUES(@@SPID, SUSER_SNAME(), 1, @Hlaska)
  RETURN
END
IF OBJECT_ID('dbo.epx_SDPripojPredpis03', 'P') IS NOT NULL
BEGIN
  EXEC dbo.epx_SDPripojPredpis03
    @IdPredpis=@IdPredpis
  , @TypHlasky=@TypHlasky OUT
  , @Hlaska=@Hlaska OUT
  IF (@TypHlasky IS NOT NULL)AND(@Hlaska IS NOT NULL)
    INSERT Tabx_SDErrors(SPID, LoginID, TypHlasky, TextHlasky) VALUES(@@SPID, SUSER_SNAME(), @TypHlasky, @Hlaska)
END
IF ISNULL(@TypHlasky, 0)=1
  RETURN
INSERT INTO Tabx_SDPredpisy(Nazev, Popis, TypDokladu, IdDoklad, Kopie, IdPredpisZdroj, Skupina, Rezim)
SELECT Nazev, Popis, TypDokladu, @IdDoklad, 1, @IdPredpis, Skupina, Rezim
FROM Tabx_SDPredpisy
WHERE ID = @IdPredpis
SET @IdPredpisNEW = SCOPE_IDENTITY()
INSERT INTO Tabx_SDPredpisVRoleVSchvalovatel(IdPredpis, IdSchvalovatel, IdRole, Uroven, VracetNaPrvniUroven)
SELECT @IdPredpisNEW, IdSchvalovatel, IdRole, Uroven, VracetNaPrvniUroven
FROM Tabx_SDPredpisVRoleVSchvalovatel
WHERE Tabx_SDPredpisVRoleVSchvalovatel.IdPredpis = @IdPredpis
ORDER BY Uroven ASC
IF @ZapsatDoLogu=1
BEGIN
  SET @TypDokladu=(SELECT TypDokladu FROM Tabx_SDPredpisy WHERE ID=@IdPredpisNEW)
  INSERT Tabx_SDLog(TypZaznamu, IdDoklad, TypDokladu, SchvaleniStav) VALUES(1, @IdDoklad, @TypDokladu, 3)
END
IF OBJECT_ID('dbo.epx_SDPripojPredpis01', 'P') IS NOT NULL
  EXEC dbo.epx_SDPripojPredpis01
    @IdPredpis=@IdPredpisNEW
IF OBJECT_ID('dbo.epx_SDPripojPredpis02', 'P') IS NOT NULL
BEGIN
  EXEC dbo.epx_SDPripojPredpis02
    @IdPredpis=@IdPredpisNEW
  , @TypHlasky=@TypHlasky OUT
  , @Hlaska=@Hlaska OUT
  IF (@TypHlasky IS NOT NULL)AND(@Hlaska IS NOT NULL)
    INSERT Tabx_SDErrors(SPID, LoginID, TypHlasky, TextHlasky) VALUES(@@SPID, SUSER_SNAME(), @TypHlasky, @Hlaska)
END
GO

