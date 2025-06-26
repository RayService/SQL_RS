USE [RayService]
GO

/****** Object:  StoredProcedure [dbo].[hpx_RS_predvyplneni_data_EP]    Script Date: 26.06.2025 10:38:38 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

CREATE PROCEDURE [dbo].[hpx_RS_predvyplneni_data_EP]
@PrvniPruchod BIT
AS
DECLARE @CisZam INT
SET @CisZam=(SELECT TabCisZam.Cislo FROM TabCisZam WHERE TabCisZam.LoginId=SUSER_SNAME())
IF EXISTS (SELECT * FROM #TempDefFormInfo WHERE BrowseID=25)
SELECT @CisZam AS CisloZam
GO

