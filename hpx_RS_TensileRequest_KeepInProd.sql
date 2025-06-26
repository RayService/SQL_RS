USE [RayService]
GO

/****** Object:  StoredProcedure [dbo].[hpx_RS_TensileRequest_KeepInProd]    Script Date: 26.06.2025 12:54:53 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

CREATE PROCEDURE [dbo].[hpx_RS_TensileRequest_KeepInProd]
@RestInProduction BIT,
@kontrola BIT,
@ID INT
AS
SET NOCOUNT ON

IF @kontrola=1
BEGIN
    UPDATE B2A_TDM_TensileTest_Request SET RestInProduction=@RestInProduction FROM B2A_TDM_TensileTest_Request WHERE B2A_TDM_TensileTest_Request.ID = @ID
END;
IF @kontrola=0
BEGIN
RAISERROR('Nic neproběhne, není zatržena žádná volba.',16,1)
RETURN;
END;
GO

