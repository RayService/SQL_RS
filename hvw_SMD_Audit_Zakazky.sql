USE [RayService]
GO

/****** Object:  View [dbo].[hvw_SMD_Audit_Zakazky]    Script Date: 04.07.2025 8:36:18 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

CREATE VIEW [dbo].[hvw_SMD_Audit_Zakazky] AS SELECT CisloZakazky, 
           z.Nazev,
           o.Nazev as Zakaznik,
           CASE z.Stav WHEN 0 THEN 'Aktivní' 
                          WHEN 1 THEN 'Uzavřeno'               
                          WHEN 2 THEN 'Blokováno' END as Stav
 FROM TabZakazka z
 LEFT OUTER JOIN TabCisOrg o ON o.CisloOrg = z.Prijemce
GO

