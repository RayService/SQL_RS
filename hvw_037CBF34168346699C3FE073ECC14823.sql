USE [RayService]
GO

/****** Object:  View [dbo].[hvw_037CBF34168346699C3FE073ECC14823]    Script Date: 03.07.2025 10:51:50 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

CREATE VIEW [dbo].[hvw_037CBF34168346699C3FE073ECC14823] AS SELECT 
	ID,
	Created,
	CreatedBy,
	TTResolved,
	TTResolvedBy,
	Status,
	IDTool,
	IDCombination,
	IDTensileTest,
	IDCuttingTest,
	CTResolved,
	CTResolvedBy,
	IDProductionOrder,
	TensileTestRequired,
	CuttingTestRequired,
                   RestInProduction,
GenerovanyVydejky,
                   IDVydejky
FROM B2A_TDM_TensileTest_Request
GO

