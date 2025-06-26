USE [RayService]
GO

/****** Object:  StoredProcedure [dbo].[hpx_VD_KonverzeMesice]    Script Date: 26.06.2025 8:39:05 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

/*rpVyuctovaniZalDane.Vyúčtování*/CREATE PROC [dbo].[hpx_VD_KonverzeMesice] @IdCizince INT
AS
DECLARE @Mesice NVARCHAR(30)
SELECT @Mesice=(
CASE WHEN m_mes_zuct1=1 THEN N'1,' ELSE '' END +
CASE WHEN m_mes_zuct2=1 THEN N'2,' ELSE '' END +
CASE WHEN m_mes_zuct3=1 THEN N'3,' ELSE '' END +
CASE WHEN m_mes_zuct4=1 THEN N'4,' ELSE '' END +
CASE WHEN m_mes_zuct5=1 THEN N'5,' ELSE '' END +
CASE WHEN m_mes_zuct6=1 THEN N'6,' ELSE '' END +
CASE WHEN m_mes_zuct7=1 THEN N'7,' ELSE '' END +
CASE WHEN m_mes_zuct8=1 THEN N'8,' ELSE '' END +
CASE WHEN m_mes_zuct9=1 THEN N'9,' ELSE '' END +
CASE WHEN m_mes_zuct10=1 THEN N'10,' ELSE '' END +
CASE WHEN m_mes_zuct11=1 THEN N'11,' ELSE '' END +
CASE WHEN m_mes_zuct12=1 THEN N'12,' ELSE '' END
) FROM dbo.Tabx_VZDSUCizinci WHERE ID=@IdCizince
IF LEN(@Mesice)>0
BEGIN
SET @Mesice = SUBSTRING(@Mesice, 1, LEN(@Mesice)-1)
EXEC dbo.hp_MzKonverzeMesice @Mesice OUT
END
ELSE BEGIN
SET @Mesice=''
END
SELECT @Mesice
GO

