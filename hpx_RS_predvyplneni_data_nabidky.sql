USE [RayService]
GO

/****** Object:  StoredProcedure [dbo].[hpx_RS_predvyplneni_data_nabidky]    Script Date: 26.06.2025 12:02:41 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

CREATE PROCEDURE [dbo].[hpx_RS_predvyplneni_data_nabidky]
@PrvniPruchod BIT
AS
DECLARE @CisZam INT
SET @CisZam=(SELECT TabCisZam.Cislo FROM TabCisZam WHERE TabCisZam.LoginId=SUSER_SNAME())
IF EXISTS (SELECT * FROM #TempDefFormInfo WHERE BrowseID=27)
SELECT GETDATE()+30 AS DatUhrady, @CisZam AS CisloZam
GO

