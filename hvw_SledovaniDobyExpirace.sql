USE [RayService]
GO

/****** Object:  View [dbo].[hvw_SledovaniDobyExpirace]    Script Date: 04.07.2025 8:30:02 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

CREATE VIEW [dbo].[hvw_SledovaniDobyExpirace] AS SELECT VC.*, IDKmenZbozi=SS.IDKmenZbozi, IDSklad=SS.IDSklad
FROM TabStavSkladu SS
  INNER JOIN TabVyrCS VC ON (VC.IDStavSkladu=SS.ID AND VC.DatExpirace IS NOT NULL AND VC.mnozstvi>0.0) 
/*WHERE SS.IDSklad=N'100'*/
GO

