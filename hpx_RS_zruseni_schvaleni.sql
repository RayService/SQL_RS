USE [RayService]
GO

/****** Object:  StoredProcedure [dbo].[hpx_RS_zruseni_schvaleni]    Script Date: 26.06.2025 10:38:08 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

CREATE PROCEDURE [dbo].[hpx_RS_zruseni_schvaleni] @IdDoklad INT
AS
--DECLARE @IdDoklad INT=1242988;
--procedura odpojí schvalovací předpis a zruší externí zatržítko Doklad ke schválení
DECLARE @IDpredpis INT
SET @IDpredpis = (SELECT ID FROM Tabx_SDPredpisy WHERE TypDokladu = 0 AND IdDoklad = @IdDoklad)
IF (SELECT ISNULL(tdze._EXT_RS_doklad_ke_schvaleni,0) FROM TabDokladyZbozi_EXT tdze WHERE tdze.ID=@IdDoklad)=1
BEGIN
DELETE FROM Tabx_SDPredpisVRoleVSchvalovatel WHERE IdPredpis =@IDpredpis
DELETE FROM Tabx_SDPredpisy WHERE ID =@IDpredpis
INSERT Tabx_SDLog(TypZaznamu, IdDoklad, TypDokladu, SchvaleniStav)
VALUES(1, @IdDoklad, 0, 5)

UPDATE tdze SET tdze._EXT_RS_doklad_ke_schvaleni=0
FROM TabDokladyZbozi_EXT tdze
WHERE tdze.ID=@IdDoklad


DECLARE @DR   DATETIMEDECLARE @Info NVARCHAR(255)--SET @IDDoklad = 53146SELECT @DR = DatumSchvaleni FROM TabDokZboDodatek WHERE IDHlavicky = @IDDokladSELECT @DRIF @DR IS NOT NULLBEGINBEGIN TRANUPDATE TabDokZboDodatek SETDatumSchvaleni = NULL,Schvalil = NULLWHERE IDHlavicky = @IDDokladSELECT @Info = N'Období='+CAST(Obdobi AS NVARCHAR(10))+N' Řada='+RadaDokladu+N' Číslo='+CAST(PoradoveCislo AS NVARCHAR(20))+N'(Druh pohybu=''+CAST(DruhPohybuZbo AS NVARCHAR(2))+N'')'FROM TabDokladyZbozi WHERE ID = @IDDokladEXEC dbo.hp_ZapisDoZurnalu 1, 31, @InfoCOMMITEND

END;
GO

