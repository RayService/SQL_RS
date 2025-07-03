USE [RayService]
GO

/****** Object:  View [dbo].[hvw_APSLogis_IN_SUPPLIERMASTER]    Script Date: 03.07.2025 13:24:30 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

CREATE VIEW [dbo].[hvw_APSLogis_IN_SUPPLIERMASTER] AS SELECT 
  SUPPLIER_ID=CO.CisloOrg, 
  SUPPLIER_NAME =LEFT(CO.Firma,100), 
  SUPPLIER_DESC = ISNULL(CO_E._odpovednaOsobaOdberatel,'') + N' | ' + ISNULL(CO.Misto+', '+CO.UliceSCisly, '') 
FROM TabCisOrg CO 
  LEFT OUTER JOIN TabCisOrg_Ext CO_E ON (CO_E.ID=CO.ID) 
WHERE CO.Stav=0 
GO

