USE [RayService]
GO

/****** Object:  View [dbo].[hvw_PinyaZakStavy]    Script Date: 03.07.2025 15:33:03 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO



CREATE VIEW [dbo].[hvw_PinyaZakStavy] AS 
SELECT
TabZakStavy.ID AS ID
,TabZakStavy.Cislo AS Cislo
,TabZakStavy.Popis AS Popis
FROM TabZakStavy





GO

