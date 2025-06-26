USE [RayService]
GO

/****** Object:  StoredProcedure [dbo].[hpx_RS_doplnkova_pole_edit]    Script Date: 26.06.2025 14:18:52 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

CREATE PROC [dbo].[hpx_RS_doplnkova_pole_edit]
@Poznamka NVARCHAR(255),
@kontrola1 INT,
@NRC_QA NUMERIC(19,6),
@kontrola2 BIT,
@NRC_technology NUMERIC(19,6),
@kontrola3 BIT,
@NRC_engineering NUMERIC(19,6),
@kontrola4 BIT,
@MOQ_costs NUMERIC(19,6),
@kontrola5 BIT,
@FAIR INT,
@kontrola6 BIT,
@FORM1 INT,
@kontrola7 BIT,
@PPAP INT,
@kontrola8 BIT,
@LT_firstpiece INT,
@kontrola9 BIT,
@LT_serie INT,
@kontrola10 BIT,
@Kontroloval NVARCHAR(50),
@kontrola11 BIT,
@ID INT
AS
IF @kontrola1 = 1
BEGIN
UPDATE dbo.TabPozaZDok_kalk SET Poznamka=@Poznamka WHERE ID = @ID;
END
IF @kontrola1 = 2
BEGIN
UPDATE dbo.TabPozaZDok_kalk SET Poznamka=CAST((ISNULL(CAST(Poznamka AS NVARCHAR(MAX)),'') +'
'+ @Poznamka) AS NTEXT)
, Zmenil=SUSER_SNAME(), DatZmeny = GETDATE()
WHERE ID=@ID;
END
IF @kontrola2 = 1
BEGIN
UPDATE dbo.TabPozaZDok_kalk SET NRC_QA=@NRC_QA
, Zmenil=SUSER_SNAME(), DatZmeny = GETDATE()
WHERE ID=@ID;
END
IF @kontrola3 = 1
BEGIN
UPDATE dbo.TabPozaZDok_kalk SET NRC_technology=@NRC_technology
, Zmenil=SUSER_SNAME(), DatZmeny = GETDATE()
WHERE ID=@ID;
END
IF @kontrola4 = 1
BEGIN
UPDATE dbo.TabPozaZDok_kalk SET NRC_engineering=@NRC_engineering
, Zmenil=SUSER_SNAME(), DatZmeny = GETDATE()
WHERE ID=@ID;
END
IF @kontrola5 = 1
BEGIN
UPDATE dbo.TabPozaZDok_kalk SET MOQ_costs=@MOQ_costs
, Zmenil=SUSER_SNAME(), DatZmeny = GETDATE()
WHERE ID=@ID;
END
IF @kontrola6 = 1
BEGIN
UPDATE dbo.TabPozaZDok_kalk SET FAIR=@FAIR
, Zmenil=SUSER_SNAME(), DatZmeny = GETDATE()
WHERE ID=@ID;
END
IF @kontrola7 = 1
BEGIN
UPDATE dbo.TabPozaZDok_kalk SET FORM1=@FORM1
, Zmenil=SUSER_SNAME(), DatZmeny = GETDATE()
WHERE ID=@ID;
END
IF @kontrola8 = 1
BEGIN
UPDATE dbo.TabPozaZDok_kalk SET PPAP=@PPAP
, Zmenil=SUSER_SNAME(), DatZmeny = GETDATE()
WHERE ID=@ID;
END
IF @kontrola9 = 1
BEGIN
UPDATE dbo.TabPozaZDok_kalk SET LT_firstpiece=@LT_firstpiece
, Zmenil=SUSER_SNAME(), DatZmeny = GETDATE()
WHERE ID=@ID;
END
IF @kontrola10 = 1
BEGIN
UPDATE dbo.TabPozaZDok_kalk SET LT_serie=@LT_serie
, Zmenil=SUSER_SNAME(), DatZmeny = GETDATE()
WHERE ID=@ID;
END
IF @kontrola11 = 1
BEGIN
UPDATE dbo.TabPozaZDok_kalk SET Kontroloval=@Kontroloval
, Zmenil=SUSER_SNAME(), DatZmeny = GETDATE()
WHERE ID=@ID;
END

IF @kontrola1=0 AND @kontrola2=0 AND @kontrola3=0 AND @kontrola4=0 AND @kontrola5=0 AND @kontrola6=0 AND @kontrola7=0 AND @kontrola8=0 AND @kontrola9=0 AND @kontrola10=0 AND @kontrola11=0
BEGIN
RAISERROR ('Nic neproběhne, není zatrženo Přepsat.',16,1);
RETURN
END;
GO

