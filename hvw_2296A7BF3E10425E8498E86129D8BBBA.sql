USE [RayService]
GO

/****** Object:  View [dbo].[hvw_2296A7BF3E10425E8498E86129D8BBBA]    Script Date: 03.07.2025 11:01:19 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

CREATE VIEW [dbo].[hvw_2296A7BF3E10425E8498E86129D8BBBA] AS SELECT 

(CASE WHEN Type = 1 THEN 'úvodní' ELSE 'závěrečná' END) as TypeString ,
Created,
CreatedBy,
IDTool

FROM B2A_TDM_DmcTest
GO

