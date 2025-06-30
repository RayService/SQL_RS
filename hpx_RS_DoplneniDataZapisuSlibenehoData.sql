USE [RayService]
GO

/****** Object:  StoredProcedure [dbo].[hpx_RS_DoplneniDataZapisuSlibenehoData]    Script Date: 30.06.2025 8:51:09 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

CREATE PROCEDURE [dbo].[hpx_RS_DoplneniDataZapisuSlibenehoData]
AS

SET NOCOUNT ON;

--SELECT tpze._EXT_RS_PromisedStockingDate, tpze._EXT_RS_LogPromisedDay
--FROM TabPohybyZbozi tpz
--LEFT OUTER JOIN TabPohybyZbozi_EXT tpze ON tpze.ID=tpz.ID
--WHERE tpze._EXT_RS_PromisedStockingDate IS NOT NULL AND tpze._EXT_RS_LogPromisedDay IS NULL

UPDATE TabPohybyZbozi_EXT SET _EXT_RS_LogPromisedDay=GETDATE() WHERE _EXT_RS_PromisedStockingDate IS NOT NULL AND _EXT_RS_LogPromisedDay IS NULL
GO

