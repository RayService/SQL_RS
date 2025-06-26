USE [RayService]
GO

/****** Object:  StoredProcedure [dbo].[hpx_Balikobot_VratUdanouCenuZasilky]    Script Date: 26.06.2025 15:07:41 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

/*rpBalikobot.Export*/CREATE PROC [dbo].[hpx_Balikobot_VratUdanouCenuZasilky]
@IdDoklad INT
, @MultiGenerovani BIT = 0
, @UdanaCenaZasilky NUMERIC(19,6) OUT
, @MenaUdaneCeny NVARCHAR(3) = NULL OUT
AS
SET NOCOUNT ON
DECLARE @PodleCehoHledatMenuACastku TINYINT
SET @PodleCehoHledatMenuACastku=dbo.hfx_Balikobot_VratZpusobHledaniMeny(@IdDoklad)
IF ISNULL(@PodleCehoHledatMenuACastku, 0)=0
BEGIN
IF @MultiGenerovani=0
SET @UdanaCenaZasilky=(SELECT SumaKcPoZaoBezZalVal FROM TabDokladyZbozi WHERE ID=@IdDoklad)
ELSE
BEGIN
SET @UdanaCenaZasilky=(SELECT SumaKcPoZaoBezZalVal FROM TabDokladyZbozi WHERE ID=@IdDoklad)
SET @UdanaCenaZasilky=@UdanaCenaZasilky + ISNULL((SELECT SUM(SumaKcPoZaoBezZalVal) FROM TabDokladyZbozi WHERE ID IN(SELECT IdDoklad FROM #Tabx_BalikobotMultiGenerovani)), 0)
END
SET @MenaUdaneCeny=(SELECT Mena FROM TabDokladyZbozi WHERE ID=@IdDoklad)
END
IF ISNULL(@PodleCehoHledatMenuACastku, 0)=1
BEGIN
IF @MultiGenerovani=0
SET @UdanaCenaZasilky=(SELECT SumaKcPoZaoBezZal FROM TabDokladyZbozi WHERE ID=@IdDoklad)
ELSE
BEGIN
SET @UdanaCenaZasilky=(SELECT SumaKcPoZaoBezZal FROM TabDokladyZbozi WHERE ID=@IdDoklad)
SET @UdanaCenaZasilky=@UdanaCenaZasilky + ISNULL((SELECT SUM(SumaKcPoZaoBezZal) FROM TabDokladyZbozi WHERE ID IN(SELECT IdDoklad FROM #Tabx_BalikobotMultiGenerovani)), 0)
END
SET @MenaUdaneCeny=(SELECT Kod FROM TabKodMen WHERE HlavniMena=1)
END
IF OBJECT_ID('dbo.epx_Balikobot_UdanaCenaZasilky', 'P') IS NOT NULL
EXEC dbo.epx_Balikobot_UdanaCenaZasilky
@IdDoklad=@IdDoklad
, @UdanaCenaZasilky=@UdanaCenaZasilky OUT
GO

