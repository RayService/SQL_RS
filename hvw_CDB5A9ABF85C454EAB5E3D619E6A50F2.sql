USE [RayService]
GO

/****** Object:  View [dbo].[hvw_CDB5A9ABF85C454EAB5E3D619E6A50F2]    Script Date: 03.07.2025 14:26:32 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

CREATE VIEW [dbo].[hvw_CDB5A9ABF85C454EAB5E3D619E6A50F2] AS select tsa.ID, tsa.Nazev, tsb.Nazev as NadSkup from TabSoz tsa
left join TabSoz tsb on tsb.ID = tsa.NadID
GO

