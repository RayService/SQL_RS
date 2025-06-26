USE [RayService]
GO

/****** Object:  StoredProcedure [dbo].[hpx_RS_SmazaniNahlaseneNeshody]    Script Date: 26.06.2025 15:08:58 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

CREATE PROCEDURE [dbo].[hpx_RS_SmazaniNahlaseneNeshody] @ID INT
AS
SET NOCOUNT ON

--DECLARE @ID INT
--SET @ID=27224
--SELECT *
--FROM Tabx_Apps_QaDefectReport
--WHERE ID=@ID--productionOrderID=158592 AND operationID=2759729

--SELECT *
--FROM Tabx_Apps_QaDefectReportFile
--WHERE defectReportId=@ID


IF EXISTS (SELECT *
FROM Tabx_Apps_QaDefectReportFile
WHERE defectReportId=@ID)
BEGIN
DELETE FROM Tabx_Apps_QaDefectReportFile WHERE defectReportId=@ID
END;
BEGIN
DELETE FROM Tabx_Apps_QaDefectReport WHERE ID=@ID
END;
GO

