USE [RayService]
GO

/****** Object:  View [dbo].[hvw_ADA0162BDAF04755BCBFEA7E90EE7129]    Script Date: 03.07.2025 12:50:41 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

CREATE VIEW [dbo].[hvw_ADA0162BDAF04755BCBFEA7E90EE7129] AS SELECT
RS_TabSouKusovProSkupinu.ID,
RS_TabSouKusovProSkupinu.IDKmenZbozi,
RS_TabSouKusovProSkupinu.mnf,
RS_TabSouKusovProSkupinu.Cena,
RS_TabSouKusovProSkupinu.Cena2,
RS_TabSouKusovProSkupinu.Cena1,
RS_TabSouKusovProSkupinu.CCena,
RS_TabSouKusovProSkupinu.CCena1,
RS_TabSouKusovProSkupinu.CCena2,
RS_TabSouKusovProSkupinu.Autor
FROM RS_TabSouKusovProSkupinu WITH(NOLOCK)
WHERE RS_TabSouKusovProSkupinu.Autor = SUSER_SNAME()
GO

