USE [RayService]
GO

/****** Object:  StoredProcedure [dbo].[hpx_RS_IssueAutoWarehouse]    Script Date: 26.06.2025 13:51:27 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

CREATE PROCEDURE [dbo].[hpx_RS_IssueAutoWarehouse]
@PrvniPruchod BIT
AS

IF EXISTS(SELECT*FROM #TempDefForm_NovaVeta WHERE RadaDokladu IN ('601','602','616') AND IDSklad=N'10000115')
SELECT '10000115' AS StredNaklad
GO

