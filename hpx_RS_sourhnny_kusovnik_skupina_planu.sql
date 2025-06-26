USE [RayService]
GO

/****** Object:  StoredProcedure [dbo].[hpx_RS_sourhnny_kusovnik_skupina_planu]    Script Date: 26.06.2025 12:12:15 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

CREATE PROCEDURE [dbo].[hpx_RS_sourhnny_kusovnik_skupina_planu]
AS 
  SET NOCOUNT ON

DELETE FROM RS_TabSouKusovProSkupinu WHERE Autor=SUSER_SNAME() 

INSERT INTO RS_TabSouKusovProSkupinu (Skupina, IDKmenZbozi, mnf, Cena, Cena1, Cena2,Autor) 
SELECT Skupina, IDKmenZbozi, SUM(mnf), MAX(Cena), MAX(Cena1), MAX(Cena2),SUSER_SNAME()
FROM TabKusovnik_polozky
WHERE Autor=SUSER_SNAME() AND Final=0 GROUP BY Skupina, IDKmenZbozi
GO

