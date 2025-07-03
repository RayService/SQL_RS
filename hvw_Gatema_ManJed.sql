USE [RayService]
GO

/****** Object:  View [dbo].[hvw_Gatema_ManJed]    Script Date: 03.07.2025 15:02:50 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

CREATE VIEW [dbo].[hvw_Gatema_ManJed] AS SELECT *, 
       Poznamka_255=(SUBSTRING(REPLACE(SUBSTRING(Poznamka,1,255),(NCHAR(13) + NCHAR(10)),NCHAR(32)),1,255)), 
       PocetPol=(SELECT count(*) FROM Gatema_ManJed H1 WHERE H1.IDNadrizeneManJed=Gatema_ManJed.ID) + (SELECT count(*) FROM Gatema_ManJedPol P WHERE P.IDManJed=Gatema_ManJed.ID), 
       PrazdnaJednotka=convert(bit, (CASE WHEN (SELECT count(*) FROM Gatema_ManJedPol P WHERE P.IDManJed=Gatema_ManJed.ID AND P.mnozstvi>0.0)>0.0 OR 
                                               (SELECT count(*) FROM Gatema_ManJed H1 INNER JOIN Gatema_ManJedPol P ON (P.IDManJed=H1.ID AND P.mnozstvi>0.0) WHERE H1.IDNadrizeneManJed=Gatema_ManJed.ID)>0.0 
                                          THEN 0 ELSE 1 END)) 
  FROM Gatema_ManJed 
GO

